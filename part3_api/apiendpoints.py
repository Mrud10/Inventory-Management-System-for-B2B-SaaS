from flask import Flask, jsonify
from datetime import datetime, timedelta
from sqlalchemy import func

app = Flask(__name__)

@app.route('/api/companies/<int:company_id>/alerts/low-stock', methods=['GET'])
def low_stock(company_id):

    alerts = []
    days = 30  # using last 30 days for now
    recent = datetime.utcnow() - timedelta(days=days)

    # getting all products of this company
    products = db.session.query(Product).filter(Product.company_id == company_id).all()

    for p in products:

        # product type check (just in case its missing)
        if p.product_type is None:
            continue

        threshold = p.product_type.low_stock_threshold

        # total sales in last X days
        total = db.session.query(func.sum(Sale.quantity))\
            .filter(Sale.product_id == p.id, Sale.sold_at >= recent)\
            .scalar()

        if total is None:
            total = 0

        # ignoring products with no sales (as per requirement)
        if total == 0:
            continue

        avg = total / days  # avg daily sales

        # get inventory for each warehouse
        invs = db.session.query(Inventory).join(Warehouse)\
            .filter(Inventory.product_id == p.id,
                    Warehouse.company_id == company_id).all()

        for i in invs:

            stock = i.quantity

            # if stock is fine then skip
            if stock >= threshold:
                continue

            # calculate approx days left
            days_left = None
            if avg != 0:
                days_left = int(stock / avg)

            # supplier info 
            sup = p.supplier
            if sup is None:
                continue

            data = {
                "product_id": p.id,
                "product_name": p.name,
                "sku": p.sku,
                "warehouse_id": i.warehouse.id,
                "warehouse_name": i.warehouse.name,
                "current_stock": stock,
                "threshold": threshold,
                "days_until_stockout": days_left,
                "supplier": {
                    "id": sup.id,
                    "name": sup.name,
                    "contact_email": sup.contact_email
                }
            }

            alerts.append(data)

    return jsonify({
        "alerts": alerts,
        "total_alerts": len(alerts)
    })
    

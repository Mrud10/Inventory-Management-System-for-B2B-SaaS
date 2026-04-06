from flask import Flask, jsonify
from datetime import datetime, timedelta
from sqlalchemy import func

app = Flask(__name__)

@app.route('/api/companies/<int:company_id>/alerts/low-stock', methods=['GET'])
def get_low_stock_alerts(company_id):

    alerts = []
    DAYS_WINDOW = 30
    recent_date = datetime.utcnow() - timedelta(days=DAYS_WINDOW)

    # Step 1: Fetch all products for company
    products = (
        db.session.query(Product)
        .filter(Product.company_id == company_id)
        .all()
    )

    for product in products:

        # --- Get threshold from product type ---
        product_type = product.product_type
        if not product_type:
            continue  # safety check

        threshold = product_type.low_stock_threshold

        # --- Get total sales in last 30 days ---
        total_sold = (
            db.session.query(func.sum(Sale.quantity))
            .filter(
                Sale.product_id == product.id,
                Sale.sold_at >= recent_date
            )
            .scalar()
        ) or 0

        # Skip products with no recent activity
        if total_sold == 0:
            continue

        avg_daily_sales = total_sold / DAYS_WINDOW

        # --- Fetch inventory across warehouses ---
        inventories = (
            db.session.query(Inventory)
            .join(Warehouse)
            .filter(
                Inventory.product_id == product.id,
                Warehouse.company_id == company_id
            )
            .all()
        )

        for inv in inventories:

            current_stock = inv.quantity

            # Skip if stock is healthy
            if current_stock >= threshold:
                continue

            # --- Calculate days until stockout ---
            days_until_stockout = None
            if avg_daily_sales > 0:
                days_until_stockout = int(current_stock / avg_daily_sales)

            supplier = product.supplier
            if not supplier:
                continue  # or set default fallback

            alerts.append({
                "product_id": product.id,
                "product_name": product.name,
                "sku": product.sku,
                "warehouse_id": inv.warehouse.id,
                "warehouse_name": inv.warehouse.name,
                "current_stock": current_stock,
                "threshold": threshold,
                "days_until_stockout": days_until_stockout,
                "supplier": {
                    "id": supplier.id,
                    "name": supplier.name,
                    "contact_email": supplier.contact_email
                }
            })

    return jsonify({
        "alerts": alerts,
        "total_alerts": len(alerts)
    })

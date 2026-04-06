from decimal import Decimal, InvalidOperation
from flask_login import login_required

@app.route('/api/products', methods=['POST'])
@login_required
def create_product():
    data = request.get_json(silent=True)
    if not data:
        return {"error": "Invalid or missing JSON body"}, 400

    # Field validation
    name = data.get('name')
    if not name:
        return {"error": "name is required"}, 400

    sku = data.get('sku')
    if not sku:
        return {"error": "sku is required"}, 400

    warehouse_id = data.get('warehouse_id')
    if not warehouse_id:
        return {"error": "warehouse_id is required"}, 400

    # SKU uniqueness check
    if Product.query.filter_by(sku=sku).first():
        return {"error": "SKU already exists"}, 409

    # Price validation
    price_raw = data.get('price')
    if price_raw is None:
        return {"error": "Price is required"}, 400
    try:
        price = Decimal(str(price_raw))
    except InvalidOperation:
        return {"error": "Invalid price format"}, 400
    if price < 0:
        return {"error": "Price cannot be negative"}, 400

    try:
        # Create new product
        product = Product(
            name=name,
            sku=sku,
            price=price,
            warehouse_id=warehouse_id
        )
        db.session.add(product)

        # Update inventory count
        inventory = Inventory(
            product_id=product.id,
            warehouse_id=warehouse_id,
            quantity=data.get('initial_quantity', 0)
        )
        db.session.add(inventory)

        db.session.commit()  # single commit for both

    except Exception as e:
        db.session.rollback()
        return {"error": str(e)}, 500

    return {"message": "Product created", "product_id": product.id}, 201

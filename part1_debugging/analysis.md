The Given API Endpoint is responsible for creating a new product and adding a new product and also initialising and adding it to the inventory , the endpoint has correct syntax but it has some logical flaws related to data integrity , validation and Business Logic that can cause failures 

ISSUES
1) TWO SEPERATE COMMIT CALLS
   - The endpoint has two different commit calls which would be a bug if the inventory commit fails for some reason there would exist a product without its information being stored in inventory.
   - Inconsistent system
   - FIX - make one system commit for both transactions.
              db.session.add(product)
              db.session.add(inventory)
              db.session.commit() 
  
2) MISSING FIELD VALIDATION
   - direct access to fields without checking if they exist
   - Product = Product(
          name=data['name'],
          sku=data['sku'],
          price=data['price'],
           warehouse_id=data['warehouse_id']
        )
   -Missing fields → KeyError
    Invalid data → inconsistent database records
      name = data.get('name')
if not name:
    return {"error": "name is required"}, 400

3) NO error handling
   - Database errors, constraint violations, or unexpected input will propagate as unhandled 500s with no useful response. Wrap in a try/except block.
   - FIX
   - try:
     except Exception as e:
    db.session.rollback()
    return {"error": str(e)}, 500

4) Any unauthenticated caller can create products. You should verify the user is logged in and has the right permissions before processing the request.
   -Any unauthenticated caller can create products. The request should verify the user is logged in and has the correct permissions before any processing occurs.
   fix-
   @app.route('/api/products', methods=['POST'])
   @login_required
   def create_product():

5) 3. SKU Uniqueness Not Enforced
 - sku=data['sku']
  No check for duplicate SKU thus Duplicate SKUs break product identification and Inventory tracking becomes unreliable.
fix - if Product.query.filter_by(sku=data.get('sku')).first():
    return {"error": "SKU already exists"}, 409

6) . Price Handling
price=data['price']
- No type validation (string, negative values possible) thus Incorrect pricing data can lead to financial inconsistencies so fix it by locking it to
- fix  -
- from decimal import Decimal, InvalidOperation

price_raw = data.get('price')
# Check if price is provided
if price_raw is None:
    return {"error": "Price is required"}, 400
# Validate format
try:
    price = Decimal(str(price_raw))
except InvalidOperation:
    return {"error": "Invalid price format"}, 400
# Validate value
if price < 0:
    return {"error": "Price cannot be negative"}, 400

7)PROPER HTTP RESPONSE 
Returning 200 OK on resource creation is incorrect. The HTTP standard for a successfully created resource is 201 Created. This matters for API clients and automated tooling that inspect status codes.
- return {"message": "Product created", "product_id": product.id}, 201



Approach / Logic

Basic idea was:

Get all products for the company
For each product:
Check recent sales (last 30 days)
If no sales → skip
Calculate average daily sales
For each warehouse inventory of that product:
Compare stock with threshold
If below → create alert
Attach supplier info
Return all alerts with count

Edge Cases Considered

Some things that could go wrong and how I handled them:

No recent sales
If total sales in last 30 days = 0 → skip that product
because requirement says only recent activity products
Null sales aggregation
SQL sum can return None, so handled it manually
Division by zero
If avg sales becomes 0 → avoided division and set days to None
Missing product type
If product_type is not present → skipped (since no threshold)
Missing supplier
If supplier is null → skipped (since response requires supplier info)
Multiple warehouses
Same product can appear multiple times (one per warehouse)
Stock already above threshold
Not included in alerts


Assumptions (base on given problem)

Since full schema was not provided, I assumed the following:

Each product belongs to a company
Each product has a product_type which contains the low stock threshold
Inventory is stored per warehouse (so same product can exist in multiple warehouses)
Sales table stores product_id, quantity and timestamp
Supplier is linked to product (one supplier per product assumed)
“Recent sales” = last 30 days (this is kinda arbitrary but seemed reasonable)


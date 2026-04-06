
Analysis: Inventory System Design
1. Identifying Gaps (Questions for Product Team)

The requirements give a good starting point, but there are quite a few things that aren’t clearly defined. Before building this out properly, I’d want to clarify the following:

Inventory Behavior
Should inventory be tracked only at product level, or do we need batch/lot tracking (for expiry dates etc)?
Do we need serial number tracking for individual items?
Should negative inventory be allowed in some edge cases, or completely restricted?
How exactly should reserved inventory behave (like when does it get released)?
Inventory Changes & Transactions
What events actually change inventory?
Sales orders
Purchase orders
Returns
Damaged goods
Should every inventory log be tied to some entity (order, transfer, etc)?
Do we need to support warehouse to warehouse transfers?
Bundles (Composite Products)
Are bundles stored as actual inventory, or calculated dynamically?
Should bundle availability depend on component stock automatically?
Can bundles contain other bundles (nested case)?
Suppliers
Can one product have multiple suppliers? (seems likely)
Do we need to track price changes over time?
Is there a concept of preferred supplier per product?
Multi-Tenancy (Companies)
Can suppliers work with multiple companies?
Are products completely isolated per company or shared?
Do we need any cross-company reporting?
Warehouses
Do warehouses have capacity limits?
Do we need more detailed structure like zones, racks, bins?
Auditing & Permissions
Do we need to track which user made each change?
Should deletes be soft deletes or hard deletes?
Are there different roles with different permissions?
2. Design Decisions & Justifications
Separation of Current State and Logs

I used two tables:

inventory → stores current stock
inventory_logs → stores all changes (append only)

Why:

Faster reads for APIs and dashboards
Full history is preserved
No need to recompute stock from logs every time
Multi-Tenant Safety (Company Isolation)

Added company_id in inventory related tables and enforced via composite keys.

Why:

Prevents mixing data across companies (this is actually a big issue if missed)
Ensures product, warehouse, etc all belong to same company
Inventory Constraints

Used constraints like:

quantity >= 0
reserved_qty >= 0
reserved_qty <= quantity

Why:

Avoids invalid states like overselling
Pushes validation to DB instead of relying only on app logic
Unique Constraints
(company_id, sku) in products
(product_id, warehouse_id) in inventory
(supplier_id, product_id) in supplier_products

Why:

Prevents duplicate entries
Matches real business rules
Indexing Strategy

Indexes added on:

inventory(product_id, warehouse_id)
inventory_logs(product_id, warehouse_id)
inventory_logs(created_at)
supplier_products(product_id)

Why:

These are common query paths
Helps avoid slow queries when data grows
Bundle Design

Used a self-referencing table bundle_items.

Why:

Flexible structure
Supports nested bundles
Keeps schema simple instead of hardcoding bundle logic
Supplier Relationship

Used a many-to-many table supplier_products.

Why:

Products can have multiple suppliers
Suppliers can supply multiple products
Allows storing price and lead time
Audit Trail

inventory_logs stores:

change_type
quantity_change
quantity_after
reference fields

Why:

Helps trace what happend and why
Useful for debugging and analytics
Can link to orders or purchases later
Soft Deletes

Used deleted_at instead of deleting rows.

Why:

Keeps history intact
Safer in case of mistakes
Useful for auditing

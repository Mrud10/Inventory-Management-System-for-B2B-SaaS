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

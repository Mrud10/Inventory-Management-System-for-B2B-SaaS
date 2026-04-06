# Inventory-Management-System-for-B2B-SaaS
This repository contains my solution to the StockFlow Inventory Management System case study, which simulates a real-world B2B SaaS backend system for managing products, warehouses, and suppliers.

TECH STACK -
Language: Python
Framework: Flask
Database: SQLite 
ORM: SQLAlchemy

stockflow-backend-case-study/
│ ├── part1_debugging/ # Code review, issues, and fixes
  ├── part2_database/ # Schema design and explanations
  ├── part3_api/ # Low-stock alerts API implementation
  ├── diagrams/ # ER diagrams
  ├── requirements.txt 
  └── README.md


Part 1: Code Review & Debugging
Identified critical issues in the provided API.
Analyzed both technical and business logic flaws.
Refactored the implementation with:
  Proper validation
  Transaction handling
  Error management


Part 2: Database Design
Designed a scalable schema supporting:
   Multi-warehouse inventory
  Supplier relationships
  Inventory tracking (audit logs)
  Product bundles

Part 3:Low-Stock Alerts API

Implemented:
GET /api/companies/{company_id}/alerts/low-stock
Features:
Handles multiple warehouses
Filters products with recent sales activity
Includes supplier details for restocking
Estimates stock-out timeline


How to Run
1. Clone the repository
git clone <your-repo-link>
cd stockflow-backend-case-study
2. Install dependencies
pip install -r requirements.txt
3. Run the application
python part3_api/app.py


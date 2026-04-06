-- =========================
-- COMPANIES
-- =========================
CREATE TABLE companies (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP
);

-- =========================
-- WAREHOUSES
-- =========================
CREATE TABLE warehouses (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL REFERENCES companies(id),
  name VARCHAR(255) NOT NULL,
  address_line VARCHAR(255),
  city VARCHAR(100),
  country VARCHAR(100),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP,
  UNIQUE (company_id, name)
);

-- =========================
-- PRODUCTS
-- =========================
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL REFERENCES companies(id),
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) NOT NULL,
  description TEXT,
  unit_of_measure VARCHAR(50) NOT NULL DEFAULT 'unit',
  price DECIMAL(12,2),
  is_bundle BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP,
  UNIQUE (company_id, sku)
);

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL REFERENCES companies(id),
  email VARCHAR(255) NOT NULL UNIQUE,
  role VARCHAR(50) NOT NULL CHECK (role IN ('admin','manager','staff')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP
);

-- =========================
-- INVENTORY
-- =========================
CREATE TABLE inventory (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  product_id INT NOT NULL,
  warehouse_id INT NOT NULL,
  quantity DECIMAL(12,3) NOT NULL DEFAULT 0,
  reserved_qty DECIMAL(12,3) NOT NULL DEFAULT 0,
  reorder_point DECIMAL(12,3),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

  FOREIGN KEY (company_id, product_id)
    REFERENCES products(company_id, id),

  FOREIGN KEY (company_id, warehouse_id)
    REFERENCES warehouses(company_id, id),

  FOREIGN KEY (company_id)
    REFERENCES companies(id),

  UNIQUE (product_id, warehouse_id),

  CHECK (quantity >= 0),
  CHECK (reserved_qty >= 0),
  CHECK (reserved_qty <= quantity)
);

-- =========================
-- INVENTORY LOGS
-- =========================
CREATE TABLE inventory_logs (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  product_id INT NOT NULL,
  warehouse_id INT NOT NULL,
  changed_by INT REFERENCES users(id),

  change_type VARCHAR(20) NOT NULL
    CHECK (change_type IN ('IN','OUT','ADJUSTMENT','RESERVED','RELEASED')),

  quantity_change DECIMAL(12,3) NOT NULL,
  quantity_after DECIMAL(12,3) NOT NULL,
  reference_type VARCHAR(50),
  reference_id INT,
  notes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  FOREIGN KEY (company_id, product_id)
    REFERENCES products(company_id, id),

  FOREIGN KEY (company_id, warehouse_id)
    REFERENCES warehouses(company_id, id),

  FOREIGN KEY (company_id)
    REFERENCES companies(id)
);

-- =========================
-- SUPPLIERS
-- =========================
CREATE TABLE suppliers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP
);

CREATE TABLE supplier_contacts (
  id SERIAL PRIMARY KEY,
  supplier_id INT NOT NULL REFERENCES suppliers(id),
  name VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(50),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE supplier_products (
  id SERIAL PRIMARY KEY,
  supplier_id INT NOT NULL REFERENCES suppliers(id),
  product_id INT NOT NULL REFERENCES products(id),
  unit_price DECIMAL(12,2) NOT NULL,
  currency CHAR(3) NOT NULL,
  lead_time_days INT,
  is_preferred BOOLEAN NOT NULL DEFAULT FALSE,

  UNIQUE (supplier_id, product_id)
);

-- =========================
-- BUNDLES
-- =========================
CREATE TABLE bundle_items (
  id SERIAL PRIMARY KEY,
  bundle_product_id INT NOT NULL REFERENCES products(id),
  component_product_id INT NOT NULL REFERENCES products(id),
  quantity DECIMAL(12,3) NOT NULL CHECK (quantity > 0),

  UNIQUE (bundle_product_id, component_product_id),
  CHECK (bundle_product_id <> component_product_id)
);

-- =========================
-- INDEXES
-- =========================
CREATE INDEX idx_inventory_product 
  ON inventory(product_id);

CREATE INDEX idx_inventory_warehouse 
  ON inventory(warehouse_id);

CREATE INDEX idx_logs_product_wh 
  ON inventory_logs(product_id, warehouse_id);

CREATE INDEX idx_logs_created_at 
  ON inventory_logs(created_at);

CREATE INDEX idx_supplier_products_product 
  ON supplier_products(product_id);
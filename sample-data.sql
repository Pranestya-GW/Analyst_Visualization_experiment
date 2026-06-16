-- ============================================================================
-- Sample analytics data — loaded into the shared PostgreSQL on first boot.
-- Uses the same schema as the pg-mcp project (customers, orders, products)
-- so you can practice cross-tool queries and dashboarding.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    registration_date DATE,
    status VARCHAR(20)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    order_date DATE,
    amount DECIMAL(10,2),
    product_category VARCHAR(50),
    status VARCHAR(20)
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    supplier_id INTEGER,
    in_stock BOOLEAN
);

-- 100K customers
INSERT INTO customers (name, email, city, country, registration_date, status)
SELECT
    'Customer ' || generate_series,
    'customer' || generate_series || '@email.com',
    CASE (generate_series % 10)
        WHEN 0 THEN 'New York'   WHEN 1 THEN 'Los Angeles'
        WHEN 2 THEN 'Chicago'    WHEN 3 THEN 'Houston'
        WHEN 4 THEN 'Phoenix'    WHEN 5 THEN 'Philadelphia'
        WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego'
        WHEN 8 THEN 'Dallas'     ELSE 'Austin'
    END,
    CASE (generate_series % 5)
        WHEN 0 THEN 'USA'     WHEN 1 THEN 'Canada'
        WHEN 2 THEN 'UK'      WHEN 3 THEN 'Germany'
        ELSE 'France'
    END,
    CURRENT_DATE - (generate_series % 1000),
    CASE (generate_series % 3)
        WHEN 0 THEN 'active'   WHEN 1 THEN 'inactive'
        ELSE 'pending'
    END
FROM generate_series(1, 100000);

-- 100K orders
INSERT INTO orders (customer_id, order_date, amount, product_category, status)
SELECT
    (generate_series % 100000) + 1,
    CURRENT_DATE - (generate_series % 365),
    (random() * 1000)::DECIMAL(10,2),
    CASE (generate_series % 5)
        WHEN 0 THEN 'Electronics' WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Books'       WHEN 3 THEN 'Home'
        ELSE 'Sports'
    END,
    CASE (generate_series % 4)
        WHEN 0 THEN 'completed' WHEN 1 THEN 'pending'
        WHEN 2 THEN 'shipped'   ELSE 'cancelled'
    END
FROM generate_series(1, 100000);

-- 50K products
INSERT INTO products (name, category, price, supplier_id, in_stock)
SELECT
    'Product ' || generate_series,
    CASE (generate_series % 8)
        WHEN 0 THEN 'Electronics' WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Books'       WHEN 3 THEN 'Home'
        WHEN 4 THEN 'Sports'      WHEN 5 THEN 'Toys'
        WHEN 6 THEN 'Garden'      ELSE 'Tools'
    END,
    (random() * 500)::DECIMAL(10,2),
    (generate_series % 1000) + 1,
    random() > 0.2
FROM generate_series(1, 50000);

-- Indexes
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_customers_country ON customers(country);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_product_category ON orders(product_category);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_products_category ON products(category);

ANALYZE customers;
ANALYZE orders;
ANALYZE products;

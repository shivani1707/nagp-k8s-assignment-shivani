-- This file is executed by Spring Boot on startup (data.sql)
-- It inserts sample product records if the table is empty

INSERT INTO products (name, category, price, stock, description)
SELECT 'Laptop Pro 15', 'Electronics', 1299.99, 50, 'High-performance laptop with 16GB RAM'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Laptop Pro 15');

INSERT INTO products (name, category, price, stock, description)
SELECT 'Wireless Mouse', 'Electronics', 29.99, 200, 'Ergonomic wireless mouse with USB receiver'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Wireless Mouse');

INSERT INTO products (name, category, price, stock, description)
SELECT 'Standing Desk', 'Furniture', 499.00, 30, 'Adjustable height standing desk'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Standing Desk');

INSERT INTO products (name, category, price, stock, description)
SELECT 'Noise Cancelling Headphones', 'Electronics', 249.99, 75, 'Over-ear headphones with ANC'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Noise Cancelling Headphones');

INSERT INTO products (name, category, price, stock, description)
SELECT 'Office Chair', 'Furniture', 350.00, 20, 'Ergonomic mesh office chair'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Office Chair');

INSERT INTO products (name, category, price, stock, description)
SELECT 'USB-C Hub', 'Electronics', 49.99, 150, '7-in-1 USB-C hub with HDMI and SD card'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'USB-C Hub');

INSERT INTO products (name, category, price, stock, description)
SELECT 'Mechanical Keyboard', 'Electronics', 129.99, 90, 'TKL mechanical keyboard with blue switches'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Mechanical Keyboard');

INSERT INTO products (name, category, price, stock, description)
SELECT 'Monitor 27 inch', 'Electronics', 399.99, 40, '4K IPS monitor with USB-C power delivery'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Monitor 27 inch');

INSERT INTO products (name, category, price, stock, description)
SELECT 'Desk Lamp', 'Furniture', 39.99, 100, 'LED desk lamp with adjustable brightness'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Desk Lamp');

INSERT INTO products (name, category, price, stock, description)
SELECT 'Webcam HD', 'Electronics', 79.99, 60, '1080p webcam with built-in microphone'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Webcam HD');

---------
--PART A: DATABASE INITIALIZATION
--Objective: Create the schema with appropriate data types and constraints.
--------------------------------
-- 1. After creating the Instacart Database

-- 2. Create 'departments' table (Parent Table)
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

-- 3. Create 'aisles' table (Parent Table)
CREATE TABLE aisles (
    aisle_id INT PRIMARY KEY,
    aisle VARCHAR(100)
);

-- 4. Create 'products' table (Child of departments & aisles)
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    unit_cost NUMERIC(10, 2), -- Using NUMERIC for financial precision
    unit_price NUMERIC(10, 2),
    aisle_id INT,
    department_id INT,
    CONSTRAINT fk_aisle FOREIGN KEY (aisle_id) REFERENCES aisles(aisle_id),
    CONSTRAINT fk_dept FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 5. Create 'orders' table (Transactional Table)
CREATE TABLE orders (
    order_id INT,
    user_id INT,
    quantity INT,
    order_date DATE,
    order_dow INT CHECK (order_dow BETWEEN 0 AND 6), -- Constraint to ensure valid days
    order_hour_of_day INT CHECK (order_hour_of_day BETWEEN 0 AND 23),
    days_since_prior_order INT,
    order_status VARCHAR(50),
    product_id INT,
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

--Import Aisles from CSV
COPY public.aisles
FROM 'C:/Users/USER/Documents/github_repo/instacart-analysis/aisle.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Import Departments
COPY public.departments
FROM 'C:/Users/USER/Documents/github_repo/instacart-analysis/departments.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Import Products
COPY public.products
FROM 'C:/Users/USER/Documents/github_repo/instacart-analysis/products.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Import Orders
COPY public.orders
FROM 'C:/Users/USER/Documents/github_repo/instacart-analysis/orders.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

--Preview
select * from aisles;
select * from departments;
select * from orders;
select * from products;
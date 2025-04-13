CREATE DATABASE IF NOT EXISTS bookstore;
USE bookstore;
--table country
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
--table address
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);
--table address status
CREATE TABLE address_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL
);
--table customer
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20)
);
--table customer_address
CREATE TABLE customer_address (
    customer_id INT,
    address_id INT,
    status_id INT,
    PRIMARY KEY (customer_id, address_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (status_id) REFERENCES address_status(status_id)
);
--table book_language
CREATE TABLE book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(50) NOT NULL
);
--table publisher
CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);
--table author
CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100)
);
--table book
CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    publisher_id INT,
    language_id INT,
    publication_date DATE,
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id),
    FOREIGN KEY (language_id) REFERENCES book_language(language_id)
);
--table book_author
CREATE TABLE book_author (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (author_id) REFERENCES author(author_id)
);
--table shipping_method
CREATE TABLE shipping_method (
    shipping_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL,
    cost DECIMAL(10,2) NOT NULL
);
--table order_status
CREATE TABLE order_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL
);
---table cust_order
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME NOT NULL,
    shipping_id INT,
    status_id INT,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (shipping_id) REFERENCES shipping_method(shipping_id),
    FOREIGN KEY (status_id) REFERENCES order_status(status_id)
);
--table order_line
CREATE TABLE order_line (
    order_id INT,
    book_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, book_id),
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id)
);
--table order_history
CREATE TABLE order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    status_id INT,
    status_date DATETIME NOT NULL,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (status_id) REFERENCES order_status(status_id)
);

--various roles
CREATE ROLE db_admin;
CREATE ROLE inventory_manager;
CREATE ROLE sales_staff;
CREATE ROLE customer_support;
CREATE ROLE data_analyst;

--grant privileges to roles
  --admin privileges
GRANT ALL PRIVILEGES ON bookstore.* TO db_admin;

  --inventory_manager privileges(manage books)
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.book TO inventory_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.book_author TO inventory_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.author TO inventory_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.publisher TO inventory_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.book_language TO inventory_manager;

  --sales-staff privileges(handle orders and customers)
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.customer TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.customer_address TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.address TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.address_status TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.country TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.cust_order TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.order_line TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.shipping_method TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.order_status TO sales_staff;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.order_history TO sales_staff;

  --customer_support privileges(handle customers(read-only))
GRANT SELECT ON bookstore.customer TO customer_support;
GRANT SELECT ON bookstore.customer_address TO customer_support;
GRANT SELECT ON bookstore.address TO customer_support;
GRANT SELECT ON bookstore.address_status TO customer_support;
GRANT SELECT ON bookstore.country TO customer_support;
GRANT SELECT ON bookstore.cust_order TO customer_support;
GRANT SELECT ON bookstore.order_line TO customer_support;
GRANT SELECT ON bookstore.shipping_method TO customer_support;
GRANT SELECT ON bookstore.order_status TO customer_support;
GRANT SELECT ON bookstore.order_history TO customer_support;

  --data_analyst privileges(read-only on all tables)
GRANT SELECT ON bookstore.* TO data_analyst;

--create users based on roles
-- Admin
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@123';
GRANT db_admin TO 'admin_user'@'localhost';

-- Inventory manager
CREATE USER 'inv_user'@'localhost' IDENTIFIED BY 'Inv@123';
GRANT inventory_manager TO 'inv_user'@'localhost';

-- Sales staff
CREATE USER 'sales_user'@'localhost' IDENTIFIED BY 'Sales@123';
GRANT sales_staff TO 'sales_user'@'localhost';

-- Support
CREATE USER 'support_user'@'localhost' IDENTIFIED BY 'Support@123';
GRANT customer_support TO 'support_user'@'localhost';

-- Analyst
CREATE USER 'analyst_user'@'localhost' IDENTIFIED BY 'Analyst@123';
GRANT data_analyst TO 'analyst_user'@'localhost';

--make roles default at login
-- analyst role
SET DEFAULT ROLE data_analyst TO 'analyst_user'@'localhost';
--admin role
SET DEFAULT ROLE db_admin TO 'admin_user'@'localhost';
--customer_support role
SET DEFAULT ROLE customer-support TO 'support_user'@'localhost';
--inventory_manager role
SET DEFAULT ROLE inventory_manager TO 'inv_user'@'localhost';
--sales_staff role
SET DEFAULT ROLE sales_staff TO 'sales_user'@'localhost';

--Insert values to the tables
--publisher table
INSERT INTO publisher (publisher_id, name, address_id) VALUES
(1, 'Penguin Books', 1),
(2, 'Oxford Press', 2),
(3, 'Heinemann', 3);

--customer_address
INSERT INTO order_history (history_id, order_id, status_id, update_time) VALUES
(1, 1, 1, '2025-04-10 10:00:00'),
(2, 1, 2, '2025-04-10 15:00:00'),
(3, 2, 1, '2025-04-11 09:30:00');

--customer table
INSERT INTO customer (customer_id, first_name, last_name, email, phone) VALUES
(1, 'Alice', 'Wanjiru', 'alice@example.com', '0712345678'),
(2, 'Bob', 'Smith', 'bob@example.com', '0712345679');

--address_status
INSERT INTO address_status (status_id, status_name) VALUES
(1, 'current'),
(2, 'old');

--country table
INSERT INTO country (country_id, name) VALUES
(1, 'Kenya'),
(2, 'United Kingdom'),
(3, 'United States');


--address table
INSERT INTO address (address_id, street, city, postal_code, country_id) VALUES
(1, '123 Main St', 'Nairobi', '00100', 1),
(2, '10 Downing St', 'London', 'SW1A 2AA', 2),
(3, '742 Evergreen Terrace', 'Springfield', '62704', 3);

--shipping_method table
INSERT INTO shipping_method (shipping_id, method_name, cost) VALUES
(1, 'Standard Shipping', 500.00),
(2, 'Express Shipping', 1000.00),
(3, 'Overnight Shipping', 1500.00);

--order_line table
INSERT INTO order_line (order_id, book_id, quantity, unit_price) VALUES
(1, 1, 1, 1200.00),
(2, 1, 2, 1200.00),
(3, 2, 3, 950.00);

--order_status table
INSERT INTO order_status (status_id, status_name) VALUES
(1, 'Pending'),
(2, 'Shipped'),
(3, 'Delivered'),
(4, 'Cancelled');

--cust_order table
INSERT INTO cust_order (order_id, customer_id, order_date, status_id, shipping_id, total_amount) VALUES
(1, 1, '2025-04-10', 1, 1, 2500),
(2, 2, '2025-04-11', 1, 2, 3200),
(3, 1, '2025-04-12', 1, 1, 2800);

--book table
INSERT INTO book (book_id, title, language_id, publisher_id, price, isbn, publication_date) VALUES
(1, '1984', 1, 1, 1200, '978-0451524935', '1949-06-08'),
(2, 'Pride and Prejudice', 1, 2, 950, '978-1503290563', '1813-01-28'),
(3, 'Things Fall Apart', 1, 3, 1100, '978-0435902687', '1958-06-17');

--order_history
INSERT INTO order_history (history_id, order_id, status_id, update_time) VALUES
(1, 1, 1, '2025-04-10 10:00:00'),
(2, 1, 2, '2025-04-10 15:00:00'),
(3, 2, 1, '2025-04-11 09:30:00');

--book_author table
INSERT INTO book_author (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3);

--author table
INSERT INTO author (author_id, first_name, last_name) VALUES
(1, 'George', 'Orwell'),
(2, 'Jane', 'Austen'),
(3, 'Chinua', 'Achebe');

--book_language table
INSERT INTO book_language (language_id, name) VALUES
(1, 'English'),
(2, 'French'),
(3, 'Spanish');


--login as different users(roles) in your command prompt and try to retrieve data
--for example inv_user who is an inventory manager
mysql -u inv_user -p 
  --input password(Inv@123 or the set password) and key in your queries

-- Get a list of books with their authors, language, and publisher
SELECT 
    b.title,
    b.isbn,
    b.price,
    l.language_name,
    p.publisher_name,
    GROUP_CONCAT(a.author_name) AS authors
FROM 
    book b
JOIN 
    book_author ba ON b.book_id = ba.book_id
JOIN 
    author a ON ba.author_id = a.author_id
JOIN 
    book_language l ON b.language_id = l.language_id
JOIN 
    publisher p ON b.publisher_id = p.publisher_id
GROUP BY 
    b.book_id;
ALTER TABLE book
ADD COLUMN book_category VARCHAR AFTER  language_id;




-- ================================================================
-- ======================= Create Database ========================
-- ================================================================

DROP database IF EXISTS MyBookstore;
CREATE DATABASE MyBookstore;
USE MyBookstore;

-- ================================================================
-- ==================== Create Database User ======================
-- ================================================================

-- Creating a new user 'db_owner' with password
CREATE USER 'db_owner'@'localhost' IDENTIFIED BY 'my_Passw0rd';

-- Granting all privileges on MyBookstore to 'db_owner'
GRANT ALL PRIVILEGES ON MyBookstore.* TO 'db_owner'@'localhost';

-- Applying the changes
FLUSH PRIVILEGES;

-- create a staff user
CREATE USER 'staff'@'localhost' IDENTIFIED BY 'my_Passw0rd';
-- Grant SELECT and UPDATE privileges on all tables in MyBookstore to 'staff'
GRANT SELECT, UPDATE ON MyBookstore.* TO 'staff'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;


-- ================================================================
-- ======================= Create Tables ==========================
-- ================================================================

-- Table: Genre
CREATE TABLE Genre (
    id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL
);

-- Table: Offer
CREATE TABLE Offer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    offer_name VARCHAR(100) NOT NULL,
    discount DECIMAL(3, 2) NOT NULL
);

-- Table: Format
CREATE TABLE Format (
    id INT AUTO_INCREMENT PRIMARY KEY,
    format_name VARCHAR(100) NOT NULL
);

-- Table: Language
CREATE TABLE Language (
    id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(100) NOT NULL
);

-- Table: StockStatus
CREATE TABLE StockStatus (
    id INT AUTO_INCREMENT PRIMARY KEY,
    stock_status_name VARCHAR(100) NOT NULL
);

-- Table: Author
CREATE TABLE Author (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL
);

-- Table: CustomerName
CREATE TABLE CustomerName (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL
);

-- Table: OrderStatus
CREATE TABLE OrderStatus (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_status_name VARCHAR(100) NOT NULL
);

-- Table: Postcode
CREATE TABLE Postcode (
    post_nr VARCHAR(10) PRIMARY KEY,
    city VARCHAR(20) NOT NULL
);

-- Table: Role
CREATE TABLE Role (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL
);

-- Creating table for storing users with foreign keys to CustomerName and Postcode
CREATE TABLE User (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(150) NOT NULL,
    salt VARCHAR(100) NOT NULL,
    username VARCHAR(100) NOT NULL,
    tlf VARCHAR(20),
    address VARCHAR(255),
    register_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_time DATETIME DEFAULT NULL,
    fk_customer_name_id INT,
    fk_post_nr VARCHAR(10),
    fk_role_id INT NOT NULL,
    FOREIGN KEY (fk_customer_name_id) REFERENCES CustomerName(id),
    FOREIGN KEY (fk_post_nr) REFERENCES Postcode(post_nr),
    FOREIGN KEY (fk_role_id) REFERENCES Role(id)
);

-- Creating table for storing books with multiple foreign keys to other attribute tables
CREATE TABLE Book (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(13) NOT NULL,
    description TEXT,
    edition INT,
    release_date DATE,
    total_pages INT,
    rating DECIMAL(3, 2),
    photo TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT,
    fk_genre_id INT,
    fk_offer_id INT,
    fk_language_id INT,
    fk_format_id INT,
    fk_stock_status_id INT,
    FOREIGN KEY (fk_genre_id) REFERENCES Genre(id),
    FOREIGN KEY (fk_offer_id) REFERENCES Offer(id),
    FOREIGN KEY (fk_language_id) REFERENCES Language(id),
    FOREIGN KEY (fk_format_id) REFERENCES Format(id),
    FOREIGN KEY (fk_stock_status_id) REFERENCES StockStatus(id)
);

-- Reviews of books by customers, linked to specific books and customers
CREATE TABLE Review (
    id INT AUTO_INCREMENT PRIMARY KEY,
    review_date DATE NOT NULL,
    grade INT,
    content TEXT,
    fk_book_id INT,
    fk_user_id INT,
    FOREIGN KEY (fk_book_id) REFERENCES Book(id),
    FOREIGN KEY (fk_user_id ) REFERENCES User(id)
);


-- each shoping cart after confirm will generate one invoice
CREATE TABLE Invoice (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fk_user_id INT,
    DOP DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_book_price DECIMAL(10, 2),
    total_tax DECIMAL(10, 2),
    delivery_price DECIMAL(10, 2),
    total_items_amount INT,
    FOREIGN KEY (fk_user_id) REFERENCES User(id)
);


-- ShoppingCart table, tracks books in the shopping cart
-- when a cart is confirmed, insert a new invoice into the Invoice table 
CREATE TABLE Cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fk_user_id INT,
    DOP DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_book_price DECIMAL(10, 2),
    total_tax DECIMAL(10, 2),
    delivery_price DECIMAL(10, 2),
    total_items_amount INT,
    confirmed BOOLEAN DEFAULT FALSE,
    fk_invoice_id INT,
    FOREIGN KEY (fk_user_id) REFERENCES User(id),
    FOREIGN KEY (fk_invoice_id) REFERENCES Invoice(id)
);

-- Cart items, linking books to shopping carts with quantity and offer
CREATE TABLE CartItem (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fk_cart_id INT,
    fk_book_id INT,
    quantity INT NOT NULL,
    fk_offer_id INT,
    total_book_price DECIMAL(10, 2),
    total_tax DECIMAL(10, 2),
    FOREIGN KEY (fk_cart_id) REFERENCES Cart(id),
    FOREIGN KEY (fk_book_id) REFERENCES Book(id),
    FOREIGN KEY (fk_offer_id) REFERENCES Offer(id)
);


--  each invoice will have multiple items
CREATE TABLE InvoiceItem (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fk_invoice_id INT,
    fk_book_id INT,
    quantity INT NOT NULL,
    fk_offer_id INT,
    total_book_price DECIMAL(10, 2),
    total_tax DECIMAL(10, 2),
    FOREIGN KEY (fk_invoice_id) REFERENCES Invoice(id),
    FOREIGN KEY (fk_book_id) REFERENCES Book(id),
    FOREIGN KEY (fk_offer_id) REFERENCES Offer(id)
);

-- QuantityChange table
CREATE TABLE QuantityChange (
    id INT AUTO_INCREMENT PRIMARY KEY,
    change_date DATETIME NOT NULL,
    quantity_change INT NOT NULL,
    fk_book_id INT,
    fk_cart_item_id INT,
    note TEXT,
    FOREIGN KEY (fk_book_id) REFERENCES Book(id),
    FOREIGN KEY (fk_cart_item_id) REFERENCES CartItem(id)
);


-- Juction tables for many-to-many relationships between books and authors
CREATE TABLE AuthorBook (
    author_book_id INT AUTO_INCREMENT PRIMARY KEY,
    fk_author_id INT,
    fk_book_id INT,
    FOREIGN KEY (fk_author_id) REFERENCES Author(id),
    FOREIGN KEY (fk_book_id) REFERENCES Book(id)
);


-- ================================================================
-- ==========================Add index ============================
-- ================================================================
CREATE INDEX idx_genre_name ON Genre (genre_name);

CREATE INDEX idx_offer_name ON Offer (offer_name);

CREATE INDEX idx_format_name ON Format (format_name);

CREATE INDEX idx_language_name ON Language (language_name);

CREATE INDEX idx_author_name ON Author (last_name, first_name);

CREATE INDEX idx_customer_name ON CustomerName (last_name, first_name);

CREATE INDEX idx_order_status_name ON OrderStatus (order_status_name);

CREATE INDEX idx_role_name ON Role (role_name);

CREATE INDEX idx_user_email ON User (email);
CREATE INDEX idx_user_username ON User (username);
CREATE INDEX idx_user_fk_customer_name_id ON User (fk_customer_name_id);
CREATE INDEX idx_user_fk_post_nr ON User (fk_post_nr);
CREATE INDEX idx_user_fk_role_id ON User (fk_role_id);

CREATE INDEX idx_book_isbn ON Book (isbn);
CREATE INDEX idx_book_fk_genre_id ON Book (fk_genre_id);
CREATE INDEX idx_book_fk_offer_id ON Book (fk_offer_id);
CREATE INDEX idx_book_fk_language_id ON Book (fk_language_id);
CREATE INDEX idx_book_fk_format_id ON Book (fk_format_id);
CREATE INDEX idx_book_fk_stock_status_id ON Book (fk_stock_status_id);

CREATE INDEX idx_review_fk_book_id ON Review (fk_book_id);
CREATE INDEX idx_review_fk_user_id ON Review (fk_user_id);
CREATE FULLTEXT INDEX idx_review_content ON Review (content);


CREATE INDEX idx_invoice_fk_user_id ON Invoice (fk_user_id);

CREATE INDEX idx_cart_fk_user_id ON Cart (fk_user_id);
CREATE INDEX idx_cart_confirmed ON Cart (confirmed);

CREATE INDEX idx_cartitem_fk_cart_id ON CartItem (fk_cart_id);
CREATE INDEX idx_cartitem_fk_book_id ON CartItem (fk_book_id);

CREATE INDEX idx_invoiceitem_fk_invoice_id ON InvoiceItem (fk_invoice_id);
CREATE INDEX idx_invoiceitem_fk_book_id ON InvoiceItem (fk_book_id);

CREATE INDEX idx_quantitychange_fk_book_id ON QuantityChange (fk_book_id);
CREATE INDEX idx_quantitychange_fk_cart_item_id ON QuantityChange (fk_cart_item_id);
CREATE INDEX idx_quantitychange_book_quantity_change ON QuantityChange (fk_book_id, quantity_change);


CREATE INDEX idx_authorbook_fk_author_id ON AuthorBook (fk_author_id);
CREATE INDEX idx_authorbook_fk_book_id ON AuthorBook (fk_book_id);

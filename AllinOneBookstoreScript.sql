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





-- ==============================================================
-- ================= Triggers for checking Stock ================
-- ==============================================================
-- The following triggers are used to check the stock level before inserting or updating the PurchaseBook table.
DELIMITER $$
CREATE TRIGGER check_stock_before_cart_item_insert
BEFORE INSERT ON CartItem
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    SELECT stock INTO available_stock FROM Book WHERE id = NEW.fk_book_id;
    IF NEW.quantity > available_stock THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for the book.';
    END IF;
END$$

CREATE TRIGGER check_stock_before_cart_item_update
BEFORE UPDATE ON CartItem
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    SELECT stock INTO available_stock FROM Book WHERE id = NEW.fk_book_id;
    IF NEW.quantity > available_stock THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for the book.';
    END IF;
END$$
DELIMITER ;


-- ================================================================================
-- ============== Trigger for updating stock when adding items to cart=============
-- ================================================================================
-- create a trigger to automatically update the stock in the Book table.
DELIMITER $$
CREATE TRIGGER update_stock_after_cart_item_insert
AFTER INSERT ON CartItem
FOR EACH ROW
BEGIN
    -- Insert into QuantityChange to track the quantity change
    INSERT INTO QuantityChange (change_date, quantity_change, fk_book_id, fk_cart_item_id, note)
    VALUES (NOW(), -NEW.quantity, NEW.fk_book_id, NEW.id, 'Add to cart');

    -- Update the stock in the Book table
    UPDATE Book
    SET stock = stock - NEW.quantity
    WHERE id = NEW.fk_book_id;
END$$
DELIMITER ;


-- ================================================================================
-- =========== Trigger for updating QuantityChange note after confirmed ===========
-- ================================================================================
-- automatically update the note in the QuantityChange table to "Purchased" after an order is confirmed and a new invoice is generated, looking at invoiceitems
DELIMITER $$
CREATE TRIGGER update_quantity_change_note_after_confirm
AFTER INSERT ON InvoiceItem
FOR EACH ROW
BEGIN
    -- Update the note in QuantityChange for the item in the confirmed cart
    UPDATE QuantityChange qc
    JOIN CartItem ci ON qc.fk_cart_item_id = ci.id
    JOIN Cart c ON ci.fk_cart_id = c.id
    JOIN Invoice i ON c.fk_invoice_id = i.id
    SET qc.note = 'Purchased'
    WHERE i.id = NEW.fk_invoice_id AND ci.fk_book_id = NEW.fk_book_id;
END$$
DELIMITER ;


-- ================================================================================
-- ============ Trigger for updating stock after deleting a cart item =============
-- ================================================================================
-- create a trigger to automatically update the stock in the Book table when a cart item is deleted
-- and update a row in QuantityChange table
DELIMITER $$
CREATE TRIGGER update_stock_after_cart_item_delete
AFTER DELETE ON CartItem
FOR EACH ROW
BEGIN
    -- Update the stock in the Book table
    UPDATE Book SET stock = stock + OLD.quantity WHERE id = OLD.fk_book_id;

    -- Insert a row into the QuantityChange table
    INSERT INTO QuantityChange (change_date, quantity_change, fk_book_id, fk_cart_item_id, note)
    VALUES (NOW(), OLD.quantity, OLD.fk_book_id, OLD.id, 'Deleted cart item release');
END$$
DELIMITER ;


-- ================================================================================
-- =============== Trigger for updating stock after deleting a cart ===============
-- ================================================================================
-- create a trigger to automatically update the stock in the Book table when a cart is deleted
-- and update a row in QuantityChange table
DELIMITER $$
CREATE TRIGGER update_stock_after_cart_delete
AFTER DELETE ON Cart
FOR EACH ROW
BEGIN
    -- Declare a variable to hold the book ID
    DECLARE book_id INT;
    -- Declare a variable to hold the quantity of the book in the cart
    DECLARE cart_item_quantity INT;
    -- Declare a variable to hold the cart item ID
    DECLARE cart_item_id INT;
     -- Declare a variable to indicate when the cursor has finished
    DECLARE done INT DEFAULT 0;

    -- Declare a cursor to select all cart items associated with the deleted cart
    -- after declare variables
    DECLARE cur CURSOR FOR SELECT fk_book_id, quantity, id FROM CartItem WHERE fk_cart_id = OLD.id;
    -- Declare a handler to handle the end of the cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open the cursor
    OPEN cur;

    -- Start a loop to process each cart item
    read_loop: LOOP
        -- Fetch the next cart item
        FETCH cur INTO book_id, cart_item_quantity, cart_item_id;
        -- If the cursor has finished, exit the loop
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Update the stock of the book in the Book table
        UPDATE Book SET stock = stock + cart_item_quantity WHERE id = book_id;

        -- Insert a row into the QuantityChange table
        INSERT INTO QuantityChange (change_date, quantity_change, fk_book_id, fk_cart_item_id, note)
        VALUES (NOW(), cart_item_quantity, book_id, cart_item_id, 'Deleted cart release');
    END LOOP;

    -- Close the cursor
    CLOSE cur;
END$$
DELIMITER ;



-- ================================================================
-- =================== Create Table for logs ======================
-- ================================================================

-- Define a log table that will store changes made to other tables
CREATE TABLE BogredenLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255),
    table_name VARCHAR(255),
    operation_type VARCHAR(50),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);


-- ================================================================
-- ====================== Create Triggers =========================
-- ================================================================

-- Implementing triggers selectively based on table importance and relevance
-- I am runing out of time, so I will implement them primarily on tables where they serve critical functions.
-- Such as the 'User', 'Cart' , 'Cartitem', 'Invoice', 'InvoiceItem' and 'Book' table, triggers will be used to log changes for auditing purposes, ensuring that any modifications to the data are tracked. 
-- This is crucial for maintaining historical data integrity and supporting compliance with data governance policies.
-- Triggers on other tables, such as 'AuthorBook', should be evaluated based on their impact on system performance and the specific requirements for data tracking and integrity.

-- ================== Create Triggers for the User table ==================
-- Trigger for INSERT Operation
DELIMITER $$
CREATE TRIGGER trg_user_insert AFTER INSERT ON User
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'User', 'INSERT', CONCAT('Inserted User with Email: ', NEW.Email, '; Username: ', NEW.Username));
END$$
DELIMITER ;

-- Trigger for UPDATE Operation
DELIMITER $$
CREATE TRIGGER trg_user_update AFTER UPDATE ON User
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'User', 'UPDATE', CONCAT_WS(', ',
        'Updated user:',
        CONCAT('Old: ', OLD.username, ' (Email: ', OLD.email, ', ID: ', OLD.id, ', Address: ', OLD.address, ', Name: ', (SELECT CONCAT(first_name, ' ', last_name) FROM CustomerName WHERE id = OLD.fk_customer_name_id), ', TLF: ', OLD.tlf, ', Post Nr: ', OLD.fk_post_nr, ')'),
        CONCAT('New: ', NEW.username, ' (Email: ', NEW.email, ', ID: ', NEW.id, ', Address: ', NEW.address, ', Name: ', (SELECT CONCAT(first_name, ' ', last_name) FROM CustomerName WHERE id = NEW.fk_customer_name_id), ', TLF: ', NEW.tlf, ', Post Nr: ', NEW.fk_post_nr, ')')
    ));
END$$
DELIMITER ;


-- Trigger for DELETE Operation
DELIMITER $$
CREATE TRIGGER trg_user_delete AFTER DELETE ON User
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'User', 'DELETE', CONCAT('Deleted user ID: ', OLD.id));
END$$
DELIMITER ;


-- ================== Create Triggers for the Cart Table ==================
-- Trigger insert operation
DELIMITER $$
CREATE TRIGGER trg_cart_insert AFTER INSERT ON Cart
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'Cart', 'INSERT', CONCAT('Inserted new cart: ', NEW.id, ' for user: ', NEW.fk_user_id));
END$$
DELIMITER ;


-- Trigger update operation
DELIMITER $$
CREATE TRIGGER trg_cart_update AFTER UPDATE ON Cart
FOR EACH ROW
BEGIN
    IF NOT (NEW.total_book_price <=> OLD.total_book_price)
    OR NOT (NEW.total_tax <=> OLD.total_tax)
    OR NOT (NEW.delivery_price <=> OLD.delivery_price)
    OR NOT (NEW.total_items_amount <=> OLD.total_items_amount)
    OR NOT (NEW.confirmed <=> OLD.confirmed)
    OR NOT (NEW.fk_invoice_id <=> OLD.fk_invoice_id) THEN
        INSERT INTO BogredenLog (username, table_name, operation_type, details)
        VALUES (CURRENT_USER(), 'Cart', 'UPDATE', CONCAT('Updated cart: ', OLD.id, ' for user: ', OLD.fk_user_id, ' Details: ',
            IF(NOT (NEW.total_book_price <=> OLD.total_book_price), CONCAT('Total Book Price: ', OLD.total_book_price, ' to ', NEW.total_book_price, '; '), ''),
            IF(NOT (NEW.total_tax <=> OLD.total_tax), CONCAT('Total Tax: ', OLD.total_tax, ' to ', NEW.total_tax, '; '), ''),
            IF(NOT (NEW.delivery_price <=> OLD.delivery_price), CONCAT('Delivery Price: ', OLD.delivery_price, ' to ', NEW.delivery_price, '; '), ''),
            IF(NOT (NEW.total_items_amount <=> OLD.total_items_amount), CONCAT('Total Items Amount: ', OLD.total_items_amount, ' to ', NEW.total_items_amount, '; '), ''),
            IF(NOT (NEW.confirmed <=> OLD.confirmed), CONCAT('Confirmed: ', OLD.confirmed, ' to ', NEW.confirmed, '; '), ''),
            IF(NOT (NEW.fk_invoice_id <=> OLD.fk_invoice_id), CONCAT('Invoice ID: ', OLD.fk_invoice_id, ' to ', NEW.fk_invoice_id), '')
        ));
    END IF;
END$$
DELIMITER ;


-- Trigger delete operation
DELIMITER $$
CREATE TRIGGER trg_cart_delete AFTER DELETE ON Cart
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'Cart', 'DELETE', CONCAT('Deleted cart: ', OLD.id, ' for user: ', OLD.fk_user_id));
END$$
DELIMITER ;


-- ================== Create Triggers for the CartItem Table ==================
-- Trigger insert operation
DELIMITER $$
CREATE TRIGGER trg_cart_item_insert AFTER INSERT ON CartItem
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'CartItem', 'INSERT', CONCAT('Inserted new cart item: ', NEW.id, ' for cart: ', NEW.fk_cart_id, ' Details: Book ID: ', NEW.fk_book_id, ', Quantity: ', NEW.quantity, ', Offer ID: ', NEW.fk_offer_id));
END$$
DELIMITER ;

-- Trigger update operation
DELIMITER $$
CREATE TRIGGER trg_cart_item_update AFTER UPDATE ON CartItem
FOR EACH ROW
BEGIN
    IF NOT (NEW.quantity <=> OLD.quantity)
    OR NOT (NEW.fk_offer_id <=> OLD.fk_offer_id) THEN
        INSERT INTO BogredenLog (username, table_name, operation_type, details)
        VALUES (CURRENT_USER(), 'CartItem', 'UPDATE', CONCAT('Updated cart item: ', OLD.id, ' for cart: ', OLD.fk_cart_id, ' Details: ',
            IF(NOT (NEW.quantity <=> OLD.quantity), CONCAT('Quantity: ', OLD.quantity, ' to ', NEW.quantity, '; '), ''),
            IF(NOT (NEW.fk_offer_id <=> OLD.fk_offer_id), CONCAT('Offer ID: ', OLD.fk_offer_id, ' to ', NEW.fk_offer_id), '')
        ));
    END IF;
END$$
DELIMITER ;

-- Trigger delete operation
DELIMITER $$
CREATE TRIGGER trg_cart_item_delete AFTER DELETE ON CartItem
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'CartItem', 'DELETE', CONCAT('Deleted cart item: ', OLD.id, ' for cart: ', OLD.fk_cart_id));
END$$
DELIMITER ;


-- ================== Create Triggers for the Invoice Table ==================
-- Trigger insert operation
DELIMITER $$
CREATE TRIGGER trg_invoice_insert AFTER INSERT ON Invoice
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'Invoice', 'INSERT', CONCAT('Inserted new invoice: ', NEW.id, ' for user: ', NEW.fk_user_id));
END$$
DELIMITER ;


-- Trigger update operation
DELIMITER $$
CREATE TRIGGER trg_invoice_update AFTER UPDATE ON Invoice
FOR EACH ROW
BEGIN
    IF NOT (NEW.total_book_price <=> OLD.total_book_price)
    OR NOT (NEW.total_tax <=> OLD.total_tax)
    OR NOT (NEW.delivery_price <=> OLD.delivery_price)
    OR NOT (NEW.total_items_amount <=> OLD.total_items_amount)
    OR NOT (NEW.fk_user_id <=> OLD.fk_user_id) THEN
        INSERT INTO BogredenLog (username, table_name, operation_type, details)
        VALUES (CURRENT_USER(), 'Invoice', 'UPDATE', CONCAT('Updated invoice: ', OLD.id, ' for user: ', OLD.fk_user_id, ' Details: ',
            IF(NOT (NEW.total_book_price <=> OLD.total_book_price), CONCAT('Total Book Price: ', OLD.total_book_price, ' to ', NEW.total_book_price, '; '), ''),
            IF(NOT (NEW.total_tax <=> OLD.total_tax), CONCAT('Total Tax: ', OLD.total_tax, ' to ', NEW.total_tax, '; '), ''),
            IF(NOT (NEW.delivery_price <=> OLD.delivery_price), CONCAT('Delivery Price: ', OLD.delivery_price, ' to ', NEW.delivery_price, '; '), ''),
            IF(NOT (NEW.total_items_amount <=> OLD.total_items_amount), CONCAT('Total Items Amount: ', OLD.total_items_amount, ' to ', NEW.total_items_amount, '; '), ''),
            IF(NOT (NEW.fk_user_id <=> OLD.fk_user_id), CONCAT('User ID: ', OLD.fk_user_id, ' to ', NEW.fk_user_id), '')
        ));
    END IF;
END$$
DELIMITER ;


-- Trigger delete operation
DELIMITER $$
CREATE TRIGGER trg_invoice_delete AFTER DELETE ON Invoice
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'Invoice', 'DELETE', CONCAT('Deleted invoice: ', OLD.id, ' for user: ', OLD.fk_user_id));
END$$
DELIMITER ;


-- ================== Create Triggers for the InvoiceItem Table ==================
-- Trigger insert operation
DELIMITER $$
CREATE TRIGGER trg_invoice_item_insert AFTER INSERT ON InvoiceItem
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'InvoiceItem', 'INSERT', CONCAT('Inserted new invoice item: ', NEW.id, ' for invoice: ', NEW.fk_invoice_id, ' Details: Book ID: ', NEW.fk_book_id, ', Quantity: ', NEW.quantity, ', Offer ID: ', NEW.fk_offer_id));
END$$
DELIMITER ;

-- Trigger update operation
DELIMITER $$
CREATE TRIGGER trg_invoice_item_update AFTER UPDATE ON InvoiceItem
FOR EACH ROW
BEGIN
    IF NOT (NEW.quantity <=> OLD.quantity)
    OR NOT (NEW.fk_offer_id <=> OLD.fk_offer_id) THEN
        INSERT INTO BogredenLog (username, table_name, operation_type, details)
        VALUES (CURRENT_USER(), 'InvoiceItem', 'UPDATE', CONCAT('Updated invoice item: ', OLD.id, ' for invoice: ', OLD.fk_invoice_id, ' Details: ',
            IF(NOT (NEW.quantity <=> OLD.quantity), CONCAT('Quantity: ', OLD.quantity, ' to ', NEW.quantity, '; '), ''),
            IF(NOT (NEW.fk_offer_id <=> OLD.fk_offer_id), CONCAT('Offer ID: ', OLD.fk_offer_id, ' to ', NEW.fk_offer_id), '')
        ));
    END IF;
END$$
DELIMITER ;

-- Trigger delete operation
DELIMITER $$
CREATE TRIGGER trg_invoice_item_delete AFTER DELETE ON InvoiceItem
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'InvoiceItem', 'DELETE', CONCAT('Deleted invoice item: ', OLD.id, ' for invoice: ', OLD.fk_invoice_id));
END$$
DELIMITER ;


-- ================== Create Triggers for the Book Table ==================
-- Trigger insert operation
DELIMITER $$
CREATE TRIGGER trg_book_insert AFTER INSERT ON Book
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'Book', 'INSERT', CONCAT('Inserted new book: ', NEW.id, ' (Title: ', NEW.title, ', ISBN: ', NEW.isbn, ')'));
END$$
DELIMITER ;


-- Trigger update operation
DELIMITER $$
CREATE TRIGGER trg_book_update AFTER UPDATE ON Book
FOR EACH ROW
BEGIN
    IF NOT (NEW.title <=> OLD.title)
    OR NOT (NEW.isbn <=> OLD.isbn)
    OR NOT (NEW.description <=> OLD.description)
    OR NOT (NEW.edition <=> OLD.edition)
    OR NOT (NEW.release_date <=> OLD.release_date)
    OR NOT (NEW.total_pages <=> OLD.total_pages)
    OR NOT (NEW.rating <=> OLD.rating)
    OR NOT (NEW.photo <=> OLD.photo)
    OR NOT (NEW.price <=> OLD.price)
    OR NOT (NEW.stock <=> OLD.stock)
    OR NOT (NEW.fk_genre_id <=> OLD.fk_genre_id)
    OR NOT (NEW.fk_offer_id <=> OLD.fk_offer_id)
    OR NOT (NEW.fk_language_id <=> OLD.fk_language_id)
    OR NOT (NEW.fk_format_id <=> OLD.fk_format_id)
    OR NOT (NEW.fk_stock_status_id <=> OLD.fk_stock_status_id) THEN
        INSERT INTO BogredenLog (username, table_name, operation_type, details)
        VALUES (CURRENT_USER(), 'Book', 'UPDATE', CONCAT('Updated book: ', OLD.id, ' (Title: ', OLD.title, ', ISBN: ', OLD.isbn, ') Details: ',
            IF(NOT (NEW.title <=> OLD.title), CONCAT('Title: ', OLD.title, ' to ', NEW.title, '; '), ''),
            IF(NOT (NEW.isbn <=> OLD.isbn), CONCAT('ISBN: ', OLD.isbn, ' to ', NEW.isbn, '; '), ''),
            IF(NOT (NEW.description <=> OLD.description), CONCAT('Description: ', OLD.description, ' to ', NEW.description, '; '), ''),
            IF(NOT (NEW.edition <=> OLD.edition), CONCAT('Edition: ', OLD.edition, ' to ', NEW.edition, '; '), ''),
            IF(NOT (NEW.release_date <=> OLD.release_date), CONCAT('Release Date: ', OLD.release_date, ' to ', NEW.release_date, '; '), ''),
            IF(NOT (NEW.total_pages <=> OLD.total_pages), CONCAT('Total Pages: ', OLD.total_pages, ' to ', NEW.total_pages, '; '), ''),
            IF(NOT (NEW.rating <=> OLD.rating), CONCAT('Rating: ', OLD.rating, ' to ', NEW.rating, '; '), ''),
            IF(NOT (NEW.photo <=> OLD.photo), CONCAT('Photo: ', OLD.photo, ' to ', NEW.photo, '; '), ''),
            IF(NOT (NEW.price <=> OLD.price), CONCAT('Price: ', OLD.price, ' to ', NEW.price, '; '), ''),
            IF(NOT (NEW.stock <=> OLD.stock), CONCAT('Stock: ', OLD.stock, ' to ', NEW.stock, '; '), ''),
            IF(NOT (NEW.fk_genre_id <=> OLD.fk_genre_id), CONCAT('Genre ID: ', OLD.fk_genre_id, ' to ', NEW.fk_genre_id, '; '), ''),
            IF(NOT (NEW.fk_offer_id <=> OLD.fk_offer_id), CONCAT('Offer ID: ', OLD.fk_offer_id, ' to ', NEW.fk_offer_id, '; '), ''),
            IF(NOT (NEW.fk_language_id <=> OLD.fk_language_id), CONCAT('Language ID: ', OLD.fk_language_id, ' to ', NEW.fk_language_id, '; '), ''),
            IF(NOT (NEW.fk_format_id <=> OLD.fk_format_id), CONCAT('Format ID: ', OLD.fk_format_id, ' to ', NEW.fk_format_id, '; '), ''),
            IF(NOT (NEW.fk_stock_status_id <=> OLD.fk_stock_status_id), CONCAT('Stock Status ID: ', OLD.fk_stock_status_id, ' to ', NEW.fk_stock_status_id), '')
        ));
    END IF;
END$$
DELIMITER ;


-- Trigger delete operation
DELIMITER $$
CREATE TRIGGER trg_book_delete AFTER DELETE ON Book
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'Book', 'DELETE', CONCAT('Deleted book: ', OLD.id, ' (Title: ', OLD.title, ', ISBN: ', OLD.isbn, ')'));
END$$
DELIMITER ;


-- ================== Create Triggers for the QuantityChange Table ==================
-- Trigger insert operation
DELIMITER $$
CREATE TRIGGER trg_quantity_change_insert AFTER INSERT ON QuantityChange
FOR EACH ROW
BEGIN
    INSERT INTO BogredenLog (username, table_name, operation_type, details)
    VALUES (CURRENT_USER(), 'QuantityChange', 'INSERT', CONCAT('Inserted new quantity change: ', NEW.id, ' for book: ', NEW.fk_book_id, ' Details: Change Date: ', NEW.change_date, ', Quantity Change: ', NEW.quantity_change, ', Note: ', NEW.note));
END$$
DELIMITER ;



-- ================================================================
-- ===================== Stores Procedures ========================
-- ================================================================


-- ================== Insert GenreName ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertGenre(IN genreName VARCHAR(100))
BEGIN
    INSERT INTO Genre (genre_name)
    VALUES (genreName);
END$$
DELIMITER ;
-- CALL SP_InsertGenre('Fantasy');


-- ================== Insert Offer ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertOffer(IN offerName VARCHAR(100), IN OfferDiscount DECIMAL(3, 2))
BEGIN
    INSERT INTO Offer (offer_name, discount)
    VALUES (offerName, OfferDiscount);
END$$
DELIMITER ;


-- ================== Insert FormatName ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertFormat(IN formatName VARCHAR(100))
BEGIN
    INSERT INTO Format (format_name)
    VALUES (formatName);
END$$
DELIMITER ;

-- ================== Insert LanguageName ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertLanguage(IN formatName VARCHAR(100))
BEGIN
    INSERT INTO Language (language_name)
    VALUES (formatName);
END$$
DELIMITER ;

-- ================== Insert StockStatusName ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertStockStatus(IN stockStatusName VARCHAR(100))
BEGIN
    INSERT INTO StockStatus (stock_status_name)
    VALUES (stockStatusName);
END$$
DELIMITER ;

-- ================== Insert OrderStatusName ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertOrderStatus(IN orderStatusName VARCHAR(100))
BEGIN
    INSERT INTO OrderStatus (order_status_name)
    VALUES (orderStatusName);
END$$
DELIMITER ;

-- ================== Insert Authur ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertAuthor(IN authorFirstName VARCHAR(255), IN authorLastName VARCHAR(255))
BEGIN
    INSERT INTO Author (first_name, last_name)
    VALUES (authorFirstName, authorLastName);
END$$
DELIMITER ;

-- CALL SP_InsertAuthor('J.K.', 'Rowling');


-- ================== Insert CustomerName ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertCustomerName(IN customerFirstName VARCHAR(255), IN customerLastName VARCHAR(255))
BEGIN
    INSERT INTO CustomerName (first_name, last_name)
    VALUES (customerFirstName, customerLastName);
END$$
DELIMITER ;
-- CALL SP_InsertCustomerName('John', 'Doe');


-- ================== Insert Role ==================
DELIMITER $$
CREATE PROCEDURE SP_InsertRole(IN roleName VARCHAR(50))
BEGIN
    INSERT INTO Role (role_name)
    VALUES (roleName);
END$$
DELIMITER ;
-- CALL InsertRole('Admin');


-- ================== Retrieve all users ==================
DELIMITER $$
CREATE PROCEDURE SP_GetAllCustomerInfo()
BEGIN
    SELECT 
        u.id,
        u.email, 
        u.username, 
        u.register_time, 
        IFNULL(u.last_login_time, NULL) AS LastLoginTime, 
        IFNULL(cn.first_name, NULL) AS FirstName, 
        IFNULL(cn.last_name, NULL) AS LastName, 
        IFNULL(u.tlf, NULL) AS TLF,
        IFNULL(u.address, NULL) AS Address,
        IFNULL(p.city, NULL) AS City,
        r.role_name
    FROM User u
    LEFT JOIN CustomerName cn ON u.fk_customer_name_id = cn.id
    LEFT JOIN Postcode p ON u.fk_post_nr = p.post_nr
    JOIN Role r ON u.fk_role_id = r.id;
END$$
DELIMITER ;
-- CALL SP_GetAllCustomerInfo();


-- ================== Retrieve one user by id ==================
DELIMITER $$
CREATE PROCEDURE SP_GetUserById(IN ID VARCHAR(255))
BEGIN
    SELECT 
        u.id,
        u.email, 
        u.username, 
        u.register_time, 
        IFNULL(u.last_login_time, NULL) AS LastLoginTime, 
        IFNULL(cn.first_name, NULL) AS FirstName, 
        IFNULL(cn.last_name, NULL) AS LastName, 
        IFNULL(u.tlf, NULL) AS TLF,
        IFNULL(u.address, NULL) AS Address,
        IFNULL(p.city, NULL) AS City,
        r.role_name
    FROM User u
    LEFT JOIN CustomerName cn ON u.fk_customer_name_id = cn.id
    LEFT JOIN Postcode p ON u.fk_post_nr = p.post_nr
    JOIN Role r ON u.fk_role_id = r.id
    WHERE u.id = userId;
END$$
DELIMITER ;


-- ================== Add New User ==================
DELIMITER $$
CREATE PROCEDURE SP_AddNewUser(
    IN userEmail VARCHAR(255), 
    IN userHashedPassword VARCHAR(150), 
    IN userSalt VARCHAR(100), 
    IN userUsername VARCHAR(100), 
    IN userRoleID INT
)
BEGIN
    INSERT INTO User (email, hashed_password, salt, username, fk_role_id)
    VALUES (userEmail, userHashedPassword, userSalt, userUsername, userRoleID);
END$$
DELIMITER ;

-- ================== UpdateUserRoleToAdmin ==================
-- assign admin role to a user
DELIMITER $$
CREATE PROCEDURE SP_UpdateUserRoleToAdmin(IN userID INT)
BEGIN
    DECLARE adminRoleID INT;
    SELECT id INTO adminRoleID FROM Role WHERE role_name = 'Admin';

    UPDATE User
    SET fk_role_id = adminRoleID
    WHERE id = userId;
END$$
DELIMITER ;


-- ================== Update a User ==================
-- Allows for updating any combination of fields, including optional ones. 
DELIMITER $$
CREATE PROCEDURE SP_UpdateUser(
    IN userId INT,
    IN userEmail VARCHAR(255), 
    IN userHashedPassword VARCHAR(150), 
    IN userSalt VARCHAR(100), 
    IN userUsername VARCHAR(100), 
    IN userTlf VARCHAR(20), 
    IN userAddress VARCHAR(255), 
    IN userPostNr VARCHAR(10),
    IN userFirstName VARCHAR(255),
    IN userLastName VARCHAR(255)
)
BEGIN
     -- Declare a variable to hold the customer name ID
    DECLARE customerNameId INT;

    -- Insert the new customer name and retrieve the last inserted ID
    IF userFirstName IS NOT NULL AND userLastName IS NOT NULL THEN
        INSERT INTO CustomerName (first_name, last_name) VALUES (userFirstName, userLastName);
        SET customerNameId = LAST_INSERT_ID();
    END IF;

    -- Update the User table
    UPDATE User
    SET
        email = IFNULL(userEmail, email), -- Update email if newUserEmail is not NULL
        hashed_password = IFNULL(userHashedPassword, hashed_password), 
        salt = IFNULL(userSalt, salt), 
        username = IFNULL(userUsername, username), 
        tlf = IFNULL(userTlf, tlf), 
        address = IFNULL(userAddress, address), 
        fk_customer_name_id = IFNULL(customerNameID, fk_customer_name_id), 
        fk_post_nr = IFNULL(userPostNr, fk_post_nr)
    WHERE id = userId;

    -- Update the CustomerName table if firstName or lastName is provided
    IF userFirstName IS NOT NULL OR userLastName IS NOT NULL THEN
        UPDATE CustomerName
        SET 
            first_name = IFNULL(userFirstName, first_name), 
            last_name = IFNULL(userLastName, last_name)
        WHERE id = CustomerNameID;
    END IF;

END$$
DELIMITER ;
-- CALL SP_UpdateUser(
--     1, -- Assuming the user ID is 1
--     NULL -- Optional new email, set to NULL if not updating
--     'newHashedPassword', 
--     'newSaltValue', 
--     'newUsername', 
--     'newTlfNumber', 
--     'newAddress', 
--     1, -- Assuming the new customer name ID is 1
--     'newPostNr', 
--     'newFirstName', 
--     'newLastName',
-- );

-- CALL UpdateUser(1, 'user@example.com', NULL, NULL, 'NewUsername', NULL, NULL, NULL, NULL, 'NewFirstName', 'NewLastName');


-- ================== Delete a User ==================
DELIMITER $$
CREATE PROCEDURE SP_DeleteUser(IN userId INT)
BEGIN
    DELETE FROM User
    WHERE id = userId;
END$$
DELIMITER ;


-- ================== Retrieve all books ==================
-- Also calculate rating, based on the average of all grades for a book in reviews, if there is any
DELIMITER $$
CREATE PROCEDURE SP_GetAllBooks()
BEGIN
    SELECT 
        b.id AS BookId, 
        b.title, 
        b.isbn,
        IFNULL(b.description, NULL) AS Description,
        IFNULL(b.edition, NULL) AS Edition,
        IFNULL(b.release_date, NULL) AS ReleaseDate,
        IFNULL(b.total_pages, NULL) AS TotalPages,
        IFNULL(b.rating, NULL) AS Rating,
        IFNULL(b.photo, NULL) AS Photo,
        b.price, 
        IFNULL(b.stock, NULL) AS Stock,
        IFNULL(g.genre_name, 'No genre specified') AS GenreName,
        IFNULL(o.offer_name, 'No offer specified') AS OfferName,
        IFNULL(l.language_name, 'No language specified') AS LanguageName,
        IFNULL(f.format_name, 'No format specified') AS FormatName,
        IFNULL(ss.stock_status_name, 'No status specified') AS StockStatus,
        GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS Authors,
        IFNULL(avg_grade.AverageGrade, NULL) AS Rating
    FROM Book b
    LEFT JOIN Genre g ON b.fk_genre_id = g.id
    LEFT JOIN Offer o ON b.fk_offer_id = o.id
    LEFT JOIN Language l ON b.fk_language_id = l.id
    LEFT JOIN Format f ON b.fk_format_id = f.id
    LEFT JOIN StockStatus ss ON b.fk_stock_status_id = ss.id
    LEFT JOIN AuthorBook ab ON b.id = ab.fk_book_id
    LEFT JOIN Author a ON ab.fk_author_id = a.id
    LEFT JOIN (
        SELECT fk_book_id, AVG(grade) AS AverageGrade
        FROM Review
        GROUP BY fk_book_id
    ) avg_grade ON b.id = avg_grade.fk_book_id
    GROUP BY b.id;
END$$
DELIMITER ;

-- ================== Retrieve a book by id ==================
DELIMITER $$
CREATE PROCEDURE SP_GetBookById(IN bookId INT)
BEGIN
    SELECT 
        b.id AS BookId, 
        b.title, 
        b.isbn,
        IFNULL(b.description, NULL) AS Description,
        IFNULL(b.edition, NULL) AS Edition,
        IFNULL(b.release_date, NULL) AS ReleaseDate,
        IFNULL(b.total_pages, NULL) AS TotalPages,
        IFNULL(b.rating, NULL) AS Rating,
        IFNULL(b.photo, NULL) AS Photo,
        b.price,
        IFNULL(b.stock, NULL) AS Stock,
        IFNULL(g.genre_name, 'No genre specified') AS GenreName,
        IFNULL(o.offer_name, 'No offer specified') AS OfferName,
        IFNULL(l.language_name, 'No language specified') AS LanguageName,
        IFNULL(f.format_name, 'No format specified') AS FormatName,
        IFNULL(ss.stock_status_name, 'No status specified') AS StockStatus,
        GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS Authors,
        GROUP_CONCAT(DISTINCT CONCAT(IFNULL(r.content, 'No review content'), ' by ', IFNULL(c.username, 'Anonymous')) SEPARATOR '; ') AS Reviews
    FROM Book b
    LEFT JOIN Genre g ON b.fk_genre_id = g.id
    LEFT JOIN Offer o ON b.fk_offer_id = o.id
    LEFT JOIN Language l ON b.fk_language_id = l.id
    LEFT JOIN Format f ON b.fk_format_id = f.id
    LEFT JOIN StockStatus ss ON b.fk_stock_status_id = ss.id
    LEFT JOIN AuthorBook ab ON b.id = ab.fk_book_id
    LEFT JOIN Author a ON ab.fk_author_id = a.id
    LEFT JOIN Review r ON b.id = r.fk_book_id
    LEFT JOIN Customer c ON r.fk_user_id = c.id
    WHERE b.id = bookId
    GROUP BY b.id;
END$$
DELIMITER ;


-- ================== Add New Book ==================
DELIMITER $$
CREATE PROCEDURE SP_AddNewBook(
    IN bookTitle VARCHAR(255),
    IN bookIsbn VARCHAR(13),
    IN bookDescription TEXT,
    IN bookEdition INT,
    IN bookReleaseDate DATE,
    IN bookTotalPages INT,
    IN bookRating DECIMAL(3, 2),
    IN bookPhoto TEXT,
    IN bookPrice DECIMAL(10, 2),
    IN bookStock INT,
    IN bookGenreID INT,
    IN bookOfferID INT,
    IN bookLanguageID INT,
    IN bookFormatID INT,
    IN bookStockStatusID INT
)
BEGIN
    INSERT INTO Book (title, isbn, description, edition, release_date, total_pages, rating, photo, price, stock, fk_genre_id, fk_offer_id, fk_language_id, fk_format_id, fk_stock_status_id)
    VALUES (bookTitle, bookIsbn, IFNULL(bookDescription, NULL), IFNULL(bookEdition, NULL), IFNULL(bookReleaseDate, NULL), IFNULL(bookTotalPages, NULL), IFNULL(bookRating, NULL), IFNULL(bookPhoto, NULL), bookPrice, IFNULL(bookStock, NULL), bookGenreID, bookOfferID, bookLanguageID, bookFormatID, bookStockStatusID);
END$$
DELIMITER ;


-- ================== Update Book ==================
DELIMITER $$
CREATE PROCEDURE SP_UpdateBook(
    IN bookID INT,
    IN bookTitle VARCHAR(255),
    IN bookIsbn VARCHAR(13),
    IN bookDescription TEXT,
    IN bookEdition INT,
    IN bookReleaseDate DATE,
    IN bookTotalPages INT,
    IN bookRating DECIMAL(3, 2),
    IN bookPhoto TEXT,
    IN bookPrice DECIMAL(10, 2),
    IN bookStock INT,
    IN bookGenreID INT,
    IN bookOfferID INT,
    IN bookLanguageID INT,
    IN bookFormatID INT,
    IN bookStockStatusID INT
)
BEGIN
    UPDATE Book
    SET title = IFNULL(bookTitle, title),
        isbn = IFNULL(bookIsbn, isbn),
        description = IFNULL(bookDescription, description),
        edition = IFNULL(bookEdition, edition),
        release_date = IFNULL(bookReleaseDate, release_date),
        total_pages = IFNULL(bookTotalPages, total_pages),
        rating = IFNULL(bookRating, rating),
        photo = IFNULL(bookPhoto, photo),
        price = IFNULL(bookPrice, price),
        stock = IFNULL(bookStock, stock),
        fk_genre_id = IFNULL(bookGenreID, fk_genre_id),
        fk_offer_id = IFNULL(bookOfferID, fk_offer_id),
        fk_language_id = IFNULL(bookLanguageID, fk_language_id),
        fk_format_id = IFNULL(bookFormatID, fk_format_id),
        fk_stock_status_id = IFNULL(bookStockStatusID, fk_stock_status_id)
    WHERE id = bookID;
END$$
DELIMITER ;
-- CALL SP_UpdateBook(
--     1, -- Assuming the book ID is 1
--     'Updated Book Title',
--     '978-3-16-148410-0',
--     'This is an updated book description.',
--     1,
--     '2023-01-01',
--     200,
--     4.5,
--     'path/to/updated_photo.jpg',
--     19.99,
--     100,
--     1, -- Assuming the genre ID is 1
--     1, -- Assuming the offer ID is 1
--     1, -- Assuming the language ID is 1
--     1, -- Assuming the format ID is 1
--     1 -- Assuming the stock status ID is 1
-- );


-- ================== SP_Delete Book ==================
DELIMITER $$
CREATE PROCEDURE SP_DeleteBook(IN bookID INT)
BEGIN
    DELETE FROM Book WHERE id = bookID;
END$$
DELIMITER ;


-- ================== Retrieve all books with a specific genre ==================
DELIMITER $$
CREATE PROCEDURE SP_GetBooksByGenre(IN genreID INT)
BEGIN
    SELECT * FROM Book WHERE fk_genre_id = IFNULL(genreID, fk_genre_id);
END$$
DELIMITER ;

-- ================== Retrieve all books with a specific offer ==================
DELIMITER $$
CREATE PROCEDURE SP_GetBooksByOffer(IN offerID INT)
BEGIN
    SELECT * FROM Book WHERE fk_offer_id = IFNULL(offerID, fk_offer_id);
END$$   
DELIMITER ;

-- ================== Retrieve all books with a specific language ==================
DELIMITER $$
CREATE PROCEDURE SP_GetBooksByLanguage(IN languageID INT)
BEGIN
    SELECT * FROM Book WHERE fk_language_id = IFNULL(languageID, fk_language_id);
END$$
DELIMITER ;

-- ================== Retrieve all books with a specific format ==================
DELIMITER $$
CREATE PROCEDURE SP_GetBooksByFormat(IN formatID INT)
BEGIN
    SELECT * FROM Book WHERE fk_format_id = IFNULL(formatID, fk_format_id);
END$$
DELIMITER ;

-- ================== Retrieve all books with a specific author ==================
-- Only get a list of books
DELIMITER $$
CREATE PROCEDURE SP_GetBooksByAuthor(IN authorID INT)
BEGIN
    SELECT b.Title
    FROM Book b
    JOIN AuthorBook ab ON b.id = ab.fk_book_id
    JOIN Author a ON ab.fk_author_id = a.id
    WHERE a.id = authorID;
END$$
DELIMITER ;




-- ================== Get all cart items by id ==================
DELIMITER $$
CREATE PROCEDURE SP_GetAllCartItems(IN cartId INT)
BEGIN
    SELECT 
        ci.id AS CartItemId,
        ci.fk_cart_id AS CartId,
        ci.fk_book_id AS BookId,
        ci.quantity AS Quantity,
        ci.fk_offer_id AS OfferId,
        CASE 
            WHEN ci.fk_offer_id IS NOT NULL THEN ci.total_book_price * (1 - o.discount)
            ELSE ci.total_book_price
        END AS TotalBookPriceAfterDiscount,
        CASE 
            WHEN ci.fk_offer_id IS NOT NULL THEN (ci.total_book_price * (1 - o.discount)) * 0.25
            ELSE ci.total_book_price * 0.25
        END AS TotalTax
    FROM CartItem ci
    LEFT JOIN Offer o ON ci.fk_offer_id = o.id
    WHERE ci.fk_cart_id = cartId AND ci.total_book_price > 0;
END$$
DELIMITER ;


-- ================== Add a cartItem ==================
DELIMITER $$
CREATE PROCEDURE SP_AddCartItem(IN cartId INT, IN bookId INT, IN itemQuantity INT, IN offerId INT, IN totalBookPrice DECIMAL(10, 2), IN totalTax DECIMAL(10, 2))
BEGIN
    -- Use IFNULL to provide default values for NULL inputs
    INSERT INTO CartItem (fk_cart_id, fk_book_id, quantity, fk_offer_id, total_book_price, total_tax)
    VALUES (
        cartId, 
        bookId, 
        itemQuantity, 
        IFNULL(offerId, 0), -- Default to 0 if NULL
        IFNULL(totalBookPrice, 0.00), -- Default to 0.00 if NULL
        IFNULL(totalTax, 0.00) -- Default to 0.00 if NULL
    );
END$$
DELIMITER ;


-- ================== Update a cartItem ==================
DELIMITER $$
CREATE PROCEDURE SP_UpdateCartItem(IN cartItemId INT, IN itemQuantity INT, IN offerId INT, IN totalBookPrice DECIMAL(10, 2), IN totalTax DECIMAL(10, 2))
BEGIN
    UPDATE CartItem
    SET 
        quantity = IFNULL(itemQuantity, quantity), -- Keep current value if NULL
        fk_offer_id = IFNULL(offerId, fk_offer_id), -- Keep current value if NULL
        total_book_price = IFNULL(totalBookPrice, total_book_price), -- Keep current value if NULL
        total_tax = IFNULL(totalTax, total_tax) -- Keep current value if NULL
    WHERE id = cartItemId;
END$$
DELIMITER ;


-- ================== Delete a cartItem ==================
DELIMITER $$
CREATE PROCEDURE SP_DeleteCartItem(IN cartItemId INT)
BEGIN
    IF cartItemId IS NOT NULL THEN
        DELETE FROM CartItem WHERE id = cartItemId;
    ELSE
        -- Handle the case where p_id is NULL, e.g., log an error or raise a warning
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete cart item with NULL ID';
    END IF;
END$$
DELIMITER ;



-- =================== Get All carts ===================
-- conditionally return invoice id if the cart is confirmed
-- calculate delivery price based on sum of total_book_price and total_tax
DELIMITER $$
CREATE PROCEDURE SP_GetAllCarts()
BEGIN
    SELECT 
        c.id AS CartId,
        c.fk_user_id AS UserId,
        c.DOP AS DateOfPurchase,
        c.total_book_price AS TotalBookPrice,
        c.total_book_price * 0.25 AS TotalTax,
        CASE 
            WHEN (c.total_book_price + (c.total_book_price * 0.25)) > 499 THEN 0
            ELSE 49
        END AS DeliveryPrice,
        (SELECT SUM(ci.quantity) FROM CartItem ci WHERE ci.fk_cart_id = c.id) AS TotalItemsAmount,
        c.confirmed AS Confirmed,
        CASE 
            WHEN c.confirmed = TRUE THEN c.fk_invoice_id
            ELSE NULL
        END AS InvoiceId
    FROM Cart c
    WHERE c.total_book_price > 0;
END$$
DELIMITER ;


-- ================== Delete unconfirmed carts more than 14 days  ==================
--  create a scheduled event that will run daily and delete carts that are not confirmed for more than 14 days
-- This event will call a stored procedure that performs the deletion.
DELIMITER $$
CREATE EVENT delete_old_carts
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    CALL delete_unconfirmed_carts();
END$$
DELIMITER ;

-- delete the carts and trigger the update_stock_after_cart_delete trigger
DELIMITER $$
CREATE PROCEDURE delete_unconfirmed_carts()
BEGIN
    DELETE FROM Cart WHERE confirmed = FALSE AND DOP < DATE_SUB(NOW(), INTERVAL 14 DAY);
END$$
DELIMITER ;




-- =================== Get All Invoice items by id ===================
DELIMITER $$
CREATE PROCEDURE SP_GetAllInvoiceItemsByInvoiceId(IN invoiceId INT)
BEGIN
    SELECT 
        ii.id AS InvoiceItemId,
        ii.fk_invoice_id AS InvoiceId,
        ii.fk_book_id AS BookId,
        ii.quantity AS Quantity,
        ii.fk_offer_id AS OfferId,
        CASE 
            WHEN ii.fk_offer_id IS NOT NULL THEN ii.total_book_price * (1 - o.discount)
            ELSE ii.total_book_price
        END AS TotalBookPriceAfterDiscount,
        CASE 
            WHEN ii.fk_offer_id IS NOT NULL THEN (ii.total_book_price * (1 - o.discount)) * 0.25
            ELSE ii.total_book_price * 0.25
        END AS TotalTax
    FROM InvoiceItem ii
    LEFT JOIN Offer o ON ii.fk_offer_id = o.id
    WHERE ii.fk_invoice_id = invoiceId AND ii.total_book_price > 0;
END$$
DELIMITER ;


-- ================== Get All Invoices ==================
DELIMITER $$
CREATE PROCEDURE SP_GetAllInvoices()
BEGIN
    SELECT 
        i.id AS InvoiceId,
        i.fk_user_id AS UserId,
        i.DOP AS DateOfPurchase,
        i.total_book_price AS TotalBookPrice,
        i.total_book_price * 0.25 AS TotalTax,
        CASE 
            WHEN (i.total_book_price + (i.total_book_price * 0.25)) > 499 THEN 0
            ELSE 49
        END AS DeliveryPrice,
        (SELECT COUNT(*) FROM InvoiceItem ii WHERE ii.fk_invoice_id = i.id) AS TotalItemsAmount,
        (SELECT c.confirmed FROM Cart c WHERE c.fk_invoice_id = i.id) AS Confirmed,
        CASE 
            WHEN (SELECT c.confirmed FROM Cart c WHERE c.fk_invoice_id = i.id) = TRUE THEN i.id
            ELSE NULL
        END AS ConfirmedInvoiceId
    FROM Invoice i
    WHERE i.total_book_price > 0;
END$$
DELIMITER ;

-- ================== Retrieve all invoices by OrderID ==================
DELIMITER $$
CREATE PROCEDURE SP_GetAllInvoicesByUserId(IN userId INT)
BEGIN
    SELECT 
        i.id AS InvoiceId,
        i.fk_user_id AS UserId,
        i.DOP AS DateOfPurchase,
        i.total_book_price AS TotalBookPrice,
        i.total_book_price * 0.25 AS TotalTax,
        CASE 
            WHEN (i.total_book_price + (i.total_book_price * 0.25)) > 499 THEN 0
            ELSE 49
        END AS DeliveryPrice,
        (SELECT COUNT(*) FROM InvoiceItem ii WHERE ii.fk_invoice_id = i.id) AS TotalItemsAmount,
        (SELECT c.confirmed FROM Cart c WHERE c.fk_invoice_id = i.id) AS Confirmed,
        CASE 
            WHEN (SELECT c.confirmed FROM Cart c WHERE c.fk_invoice_id = i.id) = TRUE THEN i.id
            ELSE NULL
        END AS ConfirmedInvoiceId
    FROM Invoice i
    WHERE i.fk_user_id = userId AND i.total_book_price > 0;
END$$
DELIMITER ;


-- ================== Retrieve all invoices with a specific period of time ==================
-- only for admin
DELIMITER $$
CREATE PROCEDURE SP_GetInvoicesByDateRange(IN startDate DATE, IN endDate DATE)
BEGIN
    SELECT
        i.id AS InvoiceId,
        i.fk_user_id AS UserId,
        i.DOP AS DateOfPurchase,
        i.total_book_price AS TotalBookPrice,
        i.total_book_price * 0.25 AS TotalTax,
        CASE 
            WHEN (i.total_book_price + (i.total_book_price * 0.25)) > 499 THEN 0
            ELSE 49
        END AS DeliveryPrice,
        (SELECT COUNT(*) FROM InvoiceItem ii WHERE ii.fk_invoice_id = i.id) AS TotalItemsAmount,
        (SELECT c.confirmed FROM Cart c WHERE c.fk_invoice_id = i.id) AS Confirmed,
        CASE 
            WHEN (SELECT c.confirmed FROM Cart c WHERE c.fk_invoice_id = i.id) = TRUE THEN i.id
            ELSE NULL
        END AS ConfirmedInvoiceId
    FROM Invoice i
    WHERE i.DOP BETWEEN startDate AND endDate;
END$$
DELIMITER ;
-- CALL SP_GetInvoicesByDateRange('2021-01-01', '2021-12-31');




-- ================================================================
-- ============== Bulk Insert Postcode and cities =================
-- ================================================================

-- Save Excel file as CSV UTF-8 (comma delimited) (*.csv) 

-- Error Code: 3948, indicates that loading local data is disabled in MySQL. This is a security feature to prevent unauthorized reading of local files. To resolve this issue, you need to enable the LOCAL_INFILE setting on both the client and server sides of your MySQL setup.

-- To enable the LOCAL_INFILE setting on the client side:
-- SET GLOBAL local_infile = 1;
-- To check the current status of the LOCAL_INFILE settin, should be ON
-- show global variables like 'local_infile';

-- ======================== Bulk insert Postcode ===========================
LOAD DATA INFILE 'C:\\Users\\ieaso\\Desktop\\MySQL\\postnumre.csv'
INTO TABLE Postcode 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'   
IGNORE 1 LINES 
(post_nr, city);










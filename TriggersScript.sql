
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

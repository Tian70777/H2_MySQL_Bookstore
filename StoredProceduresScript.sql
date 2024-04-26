
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











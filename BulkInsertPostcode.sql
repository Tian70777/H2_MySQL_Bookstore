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

-- ======================== Bulk insert Genre ===========================
CALL SP_InsertGenre('Fantasy');
CALL SP_InsertGenre('Science Fiction');
CALL SP_InsertGenre('Mystery');
CALL SP_InsertGenre('Romance');
CALL SP_InsertGenre('Thriller');
CALL SP_InsertGenre('Horror');
CALL SP_InsertGenre('Adventure');
CALL SP_InsertGenre('Comedy');

-- ======================== Bulk insert Offer ===========================
CALL SP_InsertOffer('Summer Sale', 0.10);
CALL SP_InsertOffer('Winter Wonderland', 0.15);
CALL SP_InsertOffer('Black Friday', 0.20);
CALL SP_InsertOffer('New Year Eve', 0.25);
CALL SP_InsertOffer('Valentine Day', 0.10);
CALL SP_InsertOffer('Halloween', 0.15);

-- ======================== Bulk insert Format ===========================
CALL SP_InsertFormat('Hardcover');
CALL SP_InsertFormat('Paperback');
CALL SP_InsertFormat('Ebook');
CALL SP_InsertFormat('Audiobook');
CALL SP_InsertFormat('PDF');

-- ======================== Bulk insert Language ===========================
CALL SP_InsertLanguage('English');
CALL SP_InsertLanguage('Spanish');
CALL SP_InsertLanguage('French');
CALL SP_InsertLanguage('German');
CALL SP_InsertLanguage('Danish');

-- ======================== Bulk insert StockStatus ===========================
CALL SP_InsertStockStatus('In Stock');
CALL SP_InsertStockStatus('Out of Stock');
CALL SP_InsertStockStatus('Low Stock');
CALL SP_InsertStockStatus('Backordered');
CALL SP_InsertStockStatus('Discontinued');

-- ======================== Bulk insert OrderStatus ===========================
CALL SP_InsertOrderStatus('Paid');
CALL SP_InsertOrderStatus('Pending');
CALL SP_InsertOrderStatus('Ready for delivery');
CALL SP_InsertOrderStatus('Under shipping');
CALL SP_InsertOrderStatus('Completed');
CALL SP_InsertOrderStatus('Cancelled');
CALL SP_InsertOrderStatus('Returned');

-- ======================== Bulk insert Author ===========================
CALL SP_InsertAuthor('J.K.', 'Rowling');
CALL SP_InsertAuthor('George R.R.', 'Martin');
CALL SP_InsertAuthor('Stephen', 'King');
CALL SP_InsertAuthor('Dan', 'Brown');
CALL SP_InsertAuthor('Jane', 'Austen');
CALL SP_InsertAuthor('Markus', 'Zusak');
CALL SP_InsertAuthor('Raymond', 'Feist');
CALL SP_InsertAuthor('Agatha', 'Christie');
CALL SP_InsertAuthor('John', 'Grisham');
CALL SP_InsertAuthor('Stephenie', 'Meyer');

-- ======================== Bulk insert Role ===========================
CALL SP_InsertRole('Customer');
CALL SP_InsertRole('Admin');
CALL SP_InsertRole('Staff');

-- ======================== Bulk insert User ===========================
CALL SP_AddNewUser('alice@example.com', 'hashedPassword456', 'salt456', 'alice', 1);
CALL SP_AddNewUser('bob@example.com', 'hashedPassword789', 'salt789', 'bob', 1);
CALL SP_AddNewUser('charlie@example.com', 'hashedPassword012', 'salt012', 'charlie', 1);
CALL SP_AddNewUser('diana@example.com', 'hashedPassword345', 'salt345', 'diana', 1);
CALL SP_AddNewUser('eva@example.com', 'hashedPassword678', 'salt678', 'eva', 1);
CALL SP_AddNewUser('admin@example.com', 'hashedPassword901', 'salt901', 'admin', 2);

-- ======================== Update User ===========================
CALL SP_UpdateUser(
    5,
    'charlie@example.com',
    'hashedPassword012',
    'salt012',
    'charlie',
    '1234567890', -- Example tlf
    '123 Main St, Anytown, USA', -- Example address
    '4200', -- Example postnr
    'Charlie', -- First name
    'Brown' -- Last name
);

CALL SP_UpdateUser(
     6,
    'diana@example.com',
    'hashedPassword345',
    'salt345',
    'diana',
    '0987654321', -- Example tlf
    '456 Elm St, Othertown, USA', -- Example address
    '2100', -- Example postnr
    'Diana', -- First name
    'Prince' -- Last name
);

-- ======================== Add New Books ===========================





-- ======================== Add cart  ===========================


-- ======================== Add  cartItems  ===========================


-- ======================== Add invoices  ===========================


-- ======================== Add invoice Items  ===========================


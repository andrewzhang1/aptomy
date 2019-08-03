-- Drop the tables if they already exist in order to start with a fresh
-- database. You will lose any changes you have made to this data.

DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS LineItems;

-- Create the tables
CREATE TABLE Products (
    ProductCode TEXT    PRIMARY KEY     NOT NULL,
    Description TEXT    UNIQUE          NOT NULL,
    Price       REAL                    NOT NULL
);

CREATE TABLE LineItems (
    LineItemID  INTEGER PRIMARY KEY     NOT NULL, 
    InvoiceID   INTEGER                 NOT NULL,
    ProductCode TEXT                    NOT NULL,
    Quantity    INTEGER                 NOT NULL,
    FOREIGN KEY(ProductCode) REFERENCES Products(ProductCode)
);


-- Populate the Products table
INSERT INTO Products VALUES
('java', 'Murach''s Java Programming', 57.50);

INSERT INTO Products VALUES
('jsp', 'Murach''s Java Servlets and JSP', 57.50);

INSERT INTO Products VALUES
('mysql', 'Murach''s MySQL', 54.50);

INSERT INTO Products VALUES
('orac', 'Murach''s Oracle and PL/SQL', 54.50);

INSERT INTO Products VALUES
('andr', 'Murach''s Android Programming', 57.50);

INSERT INTO Products VALUES
('html', 'Murach''s HTML and CSS', 54.50);

INSERT INTO Products VALUES
('jscr', 'Murach''s JavaScript and jQuery', 54.50);


-- Populate the LineItems table
INSERT INTO LineItems VALUES
(1, 1, 'java', 5);

INSERT INTO LineItems VALUES
(2, 1, 'jsp', 5);

INSERT INTO LineItems VALUES
(3, 2, 'mysql', 1);

INSERT INTO LineItems VALUES
(4, 3, 'andr', 1);

INSERT INTO LineItems VALUES
(5, 3, 'orac', 2);

INSERT INTO LineItems VALUES
(6, 4, 'html', 1);

INSERT INTO LineItems VALUES
(7, 5, 'java', 1);

INSERT INTO LineItems VALUES
(8, 5, 'mysql', 5);

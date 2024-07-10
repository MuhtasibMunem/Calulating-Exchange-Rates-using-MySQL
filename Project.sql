create database Data_Analyst_Project;
use data_analyst_project;
CREATE TABLE Orders (
    SubscriptionID TEXT,
    FinanceMonth TEXT,
    SubscriptionFirstStartDate TEXT,
    OrderID TEXT,
    OrderDate TEXT,
    InvoiceDate TEXT,
    InvoiceNumber TEXT,
    CancellationDate TEXT,
    PaymentMethod VARCHAR(255),
    ProductCode INT NULL,
    ProductName TEXT,
    ProductCategory TEXT,
    InvoiceType VARCHAR(255),
    NoOfUsers INT NULL,
    Months INT NULL,
    TaxRate TEXT,
    Currency VARCHAR(255),
    `NetInvoiceAmount 
    (Local Currency)` FLOAT NULL,
    `NetTaxInvoiceAmount 
    (Local Currency)` FLOAT NULL,
    `GrossInvoiceAmount 
    (Local Currency)` FLOAT NULL,
    `MonthlyAmount 
    (Local Currency)` FLOAT NULL,
    `FX Rate to GBP 
    (By SubscriptionFirstStart Date)` TEXT,
    `NetInvoiceAmount
    (By SubscriptionFirstStart Date)` TEXT,
    `TaxAmount
    (By SubscriptionFirstStart Date)` TEXT,
    `GrossInvoiceAmount
    (By SubscriptionFirstStart Date)` TEXT,
    `MonthlyAmount
    (By SubscriptionFirstStart Date)` TEXT,
    `FX Rate to GBP 
    (By Order Date)` TEXT,
    `NetInvoiceAmount
    (By Order Date)` TEXT,
    `TaxAmount
    (By Order Date)` TEXT,
    `GrossInvoiceAmount
    (By Order Date)` TEXT,
    `MonthlyAmount
    (By Order Date)` TEXT,
    `Billing_Invoice Company ID` TEXT,
    `Billing_Invoice CompanyName` TEXT,
    `Billing_End User ID` TEXT,
    `Billing EndUserName` TEXT,
    `Billing_Reseller ID` TEXT,
    `Billing_ResellerName` TEXT,
    `Billing CustomerType` TEXT,
    `Billing_Saleschannel` TEXT,
    `Billing_Territory` TEXT,
    `Billing_Country` TEXT,
    `Live_Invoice Company ID` TEXT,
    `Live_Invoice CompanyName` TEXT,
    `Live_End User ID` TEXT,
    `Live_EndUserName` TEXT,
    `Live_ResellerID` TEXT,
    `Live_ResellerName` TEXT,
    `Subscription Status` VARCHAR(255),
    `SubscriptionStartDate` TEXT,
    `SubscriptionEndDate` TEXT,
    `RevenueStartDate` TEXT,
    `RevenueEndDate` TEXT,
    `SalesPerson` TEXT,
    `NextInvoiceDate` TEXT
);
alter table orders
modify column CancellationDate text;
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Orders.csv"
into table orders
fields terminated by ','
lines terminated by '\n';
SELECT 
    *
FROM
    orders;
UPDATE orders 
SET 
    NextInvoiceDate = NULL
WHERE
    NextInvoiceDate = '';
CREATE TABLE Exchange_Rate (
    Name TEXT,
    `Exchange Rate in GBP` DOUBLE,
    `Effective From` DATE,
    `Effective To` DATE
);
LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Exchange_Rates.csv"
into table exchange_rate
fields terminated by ','
lines terminated by '\n'
ignore 1 lines;
SELECT 
    *
FROM
    exchange_rate;
SELECT 
    *
FROM
    orders
WHERE
    InvoiceNumber LIKE 'invoice%';
SELECT 
    *
FROM
    orders
WHERE
    `Billing CustomerType` = 'Direct'
        AND Billing_Saleschannel = 'Indirect';
SELECT 
    *
FROM
    orders
WHERE
    OrderID LIKE '%cnx%'
        OR OrderID IN (SELECT 
            OrderID
        FROM
            orders
        WHERE
            OrderID NOT LIKE '%cnx%'
                AND CancellationDate LIKE '____%');
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%M')
FROM
    orders;
SELECT 
    (SELECT 
            DATE_FORMAT(OrderDate, '%Y-%M')
        FROM
            orders
        WHERE
            InvoiceNumber = O.InvoiceNumber) AS Yr_Mnth,
    COUNT(O.InvoiceNumber) AS Invoice_counts
FROM
    orders O
GROUP BY Yr_Mnth;
WITH Order_Y_M AS (SELECT DATE_FORMAT(OrderDate, '%Y-%M') AS Y_M from orders)
SELECT COUNT(InvoiceNumber) AS Invoice_Counts FROM orders, Order_Y_M
GROUP BY Y_M;
SELECT DISTINCT
    DATE_FORMAT(OrderDate, '%Y-%M') AS Y_M
FROM
    orders;
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%M') AS Y_M,
    COUNT(InvoiceNumber) AS Invoice_Counts
FROM
    orders
GROUP BY Y_M;
SELECT 
    e.`Exchange Rate in GBP`, o.SubscriptionFirstStartDate
FROM
    exchange_rate e,
    orders o
WHERE
    o.SubscriptionFirstStartDate BETWEEN e.`Effective From` AND e.`Effective To`;
SELECT DISTINCT
    SubscriptionFirstStartDate
FROM
    orders;
alter table exchange_rate
modify column `Effective To` text;
SELECT 
    *
FROM
    exchange_rate;
CREATE TABLE Ex_Rates_by_date (
    SFD DATE,
    Name VARCHAR(255),
    `Exchange Rate in GBP` DOUBLE,
    `Effective From` TEXT,
    `Effective To` TEXT
);
 insert into ex_rates_by_date (SFD,Name,  `Exchange Rate in GBP`,`Effective From`,  `Effective To`) 
 (select distinct o.SubscriptionFirstStartDate, o.Currency, e.`Exchange Rate in GBP`,e.`Effective From`, e.`Effective To` from exchange_rate e,orders o
where o.SubscriptionFirstStartDate between e.`Effective From` and e.`Effective To`);
UPDATE orders o
        JOIN
    ex_rates_by_date e ON o.SubscriptionFirstStartDate = e.SFD
        AND o.currency = e.name 
SET 
    o.`FX Rate to GBP 
    (By SubscriptionFirstStart Date)` = e.`Exchange Rate in GBP`;
SELECT 
    *
FROM
    orders;
UPDATE orders 
SET 
    `NetInvoiceAmount
    (By SubscriptionFirstStart Date)` = (`NetInvoiceAmount 
    (Local Currency)` * `FX Rate to GBP 
    (By SubscriptionFirstStart Date)`);
UPDATE orders 
SET 
    `TaxAmount
    (By SubscriptionFirstStart Date)` = (`NetTaxInvoiceAmount 
    (Local Currency)` * `FX Rate to GBP 
    (By SubscriptionFirstStart Date)`);
UPDATE orders 
SET 
    `GrossInvoiceAmount
    (By SubscriptionFirstStart Date)` = (`GrossInvoiceAmount 
    (Local Currency)` * `FX Rate to GBP 
    (By SubscriptionFirstStart Date)`);
UPDATE orders 
SET 
    `MonthlyAmount
    (By SubscriptionFirstStart Date)` = (`MonthlyAmount 
    (Local Currency)` * `FX Rate to GBP 
    (By SubscriptionFirstStart Date)`);
alter table ex_rates_by_date
add column OD date;
UPDATE ex_rates_by_date e
        JOIN
    orders o ON e.`Effective From` = o.effective_from 
SET 
    e.OD = o.OrderDate;
SELECT 
    *
FROM
    ex_rates_by_date;
SELECT 
    *
FROM
    orders;
UPDATE orders o
        JOIN
    ex_rates_by_date e ON o.SubscriptionFirstStartDate = e.SFD
        AND o.currency = e.name 
SET 
    o.`FX Rate to GBP 
    (By Order Date)` = e.`Exchange Rate in GBP`;
UPDATE orders 
SET 
    `NetInvoiceAmount
    (By Order Date)` = (`NetInvoiceAmount 
    (Local Currency)` * `FX Rate to GBP 
    (By Order Date)`);
UPDATE orders 
SET 
    `TaxAmount
    (By Order Date)` = (`NetTaxInvoiceAmount 
    (Local Currency)` * `FX Rate to GBP 
    (By Order Date)`);
UPDATE orders 
SET 
    `GrossInvoiceAmount
    (By Order Date)` = (`GrossInvoiceAmount 
    (Local Currency)` * `FX Rate to GBP 
    (By Order Date)`);
UPDATE orders 
SET 
    `MonthlyAmount
    (By Order Date)` = (`MonthlyAmount 
    (Local Currency)` * `MonthlyAmount
    (By Order Date)`);
UPDATE orders 
SET 
    `Live_Invoice Company ID` = CASE
        WHEN `Subscription Status` = 'Active' THEN `Billing_Invoice Company ID`
        ELSE NULL
    END;
UPDATE orders 
SET 
    `Live_Invoice CompanyName` = CASE
        WHEN `Subscription Status` = 'Active' THEN `Billing_Invoice CompanyName`
        ELSE NULL
    END;
UPDATE orders 
SET 
    `Live_End User ID` = CASE
        WHEN `Subscription Status` = 'Active' THEN `Billing_End User ID`
        ELSE NULL
    END;
UPDATE orders 
SET 
    Live_EndUserName = CASE
        WHEN `Subscription Status` = 'Active' THEN `Billing EndUserName`
        ELSE NULL
    END;
UPDATE orders 
SET 
    Live_ResellerID = CASE
        WHEN `Subscription Status` = 'Active' THEN `Billing_Reseller ID`
        ELSE NULL
    END;
UPDATE orders 
SET 
    Live_ResellerName = CASE
        WHEN `Subscription Status` = 'Active' THEN Billing_ResellerName
        ELSE NULL
    END;
UPDATE orders 
SET 
    NextInvoiceDate = (SELECT 
            DATE_ADD(SubscriptionEndDate,
                    INTERVAL 1 DAY)
        );
SELECT 
    *
FROM
    orders;



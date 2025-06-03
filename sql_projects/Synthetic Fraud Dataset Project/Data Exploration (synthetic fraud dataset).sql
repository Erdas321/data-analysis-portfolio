-- Create a new schema (i.e., database) named 'aml' for organizing AML-related tables
CREATE SCHEMA aml;

-- Switch to using the 'aml' schema for all subsequent operations
USE aml;

-- Increase network timeout limits to handle large file imports without interruption
SET net_read_timeout = 600;
SET net_write_timeout = 600;

-- Check if loading local files is enabled
SHOW VARIABLES LIKE 'local_infile';

-- Enable the ability to load data from local files
SET GLOBAL local_infile = 'ON';

-- Create the main table for fraud detection analysis
CREATE TABLE fraud_det (
	step INT,                            -- Time step of the transaction
	`type` VARCHAR(250),                -- Transaction type (e.g., TRANSFER, CASH_OUT)
	amount FLOAT,                       -- Transaction amount
	nameOrig VARCHAR(250),             -- Sender’s ID
	oldbalanceOrg FLOAT,               -- Sender’s balance before transaction
	newbalanceOrig FLOAT,              -- Sender’s balance after transaction
	nameDest VARCHAR(250),             -- Receiver’s ID
	oldbalanceDest FLOAT,              -- Receiver’s balance before transaction
	newbalanceDest FLOAT,              -- Receiver’s balance after transaction
	isFraud INT,                       -- 1 if transaction is fraudulent, else 0
	isFlaggedFraud INT                 -- 1 if transaction was flagged, even if not confirmed fraud
);

-- Load the transaction dataset from a local CSV file into the fraud_det table
LOAD DATA LOCAL INFILE "sfd_fraud_1m.csv" 
INTO TABLE fraud_det 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;                         -- Skip CSV header row

-- Standardize column names using snake_case for consistency and readability
ALTER TABLE fraud_det
RENAME COLUMN nameOrig TO name_orig,
RENAME COLUMN oldbalanceOrg TO oldbalance_orig,
RENAME COLUMN newbalanceOrig TO newbalance_orig,
RENAME COLUMN nameDest TO name_dest,
RENAME COLUMN oldbalanceDest TO oldbalance_dest,
RENAME COLUMN newbalanceDest TO newbalance_dest,
RENAME COLUMN isFraud TO is_fraud,
RENAME COLUMN isFlaggedFraud TO is_flagged_fraud;

-- View all rows in the fraud_det table (optional for verification)
SELECT * FROM fraud_det;

-- Identify and return duplicate rows based on all transaction attributes
WITH numbered_rows AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY
			step, `type`, amount,
			name_orig, oldbalance_orig, newbalance_orig,
			name_dest, oldbalance_dest, newbalance_dest,
			is_fraud, is_flagged_fraud
		) AS row_num
	FROM fraud_det
)
SELECT * FROM numbered_rows WHERE row_num > 1;

-- List distinct transaction types that have been involved in fraud or flagged as fraud
SELECT DISTINCT `type`
FROM fraud_det
WHERE is_fraud = 1 OR is_flagged_fraud = 1;

-- Create a filtered table of only TRANSFER and CASH_OUT transactions
-- Add a flag for transactions where amount exceeds sender’s original balance
CREATE TABLE transfer_cashout AS
SELECT *,
	IF(amount > oldbalance_orig, 1, 0) AS balance_error
FROM fraud_det
WHERE `type` = 'TRANSFER' OR `type` = 'CASH_OUT';

-- View the newly created transfer_cashout table (optional)
SELECT * FROM transfer_cashout;

-- Check for any logically invalid transactions with negative balances
SELECT * 
FROM transfer_cashout 
WHERE oldbalance_orig < 0 
   OR newbalance_orig < 0 
   OR oldbalance_dest < 0 
   OR newbalance_dest < 0;

-- Count how often each sender (name_orig) appears in transactions with no balance errors
SELECT 
	name_orig,
	COUNT(name_orig) AS count_name_orig
FROM (
	SELECT name_orig
	FROM transfer_cashout
	WHERE balance_error = 0
	ORDER BY amount DESC
) AS just_name_orig
GROUP BY name_orig
HAVING count_name_orig > 2
ORDER BY count_name_orig DESC;

-- Count how often each receiver (name_dest) appears in transactions with no balance errors
SELECT 
	name_dest,
	COUNT(name_dest) AS count_name_dest
FROM (
	SELECT *
	FROM transfer_cashout
	WHERE balance_error = 0
	ORDER BY amount DESC
) AS just_name_dest
GROUP BY name_dest
HAVING count_name_dest > 2
ORDER BY count_name_dest DESC;

-- Create a temporary table containing average transaction amounts per receiver
-- Only include receivers with 3 or more valid (no-error) transactions
CREATE TEMPORARY TABLE averages AS
SELECT
	name_dest,
	ROUND(AVG(amount), 2) AS avg_amount
FROM transfer_cashout
WHERE balance_error = 0
GROUP BY name_dest
HAVING COUNT(name_dest) >= 3;

-- Create a temporary table to label transactions as Normal, Suspicious, or Extreme outliers
CREATE TEMPORARY TABLE outliers AS
SELECT 
	tc.name_dest,
	tc.amount,
	avg_amount,
	CASE
        WHEN tc.amount > avg_amount * 2 THEN 'Extreme'
        WHEN tc.amount >= avg_amount * 1.75 THEN 'Suspicious'
        ELSE 'Normal'
    END AS outlier
FROM transfer_cashout AS tc
INNER JOIN averages AS av
	ON tc.name_dest = av.name_dest
WHERE tc.balance_error = 0
ORDER BY tc.name_dest;

-- Create a final table joining all transaction data with outlier classification
CREATE TABLE tc_table
SELECT 
	step,
	`type`,
	tc.amount,
	name_orig,
	oldbalance_orig,
	newbalance_orig,
	tc.name_dest,
	oldbalance_dest,
	newbalance_dest,
    outlier,
	balance_error,
	is_fraud,
	is_flagged_fraud
FROM transfer_cashout AS tc
LEFT JOIN outliers AS ol
	ON tc.name_dest = ol.name_dest
	AND tc.amount = ol.amount;

-- Expand the column size to accommodate full outlier category labels like 'Small Sample'
ALTER TABLE tc_table
MODIFY COLUMN outlier VARCHAR(100);

-- Label transactions not included in the averages as 'Small Sample'
UPDATE tc_table
SET outlier = 'Small Sample'
WHERE outlier IS NULL;

-- Final preview of the classified transaction table
SELECT * FROM tc_table;

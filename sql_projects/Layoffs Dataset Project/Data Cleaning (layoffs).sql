-- CREATE a new database
CREATE SCHEMA IF NOT EXISTS world_layoffs;

-- USE the world_layoffs database
USE `world_layoffs`;

-- Manually import the dataset using MySQL Workbench

-- Instructions:
-- 1. In MySQL Workbench, right-click the 'Tables' section.
-- 2. Select 'Table Data Import Wizard' from the context menu.
-- 3. Choose the CSV file that contains your data and click 'Next'.
-- 4. Follow the prompts (Next, Next, Finish) to import the data.
-- 5. After import, click 'Refresh' in the MySQL Workbench to see the data.
-- 6. Run the following command to verify the data is in the table:
--    SELECT * FROM layoffs LIMIT 10;

-- CREATE a copy of the layoffs table
CREATE TABLE IF NOT EXISTS layoffs_copy
SELECT *
FROM layoffs;

-- SELECT all columns from the layoffs_copy table to view the data
SELECT *
FROM layoffs_copy;

-- Create a temporary "row_filter" with row_number to identify duplicate rows based on a set of columns
WITH row_filter AS (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY 
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    ) row_num
    FROM layoffs_copy
)

-- SELECT only rows where the row number is greater than 1, identifying duplicates
SELECT *
FROM row_filter
WHERE row_num > 1;

-- CREATE a new table `new_layoffs` with a similar structure to `layoffs_copy` but with an additional row_num column
CREATE TABLE new_layoffs
(
    company VARCHAR(60),
    location VARCHAR(60),
    industry VARCHAR(60),
    total_laid_off INT,
    percentage_laid_off VARCHAR(60),
    `date` VARCHAR(60),
    stage VARCHAR(60),
    country VARCHAR(60),
    funds_raised_millions INT,
    row_num INT
);

-- INSERT data into `new_layoffs` from `layoffs_copy`, adding the row number for identifying duplicates
INSERT INTO new_layoffs
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
) row_num
FROM layoffs_copy;

-- SELECT all records from `new_layoffs` to verify the insertion
SELECT *
FROM new_layoffs;

-- ALTER the `new_layoffs` table to MODIFY the column `percentage_laid_off` to a decimal type for consistency
ALTER TABLE new_layoffs
MODIFY COLUMN percentage_laid_off DECIMAL(10, 2);

-- UPDATE `company` field to remove leading or trailing spaces in `new_layoffs`
UPDATE new_layoffs 
SET company = TRIM(company);

-- UPDATE `industry` to 'Crypto' if the industry field starts with 'Crypto'
UPDATE new_layoffs 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- CONVERT the `date` field from string to date format and create a new column `new_date`
SELECT 
    `date`,
    STR_TO_DATE(`date`, '%m/%d/%Y') new_date
FROM new_layoffs;

-- UPDATE the `date` field to store the date in proper format (convert string to date)
UPDATE new_layoffs 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- ALTER the `new_layoffs` table to MODIFY the `date` column type to `date` for proper date handling
ALTER TABLE new_layoffs
MODIFY COLUMN `date` DATE;

-- SELECT distinct countries from the `new_layoffs` table, ordered by country in descending order
SELECT DISTINCT country
FROM new_layoffs
ORDER BY 1 DESC;

-- SELECT all records for the company 'AirBnB' to inspect their data
SELECT *
FROM new_layoffs
WHERE company = 'AirBnB';

-- UPDATE the `country` field to trim trailing periods for data consistency
UPDATE new_layoffs 
SET country = TRIM(TRAILING '.' FROM country);

-- UPDATE `industry` to `NULL` where it is an empty string, as empty strings are invalid values for industry
UPDATE new_layoffs
SET industry = NULL
WHERE industry = '';

-- SELECT pairs of companies where one has a NULL `industry` and the other has a valid `industry`
-- This helps identify rows with missing industry data
SELECT 
    nl1.company,
    nl1.location,
    nl1.industry,
    nl2.company,
    nl2.location,
    nl2.industry
FROM new_layoffs nl1
INNER JOIN new_layoffs nl2
    ON nl1.company = nl2.company
WHERE nl1.industry IS NULL
AND nl2.industry IS NOT NULL;

-- UPDATE rows where the `industry` is NULL in one row and not NULL in the other row for the same company
-- This will propagate the valid `industry` value to the NULL `industry`
UPDATE new_layoffs nl1
INNER JOIN new_layoffs nl2
    ON nl1.company = nl2.company 
SET nl1.industry = nl2.industry
WHERE nl1.industry IS NULL
AND nl2.industry IS NOT NULL;

-- ALTER the `new_layoffs` table to DROP the `row_num` column as it is no longer needed
ALTER TABLE new_layoffs 
DROP COLUMN row_num;

-- SELECT all records from `new_layoffs` to verify the final data after all transformations
SELECT *
FROM new_layoffs;

-- Selects all records from the new_layoffs table
SELECT *
FROM new_layoffs;

-- Finds the maximum number of laid-off employees and the maximum layoff percentage
SELECT 
    MAX(total_laid_off) max_laid_off,
    MAX(percentage_laid_off) max_percentage_laid_off
FROM new_layoffs;

-- Retrieves all records where 100% of the company's employees were laid off
SELECT *
FROM new_layoffs
WHERE percentage_laid_off = 1;

-- Filters companies that had 100% layoffs and also raised funds, sorted by funds raised
SELECT *
FROM new_layoffs
WHERE percentage_laid_off = 1
AND funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC;

-- Calculates the total number of laid-off employees per company, sorted by highest total
SELECT 
    company,
    SUM(total_laid_off) sum_laid_off
FROM new_layoffs
GROUP BY company
ORDER BY sum_laid_off DESC;

-- Calculates total layoffs per industry, sorted by highest total
SELECT 
    industry,
    SUM(total_laid_off) sum_laid_off
FROM new_layoffs
GROUP BY industry
ORDER BY sum_laid_off DESC;

-- Calculates total layoffs per country, sorted by highest total
SELECT 
    country,
    SUM(total_laid_off) sum_laid_off
FROM new_layoffs
GROUP BY country
ORDER BY sum_laid_off DESC;

-- Calculates total layoffs per year, filtering out NULL values, sorted by year in descending order
SELECT 
    YEAR(`date`) `year`,
    SUM(total_laid_off) sum_laid_off
FROM new_layoffs
WHERE YEAR(`date`) IS NOT NULL
GROUP BY `year`
ORDER BY `year` DESC;

-- Calculates total layoffs per month, sorted by month in descending order
SELECT 
    SUBSTRING(`date`, 1, 7) `month`,
    SUM(total_laid_off) sum_laid_off
FROM new_layoffs
GROUP BY `month`
ORDER BY `month` DESC;

-- Calculates total layoffs per company stage, sorted alphabetically
SELECT 
    stage,
    SUM(total_laid_off) sum_laid_off
FROM new_layoffs
GROUP BY stage
ORDER BY stage ASC;

-- Creates a CTE to compute cumulative total layoffs per month
WITH rolling_cte AS (
    SELECT 
        SUBSTRING(`date`, 1, 7) `month`,
        SUM(total_laid_off) sum_laid_off
    FROM new_layoffs
    GROUP BY `month`
)
SELECT *,
    SUM(sum_laid_off) OVER(ORDER BY `month`) rolling_total
FROM rolling_cte;

-- Ranks companies by total layoffs per year and returns the top 5 companies for each year
WITH rank_system_1 AS (
    SELECT 
        company,
        YEAR(`date`) `year`,
        SUM(total_laid_off) sum_laid_off
    FROM new_layoffs
    GROUP BY company, `year`
),
rank_system_2 AS (
    SELECT *,
        DENSE_RANK() OVER(PARTITION BY `year` ORDER BY sum_laid_off DESC ) ranking
    FROM rank_system_1
)
SELECT *
FROM rank_system_2
WHERE ranking <= 5
AND `year` IS NOT NULL;

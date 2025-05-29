-- Data Cleaning

USE world_layoffs;

SELECT * 
FROM layoffs;

-- remove duplicates if any
-- standardize the data
-- look at the null and blank values
-- remove any unnecessary columns

-- create my working table so as not to interfere with the raw data
CREATE TABLE layoffs_working
LIKE layoffs;

INSERT layoffs_working
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_working;

-- remove duplicates if any
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_working;

WITH duplicate_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_working
)
SELECT *
FROM duplicate_CTE
WHERE row_num > 1;

SELECT *
FROM layoffs_working
WHERE company = 'Casper';

-- create a new table with row_num column
CREATE TABLE layoffs_working2 AS
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
           `date`, stage, country, funds_raised_millions
         ) AS row_num
  FROM layoffs_working
) AS ranked;
SELECT *
FROM layoffs_working2;

-- removes duplicate rows in layoffs_working2, leaving only the first instance of each duplicate group
DELETE FROM layoffs_working2
WHERE row_num > 1;

SELECT *
FROM layoffs_working2
WHERE row_num > 1;

SELECT *
FROM layoffs_working2;

-- standardizing the data
SELECT DISTINCT company, TRIM(company)
FROM layoffs_working2;

UPDATE layoffs_working2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_working2
ORDER BY 1;

SELECT *
FROM layoffs_working2
WHERE industry LIKE 'Crypto%';
-- Crypto, Crypto Currency, CryptoCurrency should be the same thing i.e Crypto

UPDATE layoffs_working2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_working2;

SELECT DISTINCT location
FROM layoffs_working2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_working2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_working2
ORDER BY 1;

UPDATE layoffs_working2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- change the date column from text to date type
SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_working2;

UPDATE layoffs_working2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_working2;

ALTER TABLE layoffs_working2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_working2;

-- null values
SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
AND funds_raised_millions IS NULL;
-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal

SELECT *
FROM layoffs_working2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_working2
WHERE company = 'Airbnb';
-- we can update the blank row industry to Travel since they are all under Airbnb company

SELECT *
FROM layoffs_working2 t1
JOIN layoffs_working2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL OR t1.industry = ''
AND t2.industry IS NOT NULL;

-- set the blanks to nulls
UPDATE layoffs_working2 t1
SET industry = NULL
WHERE industry = '';

-- -- now we need to populate those nulls 
SELECT t1.industry, t2.industry
FROM layoffs_working2 t1
JOIN layoffs_working2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_working2 t1
JOIN layoffs_working2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL; 

SELECT *
FROM layoffs_working2;

SELECT *
FROM layoffs_working2
WHERE company LIKE 'Bally%';

-- remove unnecessary columns and rows that won't help us in studying the data

SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- we delete these rows because we really don't need them 
DELETE FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_working2;

ALTER TABLE layoffs_working2
DROP COLUMN row_num;

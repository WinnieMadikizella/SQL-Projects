# SQL Data Cleaning Project – Layoffs Data

This project aims to clean a real-life layoff dataset using MySQL. The goal is to make the data consistent, reliable, and well-structured, ready for analysis.

## Dataset
The dataset `layoffs` contains information about global layoffs, including company names, industry, country, total laid-off, and more. The dataset used in this project is available in this repository: [layoffs_dataset.csv](./layoffs_dataset.csv)

## Cleaning Steps Performed
## 1. Create a Working Table
To preserve the raw dataset, we create a working table to apply all transformations:

```sql
-- Create a working table to avoid altering the original data
CREATE TABLE layoffs_working
LIKE layoffs;

INSERT layoffs_working
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_working;
```

## 2. Identify and Remove Duplicate Records
To detect duplicates based on key columns, we use `ROW_NUMBER()` with a window function:

```sql
-- identify duplicates by assigning a row_number partitioned by key columns
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_working;
```

```sql
-- use CTEs to select only duplicate rows (row_num > 1)
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
```

```sql
-- create a new table with row_num column
CREATE TABLE layoffs_working2 AS
SELECT *
FROM (
   SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
  `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_working) AS ranked;
SELECT *
FROM layoffs_working2;
```

```sql
-- removes duplicate rows in layoffs_working2, leaving only the first instance of each duplicate group
DELETE FROM layoffs_working2
WHERE row_num > 1;

```

## 3. Standardized textual data
   - Trimmed white spaces
     ```sql
     SELECT DISTINCT company, TRIM(company)
     FROM layoffs_working2;

     UPDATE layoffs_working2
     SET company = TRIM(company);
     ```
     
   - Standardized `industry` names (e.g., Crypto, Crypto Currency → Crypto)
     ```sql
     SELECT *
     FROM layoffs_working2
     WHERE industry LIKE 'Crypto%';
     -- Crypto, Crypto Currency, CryptoCurrency should be the same thing i.e Crypto

     UPDATE layoffs_working2
     SET industry = 'Crypto'
     WHERE industry LIKE 'Crypto%';
     ```
     
   - Removed trailing characters in `country`
     ```sql
     SELECT DISTINCT country
     FROM layoffs_working2
     ORDER BY 1;

     SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
     FROM layoffs_working2
     ORDER BY 1;

     UPDATE layoffs_working2
     SET country = TRIM(TRAILING '.' FROM country)
     WHERE country LIKE 'United States%';
     ```

## 4. Converted date columns from text to date format using `STR_TO_DATE`.
   ```sql
   SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
   FROM layoffs_working2;

   UPDATE layoffs_working2
   SET `date` = str_to_date(`date`, '%m/%d/%Y');

   SELECT `date`
   FROM layoffs_working2;

   ALTER TABLE layoffs_working2
   MODIFY COLUMN `date` DATE;
   ```
   
## 5. Handled null and blank values
   - Replaced blanks with NULLs
     ```sql
     UPDATE layoffs_working2 t1
     SET industry = NULL
     WHERE industry = '';
     ```

   - Imputed NULLs in `industry` using company matches
     ```sql
     UPDATE layoffs_working2 t1
     JOIN layoffs_working2 t2
        ON t1.company = t2.company
     SET t1.industry = t2.industry
     WHERE t1.industry IS NULL
     AND t2.industry IS NOT NULL;
     ```
     
## 6. Dropped unnecessary rows with no key information (e.g., all nulls in numeric columns).
```sql
SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- we delete these rows because we really don't need them 
DELETE FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
```

## 7. Dropped helper columns (`row_num`) after use.
```sql
ALTER TABLE layoffs_working2
DROP COLUMN row_num;
```

## SQL Highlights
- Utilization of window functions `ROW_NUMBER()`.
- The join-based imputation of missing values.
- Date conversion and type casting.
- Standardization of text with `TRIM()` and `LIKE`.


## Tech Stack - MySQL Workbench 

> This project demonstrates data cleaning as a foundational step before analysis or visualization. Clean data = Better insights!

-- Exploratory Data Analysis
USE world_layoffs;
SELECT *
FROM layoffs_working2;

-- date range
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_working2;
-- march 2020 to march 2023

-- maximum total laid off
SELECT MAX(total_laid_off), max(percentage_laid_off)
FROM layoffs_working2;
-- 12000 people corresponding to 100% laid off at once

-- total number of people laid off by company
SELECT company, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company
ORDER BY 2 DESC;
-- Amazon had the highest lay-offs at 18150 people, followed by Google at 12000

-- total number of people laid off by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY industry
ORDER BY 2 DESC;
/* Consumer at 45182 and Retail at 43616 were the most affected, while Fin-Tech and manufacturing had the least 
lay-offs at 215 and 20 respectively */

-- total number of people laid off by country
SELECT country, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY country
ORDER BY 2 DESC;
/* United States at 256559 and India at 35993 had the most number of layoffs */

-- Year with the most number of lay-offs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
/* 2023 with only 3 months of data the layoffs are already at 125677. 2022 had 160661 layoffs, 2021 at 15823 and 2020 had 80998 */

-- stage of the company
SELECT stage, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY stage
ORDER BY 2 DESC;
/* Post-IPO had the most layoffs at 204132 and also the ones at unknown stage had a significant number of layoffs at 40716 */

-- rolling totals of lay-offs
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_working2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

WITH rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_working2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, total_off, SUM(total_off) OVER (ORDER BY `month`) AS rolling_total
FROM rolling_total;
-- by March 2023 383159 people ad lost their jobs from 9628 jobs lost in March 2020

-- total number of people laid off by company per year
SELECT company, YEAR (`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company, YEAR (`date`)
ORDER BY 3 DESC;

WITH company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR (`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company, YEAR (`date`)
), company_year_rank AS
(SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL)
SELECT *
FROM company_year_rank
WHERE ranking <=5;

-- monthly patterns
SELECT MONTH(`date`) AS 'month', SUM(total_laid_off) AS total_layoffs
FROM layoffs_working2
GROUP BY MONTH(`date`)
ORDER BY total_layoffs DESC;
-- January had the highest number of lay-offs at 92037

-- lay-offs percentage analysis
SELECT company, percentage_laid_off, total_laid_off
FROM layoffs_working2
WHERE total_laid_off IS NOT NULL
ORDER BY percentage_laid_off DESC
LIMIT 10;
-- several companies had a 100% lay-offs and some even had less than 10 employees



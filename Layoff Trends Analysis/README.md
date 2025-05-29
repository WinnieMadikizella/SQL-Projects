# Global Tech Layoffs – SQL Exploratory Data Analysis

After finishing cleaning the layoffs data, I chose to explore the meaning of the data by telling the story through writing, not visualization, to see how the pandemic influenced the tech industry. The data covers layoffs happening from the outbreak of COVID-19 in March 2020 through March 2023, its peak period. That’s why we’ve given the article the title: Global Tech Layoffs.

## Project Context

The data was collected from March 2020 to March 2023, happening during the global COVID-19 pandemic. During this period, the pressure on tech companies was very high.
- Economic slowdown
- Problems in the flow of goods from one place to another
- The move to working from home
- Modifying how people make shopping decisions
- A huge surge in digital transformation

Because of this, there were many big changes, including companies laying off teams or stopping operations altogether.

## Dataset Overview

The dataset used for this project is available here: [layoffs_dataset.csv](layoffs_dataset.csv)

### Data Cleaning Script

Access the full SQL cleaning script here: [Data Cleaning in MySQL.sql](Data%20Cleaning%20in%20MySQL.sql)
 


## Exploratory Questions & Key Insights

### Date Range
```sql
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_working2;
-- Layoffs occurred between March 2020 to March 2023

```
### Highest Single Layoff Event
```sql
SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM layoffs_working2;
-- One company laid off 12,000 people, amounting to 100% of its workforce

```

###  Companies with the Most Layoffs
```sql
SELECT company, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company
ORDER BY 2 DESC;
-- Amazon had the highest lay-offs at 18150 people, followed by Google at 12000

```

### Layoffs by Industry
```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY industry
ORDER BY 2 DESC;
/* Consumer at 45182 and Retail at 43616 were the most affected, while Fin-Tech and manufacturing had the least 
lay-offs at 215 and 20 respectively */

```

### Layoffs by Country
```sql
SELECT country, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY country
ORDER BY 2 DESC;
/* United States at 256559 and India at 35993 had the most number of layoffs */

```

### Yearly Layoff Trends
```sql
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
/* 2023 with only 3 months of data the layoffs are already at 125677. 2022 had 160661 layoffs, 2021 at 15823 and 2020 had 80998 */

```

### Rolling Monthly Layoffs
```sql
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
/* By March 2023, cumulative layoffs reached 383,159, starting from just 9,628 in March 2020 */

```
### Layoffs by Company Stage
```sql
SELECT stage, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY stage
ORDER BY 2 DESC;
/* Post-IPO had the most layoffs at 204132 and also the ones at unknown stage had a significant number of layoffs at 40716 */

```
### Monthly Pattern of Layoffs
```sql
SELECT MONTH(`date`) AS 'month', SUM(total_laid_off) AS total_layoffs
FROM layoffs_working2
GROUP BY MONTH(`date`)
ORDER BY total_layoffs DESC;
-- January was the peak layoff month across all years: 92,037 layoffs

```
### Top 10 Companies with 100% Layoffs
```sql
SELECT company, percentage_laid_off, total_laid_off
FROM layoffs_working2
WHERE total_laid_off IS NOT NULL
ORDER BY percentage_laid_off DESC
LIMIT 10;
-- several companies had a 100% lay-offs and some even had less than 10 employees

```

## Conclusion
By using SQL, this analysis details how many layoffs there have been in the tech industry and when they occurred which helps stakeholders see which governments, companies and countries faced the most redundancies and how layoff numbers changed from when the pandemic started to now.

## Next Steps
1. Prepare Power BI dashboards for visualization
2. Review and analyze the emotions in news headlines about layoffs
3. Include predictive modeling (e.g. the chance of future layoffs)
4. Customize the dashboards so update every month.


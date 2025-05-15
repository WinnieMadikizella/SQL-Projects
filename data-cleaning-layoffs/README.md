# SQL Data Cleaning Project – Layoffs Data

This project aims to clean a real-life layoff dataset using MySQL. The goal is to make the data consistent, reliable, and well-structured, ready for analysis.

## Dataset

The dataset (`layoffs`) contains information about global layoffs, including company names, industry, country, total laid-off, and more. 
The database used is `world_layoffs`.

## 🔧 Cleaning Steps Performed

1. **Created a working copy of the raw table** to preserve original data.
2. **Removed duplicates** using `ROW_NUMBER()` and filtered them out.
3. **Standardized textual data**:
   - Trimmed white spaces
   - Standardized `industry` names (e.g., Crypto, Crypto Currency → Crypto)
   - Removed trailing characters in `country`
4. **Converted date columns** from text to date format using `STR_TO_DATE`.
5. **Handled null and blank values**:
   - Replaced blanks with NULLs
   - Imputed NULLs in `industry` using company matches
6. **Dropped unnecessary rows** with no key information (e.g., all nulls in numeric columns).
7. **Dropped helper columns** (`row_num`) after use.

## 📌 SQL Highlights

- Use of **window functions** (`ROW_NUMBER()`).
- **Join-based imputation** for missing values.
- **Date conversion and type casting**.
- **Text standardization** using `TRIM()` and `LIKE`.

## 🛠 Tech Stack

- SQL (MySQL 8.0)
- MySQL Workbench / any SQL IDE

## 🚀 How to Run

1. Clone the repository.
2. Load your database `world_layoffs` and import the raw `layoffs` table.
3. Run the `layoffs_data_cleaning.sql` script step-by-step to reproduce the cleaning process.

## 📈 Author

**Winnie Madikizella Akinyi**  
_Data & Business Intelligence Specialist_  
🔗 [LinkedIn](https://www.linkedin.com/in/your-profile)

---

> This project demonstrates data cleaning as a foundational step before analysis or visualization. Clean data = Better insights!

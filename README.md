# World_layoffs-Data-cleaning-and-EDA

## Overview

This project involves data cleaning and exploratory data analysis (EDA) on a dataset containing information about layoffs across various companies. The main objectives are to clean the data by removing duplicates, standardizing values, handling nulls, and then performing EDA to uncover insights regarding layoffs by industry, company, and year.

## Table of Contents

- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Installation](#installation)
- [Usage](#usage)

## Data Cleaning

Data cleaning is essential for preparing the dataset for analysis. Below are the steps taken in this project:

### 1. Removing Duplicates

First, we identify and remove duplicate records from the `layoffs_staging` table.

```sql
WITH duplicate_cte AS 
(
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, 
    percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
    FROM layoffs_staging
)
DELETE FROM duplicate_cte WHERE row_num > 1;
```

### 2. Standardizing Data

Next, we standardize the data by trimming whitespace and standardizing values in specific columns.

```sql
UPDATE layoffs_staging2 
SET company = TRIM(company);

UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';
```

### 3. Handling Null Values

We handle null and blank values by updating and removing entries as necessary.

```sql
UPDATE layoffs_staging2 
SET industry = NULL 
WHERE industry = '';

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```

### 4. Removing Unnecessary Columns

Finally, we drop any unnecessary columns that do not contribute to our analysis.

```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

## Exploratory Data Analysis

Once the data is cleaned, we proceed with exploratory data analysis to extract insights.

### Key Analysis Queries

1. **Total layoffs by company:**
   ```sql
   SELECT company, MAX(total_laid_off) AS people_laidoff 
   FROM layoffs_staging2
   GROUP BY company
   ORDER BY people_laidoff DESC;
   ```

2. **Sum of layoffs by industry:**
   ```sql
   SELECT industry, SUM(total_laid_off) 
   FROM layoffs_staging2
   GROUP BY industry
   ORDER BY 2 DESC;
   ```

3. **Rolling total layoffs by month:**
   ```sql
   WITH rolling_total AS 
   (
       SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off) AS total_off
       FROM layoffs_staging2
       WHERE SUBSTRING(date, 1, 7) IS NOT NULL
       GROUP BY month
       ORDER BY 1
   )
   SELECT month, total_off, SUM(total_off) OVER (ORDER BY month ASC) AS rolling_tot
   FROM rolling_total;
   ```

4. **Year-wise top 5 ranking of companies that laid off:**
   ```sql
   WITH company_year AS 
   (
       SELECT company, YEAR(date), SUM(total_laid_off)
       FROM layoffs_staging2
       GROUP BY company, YEAR(date)
   ), company_year_rank AS 
   (
       SELECT *, 
       DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS company_rank
       FROM company_year
       WHERE years IS NOT NULL
   )
   SELECT *
   FROM company_year_rank
   WHERE company_rank <= 5;
   ```

## Installation

1. Clone the repository to your local machine using:
   ```bash
   git clone https://github.com/yourusername/layoffs-data-analysis.git
   ```

2. Ensure you have the necessary database setup (MySQL or similar) and import the dataset into your database.

## Usage

- Run the SQL scripts in your database management tool to clean the data and perform the exploratory analysis.
- Modify the SQL queries as needed to explore different aspects of the dataset.

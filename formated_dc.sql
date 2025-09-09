-- proper formated pipeline 
-- same DB - clean code 


drop table if exists layoffs_staging ;
drop table if exists layoffs_staging2 ;

SELECT * FROM layoffs ; -- original uncleaned table

create table layoffs_staging like layoffs; -- create a staging table

insert layoffs_staging
select * from layoffs ; -- insert data from the table

select * from layoffs_staging;



-- ======================================================
-- LAYOFFS DATA CLEANING PIPELINE
-- Goal: Clean raw layoffs dataset into layoffs_cleaned
-- ======================================================

DROP TABLE IF EXISTS layoffs_cleaned;

-- ======================================================
-- STEP 1: Deduplicate
-- Remove exact duplicate records based on all meaningful columns
-- ======================================================
#creating a CTE to do the task
CREATE TABLE layoffs_cleaned AS
WITH deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, total_laid_off, industry,
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs
)
SELECT *
FROM deduped
WHERE row_num = 1;

-- ======================================================
-- STEP 2: Standardize text fields
-- Trim spaces, fix inconsistent names
-- ======================================================
UPDATE layoffs_cleaned
SET company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    stage = TRIM(stage),
    country = TRIM(TRAILING '.' FROM country);

-- Crypto variations
UPDATE layoffs_cleaned
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- Replace blanks with NULLs
UPDATE layoffs_cleaned
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_cleaned
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

-- ======================================================
-- STEP 3: Fix date column (convert from text to DATE)
-- ======================================================
UPDATE layoffs_cleaned
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_cleaned
MODIFY COLUMN `date` DATE;

-- ======================================================
-- STEP 4: Handle NULLs
-- Remove useless rows where both layoffs and percentage are NULL
-- ======================================================
DELETE
FROM layoffs_cleaned
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- ======================================================
-- STEP 5: Final cleanup
-- Drop helper column row_num
-- ======================================================
ALTER TABLE layoffs_cleaned
DROP COLUMN row_num;

-- ======================================================
-- STEP 6: Verification
-- Row counts before vs after cleaning
-- ======================================================
SELECT 'Raw layoffs' AS dataset, COUNT(*) AS total_rows FROM layoffs
UNION
SELECT 'Cleaned layoffs', COUNT(*) FROM layoffs_cleaned;

-- Check industries
SELECT DISTINCT industry FROM layoffs_cleaned ORDER BY industry;

-- Check countries
SELECT DISTINCT country FROM layoffs_cleaned ORDER BY country;

-- Final  cleaned table 
 SELECT *  from layoffs_cleaned;

select count(*) from layoffs;
select count(*) from layoffs_cleaned;
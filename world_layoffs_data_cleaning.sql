SELECT *
FROM layoffs.layoffs; 

 -- 1. Remove Duplicates
 -- 2. Standardize the data
 -- 3. Null or Blank Values 
-- 4. Remove any unnecessary columns 

USE layoffs; 

CREATE TABLE layoffs_staging
LIKE layoffs; 

SELECT * 
FROM layoffs_staging ;

INSERT layoffs_staging 
SELECT * 
FROM layoffs; 

-- 1. Remove Duplicates (Row Number)
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) row_num
FROM layoffs_staging ; 


WITH DUPLICATE_CTE AS (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) row_num
FROM layoffs_staging 
)

SELECT * FROM DUPLICATE_CTE 
WHERE row_num > 1; 

SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;


INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) row_num
FROM layoffs_staging ; 

SET SQL_SAFE_UPDATES = 0;


DELETE  
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2 ;


-- 2. Standardizing data 

SELECT company, TRIM(company) 
FROM layoffs_staging2 ;

UPDATE layoffs_staging2
SET company = TRIM(company); 

SELECT DISTINCT industry 
FROM layoffs_staging2 
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%' ; 

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1; 

SELECT * 
FROM layoffs_staging2;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) 
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%' ;


SELECT 
`date`
,str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y'); 

SELECT 
`date`
FROM layoffs_staging2; 

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;

SELECT * 
FROM layoffs_staging2 ; 

-- 3. Remove Null and Blank values 

SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT * 
FROM layoffs_staging2 
WHERE company = 'Airbnb'; 

SELECT t1.industry, t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company 
    AND t1.location = t2.location 
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL ; 

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL ; 

SELECT * 
FROM layoffs_staging2; 

-- 4. Remove Uneccessary Columns/Rows
SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

SELECT * 
FROM layoffs_staging2; 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num; 
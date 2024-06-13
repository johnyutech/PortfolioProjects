USE layoffs;

SELECT * FROM layoffs_staging2 ; 

SELECT 
 MAX(total_laid_off)
,MAX(percengtage_laid_off)
FROM layoffs_staging2 ; 

SELECT * 
FROM layoffs_staging2 
WHERE 1=1 
AND percentage_laid_off = 1
AND funds_raised_millions IS NOT NULL 
ORDER BY funds_raised_millions; 

-- TOTAL LAID OFF BY INDUSTRY 
SELECT
 industry
,SUM(total_laid_off) "total_laid_off"
FROM layoffs_staging2
GROUP BY industry 
ORDER BY 2 DESC ;  

-- TOTAL LAID OFF BY COUNTRY 
SELECT
 country
,SUM(total_laid_off) "total_laid_off"
FROM layoffs_staging2
GROUP BY country 
ORDER BY 2 DESC ;  

-- TOTAL LAID OFF BY DATE 
SELECT * FROM layoffs_staging2; 

-- TOTAL LAID OFF BY YEAR 
SELECT
 YEAR(`date`)	
,SUM(total_laid_off) "total_laid_off"
FROM layoffs_staging2
GROUP BY YEAR(`date`) 
ORDER BY 1 DESC ;

-- TOTAL LAID OFF BY MONTH 
SELECT 
 SUBSTRING(`date`,1,7) AS `month` 
,SUM(total_laid_off)
FROM layoffs_staging2  
WHERE SUBSTRING(`date`,1,7) IS NOT NULL 
GROUP BY `month`
ORDER BY 1 ASC ; 

WITH ROLLING_TOTAL_CTE AS (
SELECT 
 SUBSTRING(`date`,1,7) AS `month` 
,SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2  
WHERE SUBSTRING(`date`,1,7) IS NOT NULL 
GROUP BY `month`
ORDER BY 1 ASC
)

SELECT 
 `month` 
,total_laid_off 
,SUM(total_laid_off) OVER(ORDER BY `month`) AS rolling_total
FROM ROLLING_TOTAL_CTE
; 
-- TOTAL LAID OFF BY COMPANY / YEAR 
SELECT
 company
,YEAR(`date`) 
,SUM(total_laid_off) "total_laid_off"
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 desc;  

-- CREATE COMPANY YEAR CTE TO RANK COMPANIES BY TOTAL LAID OFF
WITH COMPANY_YEAR (company,years,total_laid_off) AS (
SELECT
 company
,YEAR(`date`) 
,SUM(total_laid_off) "total_laid_off"
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
-- CREATE RANKING CTE TO SEE WHICH COMPANIES LAID OFF THE MOST BY YEAR 
, 
COMPANY_YEAR_RANK AS (
SELECT 
 *
,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) "ranking" 
FROM COMPANY_YEAR 
WHERE 1=1 
AND years IS NOT NULL
) 

SELECT * 
FROM COMPANY_YEAR_RANK 
WHERE 1=1 
AND ranking <= 5; 
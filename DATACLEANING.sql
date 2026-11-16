

-- DATA CLEANING 

SELECT  *
FROM layoffs;

-- 1.Remove duplicates
-- 2.Standardize the data (ISSUES OF THE DATA WITH SPELLINGS)
-- 3.Null values or blank values
-- 4.Remove any  Columns 




CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM  layoffs_staging;

INSERT layoffs_staging
SELECT*
FROM layoffs;
# why we do this : since we are going to change alot of the staging data , to avoid making mistakes in the original data table , we make a copy of it , so that if we make a mistake on the copy we can go back to the original data 

-- 1.Remove duplicates
-- search for non duplicates and combine them as row number


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry, total_laid_off,percentage_laid_off, 'date', stage , country, funds_raised_millions) AS row_num
FROM  layoffs_staging;

WITH duplicates_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry, total_laid_off,percentage_laid_off, 'date', stage , country, funds_raised_millions) AS row_num
FROM  layoffs_staging
)


-- DELETE ALL DUPLICATES

SELECT *
FROM duplicates_cte
WHERE row_num > 1;








WITH duplicates_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry, total_laid_off,percentage_laid_off, 'date', stage , country, funds_raised_millions) AS row_num
FROM  layoffs_staging
)


DELETE
FROM duplicates_cte
WHERE row_num > 1; 











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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



SELECT *
FROM  layoffs_staging2;



INSERT INTO  layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry, total_laid_off,percentage_laid_off, 'date', stage , country, funds_raised_millions) AS row_num
FROM  layoffs_staging;




SELECT *
FROM  layoffs_staging2
WHERE row_num>1 ;





DELETE 
FROM  layoffs_staging2
WHERE row_num>1 ;


SELECT *
FROM layoffs_staging2;


-- STANDARDIZING DATA

SELECT company,TRIM(company)
FROM layoffs_staging2;




UPDATE layoffs_staging2
SET company = TRIM(company);    -- trim takes the white space  of the start and the end




SELECT DISTINCT industry  -- distinct to give the different results like industries without over duplicate it  EVEN IF THEY HAVE THE SAME MEANING AS LONG AS THEY ARE DIFFERENT IN TERMS OF TITLE
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';



SELECT DISTINCT country , TRIM(TRAILING '.'FROM country) AS TRIM  -- TRAILING MEANS TO REMOVE THE COMING AT THE END 
FROM layoffs_staging2
ORDER BY 1;


SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2;



-- CHANGE THE TYPE OF DATE FROM TEXT TO DATE COLUMN (TIME SERIES)




SELECT  `date`
FROM layoffs_staging2;





UPDATE layoffs_staging2
SET `date`= STR_TO_DATE( `date`,'%m/%d/%Y');


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Null values or blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off is null
 and percentage_laid_off is null;
 
 
 UPDATE layoffs_staging2
 set industry = null
 WHERE industry= '';
 
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry='';



SELECT *
FROM layoffs_staging2
WHERE company='Airbnb';


SELECT t1.industry ,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON  t1.company = t2.company
    AND t1.location = t2.location
WHERE  (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;



UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON  t1.company = t2.company
SET t1.industry =  t2.industry
WHERE  t1.industry IS NULL 
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND  percentage_laid_off  IS NULL;






DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND  percentage_laid_off  IS NULL;



SELECT *
FROM layoffs_staging2;

-- drop column frommthe table that we don't need it anymore


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

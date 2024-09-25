-- DATA CLEANING --

SELECT * 
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Stardardize the Data (Finding issues in your data and fixing it)
-- 3. Null values and Blank values
-- 4. Remove any column or rows


CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- 1. Remove Duplicates

WITH duplicate_cte AS 
(
SELECT * , ROW_NUMBER () 
OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off, `date`,stage,country,funds_raised_millions ) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


# OUTCOME- 5 are duplicates But because we cannot delete the data directly in mysql we will create staging2 table
# and put row_num  as a column and then we will remove the duplicates

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


INSERT INTO layoffs_staging2
SELECT * , ROW_NUMBER () 
OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off, `date`,stage,country,funds_raised_millions ) as row_num
FROM layoffs_staging;  

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

#Duplicates are deleted.


-- 2. Stardardize the Data 

# Company Column.  
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


# Country Column.
SELECT DISTINCT country, TRIM(TRAILING "." FROM country)
FROM  layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING "." FROM country)
WHERE country LIKE "United States%";


# Industry Column 
SELECT DISTINCT industry
FROM  layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%"; 


# Date Column 
SELECT `date`, str_to_date(`date`, "%m/%d/%Y")
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET `date`= str_to_date(`date`, "%d/%m/%Y");

	#changing data type
    ALTER TABLE  layoffs_staging2
    MODIFY COLUMN `date` DATE;
    

-- 3. Null values and Blank values

# Industry Column
SELECT * FROM  layoffs_staging2
WHERE industry IS NULL
OR industry ='';
 
SELECT *
FROM layoffs_staging2 t1 
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    WHERE (t1.industry IS NULL OR t1.industry  ='')
    AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
jOIN layoffs_staging2 t2
	ON t1.company = t2.company
	SET t1.industry = t2.industry
	WHERE t1.industry IS NULL 
	AND t2.industry IS NOT NULL;
    
-- 4. Remove any unnecessary column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_staging2;
#row_num column removed


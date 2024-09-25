SELECT * FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 
# maximum layoffs by a company is 12000 and also % of layoffs is 1 which means almost 100.

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1 
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
# Top Companies globally known had the most number of layoffs

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
# From early 2020 to early 2023 these layoff happened which implies that coronavirus
# has effected alot of companies during this period.

SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
# Top 2 industries which is consumer and retail had the most layoffs during this period.


SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
# United States, India and Netherlands are the top three countries with the most layoffs.

SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
# year 2022 had the most number of layoffs followed by 2023.



SELECT SUBSTRING(`date`,1,7) `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) `MONTH`, SUM(total_laid_off) t_laidoff
FROM layoffs_staging2
	WHERE SUBSTRING(`date`,1,7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1 
) 
SELECT `MONTH`, t_laidoff,
SUM(t_laidoff) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
# comparison between sum of laid off and Rolling total laid off month wise.

SELECT company, substring(`date`,1,4) AS `Years`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `Years`
ORDER BY 3 DESC;

WITH Company_Year (company,Years,Total_laid_off) AS
(
SELECT company, substring(`date`,1,4) AS `Years`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `Years`
)
, Company_Year_Rank AS(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY `Years` ORDER BY total_laid_off DESC ) AS Ranking
FROM Company_Year 
WHERE Years  IS NOT NULL
)
SELECT *
FROM Company_Year_Rank 
WHERE Ranking <= 5;
# Top 5 Companies in each year having the highest layoffs.

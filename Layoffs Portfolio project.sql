-- Data cleaning
USE world_layoffs;
SELECT *
FROM layoffs;

-- 1. Remove duplicates

	-- Create copys
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

	-- Check for duplicates
WITH duplicate_cte AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, stage, country, `date`) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

	-- Remove duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text DEFAULT NULL,
  `location` text DEFAULT NULL,
  `industry` text DEFAULT NULL,
  `total_laid_off` int(11) DEFAULT NULL,
  `percentage_laid_off` text DEFAULT NULL,
  `date` text DEFAULT NULL,
  `stage` text DEFAULT NULL,
  `country` text DEFAULT NULL,
  `funds_raised_millions` int(11) DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, stage, country, `date`) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num >1;

DELETE FROM layoffs_staging2
WHERE row_num >1;

SELECT *
FROM layoffs_staging2;

-- 2. Standardize the data

	-- Looking at company
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

	-- Looking at industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

	-- Looking at country
SELECT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE '%States.%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%States.%';

	-- Set the format for date
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date;

-- 3. Null values or blank values

	-- Looking at total_laid_off and percentage_laid_off
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

	-- Looking at industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT ls1.industry, ls2.industry
FROM layoffs_staging2 ls1
JOIN layoffs_staging2 ls2
ON ls1.company = ls2.company 
WHERE (ls1.industry IS NULL OR ls1.industry = '') AND ls2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 ls1
JOIN layoffs_staging2 ls2
ON ls1.company = ls2.company 
SET ls1.industry = ls2.industry
WHERE ls1.industry IS NULL AND ls2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- 4. Remove any columns or rows

	-- Remove row_num
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

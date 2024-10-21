-- Exploratory Data Analysis

select * From layoffs_staging2;

select company,max(total_laid_off) as people_layedoff, max(percentage_laid_off)
from layoffs_staging2
group by company
order by people_layedoff desc;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

select company,sum(total_laid_off) 
from layoffs_staging2
group by company
order by 2 desc;

select Industry,sum(total_laid_off) 
from layoffs_staging2
group by 1
order by 2 desc;

select Country,sum(total_laid_off) 
from layoffs_staging2
group by 1
order by 2 desc;

select year(date),sum(total_laid_off) 
from layoffs_staging2
group by 1
order by 1 desc;

select stage,sum(total_laid_off) 
from layoffs_staging2
group by 1
order by 2 desc;

select Company,(percentage_laid_off)*100
from layoffs_staging2
group by 1,2
order by 2 desc;

-- Rolling total layyoffs
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_laid_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 ;

with rolling_total as 
(select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1
)
select `month`,total_off, sum(total_off) over (order by `month` asc) as rolling_tot
from rolling_total;

-- Ranking companies according to the layoffs in a year
select Company,year(`date`), sum(total_laid_off)
from layoffs_staging2
group by 1,2
order by 3 desc;

-- Year wise top 5 ranking of companies that laidoff

with company_year (company,years, total_laid_off) as
(select Company,year(`date`), sum(total_laid_off)
from layoffs_staging2
group by 1,2
), company_year_rank as 
(select *, 
dense_rank() over (partition by years order by total_laid_off desc) as company_rank
from company_year
where years is not null)
select *
from company_year_rank
where company_rank <= 5;



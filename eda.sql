-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- EDA - exploring the data trends 
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

select * from layoffs_cleaned ;

-- Attributes 
-- company,location,industry,country,stage
-- total_laid_off, percentage_laid_off, funds_raised_millions 
-- date - time series analysis

-- maximun layoffs (company wise)
#Q- top 10 companies that laid off maximum employees

select company,sum(total_laid_off) as total_laid from layoffs_cleaned 
group by company
order by total_laid desc limit 10 ;
-- ========================================================================
-- maximun layoffs (country wise)
#Q- top 10 counries that laid off maximun number of people 
select country,sum(total_laid_off) as total_laid from layoffs_cleaned
group by country 
order by total_laid desc  limit 10 ;
-- =======================================================================
#Q - least number of employees laid off by which country
select country,sum(total_laid_off) as total_laid , sum(percentage_laid_off)
from layoffs_cleaned
group by country 
order by total_laid asc 
limit 10 ;
-- we get null values for the top 8 countries but 
-- this is not possible as we can see that there is some percentage of layoff
-- we just do not have the numbers 
-- ==========================================================================
-- maximun layoffs (industry wise)
#Q- top 10 industries that laid off maximun/minimun number of people

select industry , sum(total_laid_off) as total_laid from layoffs_cleaned
group by industry
order by total_laid desc limit 10
;
select industry , sum(total_laid_off) as total_laid from layoffs_cleaned
group by industry
order by total_laid asc limit 10 ;
-- ===========================================================================
#Q- maximun laid_off at once 

select max(total_laid_off) laid_off from layoffs_cleaned;

select company from layoffs_cleaned
where total_laid_off = 12000;
-- ============================================================================
#Q- comapnies that laid off 100% off the force - basically that shut down

select company ,percentage_laid_off from layoffs_cleaned
where percentage_laid_off=1 ;

-- whe want to see jow many funds did these comapaies raised 
select company ,funds_raised_millions,percentage_laid_off,`date` from layoffs_cleaned
where percentage_laid_off=1 
order by funds_raised_millions desc;

-- the above querygives us the name of the comapnies that have raised funds but also been shut down .for

-- =============================================================================
 #Q- find the date range of the data 
 
select min(`date`),max(`date`) from layoffs_cleaned ;
-- the range of the data is for march 2020 - march 2023 ( 3 years )
 
#Q - how many companies laid off in which year/ how many people were laid_off
 
select year(`date`),sum(total_laid_off) from layoffs_cleaned
group by year(`date`) ;

select year(`date`),count(company) num_company_laid_off from layoffs_cleaned
group by year(`date`) 
order by num_company_laid_off desc;

-- maximum layoffs occured during the year 2022, approx 1030 companies accross the globe laid of about 160661 employees 
-- minimun layoff occured during the year 2021,approx 35 companies accross the globe laid of about 15823 employees
-- as the data is only for 3 monts for 2023, 2023 will be expected to ahve the highest layoff so far in near futute as for only 3 months it is about 125677 
-- baiscally , th  layoff is increasing year by year from 2020 to 2023, just a slight diff in 2021 the people laid off were bery less as compared to the past year .

-- =======================================================================================
#Q- explore the stage of the compnaies that laid off 

select stage, sum(total_laid_off) from layoffs_cleaned
group by stage order by 2 desc;
-- max layoff occured in the comapnaies that were the in the post-IPO stage

-- ================================================================================
-- ROLLING SUM - month wise 

select substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as laid_off from layoffs_cleaned
where substring(`date`,1,7) is not null
group by `MONTH` order by 1 ;
-- per month lay off count

#Q- rolling total month by month 

with rolling_total as
(
select substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as laid_off from layoffs_cleaned
where substring(`date`,1,7) is not null
group by `MONTH` order by 1 
)
select `MONTH`,laid_off , sum(laid_off) over(order by `month` asc) rolling_total from rolling_total;

-- total of 3,83,158 employees have been laid off during the 3 years 
-- =============================================================================================

#Q - how many layoff per year company wise 

select company , sum(total_laid_off) , year(`date`)  from layoffs_cleaned 
group by company,year(`date`) order by year(`date`)  ;

-- which year maximum layoffs occured by each comapany

select company , year(`date`),sum(total_laid_off)  from layoffs_cleaned 
group by company,year(`date`) order by sum(total_laid_off)  desc ;

-- now we rank these companies

with company_year(company, sum , years )as 
(
select company , sum(total_laid_off) , year(`date`) from layoffs_cleaned 
group by company,year(`date`) order by year(`date`) 
)
select *, 
dense_rank() over(partition by years order by sum desc) from company_year AS Ranking 
where years is not null
order by dense_rank() over(partition by years order by sum desc) ASC ;

-- the above gives us the company that laid off maximun employees year wise

-- =======================================================================================
-- more adv - cte 

with company_year(company, sum , years )as 
(
select company , sum(total_laid_off) , year(`date`) from layoffs_cleaned 
group by company,year(`date`) order by year(`date`) 
), company_rank as (
select *, 
dense_rank() over(partition by years order by sum desc) Ranking  from company_year 
where years is not null
order by Ranking ASC
)
select * from company_rank 
where Ranking <=5 order by years asc 
;
-- this will give the top 5 companies that laid_off maximun employees year wise 









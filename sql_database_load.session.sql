
-- date and time functions
SELECT job_title_short as title,
job_location as location,
job_posted_date :: DATE  as date
from job_postings_fact
LIMIT 10;

SELECT job_title_short as title,
job_location as location,
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' as date_time
from job_postings_fact
LIMIT 10;

SELECT job_title_short as title,
job_location as location,
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
EXTRACT( MONTH FROM job_posted_date) as date_month
FROM job_postings_fact
LIMIT 10;

/* practice problem*/
SELECT count(job_id) as job_distribution, 
EXTRACT(MONTH from job_posted_date) as date_month
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
group by date_month
order by job_distribution desc
LIMIT 10;

/* practice problem*/
SELECT job_schedule_type,
AVG(salary_year_avg) AS avg_year_salary,
AVG(salary_hour_avg) AS avg_hour_salary
from job_postings_fact
where job_posted_date > '2023-06-01 00:00:01'
group by job_schedule_type;

/* practice problem*/
SELECT COUNT(job_id) as job_distribution,
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'WAT' AS date_time,
EXTRACT(MONTH FROM job_posted_date) as date_month
from job_postings_fact
group by date_month
order by date_month
LIMIT 10;

/* practice problem*/
SELECT job_via,
EXTRACT (MONTH FROM job_posted_date) as date_month
from job_postings_fact
where (job_health_insurance is TRUE) and (job_posted_date between  '2023-05-01 00:00:01' and '2023-08-31 23:59:59')
order by date_month desc

/* practice problem* CREATING_TABLES*/

CREATE TABLE january_jobs AS 
    SELECT *
    from job_postings_fact
    where EXTRACT (MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    from job_postings_fact
    where EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE March_jobs AS
    SELECT *
    from job_postings_fact
    where EXTRACT(MONTH FROM job_posted_date) = 3;


SELECT job_posted_date
from March_jobs


/*CASE STATEMENTS*/
SELECT COUNT(job_id) as no_of_jobs,
CASE
WHEN job_location = 'Anywhere' then 'Remote'
when job_location = 'New York, NY' then 'Local'
ELSE 'Onsite'
END AS Location_status
from job_postings_fact
WHERE job_title_short = 'Data Analyst'
group by Location_status

/*practice problem*/
SELECT avg(salary_year_avg) as avg_annual_salary,
count(job_id) as no_of_jobs,
CASE
WHEN salary_year_avg > '100000' then 'high'
when salary_year_avg between '50000' and '100000' then 'standard'
when salary_year_avg <'50000' then 'low'
ELSE 'other'
END as salary_range
FROM job_postings_fact
where job_title_short = 'Data Analyst' and job_location = 'New York, NY'
group by salary_range


/*SUB-QUERIES AND CTE'S*/
with main_cte as
(
SELECT a.job_id, b.company_id, b.name
from job_postings_fact a
right join company_dim b
on a.company_id = b.company_id
)
 
 select name, count(job_id) as job_distribution
 from main_cte
group by name
order by job_distribution desc

-- PRACTICE PROBLEM 
with sub_query as 
(
SELECT a.job_id, a.skill_id, b.skills, b.type
from skills_job_dim a
right join skills_dim b
on a.skill_id = b.skill_id

)


SELECT  skills, count( skill_id) as frequency
from sub_query
group by skills
order by frequency desc

-- 2
with main_cte as 
(
select job_via, count(job_id) as jobs
from job_postings_fact
group by job_via
order by jobs desc
)
 SELECT *,
 case 
 when jobs < '10' then 'Small' 
 when jobs  between '10 and 50' then 'Medium'
 when jobs > '50' then 'Large'
 ELSE 'other'
 end as job_stratification
 from main_cte
 group by job_stratification
 order by jobs

with main_cte AS
(
SELECT COUNT(*) AS jobs,
b.skill_id
FROM skills_dim a
left join skills_job_dim b
on a.skill_id = b.skill_id
right join job_postings_fact c
on b.job_id = c.job_id
WHERE job_work_from_home = 'TRUE' and job_title_short = 'Data Analyst'
group by b.skill_id

)
select jobs, d.skill_id, skills
from main_cte
inner join skills_dim d
on d.skill_id = main_cte.skill_id
order by jobs desc
limit 5


-- UNION AND UNION ALL
with quarter_1_job_postings as 
(select *
from january_jobs
union ALL
select *
from february_jobs
union ALL
select *
from March_jobs
)

select job_title_short, job_posted_date :: date, job_via, salary_year_avg
from quarter_1_job_postings
where salary_year_avg > 70000 and job_title_short = 'Data Analyst'
order by salary_year_avg desc

/* NUMBER 1*/
select job_id, job_title_short, job_via, job_work_from_home, salary_year_avg
from job_postings_fact
where job_title_short = 'Data Analyst' and salary_year_avg > 70000
order by salary_year_avg desc

-- 2
WITH TOP_JOBS AS
(
select job_id, job_title_short, job_via, job_work_from_home, salary_year_avg
from job_postings_fact
where job_title_short = 'Data Analyst' and salary_year_avg > 70000
order by salary_year_avg desc
)
SELECT job_title_short, c.skills, salary_year_avg
FROM TOP_JOBS a 
inner join skills_job_dim b
on a.job_id = b.job_id
inner join skills_dim c
on b.skill_id = c.skill_id



select count (a.skill_id) as skill_count, skills
from skills_job_dim a
inner join job_postings_fact b
on a.job_id = b.job_id
inner join skills_dim c 
on a.skill_id = c.skill_id
group by skills 
order by skill_count desc


select *
from job_postings_fact a
inner join top_skills b
on a.job_id = b.job_id








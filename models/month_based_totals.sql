{{ config(materialized='table') }}

with date_based_totals as (
	select
	date,
	concat(MONTHname(cast(DATE as date)),' ',cast(year(cast(DATE as date)) as varchar(5))) monthvalue,
	concat(cast(year(cast(DATE as date)) as varchar(5)),' - week ',WEEKOFYEAR(cast(DATE as date))) weekvalue,
	TOTAL_CASES,
	TOTAL_DEATHS,
	TOTAL_RECOVERED
	from "FIVETRAN_INTERVIEW_DB"."GOOGLE_SHEETS"."COVID_19_INDONESIA_VAIBHAV_MAHAJAN"
    where LOCATION_LEVEL = 'Country'
),
last_monthdays as (
	select
	monthvalue,
	max(cast(DATE as date)) as last_monthday
	from date_based_totals
	group by monthvalue
),
month_based_totals as (
	select
	dbt.monthvalue,
	sum(dbt.TOTAL_CASES) as TOTAL_CASES_mth,
	sum(dbt.TOTAL_DEATHS) as TOTAL_DEATHS_mth,
	sum(dbt.TOTAL_RECOVERED) as TOTAL_RECOVERED_mth
	from date_based_totals dbt
	join last_monthdays lm
	 on dbt.monthvalue = lm.monthvalue
	and dbt.date = lm.last_monthday
	group by dbt.monthvalue
)
select * from month_based_totals
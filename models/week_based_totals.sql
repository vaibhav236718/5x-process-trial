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
last_weekdays as (
	select
	weekvalue,
	max(cast(DATE as date)) as last_weekday
	from date_based_totals
	group by weekvalue
),
week_based_totals as (
	select
	dbt.weekvalue,
	sum(dbt.TOTAL_CASES) as TOTAL_CASES_wk,
	sum(dbt.TOTAL_DEATHS) as TOTAL_DEATHS_wk,
	sum(dbt.TOTAL_RECOVERED) as TOTAL_RECOVERED_wk
	from date_based_totals dbt
	join last_weekdays lw
	 on dbt.weekvalue = lw.weekvalue
	and dbt.date = lw.last_weekday
	group by dbt.weekvalue
)
select * from week_based_totals
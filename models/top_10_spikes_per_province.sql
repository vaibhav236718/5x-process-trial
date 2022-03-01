{{ config(materialized='table') }}

with top_10_spikes_per_province as (
	select
    row_number() over (partition by LOCATION order by cast(NEW_CASES as float) desc) as row_number,
	cast(DATE as date) as date_val,
	LOCATION,
	NEW_CASES
	from "FIVETRAN_INTERVIEW_DB"."GOOGLE_SHEETS"."COVID_19_INDONESIA_VAIBHAV_MAHAJAN"
	where LOCATION_LEVEL = 'Province'
)
select date_val, LOCATION, NEW_CASES  from top_10_spikes_per_province where row_number <=10
-- with df as (
-- SELECT role_id,"#event_Time","stage_id","sub_stage_id","choose_skills"
-- ,concat(
--         cast(json_extract(skills_group, '$["1"]') as varchar)
--         ,','
--         ,cast(json_extract(skills_group, '$["2"]')as varchar)
--         ,','
--         ,cast(json_extract(skills_group, '$["3"]')as varchar)
--         )skills_group
-- FROM v_event_15 
-- WHERE "$part_event"='select_skills' 
-- AND "$part_date"='2026-02-04' 
-- LIMIT 10
-- )
-- SELECT *, col
-- FROM (select *, split(skills_group,',') as numbers_array from df)
-- CROSS JOIN UNNEST(numbers_array) as temp_table(col)


with tmp as (
select 
    role_id
    ,"#event_time"
    ,stage_id
    ,sub_stage_id
    ,choose_skills
    ,concat(cast(json_extract(skills_group,'$.1') as varchar),','
           ,cast(json_extract(skills_group,'$.2') as varchar),','
           ,cast(json_extract(skills_group,'$.3') as varchar)
           )skills_group
from ta.v_event_15
where "$part_event" = 'select_skills'
    and "$part_date" >= '2026-02-03'
    )
    
select *
from(select *,split(skills_group,',') as number_array from tmp)
cross join unnest (number_array) as temp_table(col)

array_agg(choose_skills) over(partition by role_id,stage_id,sub_stage_id order by "#event_time") as choose_skills_array


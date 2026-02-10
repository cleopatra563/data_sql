with stage_log as(
select
role_id,"#event_time","$part_date",stage_id,round_id,fight_result,"$part_event"
,row_number() over(partition by "$part_date",role_id order by "#event_time" ) as rn
from ta.v_event_15 
where ${PartDate:date} 
    and "$part_event" in ('main_stage_end')
    
)

-- 每个玩家，stage round 挑战次数
-- select role_id,stage_id,round_id,count(*) as challenge_cnt
-- from stage_log
-- where fight_result is not null
-- group by 1,2,3
-- having count(*) >=2

-- select  
--     count(*)filter(where fight_result = 1)  as "成功次数"      
--     ,count(*)filter(where fight_result = 2) as "失败次数"     
-- from(
--     select *
--     from stage_log
--     where role_id in ('US100172') 
--         and round_id in (1010010200502)
--     )a
-- group by role_id,stage_id,round_id

select *
from stage_log
where role_id in ('US100172') 
    and round_id in (1010010200502)

count(*) filter(where fight_result = 1) as "成功次数"
sum(case when fight_result = 1 then 1 else 0 end) as "成功次数"

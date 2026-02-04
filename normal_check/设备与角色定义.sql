
select 
    count(distinct "#device_id") as device_num
    ,count(distinct role_id) as role_num
    ,count(distinct "#uuid") as uuid_num
    ,count(distinct "#account_id") as account_num
    ,count(distinct "#user_id") as user_num
    ,count(distinct "#distinct_id") as distinct_num
from ta.v_event_15
where "$part_date" = '2026-02-03'

select 
    "#device_id"
    ,count(*) as 
from ta.v_event_15
where "$part_date" = '2026-02-02'
-- 算占比 nullif(,0)
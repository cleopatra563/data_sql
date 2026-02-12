-- 转换到美国东部时区EST
select     
    role_id
    ,"#event_time"
    ,"#event_time" at time zone 'UTC' at time zone 'America/New_York' as check_utc5
    ,at_timezone("#event_time",'America/New_York') as local_time
    ,hour(at_timezone("#event_time",'America/New_York')) as local_hour
from ta.v_event_15    
where "$part_date" = '2026-02-10'
    and "$part_event" in ('enter_game')
    and "#country" in ('美国')
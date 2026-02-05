-- with time_conf as (select '2026-02-03 16:50:00.000' as conf)
-- ,df1 as (
--         select role_id,reg_date,reg_time,"#device_id"device_id 
--         ,"#country"reg_country
--         ,"#zone_offset"zone_offset
--         ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST((("#zone_offset"-8) * 3600) AS integer), reg_time), reg_time)reg_local_time
--         ,cast(IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST((("#zone_offset"-8) * 3600) AS integer), reg_time), reg_time) as date)reg_local_date
--         from  
--             (
--             SELECT role_id,"$part_date"reg_date,"#event_time"reg_time
--             ,row_number()over(partition by role_id order by "#event_time")rn
--             ,"#device_id"
--             ,"#country"
--             ,"#zone_offset"
--             FROM ta.v_event_15
--             WHERE "$part_date" >= '2026-02-02'
--             and "#event_time" >= (select cast(conf as timestamp) from time_conf)
--             and "$part_event" = 'enter_game'
--             and role_id is not null
--             and role_id != ''
--             and "#distinct_id" != 'test'
--             )t    
--         where rn = 1 
--         )
        
        
-- select role_id,reg_country 
-- from  
-- df1

with time_config as(
    select '2026-02-03 16:50:00.000' as conf
)
,base as (
select *
      ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST((("#zone_offset"-8) * 3600) AS integer), reg_time), reg_time) as reg_local_time
      ,cast(IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST((("#zone_offset"-8) * 3600) AS integer), reg_time), reg_time) as date) as reg_local_date
from (
    select 
        "#device_id" as device_id
        ,"#event_time" as reg_time 
        ,"$part_date" as reg_date
        ,"#zone_offset"
        ,"#country"country
        ,row_number() over(partition by "#device_id" order by "#event_time") as rn
    from ta.v_event_15
    where "$part_date" >= '2026-02-02'
        and "#event_time" >= (select cast(conf as timestamp)from time_config)
        and "$part_event" in ('enter_game','item_change','guide')
        and "#distinct_id" != 'test'
    ) a     
where rn = 1
)

select device_id,country 
from base 

select device_id,reg_time 
from base   

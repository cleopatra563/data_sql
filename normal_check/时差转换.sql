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

with us_log_time as(
-- 每小时登录
select "$part_date","#country",hour("#event_time") as hour,count(distinct role_id) as active
from ta.v_event_15    
where "$part_date" = '2026-02-10'
    and "$part_event" in ('enter_game')
    and "#country" in ('美国')
group by 1,2,3
order by 3 asc
)


-- 转换到美国东部时区EST
select local_date,local_hour,count(distinct role_id) as acitve_user
from(
    select     
        role_id
        ,"#event_time"
        ,"#event_time" at time zone 'UTC' at time zone 'America/New_York' as check_utc5
        ,at_timezone("#event_time",'America/New_York') as local_time
        ,hour(at_timezone("#event_time",'America/New_York')) as local_hour
        ,date(at_timezone("#event_time",'America/New_York')) as local_date
    from ta.v_event_15    
    where "$part_date" = '2026-02-10'
        and "$part_event" in ('enter_game')
        and "#country" in ('美国')
    ) a           

group by 1,2     
order by 2

with us_log_time as(
-- 每小时登录
select "$part_date","#country",hour("#event_time") as hour,count(distinct role_id) as active
from ta.v_event_15    
where "$part_date" = '2026-02-10'
    and "$part_event" in ('enter_game')
    and "#country" in ('美国')
group by 1,2,3
order by 3 asc
)


-- 转换到美国东部时区EST
-- select local_time,local_hour,count(distinct role_id) as acitve_user
-- from(
--     select     
--         role_id
--         ,"#event_time"
--         ,"#event_time" at time zone 'UTC' at time zone 'America/New_York' as check_utc5
--         ,at_timezone("#event_time",'America/New_York') as local_time
--         ,hour(at_timezone("#event_time",'America/New_York')) as local_hour
--         ,date(at_timezone("#event_time",'America/New_York')) as local_date
--     from ta.v_event_15    
--     where "$part_date" = '2026-02-10'
--         and "$part_event" in ('enter_game')
--         and "#country" in ('美国')
--     ) a           

-- group by 1,2     
-- order by 2

select local_date,local_hour,count(distinct role_id) as active_users
from(
    select     
        role_id
        ,"#event_time"
        ,"#event_time" at time zone 'UTC' at time zone 'America/New_York' as check_utc5
        ,at_timezone("#event_time",'America/New_York') as local_time
        ,hour(at_timezone("#event_time",'America/New_York')) as local_hour
        ,date_trunc('day',at_timezone("#event_time",'America/New_York')) as local_date
        -- ,date_trunc('hour',at_timezone("#event_time",'America/New_York')) 
    from ta.v_event_15    
    where "$part_date" = '2026-02-10'
        and "$part_event" in ('enter_game')
        and "#country" in ('美国')
    ) a       
group by 1,2
order by 1,2


-- 分小时的留存    
select reg_local_date,reg_local_hour
       ,sum(iskeep2) as "次日留存人数"
       ,count(distinct role_id) filter(where iskeep2 = 1)  as "次日人数"

with role_register as (
select reg_date,reg_time,role_id
       ,at_timezone(reg_time,'America/New_York') as reg_local_time
       ,date(at_timezone(reg_time,'America/New_York')) as reg_local_date
       ,hour(at_timezone(reg_time,'America/New_York')) as reg_local_hour
from(
    select "$part_date"reg_date,"#event_time"reg_time,role_id
            ,row_number() over(partition by role_id order by "#event_time") as rn
    from ta.v_event_15 
    where "$part_date">='2026-02-09'
        and "$part_event" in ('enter_game','ta_app_start','item_change')
        and "#country" in ('美国')
    ) a       
where rn = 1
)
,role_log as(
select log_date,log_time,role_id
      ,at_timezone(log_time,'America/New_York') as log_local_time
      ,date(at_timezone(log_time,'America/New_York')) as log_local_date
from(
    select "$part_date"log_date,"#event_time"log_time,role_id
            ,row_number() over(partition by role_id,"$part_date" order by "#event_time") as rn
    from ta.v_event_15 
    where "$part_date">='2026-02-09'
        and "$part_event" in ('enter_game','ta_app_start','item_change')
        and "#country" in ('美国')
    ) a    
where rn = 1
)
,new_users as(
select reg_local_hour,reg_local_date,count(distinct role_id) as new
from role_register
group by 1,2
)

select a.reg_local_date,b.reg_local_hour
       ,cast(retention_2 as double) / nullif(b.new,0) as "次留"
from(
select reg_local_date,reg_local_hour
       ,count(distinct role_id) as active
       ,count(distinct role_id) filter(where iskeep2 = 1) as retention_2
       ,count(distinct role_id) filter(where iskeep3 = 1) as retention_3
       ,count(distinct role_id) filter(where iskeep4 = 1) as retention_4
from (
    select role_id,reg_local_date,reg_local_hour
           ,count(distinct role_id) filter(where day_diff = 2) iskeep2
           ,count(distinct role_id) filter(where day_diff = 3) iskeep3
           ,count(distinct role_id) filter(where day_diff = 4) iskeep4
    from(
        select *,date_diff('day',reg_local_date,log_local_date)+1 as day_diff
        from (
            select a.*,b.reg_local_date,b.reg_local_hour
            from role_log a      
            left join role_register b     
                on a.role_id = b.role_id
                and a.log_local_time >= b.reg_local_time
            ) t1     
         ) t2     
    group by 1,2,3
        ) t3     
group by 1,2
    ) a       
left join (select * from new_users) b   
    on a.reg_local_date = b.reg_local_date and a.reg_local_hour = b.reg_local_hour
order by 1,2

--分日计算
-- new_users group by 去掉 hour
select a.reg_local_date
       ,b.new
       ,cast(retention_2 as double) / nullif(b.new,0) as "次留"
from(
select reg_local_date
       ,count(distinct role_id) as active
       ,count(distinct role_id) filter(where iskeep2 = 1) as retention_2
       ,count(distinct role_id) filter(where iskeep3 = 1) as retention_3
       ,count(distinct role_id) filter(where iskeep4 = 1) as retention_4
from (
    select role_id,reg_local_date
           ,count(distinct role_id) filter(where day_diff = 2) iskeep2
           ,count(distinct role_id) filter(where day_diff = 3) iskeep3
           ,count(distinct role_id) filter(where day_diff = 4) iskeep4
    from(
        select *,date_diff('day',reg_local_date,log_local_date)+1 as day_diff
        from (
            select a.*,b.reg_local_date
            from role_log a      
            left join role_register b     
                on a.role_id = b.role_id
                and a.log_local_time >= b.reg_local_time
            ) t1     
         ) t2     
    group by 1,2
        ) t3    
group by 1
    ) a       
left join (select * from new_users) b   
    on a.reg_local_date = b.reg_local_date
where a.reg_local_date is not null
order by 1

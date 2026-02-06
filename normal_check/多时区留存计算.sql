-- 东八 东九 西五 西三 当地时间
-- 首次zone_offset 出现
with time_conf as(select '2026-02-03 16:50:00.000' as conf)
,zone_offset as(
select device_id,zone_offset
from (
select
    "#device_id"device_id
    ,role_id
    ,"$part_event"
    ,"#zone_offset" as zone_offset
    ,row_number() over(partition by role_id order by "#event_time") as rn
from ta.v_event_15  
where "$part_date" >= '2026-02-03'
    and "#event_time" >= (select cast(conf as timestamp) from time_conf)
    and ("#device_id" is not null and "#zone_offset" is not null)
    and role_id is not null
 ) a     
where rn = 1
)

,register as (-- 注册
select 
    a.role_id
    ,a.reg_time
    ,b.zone_offset
    ,a.reg_country
    ,a.reg_country_code
    ,a.reg_date
from(
    select *
    from(
        select 
            role_id
            ,"#device_id" as device_id
            ,"#event_time" as reg_time  
            ,"#zone_offset" as zone_offset
            ,"#country" as reg_country 
            ,"#country_code" as reg_country_code
            ,"$part_date" as reg_date
            ,row_number() over(partition by role_id order by "#event_time") as rn
        from ta.v_event_15
        where "$part_date" >= '2026-02-03'
            and "#event_time" >= (select cast(conf as timestamp) from time_conf)
            and "$part_event" in ('enter_game','item_change','guide','main_stage_into','main_stage_start','main_stage_end')
    )
    where rn = 1 
    ) a    
left join zone_offset b on a.device_id = b.device_id
)

,login_register as( 
select 
    a.*,reg_date,reg_time,reg_country,reg_country_code,zone_offset
    ,date_diff('day',date(reg_date),date(login_date))+1 as day_diff
from(
select 
    role_id 
    ,"#event_time" as login_time
    ,"$part_date" as login_date
from ta.v_event_15
where "$part_event" in ('enter_name','item_change','main_stage_into','main_stage_start','main_stage_end','guide')
    and "$part_date" >= '2026-02-03'
)a   
left join register b on a.role_id = b.role_id and a.login_date >= b.reg_date
)


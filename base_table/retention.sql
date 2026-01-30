-- 再加	lobby_enter
-- 1,写大盘数据
-- 2,写LTV
-- 3,写LTV拆成子商品贡献度
-- 4,对比安装时间和注册时间的差异
-- 5,留存拆回流和连续登录
-- 6,黑产用户分析：单账号多设备/ip充值 单账号多设备登录

-- 表分析&表结构



-- 登录表，选每天第1条记录
with login as(
select 
    role_id
    ,log_date
    ,country
    ,zone_offset
    ,uuid
from (
    select 
        *
        ,row_number() over(partition by role_id,log_date order by log_time) as rn
    from(
        select 
            "#account_id"role_id
            ,"$part_date"log_date
            ,"#country"country
            ,"#zone_offset"zone_offset
            ,"#event_time"log_time 
            ,"#uuid"uuid 
        from ta.v_event_4
        where "$part_event" in('lobby_enter','ta_app_start') 
        and "$part_date" >= '2025-12-29'
        and "$part_date" <= '2026-01-07'
        ) a         
    ) b
where rn = 1
)

-- 注册表，选取最早时间戳记录
,register as(
select  
    role_id
    ,reg_date
    ,country
    ,zone_offset
    ,uuid
from(
    select *
        ,row_number() over(partition by role_id order by reg_time) as rn
    from (
        select 
            "#account_id"role_id
            ,"$part_date"reg_date
            ,"#country"country
            ,"#zone_offset"zone_offset
            ,"#event_time"reg_time
            ,"#uuid"uuid
        from ta.v_event_4
        where "$part_event" in('lobby_enter','ta_app_start')
        and "$part_date" >= '2025-12-29'
        and "$part_date" <= '2026-01-07'
        ) a
    ) b   
where rn = 1
)

-- 注册表与登录表关联，创建day_diff
,register_login as(
select 
    t1.role_id
    ,t1.reg_date
    ,t2.log_date
    ,t1.country
    ,t1.zone_offset
    ,t1.uuid
    ,date_diff('day',date(t1.reg_date),date(t2.log_date))+1 as day_diff
from register t1 
left join login t2
    on t1.role_id=t2.role_id
    and t1.reg_date<=t2.log_date

)

-- 按用户，行转列
,user_retention as(
select 
    role_id
    ,reg_date
    ,country
    ,zone_offset
    ,uuid
    ,count(distinct case when day_diff =1 then role_id else null end) as day_1_retention

from register_login
group by 1,2,3,4,5
)

select *
from user_retention
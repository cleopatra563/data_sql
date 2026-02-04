-- 再加	lobby_enter
-- 1,写大盘数据
-- 2,写LTV
-- 3,写LTV拆成子商品贡献度
-- 4,对比安装时间和注册时间的差异
-- 5,留存拆回流和连续登录
-- 6,黑产用户分析：单账号多设备/ip充值 单账号多设备登录


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
    ,t1.log_date
    ,t2.reg_date
    ,t1.country
    ,t1.zone_offset
    ,t1.uuid
    ,date_diff('day',date(t2.reg_date),date(t1.log_date))+1 as day_diff
from login t1 
left join register t2  -- 小表连大表，小表作为左表
    on t1.role_id=t2.role_id
    and t2.reg_date<=t1.log_date

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
    ,count(distinct case when day_diff = 2 then role_id else null end) as day_2_retention
    ,count(distinct case when day_diff = 3 then role_id else null end) as day_3_retention

from register_login
group by 1,2,3,4,5
)

-- 流失用户，窗口期：连续3天未登录，辅助列rn
    -- lag() over() 相邻两次登录时间差
    -- 连续登录的起始点
    -- 每个连续登录序列的开始和结束日期
    -- 计算流失
-- https://www.php.cn/faq/1511633.html
,churn_users as(





)


-- 回流用户，窗口期：连续3天未登录，最近7天有登录 ,流失表 left join 登录表 




-- 回流率 = 流失用户数 / 流失用户




-- 流失率 = 流失用户 / 活跃用户




-- 连续登录用户






select *
from your_table 
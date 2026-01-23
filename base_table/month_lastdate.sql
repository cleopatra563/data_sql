-- 求2025~2026年，每个月最后一天的不同国家订单总额
-- https://blog.csdn.net/redis7keeper/article/details/153172405
with recharge as (SELECT "#account_id"role_id
                ,"#event_time"log_time
                ,date("$part_date")log_date
                ,"#zone_offset"
                ,"#country"country
                ,"#uuid" -- 设备id
                ,sub_game_name as item_name -- 购买商品
                ,cast(game_id as int) as money
                ,'CNY' as money_type
                FROM v_event_4 
                WHERE "$part_event"='game_end'
                AND "$part_date">='2025-12-29' 
                AND "$part_date"<='2026-01-07' 
                )

-- recharge做聚合，求出每天订单总额，作为主表
,recharge2 as(
select  
     log_date
    ,country 
    ,sum(money) as total_money
from recharge  
group by log_date,country 
)

-- last_day表
,last_day as(   
select 
    distinct 
    last_day_of_month(date(log_date)) as last_date   
from recharge2
)

-- 每个月最后一天，不同国家的订单总额
select
     t2.last_date
    ,t1.country
    ,t1.total_money
from recharge2 t1 
join last_day t2
    on t1.log_date=t2.last_date
order by t2.last_date,t1.country


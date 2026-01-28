-- 再加	lobby_enter
-- 1,写大盘数据
-- 2,写LTV
-- 3,写LTV拆成子商品贡献度
-- 4,对比安装时间和注册时间的差异
-- 5,留存拆回流和连续登录
-- 6,黑产用户分析：单账号多设备/ip充值 单账号多设备登录

-- 表分析&表结构
-- LTV = 前7天的订单金额 / 注册当日的新增人数
-- 求7日LTV：
--     1、注册日期（reg_date）
--     2、7日内总充值金额（7d_money） ps 内购+广告 sum()
--     3、按注册日期分组，计算7日LTV

-- 注册表
with register as(
select 
    role_id
    ,log_date as reg_date
    ,country
    ,zone_offset
from(
    select *
        ,row_number() over(partition by role_id order by log_time) as rn
    from(    
        select 
            "#account_id"role_id
            ,"$part_date"log_date
            ,"#country"country
            ,"#zone_offset"zone_offset
            ,"#event_time"log_time 
        from ta.v_event_4 
        where "$part_event" in('lobby_enter','ta_app_start')
        and "$part_date" >= '2025-12-29'
        and "$part_date" <= '2026-01-07'
        ) a         
    ) b        
where rn = 1
)

-- 订单表(IAP)
,recharge as(
select 
    role_id
    ,pay_date
    ,item_name -- 多加一列，是否会引起数据膨胀
    ,sum(money) as money
from(
    select 
        "#account_id"role_id
        ,"$part_date" pay_date
        ,"#event_time" pay_time 
        ,"#country" country
        ,"#zone_offset" zone_offset
        ,sub_game_name as item_name -- 购买商品
        ,cast(game_id as int) as money
        ,'CNY' as money_type
    from ta.v_event_4 
    where "$part_event" in('game_end')
    and "$part_date" >= '2025-12-29'
    and "$part_date" <= '2026-01-07'
    ) a   
group by 1,2,3
)

-- 注册充值表+辅助列(day_diff)
,register_recharge as(
select 
    t1.*
    ,t2.pay_date
    ,t2.item_name
    ,coalesce(t2.money,0) as pay_money
    ,date_diff('day',date(t1.reg_date),date(t2.pay_date))+1 as day_diff
from register t1
left join recharge t2
    on t1.role_id = t2.role_id
    and t1.reg_date <= t2.pay_date
)

-- 按用户，计算首日~7日总充值
,user_money as(
select 
    role_id
    ,reg_date
    ,sum(pay_money)filter(where day_diff = 1) as first_day_money
    ,sum(pay_money) filter(where day_diff <=2 ) as second_day_money
    ,sum(pay_money) filter(where day_diff <=3 ) as third_day_money
    ,sum(pay_money) filter(where day_diff <=4 ) as fourth_day_money
    ,sum(pay_money) filter(where day_diff <=5 ) as fifth_day_money
    ,sum(pay_money) filter(where day_diff <=6 ) as sixth_day_money
    ,sum(pay_money) filter(where day_diff <=7 ) as seventh_day_money
from register_recharge
group by 1,2
)

-- 按注册日期，计算首日~7日LTV
,ltv as(
select 
    reg_date
    ,count(distinct role_id) as user_cnt
    ,cast(sum(pay_money) filter(where day_diff = 1) as double) / nullif(count(distinct role_id),0) as ltv_1d
    ,cast(sum(pay_money) filter(where day_diff <= 2) as double) / nullif(count(distinct role_id),0) as ltv_2d
    ,cast(sum(pay_money) filter(where day_diff <= 3) as double) / nullif(count(distinct role_id),0) as ltv_3d
    ,cast(sum(pay_money) filter(where day_diff <= 4) as double) / nullif(count(distinct role_id),0) as ltv_4d
    ,cast(sum(pay_money) filter(where day_diff <= 5) as double) / nullif(count(distinct role_id),0) as ltv_5d
    ,cast(sum(pay_money) filter(where day_diff <= 6) as double) / nullif(count(distinct role_id),0) as ltv_6d
    ,cast(sum(pay_money) filter(where day_diff <= 7) as double) / nullif(count(distinct role_id),0) as ltv_7d
from register_recharge
group by 1
)

-- 按商品，计算首日~7日LTV
,item_ltv as(
select
    reg_date
    ,item_name
    ,count(distinct role_id) as item_user_cnt 
    ,cast(sum(pay_money)filter(where day_diff = 1) as double) / nullif(count(distinct role_id),0) as item_ltv_1d
    ,cast(sum(pay_money)filter(where day_diff <= 2) as double) / nullif(count(distinct role_id),0) as item_ltv_2d
    ,cast(sum(pay_money)filter(where day_diff <= 3) as double) / nullif(count(distinct role_id),0) as item_ltv_3d
    ,cast(sum(pay_money)filter(where day_diff <= 4) as double) / nullif(count(distinct role_id),0) as item_ltv_4d
    ,cast(sum(pay_money)filter(where day_diff <= 5) as double) / nullif(count(distinct role_id),0) as item_ltv_5d
    ,cast(sum(pay_money)filter(where day_diff <= 6) as double) / nullif(count(distinct role_id),0) as item_ltv_6d
    ,cast(sum(pay_money)filter(where day_diff <= 7) as double) / nullif(count(distinct role_id),0) as item_ltv_7d
from register_recharge
group by 1,2

)

-- 子商品7日贡献度
,item_contribution as(
select
    t1.reg_date
    ,t1.item_name
    ,item_ltv_7d / ltv_7d as contribution
from item_ltv t1
left join ltv  t2
    on t1.reg_date = t2.reg_date
)

-- 补充:广告收益表（IAA）





select * 
from item_ltv 
order by reg_date, item_name
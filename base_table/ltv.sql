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
--     2、7日内总充值金额（7d_money）ps 内购+广告
--     3、按注册日期分组，计算7日LTV

-- 注册表
with register as(
    select 
        role_id
        ,log_date as reg_date
        ,country
        ,zone_offset
    from 
    (select 
        "#account_id"role_id
        ,"$part_date"log_date
        ,"#country"country
        ,"#zone_offset"zone_offset
        ,row_number() over (partition by role_id order by "#event_time") as rn
    from ta.v_event_4 
    where "$part_event" in('lobby_enter','ta_app_start')
    and "$part_date" >= '2025-12-29'
    and "$part_date" <= '2026-01-07'
    ) a 
    where rn = 1
)

-- 运行和调试
-- step 1
select *
from register

-- -- step 2
-- select role_id,reg_date,count(*)
-- from register
-- group by role_id,reg_date
-- having count(*)>1

-- -- step 3
-- select *
-- from register
-- where role_id in ('7603ae366460a0bb')


-- 订单表(IAP)





-- 注册充值表+辅助列(day_diff)






-- 按用户，计算total_money_7d






-- 补充:广告收益表（IAA）







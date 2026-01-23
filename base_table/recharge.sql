-- 再加	lobby_enter
-- 1,写大盘数据
-- 2,写LTV
-- 3,写LTV拆成子商品贡献度
-- 4,对比安装时间和注册时间的差异
-- 5,留存拆回流和连续登录
-- 6,黑产用户分析：单账号多设备/ip充值 单账号多设备登录

with recharge as (SELECT "#account_id"role_id
                ,"#event_time"log_time
                ,"$part_date"log_date
                ,"#zone_offset"
                ,"#country"
                ,"#uuid" # 设备id
                ,sub_game_name as item_name # 购买商品
                ,cast(game_id as int) as money
                ,'CNY' as money_type
                FROM v_event_4 
                WHERE "$part_event"='game_end'
                AND "$part_date">='2025-12-29' 
                AND "$part_date"<='2026-01-07' 
                )

-- select 
--  ' ' as "日期"
-- ,' ' as "国家"
-- ,' ' as "新增-用户"
-- ,' ' as "新增-广告用户"
-- ,' ' as "新增-自然量用户"
-- ,' ' as "新增-点击广告用户"
-- ,' ' as  "新增-广告金额"
-- ,' ' as  "活跃用户"
-- ,' ' as  "广告用户" 
-- ,' ' as  "广告金额"
-- ,' ' as  "广告用户占比" 广告用户 / 所有用户
-- ,' ' as  "Arpu" 充值金额/所有用户
-- ,' ' as  "Arppu" 充值金额/点击广告用户

-- 大盘数据 
    新增表 日期+国家  所有用户，广告用户，自然量用户 |lobby_enter ，用户表[te_ads_object.ad_group_id]
    活跃表 日期+国家  活跃用户，广告用户   |lobby_enter
    充值表 日期+国家  充值金额            |recharge
    广告表 日期+国家  点击广告用户，新增广告金额，广告金额     |ad_click

with ad_click as( --游戏内广告点击
select 
    "#account_id"role_id
    ,"$part_date"
    ,"#country"country
    ,fb_install_referrer_adgroup_id as ad_group_id
    ,ads_type
from ta.v_event_4 
where "$part_event" = 'ad_click'
    and "$part_date" <= '2025-12-29'
    and "$part_date" <= '2026-01-07'
)

,user_log as(-- 活跃表
select 
    "#account_id"role_id
    ,"$part_date"
    ,"#country"country
    ,case when install_ad_name is not null then 'install' else 'natural' end as user_type
from ta.v_event_4
where "$part_event" = 'lobby_enter'
    and "$part_date" <= '2025-12-29'
    and "$part_date" <= '2026-01-07'

)

,user_dim as( -- 用户维度表
select        
    "te_ads_object.ad_group_id@adid"
    ,"te_ads_object.ad_group_id@amount"
from ta_dim.dim_4_1_3247 

)
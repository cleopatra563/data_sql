-- 再加	lobby_enter
-- 1,写大盘数据
-- 2,写LTV
-- 3,写LTV拆成子商品贡献度
-- 4,对比安装时间和注册时间的差异
-- 5,留存拆回流和连续登录
-- 6,黑产用户分析：单账号多设备/ip充值 单账号多设备登录

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
    -- 新增表 日期+国家  所有用户，广告用户，自然量用户 |lobby_enter 
    -- 活跃表 日期+国家  活跃用户，广告用户，广告金额   |lobby_enter ，用户表[te_ads_object.ad_group_id]，用户维度表[te_ads_object.ad_group_id@amount]
    -- 充值表 日期+国家  充值金额            |recharge
    -- 广告表 日期+国家  点击广告用户，新增广告金额，广告金额     |ad_click

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

,active as(-- 活跃表
select 
    "#account_id"role_id
    ,"#event_time"log_time
    ,"$part_date"log_date
    ,"#country"country
    ,"#zone_offset"zone_offset
    ,"#uuid"uuid -- 设备id
from ta.v_event_4
where "$part_event" = 'lobby_enter'
    and "$part_date" <= '2025-12-29'
    and "$part_date" <= '2026-01-07'

)

,user_dim as( -- 用户维度表
select        
    "te_ads_object.ad_group_id@adid"as ad_id
    ,"te_ads_object.ad_group_id@amount"as ad_amount
from ta_dim.dim_4_1_3247 

)

,ad as( -- 用户表
select 
    "#account_id"role_id  
    ,te_ads_object.ad_group_id as ad_id 
    ,te_ads_object.ad_group_name as ad_name 
    ,split_part(te_ads_object.ad_group_name,'-',2) as ad_game_name
from ta.v_user_4 
where te_ads_object.ad_group_id is not null

)

,recharge as( -- 充值表
select 
    "#account_id"role_id
    ,"#event_time"log_time
    ,"$part_date"log_date
    ,"#zone_offset"
    ,"#country"
    ,"#uuid" -- 设备id
    ,sub_game_name as item_name -- 购买商品
    ,cast(game_id as int) as money
    ,'CNY' as money_type
from v_event_4 
where "$part_event"='game_end'
and "$part_date">='2025-12-29' 
and "$part_date"<='2026-01-07' 

)

-- active left join ad left join user_dim
,active_ad as( -- 活跃广告表
select 
    t1.role_id
    ,t1.log_time
    ,t1.log_date
    ,t1.country
    ,t1.zone_offset
    ,t1.uuid
    ,t2.ad_id
    ,t2.ad_name
    ,t2.ad_game_name
    ,t3.ad_amount
    ,case when t2.ad_id is not null then 'click' else 'natural' end as user_type
from active t1   
left join ad t2  
    on t1.role_id=t2.role_id
left join user_dim t3
    on t2.ad_id=t3.ad_id

)

,reg_ad as( -- 注册广告表
select
    select *
    from(
        distinct 
        role_id
        ,min(log_time) over(partition by role_id order by log_time ) as reg_time
        ,min(log_date) over(partition by role_id order by log_date ) as reg_date
        ,country
        ,zone_offset
        ,ad_id
        ,ad_name
        ,ad_game_name
        ,ad_amount
        ,user_type
    from active_ad
        )
    where reg_date >= '2025-12-29'
        and reg_date <= '2026-01-07'
)

-- 新增表
select 
    reg_date as dt 
    ,country  
    ,count(distinct role_id) as new_user_cnt
    ,count(distinct role_id) filter(where user_type='click') as click_user_cnt 
    ,count(distinct role_id) filter(where user_type='natural') as nat_user_cnt 
from reg_ad

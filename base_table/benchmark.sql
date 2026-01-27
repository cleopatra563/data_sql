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
-- ,' ' as  "Arpu" 充值金额/活跃用户
-- ,' ' as  "Arppu" 充值金额/点击广告用户

-- 大盘数据 
    -- 新增表 日期+国家  所有用户，广告用户，自然量用户，广告金额 
    --     |lobby_enter: reg_date,country,role_id,user_type
    -- 活跃表 日期+国家  活跃用户，广告用户，广告金额   
    --     |lobby_enter ，用户表[te_ads_object.ad_group_id]，用户维度表[te_ads_object.ad_group_id@amount]
    -- 充值表 日期+国家  充值金额            
    --     |recharge: role_id,log_date,money,money_type
    -- 广告表 日期+国家  点击广告用户         
    --     |ad_click: ad_id,role_id,log_date,ad_amount
    -- 搭建宽表    
    --     select t1.*,t2.* from t1 left join t2 on t1.index = t2.index left join t3 on t1.index = t3.index

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

,active as(-- 登录表
select 
    distinct
    "#account_id"role_id
    ,"#event_time"log_time
    ,"$part_date"log_date
    ,"#country"country
    ,"#zone_offset"zone_offset
from ta.v_event_4
where "$part_event" in('ta_app_start','lobby_enter') 
    and "$part_date" >= '2025-12-29'
    and "$part_date" <= '2026-01-07'

)

,register as ( -- 注册表
select 
    role_id
    ,log_date
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

,ad_amount as( -- 广告收益（消耗）
select        
    "te_ads_object.ad_group_id@adid"as ad_id
    ,cast("te_ads_object.ad_group_id@amount" as double)as ad_amount
from ta_dim.dim_4_1_3247 

)

,ad as( -- 广告维度表
select 
    "#account_id"role_id  
    ,te_ads_object.ad_group_id as ad_id 
    ,te_ads_object.ad_group_name as ad_name 
    ,split_part(te_ads_object.ad_group_name,'-',2) as ad_game_name
from ta.v_user_4 
where te_ads_object.ad_group_id is not null

)

,recharge as( -- 订单表
select 
    "#account_id"role_id
    ,"#event_time"log_time
    ,"$part_date"log_date
    ,"#zone_offset"zone_offset
    ,"#country"country
    ,sub_game_name as item_name -- 购买商品
    ,cast(game_id as int) as money
    ,'CNY' as money_type
from v_event_4 
where "$part_event"='game_end'
and "$part_date">='2025-12-29' 
and "$part_date"<='2026-01-07'

)

,active_ad as( -- 活跃广告表
select 
    t1.role_id
    ,t1.log_date
    ,t1.country
    ,t1.zone_offset
    ,t2.ad_id
    ,t2.ad_name
    ,t2.ad_game_name
    ,t3.ad_amount
    ,case when t2.ad_id is not null then 'click' else 'natural' end as user_type
from active t1   
left join ad t2  
    on t1.role_id=t2.role_id
left join ad_amount t3
    on t2.ad_id=t3.ad_id

)

,reg_ad as( -- 注册广告表
select 
    t1.role_id
    ,t1.log_date reg_date
    ,t1.country
    ,t1.zone_offset
    ,t2.ad_id
    ,t2.ad_name
    ,t2.ad_game_name
    ,t3.ad_amount
    ,case when t2.ad_id is not null then 'click' else 'natural' end as user_type
from register t1 
left join ad t2
    on t1.role_id = t2.role_id
left join ad_amount t3
    on t2.ad_id = t3.ad_id

)

,new_user as( -- 新增类指标
select 
    reg_date as dt 
    ,country  
    ,count(distinct role_id) as new_user_cnt -- 新增用户
    ,count(distinct role_id) filter(where user_type='click') as click_new_cnt --新增买量用户 
    ,count(distinct role_id) filter(where user_type='natural') as nat_new_cnt -- 新增自然量用户
    ,sum(distinct t2.ad_amount) filter(where user_type='click') as new_click_ad_amount -- 新增广告金额
from reg_ad t1  
left join ad_amount t2
    on t1.ad_id = t2.ad_id
group by 1,2

)

,active_user as( -- 活跃类指标
select 
    t1.log_date as dt
    ,t1.country  
    ,count(distinct t1.role_id) as active_user_cnt -- 活跃用户
    ,count(distinct t1.role_id) filter(where user_type='click') as click_active_cnt -- 活跃买量用户
    ,cast(count(distinct t1.role_id) filter(where user_type='click') as double) / nullif(count(distinct t1.role_id),0) as click_active_ratio -- 活跃买量用户占比
    ,sum(distinct t2.ad_amount) filter(where user_type='click') as active_click_ad_amount -- 活跃广告金额
    ,sum(t3.money) as active_money -- 活跃充值金额  
    ,sum(t3.money) / nullif(count(distinct t1.role_id),0) as arpu -- 活跃充值金额 / 活跃用户
    ,sum(t3.money) / nullif(count(distinct t3.role_id) filter(where user_type='click'),0) as arppu -- 活跃充值金额 / 活跃付费用户
from active_ad t1  
left join ad_amount t2 
    on t1.ad_id = t2.ad_id
left join (
    select 
        role_id 
        ,log_date -- 每天
        ,sum(money) as money
    from recharge
    group by 1,2    
) t3
    on t1.role_id = t3.role_id
    and t1.log_date = t3.log_date
group by 1,2

)

-- 搭建宽表
select 
    t1.*
    ,t2.new_user_cnt -- 新增用户
    ,t2.click_new_cnt -- 新增买量用户
    ,t2.nat_new_cnt -- 新增自然量用户
    ,t2.new_click_ad_amount -- 新增广告金额
from active_user t1 
left join new_user t2
    on t1.dt = t2.dt
    and t1.country = t2.country
where t1.country in ('巴西','印度尼西亚','印度')
order by dt asc,country asc
 
-- select *
-- from active_user
-- where country in ('巴西','印度尼西亚','印度')
-- order by dt asc,country asc
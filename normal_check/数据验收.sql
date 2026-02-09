-- 所有事件倒序
select 
    "$part_event"
    ,count(distinct "#distinct_id") as cnt
    ,min("#event_time") as time
from ta.v_event_15
where ${PartDate:date} 
group by 1
order by 3 asc


-- 设备id最早注册时间
with tmp as(
select 
    device_id
    ,role_id
    ,"$part_event"
    ,reg_time
    ,reg_date
from(
select 
    "#device_id"device_id
    ,role_id
    ,"#event_time"reg_time
    ,"$part_date"reg_date
    ,"$part_event"
    ,row_number() over(partition by "#device_id" order by "#event_time") as rn
from ta.v_event_15 
where "$part_date" >= '2026-02-03'
    and "#device_id" in (select "#varchar_id" from user_result_cluster_15 where "cluster_name"='cohort_20260206_113105')
    ) a       
where rn = 1 
    and date(reg_date) = date('2026-02-03')
)


-- 2月3日注册用户，2月5日登录，所触发所有事件
select    
    "#device_id"device_id
    ,"#event_time"
    ,"$part_date"
    ,"$part_event"
from ta.v_event_15 
where "$part_date" = '2026-02-05'
    and "#device_id" = 'fd1190969d8edb48'
order by "#event_time" desc



-- 核心字段
    "#event_time"
    "$part_date"
    "#zone_offset"
   "#country_code"
   "#country"
   "#device_id"  role_id  uuid  user_id  distinct_id  account_id 
   "#app_version"
   "app_name"
   "sdk_version"
   "server_id"
   "server_name"


-- 首个事件(enter_game)
-- 登录事件（enter_game item_change）
-- first_reg_time 最早注册时间
-- #server_time #event_time

SELECT 
    role_name,"$part_event","$part_date","#user_id","#event_name"
    ,"#event_time","#account_id"
    ,"#distinct_id","#server_time","#kafka_offset","#uuid","#dw_create_time"
    ,"#dw_update_time","#te_event_id","#lib_version","#os","#zone_offset","#ip"
    ,"#ram","#data_source","#screen_height","#device_model","#system_language"
    ,"#network_type","#lib","#device_type","#city","#disk","#carrier","#country_code"
    ,"#device_id","#province","#bundle_id","#screen_width","#install_time","#simulator"
    ,"#country","#fps","#manufacturer","#os_version","#app_version","#title","#resume_from_background"
    ,"#screen_name","#duration","#scene_name","#scene_path","boss_list","#app_crashed_reason"
    ,"systerm_choose","player_choose","level_id","player_team","round_id","is_win","is_super_merge"
    ,"left_diamond","mp_num","#start_reason","#background_duration","vpn_status","app_id","device_id"
    ,"phone_model","app_name","android_id","time","referrer","reason","country","app_version"
    ,"te_ads_object","timezone","network_name","#data_source_detail","ta_distinct_id","os_name","publisher_parameters","created_at_milli","activity_kind","install_ad_name","campaign_id","creative_name","fb_install_referrer_campaign_id","fb_install_referrer_campaign_group_name","campaign_name","fb_install_referrer_account_id","fb_install_referrer_adgroup_name","fb_install_referrer_ad_id","fb_install_referrer","fb_install_referrer_publisher_platform","fb_install_referrer_adgroup_id","fb_install_referrer_campaign_name","fb_install_referrer_ad_objective_name","fb_install_referrer_campaign_group_id","adgroup_name","sdk_version","os_api_level","sim_state","install_device_id","channel_id","gaid","google_referrer","logintype","user_id","qc_install_referrer","error_message","is_success","install_source","check_step","desc","before_scence","after_scence","boss_id","scence","choose_skills","skills_group","stage_id","sub_stage_id","setting_type","language_type","is_sign","item_gain","create_time","last_login_time","level","sex","online_duration_total","role_name","role_id","last_out_time","first_login_time","reason_cn","guide_id","guide_status","online_time","login_time","item_id","change","item_name","change_value","after_value","before_value","item_type","equipment_id","log_info","equip_attr","equip_id","event_type","card_id","pool_id","draw_result" 
FROM ta.v_event_15
WHERE "$part_date" >= '2026-01-20' 
-- and role_name is not null
and (("#distinct_id" = 'be4a64cc-fed6-4b7b-bc79-234155f90cbc') or (role_name = 'player40346'))
order by "#server_time" desc

SELECT
    "#distinct_id"
    ,role_id
    ,"#server_time"
    ,"$part_event"
    ,"#event_time"
    ,"$part_date"
    ,login_time
    ,"#user_id","#event_name","#event_time","#account_id","#distinct_id","#server_time","#kafka_offset","#uuid","#dw_create_time","#dw_update_time","#te_event_id","#lib_version","#os","#zone_offset","#ip","#ram","#data_source","#screen_height","#device_model","#system_language","#network_type","#lib","#device_type","#city","#disk","#carrier","#country_code","#device_id","#province","#bundle_id","#screen_width","#install_time","#simulator","#country","#fps","#manufacturer","#os_version","#app_version","#title","#resume_from_background","#screen_name","#duration","#scene_name","#scene_path","boss_list","#app_crashed_reason","systerm_choose","player_choose","level_id","player_team","round_id","is_win","is_super_merge","left_diamond","mp_num","#start_reason","#background_duration","vpn_status","app_id","device_id","phone_model","app_name","android_id","time","referrer","reason","country","app_version","te_ads_object","timezone","network_name","#data_source_detail","ta_distinct_id","os_name","publisher_parameters","created_at_milli","activity_kind","install_ad_name","campaign_id","creative_name","fb_install_referrer_campaign_id","fb_install_referrer_campaign_group_name","campaign_name","fb_install_referrer_account_id","fb_install_referrer_adgroup_name","fb_install_referrer_ad_id","fb_install_referrer","fb_install_referrer_publisher_platform","fb_install_referrer_adgroup_id","fb_install_referrer_campaign_name","fb_install_referrer_ad_objective_name","fb_install_referrer_campaign_group_id","adgroup_name","sdk_version","os_api_level","sim_state","install_device_id","channel_id","gaid","google_referrer","logintype","user_id","qc_install_referrer","error_message","is_success","install_source","check_step","desc","before_scence","after_scence","boss_id","scence","choose_skills","skills_group","stage_id","sub_stage_id","setting_type","language_type","is_sign","item_gain","create_time","last_login_time","level","sex","online_duration_total","role_name","role_id","last_out_time","first_login_time","reason_cn","guide_id","guide_status","online_time","login_time","item_id","change","item_name","change_value","after_value","before_value","item_type","equipment_id","log_info","equip_attr","equip_id","event_type","card_id","pool_id","draw_result","server_open_time","offline_type","cost_time","oldname","newname","now_people","server_id","ta_account_id","part_id","server_name","role_level","role_create_time","vip_level" 
FROM ta.v_event_15 
WHERE "$part_date" = '2026-01-31' 
and (role_id = 'HK103530' or "#distinct_id" = 'd444ab0f-ecef-4807-9922-acc7cf88e6ee')
and "#event_time" <= timestamp '2026-01-31 10:59:11.747'

select "$part_event",count(*)
from tmp
group by 1

-- 时间处理
-- login_time处理
date_format(from_unixtime(login_time/1000),'%Y-%m-%d %H:%m:%s') as login_time
'yyyy-MM-dd HH:mm:ss.SSS'

with time_conf as (select '2026-02-03 16:50:00.000' as conf)
,df1 as (
        select role_id,reg_date,reg_time,device_id 
        ,reg_country
        ,"#zone_offset"zone_offset
        ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST((("#zone_offset"-8) * 3600) AS integer), reg_time), reg_time)reg_local_time
        ,cast(IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST((("#zone_offset"-8) * 3600) AS integer), reg_time), reg_time) as date)reg_local_date
        from  
            (
            SELECT role_id,"$part_date"reg_date,"#event_time"reg_time
            ,row_number()over(partition by role_id order by "#event_time")rn
            ,"#device_id"device_id
            ,case when "#country_code" = 'HK' then '香港'
                  when "#country_code" = 'TW' then '台湾'
                  when "#country_code" = 'ID' then '印尼'
                  else "#country" end as reg_country
            -- ,"#country"reg_country
            ,"#zone_offset"
            FROM ta.v_event_15
            WHERE "$part_date" >= '2026-02-02'
            and "#event_time" >= (select cast(conf as timestamp) from time_conf)
            and "$part_event" = 'enter_game'
            and role_id is not null
            and role_id != ''
            and "#distinct_id" != 'test'
            )t    
        where rn = 1 
        )
        
        
select role_id,reg_country 
from  
df1

with time_conf as (select '2026-02-03 16:50:00.000' as conf)
select "#device_id",reg_time
from  
(
SELECT "#device_id","#event_time"reg_time
,row_number()over(partition by "#device_id" order by "#event_time")rn
FROM ta.v_event_15
WHERE "$part_date" >= '2026-02-02'
and "#event_time" >= (select cast(conf as timestamp) from time_conf)
and "#distinct_id" != 'test'
)t    
where rn = 1 


with time_conf as (select timestamp '2026-02-03 16:50:00.000' as conf)

/* sessionProperties: {"ignore_downstream_preferences":"true"} */
select * 
from (
    select *,count(data_map_0) over () group_num_0,count(1) over () group_num 
    from (
        select map_agg(if(amount_0 is not null and is_finite(amount_0) , "$__Date_Time", null), amount_0) data_map_0
              ,map_agg(if(true, "$__Date_Time", null), cast(row(internal_amount_0) as row(internal_amount_0 DOUBLE))) data_part_map_0
              ,sum(if(is_finite(amount_0) and ("$__Date_Time" <> timestamp '1981-01-01'), amount_0, 0)) total_amount 
        from (
            select *, internal_amount_1 amount_0 
            from (
                select *, cast(coalesce(internal_amount_0, 0) as double) internal_amount_1 
                from (
                    select cast("$part_date" as TIMESTAMP) "$__Date_Time",cast(coalesce(try(try_cast(SUM(cast(ta_ev."#vp@duration" as double)) AS DOUBLE )/COUNT(DISTINCT ta_ev."role_id")), 0) as double) internal_amount_0 
                    from (
                        select *, ta_date_trunc('day',"@vpc_tz_#event_time", 1) "$__Date_Time" 
                        from (
                            select * from (select *, "#event_time" "@vpc_tz_#event_time" 
                            from (
                                select *, try_cast(try(round((CAST("#duration" AS double) / 60), 2)) as double) "#vp@duration" 
                                from (
                                    select a.*,"@vpc_cluster_role_reg_country_cbt1","@vpc_cluster_role_reg_country_cbt1_v2" 
                                    from (
                                        select "#duration" "#duration","#event_name" "#event_name","#event_time" "#event_time","#user_id" "#user_id","$part_date" "$part_date","$part_event" "$part_event","role_id" "role_id" 
                                        from (
                                            select "#user_id", "role_id" "role_id","#event_time" "#event_time","$part_event" "$part_event","#duration" "#duration","$part_date" "$part_date","#event_name" "#event_name" 
                                            from v_event_15 
                                            where "$part_event" in ('ta_app_end'))) a 
                                            left join (
                                                select "#varchar_id" "id"
                                                        ,arbitrary(if(cluster_name = 'role_reg_country_cbt1', tag_value, null)) "@vpc_cluster_role_reg_country_cbt1"
                                                        ,arbitrary(if(cluster_name = 'role_reg_country_cbt1_v2', tag_value, null)) "@vpc_cluster_role_reg_country_cbt1_v2" 
                                                from user_result_cluster_15 
                                                where (cluster_name = 'role_reg_country_cbt1') or (cluster_name = 'role_reg_country_cbt1_v2') 
                                                group by "#varchar_id") b0 on a."role_id"=b0."id"
                                                ))))) ta_ev 
                    where (((( "$part_event" IN ( 'ta_app_end' )))) and (ta_ev."role_id" IS NOT NULL)) and (("$part_date" = '2026-02-08') and ((ta_ev."@vpc_cluster_role_reg_country_cbt1" IS NOT NULL) and (ta_ev."@vpc_cluster_role_reg_country_cbt1_v2" NOT IN ('中国')))) 
                    group by "$part_date"))))) 
                    order by total_amount DESC limit 1000

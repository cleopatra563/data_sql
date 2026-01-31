-- 所有事件倒序
select 
    "$part_event"
    ,count(distinct "#distinct_id") as cnt
    ,min("#event_time") as time
from ta.v_event_15
where ${PartDate:date} 
group by 1
order by 3 asc

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
date_format(from_unixtime(login_time / 1000),'yyyy-MM-dd HH:mm:ss')
'yyyy-MM-dd HH:mm:ss.SSS'


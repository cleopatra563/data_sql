-- 流程介绍:
-- 流量情况下：
-- sdk_lebian_dialog_show
-- sdk_lebian_dialog_click_download ,isTraffic=1
-- sdk_lebian_dialog_download_start ,isTraffic=1
-- sdk_lebian_download_progress,isTraffic=1

with dialog_show as(
   select 
    "#user_id","#account_id","#distinct_id","$part_event","#event_time","$part_date","#uuid","#lib_version","#os","#zone_offset","#ip","#ram","#data_source","#screen_height","#device_model","#system_language","#network_type","#lib","#device_type","#city","#disk","#carrier","#country_code","#device_id","#province","#bundle_id","#screen_width","#install_time","#simulator","#country","#fps","#manufacturer","#os_version","#app_version","vpn_status","app_name","android_id","sdk_version","os_api_level","sim_state","install_device_id","channel_id","gaid","google_referrer","user_id","qc_install_referrer","role_name","role_id","server_id","server_name","role_level","role_create_time","vip_level","game_version","total","content" 
from v_event_15 
where "$part_event"='sdk_lebian_dialog_show' 
   and "$part_date"='2026-02-02'
)
,click_download as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
   from v_event_15  
   where "$part_event"='sdk_lebian_dialog_click_download' 
   and "$part_date"='2026-02-02'
   and isTraffic=1
)

select *
from click_download
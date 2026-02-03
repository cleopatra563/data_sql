-- 流程介绍:
-- 流量情况下：
-- sdk_lebian_dialog_show
-- sdk_lebian_dialog_click_download ,isTraffic=1
-- sdk_lebian_dialog_download_start ,isTraffic=1
-- sdk_lebian_download_progress,isTraffic=1

with dialog_show as( -- 流量情况下提示弹窗
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"$part_event"
    ,"#event_time"
    ,"$part_date"
    ,"#zone_offset"
   ,"#country_code"
   ,"#device_id"
   ,"#app_version"
   ,"app_name"
   ,"sdk_version"
   ,"server_id"
   ,"server_name"
from v_event_15 
where "$part_event"='sdk_lebian_dialog_show' 
   and ${PartDate:date} 
)

,click_download as( -- 弹窗点击开始下载
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"$part_event"
    ,"#event_time"
    ,"$part_date"
    ,"#zone_offset"
   ,"#country_code"
   ,"#device_id"
   ,"#app_version"
   ,"app_name"
   ,"sdk_version"
   ,"server_id"
   ,"server_name"
   from v_event_15  
   where "$part_event"='sdk_lebian_dialog_click_download' 
   and ${PartDate:date} 
   and isTraffic=1
)

-- 弹窗点击以后下载 sdk_lebian_dialog_click_later
,click_later as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,role_id
    ,"#device_id"
   from v_event_15  
   where "$part_event"='sdk_lebian_dialog_click_later' 
   and ${PartDate:date} 
   and isTraffic=1
)


-- 开始下载 sdk_lebian_dialog_download_start/sdk_lebian_download_start




-- 下载进度 （25% 50% 75%三节点上报） sdk_lebian_download_progress





-- 下载资源完成 sdk_lebian_download_finish





select *
from click_download
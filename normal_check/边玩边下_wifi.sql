-- 流程介绍:
-- 流量情况下：
-- sdk_lebian_dialog_show
-- sdk_lebian_dialog_click_download ,isTraffic=0
-- sdk_lebian_dialog_download_start ,isTraffic=0
-- sdk_lebian_download_progress,isTraffic=0

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
   ,"#country"
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
   ,"#country"
   ,"#device_id"
   ,"#app_version"
   ,"app_name"
   ,"sdk_version"
   ,"server_id"
   ,"server_name"
   from v_event_15  
   where "$part_event"='sdk_lebian_dialog_click_download' 
   and ${PartDate:date} 
   and isTraffic=0
)

-- 弹窗点击以后下载 sdk_lebian_dialog_click_later
,click_later as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"$part_event"
    ,"#event_time"
    ,"$part_date"
    ,"#zone_offset"
   ,"#country_code"
   ,"#country"
   ,"#device_id"
   ,"#app_version"
   ,"app_name"
   ,"sdk_version"
   ,"server_id"
   ,"server_name"
   from v_event_15  
   where "$part_event"='sdk_lebian_dialog_click_later' 
   and ${PartDate:date} 
   and isTraffic=0
)

-- 开始下载 sdk_lebian_dialog_download_start/sdk_lebian_download_start
,download_start as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"$part_event"
    ,"#event_time"
    ,"$part_date"
    ,"#zone_offset"
   ,"#country_code"
   ,"#country"
   ,"#device_id"
   ,"#app_version"
   ,"app_name"
   ,"sdk_version"
   ,"server_id"
   ,"server_name"
   from v_event_15  
   where "$part_event" in('sdk_lebian_dialog_download_start','sdk_lebian_download_start') 
   and ${PartDate:date} 
   and isTraffic=0
)

-- 下载进度 （25% 50% 75%三节点上报） sdk_lebian_download_progress
,download_progress as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"$part_event"
    ,"#event_time"
    ,"$part_date"
    ,"#zone_offset"
   ,"#country_code"
   ,"#country"
   ,"#device_id"
   ,"#app_version"
   ,"app_name"
   ,"sdk_version"
   ,"server_id"
   ,"server_name"
   from v_event_15  
   where "$part_event"='sdk_lebian_download_progress' 
   and ${PartDate:date} 
   and isTraffic=0
   
)

-- 下载资源完成 sdk_lebian_download_finish
,download_finish as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"$part_event"
    ,"#event_time"
    ,"$part_date"
    ,"#zone_offset"
   ,"#country_code"
   ,"#country"
   ,"#device_id"
   ,"#app_version"
   ,"app_name"
   ,"sdk_version"
   ,"server_id"
   ,"server_name"
   from v_event_15  
   where "$part_event"='sdk_lebian_download_finish' 
   and ${PartDate:date} 
   and isTraffic=0
   
)

-- select *
-- from click_download

-- 各个环节的下载漏斗 #app_version = '0.0.17' no wifi流量环境
,dialog_show_num as(
select 
   "#device_id"
   ,count(distinct "#device_id") as dialog_show
from dialog_show
group by 1   
)

,click_download_num as(
select 
   "#device_id"  
   ,count(distinct "#device_id") as click_download
from click_download
group by 1   
)
,click_start_num as(
select 
   "#device_id"
   ,count(distinct "#device_id") as click_start
from download_start
group by 1   
)

select 
   a."#device_id"
   ,a.dialog_show
   ,b.click_download
   ,c.click_start
from dialog_show_num a
left join click_download_num b on a."#device_id" = b."#device_id"
left join click_start_num c on a."#device_id" = c."#device_id"

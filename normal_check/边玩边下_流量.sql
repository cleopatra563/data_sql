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
    ,"#uuid"
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
    ,"#uuid"
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
   and isTraffic=1
)

-- 弹窗点击以后下载 sdk_lebian_dialog_click_later
,click_later as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"#uuid"
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
   and isTraffic=1
)

-- 开始下载 sdk_lebian_dialog_download_start/sdk_lebian_download_start
,download_start as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"#uuid"
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
   and isTraffic=1
)

-- 下载进度 （25% 50% 75%三节点上报） sdk_lebian_download_progress
,download_progress as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"#uuid"
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
   and isTraffic=1
   
)

-- 下载资源完成 sdk_lebian_download_finish
,download_finish as(
   select 
    "#user_id"
    ,"#account_id"
    ,"#distinct_id"
    ,"#uuid"
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
   and isTraffic=1
   
)

-- select *
-- from click_download

-- 各个环节的下载漏斗 #app_version = '0.0.17' no wifi流量环境
,dialog_show_device_num as(
select 
   "#device_id"
   ,count(*) as dialog_show
from dialog_show
group by 1   
)

,click_download_device_num as(
select 
   "#device_id"  
   ,count(*) as click_download
from click_download
group by 1   
)

,download_start_device_num as(
select 
   "#device_id"
   ,count(*) as download_start
from download_start
group by 1   
)

,download_progress_device_num as(
select 
    "#device_id"
    ,count(*) as download_progress
from download_progress 
group by 1
)

,download_finish_device_num as(
select 
   "#device_id"
   ,count(*) as download_finish
from download_finish
group by 1   
)

-- select 
--    a."#device_id"
--    ,a.dialog_show
--    ,b.click_download
--    ,d.download_start
--    ,e.download_progress
--    ,f.download_finish
-- from dialog_show_num a
-- left join click_download_num b on a."#device_id" = b."#device_id"
-- left join download_start_num d on a."#device_id" = d."#device_id"
-- left join download_progress_num e on a."#device_id" = e."#device_id"
-- left join download_finish_num f on a."#device_id" = f."#device_id"

-- select "#device_id",*
-- from dialog_show
-- where "#device_id" = '9383cb203233a548'
-- order by "#event_time"

-- 按照device_id分组，统计对应行数
-- count(*)


select 
   date(a."#event_time") as dt 
   ,count(distinct a."#device_id") as dialog_show_num
   ,count(distinct b."#device_id") as click_download_num
   ,count(distinct c."#device_id") as download_start_num
   ,count(distinct d."#device_id") as download_progress_num
   ,count(distinct e."#device_id") as download_finish_num
from dialog_show a 
left join click_download b on a."#device_id" = b."#device_id" and date(a."#event_time") = date(b."#event_time")
left join download_start c on a."#device_id" = c."#device_id" and date(a."#event_time") = date(c."#event_time")
left join download_progress d on a."#device_id" = d."#device_id" and date(a."#event_time") = date(d."#event_time")
left join download_finish e on a."#device_id" = e."#device_id" and date(a."#event_time") = date(e."#event_time")
group by 1

select 
from dialog_show a  
left join 
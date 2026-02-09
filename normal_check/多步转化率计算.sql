-- sdk_lebian_check_download_status
-- sdk_lebian_download_start
-- sdk_lebian_download_progress
--     download_label '25%' '50%' '75%'
-- sdk_lebian_download_finish
-- 'enter_game','item_change','guide'

with time_conf as (select '2026-02-03 15:00:00' as conf)
,base as (
select 
    "#device_id"device_id
    ,array_agg(distinct "#country")[1] as country
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_check_download_status') as check_download_status
    ,count(distinct "#device_id")filter(where "$part_event" ='sdk_lebian_download_start') as download_start
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_download_progress' and download_label = '25%') as download_progress_25
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_download_progress' and download_label = '50%') as download_progress_50
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_download_progress' and download_label = '75%') as download_progress_75
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_download_finish') as download_finish
    ,count(distinct "#device_id")filter(where "$part_event" in ('enter_game','item_change','guide')) as enter_game
    ,count(distinct "#device_id")filter(where "$part_event" in ('sdk_lebian_download_start','sdk_lebian_download_finish')) as label
from ta.v_event_15
where 1=1
    and "$part_date" >= '2026-02-03'
    and "#event_time" >= (select cast(conf as timestamp) from time_conf) 
    and '#device_id' is not null 
group by "#device_id"
)

,country_agg as(
select 
    country as "国家"
    ,case when label = 1 then '边玩边下' else '无边玩边下' end as "更新方式"
    ,count(distinct device_id) as "设备数"
    ,sum(check_download_status) as "下载资源检查"
    ,sum(download_start) as "下载开始"
    ,sum(download_progress_25) as "25%下载进度"
    ,sum(download_progress_50) as "50%下载进度"
    ,sum(download_progress_75) as "75%下载进度"
    ,sum(download_finish) as "下载完成"
    ,sum(enter_game) as "进入游戏"
    ,cast(sum(enter_game) as double) / nullif(count(distinct device_id),0) as "设备转化率"
from base
group by country,label
)

,all_agg as(
select 
    '合计' as "国家"
    ,case when label = 1 then '边玩边下' else '无边玩边下' end as "更新方式"
    ,count(distinct device_id) as "设备数"
    ,sum(check_download_status) as "下载资源检查"
    ,sum(download_start) as "下载开始"
    ,sum(download_progress_25) as "25%下载进度"
    ,sum(download_progress_50) as "50%下载进度"
    ,sum(download_progress_75) as "75%下载进度"
    ,sum(download_finish) as "下载完成"
    ,sum(enter_game) as "进入游戏"
    ,cast(sum(enter_game) as double) / nullif(count(distinct device_id),0) as "设备转化率"
    -- ,cast( as double) / nullif(,0)
from base
group by label   
)

select *
from 
(select * from country_agg) 
union all
(select * from all_agg)

-- SQL伪代码编写
union all 
(

select 
    '合计' as "国家" 
    ,label as "更新方式"
from your_table

)


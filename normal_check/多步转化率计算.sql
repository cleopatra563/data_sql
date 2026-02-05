-- sdk_lebian_check_download_status
-- sdk_lebian_download_start
-- sdk_lebian_download_progress
--     download_label '25%' '50%' '75%'
-- sdk_lebian_download_finish
-- 'enter_game','item_change','guide'

with time_conf as (select '2026-02-03 15:00:00' as conf)

select 
    "#device_id"device_id
    ,case when "#country_code" = 'HK' then '香港' 
          when "#country_code" = 'TW' then '台湾'
          when "#country_code" = 'ID' then '印尼'
          else array_agg(distinct "country")[1] end as country
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_check_download_status') as check_download_status
    ,count(distinct "#device_id")filter(where "$part_event" ='sdk_lebian_download_start') as download_start
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_download_progress' and download_label = '25%') as download_progress_25
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_download_progress' and download_label = '50%') as download_progress_50
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_download_progress' and download_label = '75%') as download_progress_75
    ,count(distinct "#device_id")filter(where "$part_event" = 'sdk_lebian_download_finish') as download_finish
    ,count(distinct "#device_id")filter(where "$part_event" in ('enter_game','item_change','guide')) as enter_game
    , as label
from ta.v_event_15
where 1=1
    and "$part_date" >= '2026-02-03'
    and "#event_time" >= (select cast(conf as timestamp) from time_conf) 
group by "#devict_id"

  
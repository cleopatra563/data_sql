with df as (select 
            role_id as "#account_id",reg_time as "#event_time"
            ,role_id
            ,'【20251229】CBT3测'test_label
            ,reg_country
            ,reg_time
            ,reg_date
            ,reg_local_time
            ,cast(reg_local_time as date)reg_local_date
            ,reg_pack
            ,reg_app_version
            ,install_time
            ,install_local_time
            ,device_id
            from  
                (
                SELECT "#account_id"role_id,"#country"reg_country,"#bundle_id"reg_pack,"$part_date"reg_date,"#event_time"reg_time
                ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30))
                    , date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "#event_time"), "#event_time")reg_local_time
                , "#app_version"reg_app_version
                ,"#install_time"install_time
                ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30))
                    , date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "#event_time"), "#install_time")install_local_time
                ,row_number()over(partition by "#account_id" order by cast("#event_time" as timestamp))rn   
                ,"#device_id"device_id
                FROM v_event_4 
                WHERE "$part_event" in ('ta_app_start','enter_game','lobby_enter','login_client')
                AND "$part_date" between '2025-12-29' and '2026-01-10' 
                and "#app_version" like '%1.8%'
                )t      
            where rn = 1
            )
,df1 as (
        select df.*,is_keep2,is_keep3,is_keep4,is_keep5,is_keep6,is_keep7,lt as lt_cnt
        from  
            df     
        left join   
            (
                select role_id
                ,count(distinct role_id)filter(where day_diff = 2)is_keep2
                ,count(distinct role_id)filter(where day_diff = 3)is_keep3
                ,count(distinct role_id)filter(where day_diff = 4)is_keep4
                ,count(distinct role_id)filter(where day_diff = 5)is_keep5
                ,count(distinct role_id)filter(where day_diff = 6)is_keep6
                ,count(distinct role_id)filter(where day_diff = 7)is_keep7
                ,count(distinct local_date)filter(where day_diff <= 7)lt
                from  
                (
                select a.*,reg_local_date
                ,date_diff('day',reg_local_date,local_date) + 1 day_diff
                from  
                    (
                    select distinct "#account_id"role_id
                    ,cast(IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30))
                    ,date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "#event_time"), "#event_time") as date)local_date
                    FROM v_event_4 
                    WHERE "$part_event" in ('ta_app_start','enter_game','lobby_enter','login_client')
                    AND "$part_date" between '2025-12-29' and '2026-01-10' 
                    and "#account_id" in (select distinct role_id from df)
                    and "#app_version" like '%1.8%'
                    )a 
                left join 
                    (select distinct role_id,reg_local_date from df)b 
                on a.role_id = b.role_id
                )t      
            group by role_id  
            )t2      
        on df.role_id = t2.role_id  
        )
,df2 as (
        select * ,row_number()over(partition by role_id order by "local_date" desc)rn2  
        from  
            (
            SELECT "#account_id"role_id
            ,reg_local_date
            ,"$part_date"log_date
            ,cast(IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "#event_time"), "#event_time") as date)local_date
            ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "#event_time"), "#event_time")local_time1
            ,"$part_event"event1
            ,sub_game_name
            ,end_type
            ,level
            ,lead(IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "#event_time"), "#event_time"))over(partition by "#user_id" order by "#event_time")local_time2
            ,lead("$part_event")over(partition by "#account_id" order by "#event_time")event2
            ,lead("end_type")over(partition by "#account_id" order by "#event_time")end_type2
            ,row_number()over(partition by "#account_id" order by "#event_Time")rn    
            FROM v_event_4 a left join  (select distinct role_id,reg_local_date from df)b on a."#account_id" = b.role_id
            WHERE "$part_event" in ('game_start','game_end')
            AND "$part_date" between '2025-12-29' and '2026-01-10' 
            and "#account_id" in (select distinct role_id from df)
            and "#app_version" like '%1.8%'
            )t      
        where reg_local_date = local_date
        )
,df3 as (
      select a.*
      ,day1_sub_game_name
        ,day1_sub_game_reason_cnt
        ,day1_sub_game_reason_win_cnt
        ,day1_sub_game_reason_fail_cnt
        ,day1_sub_game_uptime
        ,day1_sub_game_win_uptime
        ,day1_sub_game_fail_uptime
        ,day1_game_reason_cnt
        ,day1_sub_game_cnt
        ,day1_total_win_reason_cnt
        ,day1_total_fail_reason_cnt
        ,day1_total_game_uptime
        ,day1_last_sub_game_name
        ,day1_is_sign
        ,day1_gold_getnum
        ,day1_unblock_gamenum
        ,day1_is_ad_rewarded
      from  
      df1 a left join  
      (
        select 
             a.role_id
            ,a.sub_game_name as day1_sub_game_name
            ,day1_sub_game_reason_cnt
            ,day1_sub_game_reason_win_cnt
            ,day1_sub_game_reason_fail_cnt
            ,day1_sub_game_uptime
            ,day1_sub_game_win_uptime
            ,day1_sub_game_fail_uptime
            ,day1_game_reason_cnt
            ,day1_sub_game_cnt
            ,day1_total_win_reason_cnt
            ,day1_total_fail_reason_cnt
            ,day1_total_game_uptime
            ,day1_last_sub_game_name
            ,day1_is_sign
            ,day1_gold_getnum
            ,day1_unblock_gamenum
            ,day1_is_ad_rewarded
        from  
              (select role_id,sub_game_name from df2 where rn = 1)a     
        left join 
              (select role_id,sub_game_name
              ,count(distinct local_time1)filter(where event1 = 'game_start')day1_sub_game_reason_cnt
              ,count(distinct local_time1)filter(where event1 = 'game_start' and end_type2 = 'win')day1_sub_game_reason_win_cnt
              ,count(distinct local_time1)filter(where event1 = 'game_start' and end_type2 = 'lose')day1_sub_game_reason_fail_cnt
              ,sum(date_diff('second',local_time1,local_time2))filter(where event1 = 'game_start' and event2 = 'game_end')day1_sub_game_uptime
              ,sum(date_diff('second',local_time1,local_time2))filter(where event1 = 'game_start' and event2 = 'game_end' and end_type2 = 'win')day1_sub_game_win_uptime
              ,sum(date_diff('second',local_time1,local_time2))filter(where event1 = 'game_start' and event2 = 'game_end' and end_type2 = 'lose')day1_sub_game_fail_uptime
              from df2 
              group by role_id,sub_game_name
              )b on a.role_id = b.role_id and a.sub_game_name = b.sub_game_name
        left join    
             (
             select role_id
            ,count(distinct local_time1)filter(where event1 = 'game_start')day1_game_reason_cnt
            ,count(distinct sub_game_name)filter(where event1 = 'game_start')day1_sub_game_cnt
            ,count(distinct local_time1)filter(where event1 = 'game_start'  and event2 = 'game_end' and end_type2 = 'win' )day1_total_win_reason_cnt
            ,count(distinct local_time1)filter(where event1 = 'game_start'  and event2 = 'game_end' and end_type2 = 'lose' )day1_total_fail_reason_cnt
            ,sum(date_diff('second',local_time1,local_time2))filter(where event1 = 'game_start' and event2 = 'game_end')day1_total_game_uptime
            from    
            df2
            group by role_id
             )c on a.role_id = c.role_id
        left join  
            (select role_id,sub_game_name as day1_last_sub_game_name from df2 where rn2 = 1)d on a.role_id = d.role_id
        left join  
            (
            select role_id 
            ,count(distinct role_id)filter(Where "$part_event" = 'event_sign_in')day1_is_sign
            ,sum(coin_get_number)filter(where "$part_event" = 'coin_get_number')day1_gold_getnum
            ,count(distinct "#event_Time")filter(Where "$part_event" = 'game_unlock')day1_unblock_gamenum
            ,count(distinct role_id)filter(Where "$part_event" = 'ad_rewarded')day1_is_ad_rewarded
            from  
                (
                SELECT "#account_id"role_id,"#distinct_id","$part_event","#event_time",coin_get_number
                ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "#event_time"), "#event_time")local_time
                ,reg_local_date
                FROM v_event_4 a left join  (select distinct role_id,reg_local_date from df)b on a."#account_id" = b.role_id
                WHERE "$part_event" in ('coin_get','event_sign_in','ad_rewarded','game_unlock')
                AND "$part_date" between '2025-12-29' and '2026-01-10' 
                )t      
            where cast(local_time as date) = reg_local_date   
            group by role_id
           )e on a.role_id = e.role_id
        )b on a.role_id = b.role_id
    )
,df4 as (
        select a.*,ad_id,ad_game_sub_name,ad_game_name
        from 
            df3 a 
        left join  
            (
            SELECT "#account_id"
            ,te_ads_object.ad_group_id as ad_id
            ,te_ads_object.ad_group_name as ad_game_sub_name
            ,split_part(te_ads_object.ad_group_name,'-',2)ad_game_name
            ,te_ads_object
            FROM ta.v_user_4 
            where te_ads_object.ad_group_id is not null
            )b on a.role_id = b."#account_id"
        )
        
select * 
,'og_gbt3_game_event'"#event_name"
from   
df4
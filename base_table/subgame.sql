with df as (
            select *,date_diff('day',reg_local_date,local_date)+1 day_diff
            from  
                (
                select distinct role_id,sub_game_name,cast(local_time as date)local_date
                ,cast(IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "sub_game_reg_time"), "sub_game_reg_time") as date)reg_local_date
                ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "sub_game_reg_time"), "sub_game_reg_time") 
                sub_game_reg_local_time
                FROM 
                    (
                    SELECT "#account_id"role_id,"#event_time"log_time,"$part_date"log_date,sub_game_name
                    ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST(((8 - "#zone_offset") * 3600) AS integer), "#event_time"), "#event_time")local_time
                    ,min("#event_time")over(partition by "#account_id",sub_game_name order by "#event_time")sub_game_reg_time
                    ,"#zone_offset"
                    FROM v_event_4
                    WHERE sub_game_name IS NOT NULL
                    AND "$part_event" IN ('game_start')
                    AND "$part_date" between '2025-12-29' and '2026-01-10'
                    and "#app_version" like '%1.8%'
                    and "#account_id" is not null
                    order by role_id,"#event_time"
                    )t     
                )t1
            order by role_id,sub_game_name,local_date
            )                        
,df1 as (            
        select reg_local_date,a.*
        FROM 
            (
            SELECT "#account_id"role_id
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
            FROM v_event_4 
            WHERE "$part_event" in ('game_start','game_end')
            AND "$part_date" between '2025-12-29' and '2026-01-10' 
            and "#account_id" in (select distinct role_id from df)
            and "#app_version" like '%1.8%'
            order by "#account_id","#event_time"
            )a left join (select distinct role_id,sub_game_name,reg_local_date from df)b on a.role_id = b.role_id and a.sub_game_name = b.sub_game_name
        )
,df2 as (
        select role_id,sub_game_name,local_date
        ,count(distinct local_time1)filter(where event1 = 'game_start')day1_reason_cnt
        ,count(distinct local_time1)filter(where event1 = 'game_start' and event2 = 'game_end' and end_type2 = 'win')day1_win_reason_cnt
        ,count(distinct local_time1)filter(where event1 = 'game_start' and event2 = 'game_end' and end_type2 = 'lose')day1_fail_reason_cnt
        ,sum(date_diff('second',local_time1,local_time2))filter(where event1 = 'game_start' and event2 = 'game_end')day1_sub_game_uptime
        ,sum(date_diff('second',local_time1,local_time2))filter(where event1 = 'game_start' and event2 = 'game_end' and end_type2 = 'win')day1_sub_game_win_uptime
        ,sum(date_diff('second',local_time1,local_time2))filter(where event1 = 'game_start' and event2 = 'game_end' and end_type2 = 'lose')day1_sub_game_fail_uptime
        ,count(distinct level)level_cnt
        ,max(cast(level as double))max_level
        ,min(cast(level as double))min_level
        FROM  
        df1
        where reg_local_date = local_date
        group by role_id,sub_game_name,local_date
        ) 
,df3 as (
        select a.*
        ,day1_reason_cnt
        ,day1_win_reason_cnt
        ,day1_fail_reason_cnt
        ,day1_sub_game_uptime
        ,day1_sub_game_win_uptime
        ,day1_sub_game_fail_uptime
        ,level_cnt
        ,max_level
        ,min_level
        ,"reg_country"
        ,"ad_id"
        ,"ad_game_sub_name"
        ,"ad_game_name"
        ,"reg_time","reg_date","reg_local_time",c."reg_local_date" as reg_local_date1
        ,day1_game_reason_cnt
        from   
            (
            select role_id,sub_game_name,reg_local_date,sub_game_reg_local_time
            ,count(distinct role_id)filter(where day_diff = 2)is_keep2
            ,count(distinct role_id)filter(where day_diff = 3)is_keep3
            ,count(distinct role_id)filter(where day_diff = 4)is_keep4
            ,count(distinct role_id)filter(where day_diff = 5)is_keep5
            ,count(distinct role_id)filter(where day_diff = 6)is_keep6
            ,count(distinct role_id)filter(where day_diff = 7)is_keep7
            ,count(distinct local_date)filter(where day_diff <= 7)lt
            FROM 
            df
            group by role_id,sub_game_name,reg_local_date,sub_game_reg_local_time
            )a  
        left join df2 b on a.role_id = b.role_id and a.sub_game_name =b.sub_game_name
        left join (SELECT "#account_id"role_id,"reg_country","ad_id","ad_game_sub_name","ad_game_name","reg_time","reg_date","reg_local_time","reg_local_date",day1_game_reason_cnt FROM temp.gbt3_game_base_table)c on a.role_id = c.role_id
        )
        
        
select 
role_id
,'og_gbt3_sub_game_event'"#event_name"
,ad_id
,ad_game_sub_name
,ad_game_name
,'【20251229】CBT3测'test_label
,reg_time
,reg_date
,reg_local_time
,reg_local_date1"reg_local_date"
,reg_country
,day1_game_reason_cnt
,sub_game_name
,reg_local_date as sub_game_reg_local_date
,sub_game_reg_local_time
,is_keep2
,is_keep3
,is_keep4
,is_keep5
,is_keep6
,is_keep7
,lt
,day1_reason_cnt
,day1_win_reason_cnt
,day1_fail_reason_cnt
,day1_sub_game_uptime
,day1_sub_game_win_uptime
,day1_sub_game_fail_uptime
,level_cnt
,max_level
,min_level
FROM  
df3 


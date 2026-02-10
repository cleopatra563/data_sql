with timconf as (select timestamp '2026-02-07 00:00:00' as conf) 

select   
    dt
    ,tag_value
    ,sum(duration) / count(distinct role_id) as avg_duration
from(
    select a.*,b.tag_value 
    from(
        select "#event_time"log_time,"$part_date"dt,role_id,round(cast("#duration" as double)/60,2) as duration
               ,row_number() over(partition by role_id order by "#event_time") as rn   
               ,round(sum(cast("#duration" as double)/60) over(partition by role_id,"$part_date" order by "#event_time"),2) as total_duration
        from ta.v_event_15
        where "$part_event" in ('ta_app_end')
            -- and "#event_time" >=  (select conf from timconf)
            and "$part_date" >= '2026-02-08'
        )  a   
    left join (select "#varchar_id",tag_value from user_result_cluster_15 where "cluster_name"='role_reg_country_cbt1' ) b on a.role_id = b."#varchar_id"
    where (role_id is not null) and (tag_value is not null)
    )c     
group by dt,tag_value


SELECT  
    grouping(group_0) group_bit, group_0 , count(1) user_num
    , retention_lost_date_collect_agg(init_date_array,coalesce(return_date_array,X''),7,'day') retention_lost_data 
FROM ( 
    SELECT group_rows[1] group_0 , virtual_user_id, init_date_array, return_date_array 
    FROM ( 
        SELECT "min_by"(row( group_0 ), "@vpc_tz_#event_time") filter (where "@is_init") group_rows, virtual_user_id, ta_date_collect("@trunc_date") filter (where "@is_init") init_date_array, ta_date_collect("@trunc_date") filter (where "@is_return") return_date_array 
        FROM ( 
            SELECT group_0 , virtual_user_id, "@vpc_tz_#event_time", ta_date_trunc('day',"@vpc_tz_#event_time",1) "@trunc_date", "@is_init", "@is_return" FROM ( select "@vpc_cluster_role_ad_group_name" group_0 , true "@is_init", false "@is_return", * 
            FROM (
                select *, "role_id" virtual_user_id 
                from ( 
                    select *, "#event_time" "@vpc_tz_#event_time" 
                    from (
                        select *, try_cast(try(IF(("#event_time" = "@vpc_cluster_role_reg_time_cbt1"), 1, 0)) as double) "#vp@is_first_reg_cbt1" 
                        from (
                            select a.*,"@vpc_cluster_role_ad_group_name","@vpc_cluster_role_reg_time_cbt1" 
                            from (
                                select "#event_name" "#event_name","#event_time" "#event_time","#user_id" "#user_id","$part_date" "$part_date","$part_event" "$part_event","role_id" "role_id" 
                                from (
                                    select "#user_id", "role_id" "role_id","#event_time" "#event_time","$part_event" "$part_event","$part_date" "$part_date","#event_name" "#event_name" 
                                    from v_event_15 
                                    where "$part_event" in ('enter_game'))) a 
                                    left join (select "#varchar_id" "id",arbitrary(if(cluster_name = 'role_ad_group_name', tag_value, null)) "@vpc_cluster_role_ad_group_name",arbitrary(if(cluster_name = 'role_reg_time_cbt1', tag_value_tm, null)) "@vpc_cluster_role_reg_time_cbt1" 
                                    from user_result_cluster_15 
                                    where (cluster_name = 'role_ad_group_name') or (cluster_name = 'role_reg_time_cbt1') 
                                    group by "#varchar_id") b0 on a."role_id"=b0."id")) )) 
                        WHERE ( ( "$part_event" IN ( 'enter_game' ) ) ) AND ("$part_date" between '2026-02-02' and '2026-02-08') AND ( ( "#vp@is_first_reg_cbt1" IN (1) ) ) 
                        union all select "@vpc_cluster_role_ad_group_name" group_0 , false "@is_init", true "@is_return", * FROM (select *, "role_id" virtual_user_id from ( select *, "#event_time" "@vpc_tz_#event_time" from (select *, try_cast(try(IF(("#event_time" = "@vpc_cluster_role_reg_time_cbt1"), 1, 0)) as double) "#vp@is_first_reg_cbt1" from (select a.*,"@vpc_cluster_role_ad_group_name","@vpc_cluster_role_reg_time_cbt1" from (select "#event_name" "#event_name","#event_time" "#event_time","#user_id" "#user_id","$part_date" "$part_date","$part_event" "$part_event","role_id" "role_id" from (select "#user_id", "role_id" "role_id","#event_time" "#event_time","$part_event" "$part_event","$part_date" "$part_date","#event_name" "#event_name" from v_event_15 where "$part_event" in ('setting_type','role_rename','main_stage_into','item_change','enter_game','main_stage_end','main_stage_start','role_levelup','offline','card_levelup','equip_log','map','seven_days_sign_in','guide','drawcard_log'))) a left join (select "#varchar_id" "id",arbitrary(if(cluster_name = 'role_ad_group_name', tag_value, null)) "@vpc_cluster_role_ad_group_name",arbitrary(if(cluster_name = 'role_reg_time_cbt1', tag_value_tm, null)) "@vpc_cluster_role_reg_time_cbt1" from user_result_cluster_15 where (cluster_name = 'role_ad_group_name') or (cluster_name = 'role_reg_time_cbt1') group by "#varchar_id") b0 on a."role_id"=b0."id")) )) WHERE ( ( ( ( "$part_event" IN ( 'card_levelup' ) ) OR ( "$part_event" IN ( 'drawcard_log' ) ) OR ( "$part_event" IN ( 'enter_game' ) ) OR ( "$part_event" IN ( 'equip_log' ) ) OR ( "$part_event" IN ( 'guide' ) ) OR ( "$part_event" IN ( 'item_change' ) ) OR ( "$part_event" IN ( 'main_stage_end' ) ) OR ( "$part_event" IN ( 'main_stage_into' ) ) OR ( "$part_event" IN ( 'main_stage_start' ) ) OR ( "$part_event" IN ( 'map' ) ) OR ( "$part_event" IN ( 'offline' ) ) OR ( "$part_event" IN ( 'role_levelup' ) ) OR ( "$part_event" IN ( 'role_rename' ) ) OR ( "$part_event" IN ( 'setting_type' ) ) OR ( "$part_event" IN ( 'seven_days_sign_in' ) ) ) ) ) AND ("$part_date" between '2026-02-02' and '2026-02-15') ) ta_ev where virtual_user_id is not null ) GROUP BY virtual_user_id HAVING bool_or("@is_init") ) ) group by GROUPING SETS( ( group_0 ), ( )) 
order by group_bit desc, user_num desc limit 1003


with register as (
select *
      ,IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST((("#zone_offset"-8) * 3600) AS integer), reg_time), reg_time) as reg_local_time
      ,cast(IF((("#zone_offset" IS NOT NULL) AND ("#zone_offset" >= -30) AND ("#zone_offset" <= 30)), date_add('second', CAST((("#zone_offset"-8) * 3600) AS integer), reg_time), reg_time) as date) as reg_local_date
from (
    select 
        "#device_id" as device_id
        ,role_id 
        ,"#event_time" as reg_time 
        ,"$part_date" as reg_date
        ,"#zone_offset"
        ,"#country"country
        ,row_number() over(partition by "role_id" order by "#event_time") as rn
    from ta.v_event_15
    where "$part_date" >= '2026-02-02'
        and "$part_event" in ('enter_game','item_change','guide')
        and "#distinct_id" != 'test'
    ) a     
where rn = 1
)

select log_date,reg_date
      ,count(distinct role_id) as "总活跃角色数"
      ,count(distinct role_id) filter(where duration < 1 and duration >0) as "0~1min"
      ,count(distinct role_id) filter(where duration <2 and duration >=1) as "1~2min"
      ,count(distinct role_id) filter(where duration <5 and duration >=2) as "2~5min"
      ,cast(count(distinct role_id) filter(where duration < 1 and duration >0) as double) / nullif(count(distinct role_id),0) as "0~1min占比"
from (
    select 
        a.*,b.reg_date
    from(
    select role_id,"$part_date"log_date,sum(round(cast("#duration"/60 as double),2)) as duration
    from ta.v_event_15 
    where "$part_date" >= '2026-02-02'
        and "$part_event" in ('ta_app_end')
    group by 1,2
        ) a                  
    left join register b on a.role_id = b.role_id
        and a.log_date >= b.reg_date
        ) t1  
where reg_date is not null
group by log_date,reg_date
order by log_date desc,reg_date desc

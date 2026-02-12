select role_id,array_agg(distinct ad_group_name)filter(where ad_group_name is not null)[1] as ad_group_name
from  
    (
    select a.*,ad_group_name
    from  
        (
        SELECT distinct role_id,"#user_id"
        FROM ta.v_event_15 
        WHERE "$part_date" >= '2026-02-03' 
        and role_id  in (SELECT "#varchar_id"  FROM user_result_cluster_15 WHERE "cluster_name"='role_reg_time_cbt1') 
        )a      
    left join   
        (
        SELECT distinct "#user_id"
        ,te_ads_object.ad_group_name
        FROM ta.v_user_15 where te_ads_object is not null 
        )b    
    on a."#user_id" = b."#user_id"
    )t      
group by role_id

-- 素材标签
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
,user_ad_id as(
SELECT 
     te_ads_object.ad_id
    ,te_ads_object.ad_group_name
    ,"#user_id"
FROM ta.v_user_15 
where te_ads_object.ad_id is not null 
)

-- 素材标签
select a.role_id,array_agg(c.ad_group_name)[1] as ad_group_name
from(
    select role_id,"$part_date" log_date,"#event_time"log_time,"#user_id"
    from ta.v_event_15
    where "$part_date" >= '2026-02-02'
        and role_id in (select "#varchar_id" from user_result_cluster_15 where "cluster_name"='role_reg_time_cbt1' )
    ) a        
left join user_ad_id c    
    on a."#user_id" = c."#user_id"
where ad_group_name is not null
group by 1
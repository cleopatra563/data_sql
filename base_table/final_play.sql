with base as(
select 
"$part_date" dt   
,"#account_id"role_id
,sub_game_name
,level    
from ta.v_event_4 
where "$part_date" >= '2025-12-29' and "$part_event" in ('game_end')
group by 1,2,3,4    
),
final as(
-- final_dt   is_final
select role_id
       ,sub_game_name
       ,level         
       ,dt      
       ,final_dt   
       ,count(distinct role_id) filter(where day_diff =0 ) is_final
from(
    select *
          ,date_diff('day',date(dt),date(final_dt)) as day_diff
    from (
        select 
            role_id
            ,sub_game_name
            ,level
            ,dt
            ,last_value(dt) over(partition by role_id,sub_game_name order by level,dt rows BETWEEN unbounded preceding AND unbounded following) as final_dt
        from base 
            )
        )
group by 1,2,3,4,5
    )
    
select  
    dt  
    ,sub_game_name
    ,level           
    ,count(distinct role_id) filter(where is_final = 1) as churn_num
from final 
group by 1,2,3  
order by dt asc
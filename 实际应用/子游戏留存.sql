with df as(
-- 一个日期+一个角色+一个子游戏
SELECT "#account_id"role_id
        ,sub_game_name
        ,game_id
        ,"level"
        ,end_type
        ,"#event_time" event_time
        ,"$part_date" log_date
        ,min("#install_time") over(partition by "#account_id" order by "#event_time") as reg_date
        ,last_value ("#event_time") over(partition by "#account_id" order by "#event_time" rows between unbounded preceding and unbounded following) as last_log_date
    FROM v_event_4 
    WHERE "$part_event"='game_start' 
        AND "$part_date" between '2025-12-29' and cast(now()-interval '1' day as varchar)
        -- AND  game_type != 999  
        AND level > 0
        AND "#bundle_id" in ('live.joyplay.offlinegame')
        AND "#app_version" like '%1.8%'
)

select date(reg_date) as reg_date
      ,sub_game_name
      ,"sub_game_name@cn"
      ,country
      ,count(distinct role_id) as "游玩人数"
      ,cast(count(distinct role_id) filter(where day_diff = 2) as double) / count(distinct role_id) as "次留"
      ,cast(count(distinct role_id) filter(where day_diff = 3) as double) / count(distinct role_id) as "3留"
      ,cast(count(distinct role_id) filter(where day_diff = 7) as double) / count(distinct role_id) as "7留"
      ,cast(count(distinct role_id) filter(where day_diff = 15) as double) / count(distinct role_id) as "15留"
    from (
        select 
            a.role_id
            ,a.sub_game_name
            ,b."sub_game_name@cn"
            ,a.reg_date
            ,c.country
            ,date_diff('day',date(a.reg_date),date(a.log_date)) + 1 as day_diff
            from df a      
            left join (SELECT "sub_game_name@name","sub_game_name@cn","sub_game_name@id" FROM ta_dim.dim_4_0_260)b  
                on a.sub_game_name = b."sub_game_name@name" 
            left join (SELECT "#account_id"role_id,"#country"country from ta.v_event_4  where "$part_date">= '2025-04-01' and "$part_event" = 'game_start')c   
                on a.role_id = c.role_id
            )
    group by 1,2,3,4

-- select 
--     a.role_id
--     ,a.sub_game_name
--     ,a.reg_date
--     ,date_diff('day',date(a.reg_date),date(a.log_date)) + 1 as day_diff
--     from df a      
--     left join (SELECT "sub_game_name@name","sub_game_name@cn","sub_game_name@id" FROM ta_dim.dim_4_0_260)b  
--         on a.sub_game_name = b."sub_game_name@name"

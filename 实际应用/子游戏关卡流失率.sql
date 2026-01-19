-- 子游戏关卡流失人数分析
with -- 子游戏结束
sub_game_finish_log as(
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
    WHERE "$part_event"='game_end' 
        AND "$part_date" between '2025-12-29' and cast(now()-interval '1' day as varchar)
        AND  game_type != 999  
        AND level > 0
        AND "#bundle_id" in ('live.joyplay.offlinegame')
        AND "#app_version" like '%1.8%'
), 
-- 添加状态标记的游戏日志
marked_game_log AS (
    SELECT 
        *,
        CASE 
            WHEN event_time = last_log_date THEN 1
            ELSE 0
        END AS is_churn
    FROM sub_game_finish_log
)
-- 统计每个日期、每个子游戏、每个关卡的流失数据
SELECT 
    log_date, -- 日期
    game_id, -- 游戏ID
    sub_game_name, -- 游戏名称
    "level", -- 关卡ID
    COUNT(DISTINCT role_id) FILTER (WHERE is_churn = 1) AS "流失人数",
    COUNT(DISTINCT role_id) AS "关卡总人数",
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT role_id) = 0 THEN 0
            ELSE cast(COUNT(DISTINCT role_id) FILTER (WHERE is_churn = 1) as double) / COUNT(DISTINCT role_id) 
        END,
        2
    ) AS "关卡流失率"
FROM marked_game_log
GROUP BY 
    log_date,
    game_id,
    sub_game_name,
    "level"
ORDER BY 
    log_date,
    game_id,
    sub_game_name, 
    "level" 

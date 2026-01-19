-- 子游戏关卡流失与次日留存关系分析
WITH 
-- 基础数据：游戏结束事件
game_log AS (
    SELECT 
        "#account_id" role_id,
        sub_game_name,
        game_id,
        "level",
        end_type,
        "#event_time" event_time,
        "$part_date" log_date,
        -- 最后游戏时间
        MAX("#event_time") OVER (
            PARTITION BY "#account_id"
            ORDER BY "#event_time"
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_log_date
    FROM v_event_4
    WHERE 
        "$part_event" = 'game_end'
        AND "$part_date" BETWEEN '2025-12-29' AND CAST(current_date AS VARCHAR)
        AND game_type != 999
        AND "#bundle_id" IN ('live.joyplay.offlinegame')
        AND "#app_version" LIKE '%1.8%'
),
-- 每日活跃用户
DAU AS (
    SELECT 
        "$part_date" log_date,
        "#account_id" role_id,
        game_id,
        sub_game_name
    FROM v_event_4
    WHERE 
        "$part_event" = 'game_end'
        AND "$part_date" BETWEEN '2025-12-29' AND CAST(current_date AS VARCHAR)
        AND game_type != 999
        AND "#bundle_id" IN ('live.joyplay.offlinegame')
        AND "#app_version" LIKE '%1.8%'
    GROUP BY "$part_date", "#account_id", game_id, sub_game_name
),
-- 活跃用户次日留存标记
user_retention AS (
    SELECT 
        d.log_date,
        d.game_id,
        d.sub_game_name,
        d.role_id,
        CASE 
            WHEN nd.role_id IS NOT NULL THEN TRUE
            ELSE FALSE
        END AS is_retained_next_day
    FROM DAU d
    LEFT JOIN DAU nd ON 
        d.role_id = nd.role_id
        AND d.game_id = nd.game_id
        AND d.log_date = CAST(CAST(nd.log_date AS DATE) - INTERVAL '1' DAY AS VARCHAR)
),
-- 子游戏每日总流失（关卡维度）
game_churn_data AS (
    SELECT 
        log_date,
        game_id,
        sub_game_name,
        SUM(CASE WHEN event_time = last_log_date THEN 1 ELSE 0 END) AS total_churn
    FROM game_log
    GROUP BY log_date, game_id, sub_game_name
)
-- 最终分析：使用统一格式计算比率
SELECT 
    gr.log_date,
    gr.game_id,
    gr.sub_game_name,
    -- 流失人数
    gc.total_churn AS churn_count,
    -- 总活跃人数
    COUNT(DISTINCT gr.role_id) AS total_active_users,
    -- 次日留存人数
    COUNT(DISTINCT gr.role_id) FILTER (WHERE gr.is_retained_next_day = TRUE) AS next_day_retained_users,
    -- 次日留存率：完全符合要求的格式
    ROUND(
        CASE WHEN COUNT(DISTINCT gr.role_id) = 0 THEN 0
        ELSE (
            CAST(COUNT(DISTINCT gr.role_id) FILTER (WHERE gr.is_retained_next_day = TRUE) AS DOUBLE PRECISION) / 
            CAST(COUNT(DISTINCT gr.role_id) AS DOUBLE PRECISION)
        ) * 100
        END,
        2
    ) AS next_day_retention_rate,
    -- 流失率：基于活跃用户的定义
    ROUND(
        CASE WHEN COUNT(DISTINCT gr.role_id) = 0 THEN 0
        ELSE (
            CAST(COUNT(DISTINCT gl.role_id) FILTER (WHERE gl.event_time = gl.last_log_date) AS DOUBLE PRECISION) / 
            CAST(COUNT(DISTINCT gr.role_id) AS DOUBLE PRECISION)
        ) * 100
        END,
        2
    ) AS churn_rate
FROM user_retention gr
INNER JOIN game_churn_data gc ON 
    gr.log_date = gc.log_date
    AND gr.game_id = gc.game_id
    AND gr.sub_game_name = gc.sub_game_name
INNER JOIN game_log gl ON 
    gr.role_id = gl.role_id
    AND gr.log_date = gl.log_date
    AND gr.game_id = gl.game_id
    AND gr.sub_game_name = gl.sub_game_name
GROUP BY gr.log_date, gr.game_id, gr.sub_game_name, gc.total_churn
ORDER BY gr.log_date, gr.game_id, gr.sub_game_name;

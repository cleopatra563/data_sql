-- 子游戏关卡流失人数分析（优化版）
WITH sub_game_finish_log AS (
    -- 子游戏结束日志底表
    SELECT 
        "#account_id" AS role_id, -- 角色ID
        sub_game_name, -- 子游戏名称
        game_id, -- 游戏ID
        "level", -- 关卡ID
        end_type, -- 战斗结果
        "#event_time" AS event_time, -- 游戏时间
        "$part_date" AS log_date, -- 登录日期
        -- 显式声明窗口函数：计算每个角色的注册时间
        MIN("#install_time") OVER (
            PARTITION BY "#account_id"
            ORDER BY "#event_time"
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS reg_date,
        -- 显式声明窗口函数：计算每个角色的最后游戏时间
        MAX("#event_time") OVER (
            PARTITION BY "#account_id"
            ORDER BY "#event_time"
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_log_date
    FROM v_event_4
    WHERE 
        "$part_event" = 'game_end' -- 游戏结束事件
        AND "$part_date" BETWEEN '2025-12-29' AND CAST(current_date AS VARCHAR) -- 日期范围
        AND game_type != 999 -- 排除特定游戏类型
        AND "#bundle_id" IN ('live.joyplay.offlinegame') -- 特定应用包
        AND "#app_version" LIKE '%1.8%' -- 特定应用版本
),
-- 添加状态标记的游戏日志
marked_game_log AS (
    SELECT 
        *,
        -- 状态标记：是否为角色的最后一次游戏记录
        CASE 
            WHEN event_time = last_log_date THEN 1
            ELSE 0
        END AS is_last_record,
        -- 状态标记：是否为角色的流失记录（流失定义：该关卡是角色最后一次游戏）
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
    -- 基于状态标记统计流失人数：使用FILTER语法
    COUNT(DISTINCT role_id) FILTER (WHERE is_churn = 1) AS churn_count,
    -- 统计该日期该关卡的总玩家数
    COUNT(DISTINCT role_id) AS total_players,
    -- 计算流失率（处理除以零情况）
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT role_id) = 0 THEN 0
            ELSE (COUNT(DISTINCT role_id) FILTER (WHERE is_churn = 1)::NUMERIC / COUNT(DISTINCT role_id)::NUMERIC) * 100
        END,
        2
    ) AS churn_rate
FROM marked_game_log
GROUP BY 
    log_date,
    game_id,
    sub_game_name,
    "level"
ORDER BY 
    log_date, -- 按日期排序
    game_id, -- 按游戏ID排序
    sub_game_name, -- 按游戏名称排序
    "level"-- 按关卡ID排序


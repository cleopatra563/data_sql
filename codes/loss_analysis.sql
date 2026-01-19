WITH sub_game_finish_log AS (
    -- 基础表：获取所有子游戏结束事件，保留原始条件
    SELECT 
        "#account_id" role_id,
        sub_game_name,
        game_id,
        "level",
        end_type,
        "#event_time",
        "$part_date" log_date
    FROM v_event_4
    WHERE "$part_event" = 'game_end'
        AND "$part_date" BETWEEN '2025-12-29' AND CAST(current_date AS VARCHAR)
        AND game_type != 999
        AND "#bundle_id" IN ('live.joyplay.offlinegame')
        AND "#app_version" LIKE '%1.8%'
),
-- 步骤1：获取每个角色在每个游戏中每个关卡的最后一次挑战记录
player_level_last_attempt AS (
    SELECT 
        role_id,
        game_id,
        sub_game_name,
        "level",
        "#event_time",
        log_date
    FROM (
        SELECT 
            role_id,
            game_id,
            sub_game_name,
            "level",
            "#event_time",
            log_date,
            ROW_NUMBER() OVER (PARTITION BY role_id, game_id, "level" ORDER BY "#event_time" DESC) AS rn
        FROM sub_game_finish_log
    ) t
    WHERE rn = 1
),
-- 步骤2：找出每个角色在每个游戏中挑战过的最高关卡
player_max_level AS (
    SELECT 
        role_id,
        game_id,
        MAX("level") AS max_level_played
    FROM sub_game_finish_log
    GROUP BY role_id, game_id
)
-- 步骤3：统计每个日期每个游戏每个关卡的流失人数
SELECT 
    plla.log_date,
    plla.game_id,
    plla.sub_game_name,
    plla."level",
    COUNT(DISTINCT plla.role_id) AS churn_count
FROM player_level_last_attempt plla
INNER JOIN player_max_level pml
    ON plla.role_id = pml.role_id
    AND plla.game_id = pml.game_id
    AND plla."level" = pml.max_level_played -- 流失条件：该关卡是玩家挑战的最高关卡
GROUP BY plla.log_date, plla.game_id, plla.sub_game_name, plla."level"
ORDER BY plla.log_date, plla.game_id, plla.sub_game_name, plla."level";

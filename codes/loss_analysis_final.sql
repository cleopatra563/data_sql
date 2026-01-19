-- 子游戏结束日志分析：排除测试账号、关卡为0和数据异常
WITH sub_game_finish_log AS (
    -- 基础数据：子游戏结束事件
    SELECT 
        "#account_id" AS role_id, -- 角色ID
        sub_game_name, -- 子游戏名称
        game_id, -- 游戏ID
        "level", -- 关卡ID
        end_type, -- 战斗结果
        "#event_time" AS event_time, -- 游戏事件时间
        "$part_date" AS log_date, -- 日志日期
        -- 用户注册时间
        MIN("#install_time") OVER (
            PARTITION BY "#account_id" 
            ORDER BY "#event_time"
        ) AS reg_date,
        -- 用户最后一次游戏时间
        LAST_VALUE("#event_time") OVER (
            PARTITION BY "#account_id" 
            ORDER BY "#event_time" 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_log_date
    FROM v_event_4
    WHERE 
        -- 事件类型：游戏结束
        "$part_event" = 'game_end'
        -- 日期范围：从2025-12-29到前一天
        AND "$part_date" BETWEEN '2025-12-29' AND CAST(NOW() - INTERVAL '1' DAY AS VARCHAR)
        -- 排除特定游戏类型
        AND game_type != 999
        -- 特定应用包
        AND "#bundle_id" IN ('live.joyplay.offlinegame')
        -- 特定应用版本
        AND "#app_version" LIKE '%1.8%'
        -- 排除测试账号（根据常见测试账号特征）
        AND "#account_id" NOT LIKE 'test%' -- 排除账号名以test开头的测试账号
        AND "#account_id" NOT LIKE '%_test' -- 排除账号名以_test结尾的测试账号
        AND "#account_id" NOT LIKE '%test%' -- 排除账号名包含test的测试账号
        AND "#account_id" NOT IN ('test001', 'test002', 'admin', 'testuser') -- 排除特定测试账号
        -- 排除关卡为0的记录
        AND "level" != 0
        -- 排除负关卡（数据异常）
        AND "level" > 0
        -- 排除空角色ID（数据异常）
        AND "#account_id" IS NOT NULL
        AND "#account_id" != ''
),
last_log AS (
    -- 标记用户最后一次游戏记录
    SELECT 
        *,
        -- 1表示该记录是用户的最后一次游戏，0表示不是
        CASE 
            WHEN event_time = last_log_date THEN 1 
            ELSE 0 
        END AS is_last
    FROM sub_game_finish_log
)
-- 统计每个日期、每个子游戏、每个关卡的流失人数
SELECT 
    log_date, -- 日志日期
    sub_game_name, -- 子游戏名称
    "level", -- 关卡ID
    -- 流失人数：用户的最后一次游戏记录数
    COUNT(DISTINCT role_id) FILTER (WHERE is_last = 1) AS "流失人数"
FROM last_log
GROUP BY 
    log_date, -- 按日期分组
    sub_game_name, -- 按子游戏分组
    "level" -- 按关卡分组
-- 结果排序
ORDER BY 
    log_date, -- 按日期升序
    sub_game_name, -- 按子游戏名称升序
    "level" -- 按关卡ID升序;

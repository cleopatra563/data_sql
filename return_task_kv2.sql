-- 优化版：统计过去7天未登录后在指定周期内再次登录的用户的任务参与率
-- 功能：计算特定时间周期内，从7天以上未登录状态恢复活跃的用户中参与特定任务的比例
-- 参数说明：
-- @start_date: 统计周期开始时间
-- @end_date: 统计周期结束时间  
-- @target_task_id: 要统计的特定任务ID
-- @inactive_days: 未登录天数阈值（此处固定为7天）

-- 设置统计参数
SET @start_date = '2026-01-01 00:00:00';
SET @end_date = '2026-01-31 23:59:59';
SET @target_task_id = 101;
SET @inactive_days = 7;

-- 核心查询：统计目标用户的任务参与率
WITH 
-- 1. 统计期间有登录行为的用户
active_users AS (
    SELECT DISTINCT user_id
    FROM user_login_logs
    WHERE login_time BETWEEN @start_date AND @end_date
),

-- 2. 计算每个活跃用户在统计期间的首次登录时间
first_login_during AS (
    SELECT 
        user_id,
        MIN(login_time) AS first_login_time
    FROM user_login_logs
    WHERE login_time BETWEEN @start_date AND @end_date
    GROUP BY user_id
),

-- 3. 识别过去7天未登录的用户（目标用户）
target_users AS (
    SELECT fld.user_id,
           fld.first_login_time
    FROM first_login_during fld
    WHERE 
        -- 检查用户在首次登录前的7天内是否有登录记录
        NOT EXISTS (
            SELECT 1
            FROM user_login_logs ull
            WHERE 
                ull.user_id = fld.user_id
                AND ull.login_time BETWEEN 
                    DATE_SUB(fld.first_login_time, INTERVAL @inactive_days DAY) 
                    AND DATE_SUB(fld.first_login_time, INTERVAL 1 DAY)
        )
),

-- 4. 统计期间参与特定任务的用户
participating_users AS (
    SELECT DISTINCT user_id
    FROM user_task_completion
    WHERE 
        task_id = @target_task_id
        AND completion_time BETWEEN @start_date AND @end_date
)

-- 5. 计算最终参与率
SELECT 
    -- 统计信息
    @start_date AS "统计周期开始",
    @end_date AS "统计周期结束",
    @target_task_id AS "任务ID",
    
    -- 统计结果
    COUNT(DISTINCT tu.user_id) AS "目标用户总数",
    COUNT(DISTINCT pu.user_id) AS "参与任务用户数",
    
    -- 参与率计算（避免除以零）
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT tu.user_id) = 0 THEN 0
            ELSE (COUNT(DISTINCT pu.user_id) / COUNT(DISTINCT tu.user_id)) * 100
        END, 2
    ) AS "任务参与率(%)"
FROM target_users tu
LEFT JOIN participating_users pu ON tu.user_id = pu.user_id;

-- 扩展查询：按日期维度统计每日参与率
WITH 
-- 1. 获取每日首次登录的用户
daily_first_logins AS (
    SELECT 
        DATE(login_time) AS login_date,
        user_id,
        MIN(login_time) AS first_login_time
    FROM user_login_logs
    WHERE login_time BETWEEN @start_date AND @end_date
    GROUP BY DATE(login_time), user_id
),

-- 2. 识别每日的目标用户（过去7天未登录）
daily_target_users AS (
    SELECT dfl.login_date, dfl.user_id
    FROM daily_first_logins dfl
    WHERE 
        NOT EXISTS (
            SELECT 1
            FROM user_login_logs ull
            WHERE 
                ull.user_id = dfl.user_id
                AND ull.login_time BETWEEN 
                    DATE_SUB(dfl.first_login_time, INTERVAL @inactive_days DAY) 
                    AND DATE_SUB(dfl.first_login_time, INTERVAL 1 DAY)
        )
),

-- 3. 每日参与任务的用户
daily_participants AS (
    SELECT 
        DATE(completion_time) AS activity_date,
        user_id
    FROM user_task_completion
    WHERE 
        task_id = @target_task_id
        AND completion_time BETWEEN @start_date AND @end_date
    GROUP BY DATE(completion_time), user_id
)

-- 4. 计算每日参与率
SELECT 
    dates.calendar_date AS "日期",
    COALESCE(COUNT(DISTINCT dtu.user_id), 0) AS "每日目标用户数",
    COALESCE(COUNT(DISTINCT dp.user_id), 0) AS "每日参与用户数",
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT dtu.user_id) = 0 THEN 0
            ELSE (COUNT(DISTINCT dp.user_id) / COUNT(DISTINCT dtu.user_id)) * 100
        END, 2
    ) AS "每日参与率(%)"
FROM (
    -- 生成统计周期内的所有日期
    SELECT DATE(@start_date) + INTERVAL seq DAY AS calendar_date
    FROM (SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) t1
    CROSS JOIN (SELECT 0 AS seq UNION ALL SELECT 7 UNION ALL SELECT 14 UNION ALL SELECT 21 UNION ALL SELECT 28) t2
    WHERE DATE(@start_date) + INTERVAL (t1.seq + t2.seq) DAY <= DATE(@end_date)
) dates
LEFT JOIN daily_target_users dtu ON dates.calendar_date = dtu.login_date
LEFT JOIN daily_participants dp ON dates.calendar_date = dp.activity_date AND dtu.user_id = dp.user_id
GROUP BY dates.calendar_date
ORDER BY dates.calendar_date;

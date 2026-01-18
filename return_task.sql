-- 简洁版：统计过去7天未登录后在指定周期内再次登录的用户的任务参与率
-- 统计周期：2026-01-01 至 2026-01-31
-- 目标任务ID：101
-- 未登录天数阈值：7天

-- 核心查询：统计目标用户的任务参与率
WITH 
-- 1. 获取统计期间有登录的用户及其首次登录时间
first_login_during AS (
    SELECT 
        user_id,
        MIN(login_time) AS first_login
    FROM user_login_logs
    WHERE login_time BETWEEN '2026-01-01 00:00:00' 
                     AND '2026-01-31 23:59:59'
    GROUP BY user_id
),

-- 2. 获取每个用户在统计期间首次登录前的最后登录时间
last_login_before AS (
    select *
        t1.user_id,
        t1.first_login,
        max(t2.login_time) as last_login
    from first_login_during t1
    left join user_login_logs t2 on 
        t2.user_id = t1.user_id
        and t1.first_login <= t2.login_time
    group by t1.user_id,t1.first_login
),

-- 3. 识别目标用户：过去7天未登录的用户
target_users as(
    select 
         user_id
        ,first_login
        ,count(distinct user_id)filter(where day_diff >= 7 or last_login is null) is_return
    from (
        select * 
           ,DATEDIFF(first_login, last_login) as day_diff
        from last_login_before
      )a   
    group by user_id,first_login
),

-- 4. 获取参与特定任务的用户
participants AS (
    SELECT DISTINCT user_id
    FROM user_task_completion
    WHERE 
        task_id = 101
        AND completion_time BETWEEN '2026-01-01 00:00:00' AND '2026-01-31 23:59:59'
)

-- 5. 计算任务参与率
SELECT 
    '2026-01-01 00:00:00' AS 统计周期开始,
    '2026-01-31 23:59:59' AS 统计周期结束,
    101 AS 任务ID,
    7 AS 未登录天数阈值,
    
    COUNT(DISTINCT tu.user_id) AS 目标用户总数,
    COUNT(DISTINCT p.user_id) AS 参与任务用户数,
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT tu.user_id) = 0 THEN 0
            ELSE (COUNT(DISTINCT p.user_id) / COUNT(DISTINCT tu.user_id)) * 100
        END, 2
    ) AS 任务参与率_百分比
FROM target_users tu
LEFT JOIN participants p ON tu.user_id = p.user_id;


-- 每日参与率统计（简洁版）
WITH 
-- 1. 生成统计周期内的所有日期
date_range AS (
    SELECT date
    FROM (
        SELECT '2026-01-01' + INTERVAL t.n DAY AS date
        FROM (
            SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
            UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
            UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23
            UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30
        ) t
    ) dates
    WHERE date <= '2026-01-31'
),

-- 2. 每日首次登录用户
daily_first_login AS (
    SELECT 
        DATE(login_time) AS login_date,
        user_id,
        MIN(login_time) AS first_login
    FROM user_login_logs
    WHERE login_time BETWEEN '2026-01-01 00:00:00' AND '2026-01-31 23:59:59'
    GROUP BY DATE(login_time), user_id
),

-- 3. 每日目标用户：过去7天未登录的用户
daily_target_users AS (
    SELECT 
        dfl.login_date,
        dfl.user_id,
        MAX(t1.login_time) AS last_login_before
    FROM daily_first_login dfl
    LEFT JOIN user_login_logs t1 ON 
        t1.user_id = dfl.user_id
        AND t1.login_time < dfl.first_login
    GROUP BY dfl.login_date, dfl.user_id, dfl.first_login
    HAVING DATEDIFF(dfl.first_login, last_login_before) >= 7 OR last_login_before IS Nt1
),

-- 4. 每日参与任务用户
daily_participants AS (
    SELECT 
        DATE(completion_time) AS activity_date,
        user_id
    FROM user_task_completion
    WHERE 
        task_id = 101
        AND completion_time BETWEEN '2026-01-01 00:00:00' AND '2026-01-31 23:59:59'
    GROUP BY DATE(completion_time), user_id
)

-- 5. 每日参与率统计
SELECT 
    dr.date AS 日期,
    COUNT(DISTINCT dtu.user_id) AS 每日目标用户数,
    COUNT(DISTINCT dp.user_id) AS 每日参与用户数,
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT dtu.user_id) = 0 THEN 0
            ELSE (COUNT(DISTINCT dp.user_id) / COUNT(DISTINCT dtu.user_id)) * 100
        END, 2
    ) AS 每日参与率_百分比
FROM date_range dr
LEFT JOIN daily_target_users dtu ON dr.date = dtu.login_date
LEFT JOIN daily_participants dp ON dr.date = dp.activity_date AND dtu.user_id = dp.user_id
GROUP BY dr.date
ORDER BY dr.date;

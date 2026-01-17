-- 用户登录日志记录表结构设计
CREATE TABLE IF NOT EXISTS user_login_logs (
    role_id INT NOT NULL COMMENT '用户角色ID',
    login_time DATETIME NOT NULL COMMENT '登录时间（精确到秒）',
    phone_model VARCHAR(100) NOT NULL COMMENT '手机型号',
    game_id INT NOT NULL COMMENT '游戏ID',
    country VARCHAR(50) NOT NULL COMMENT '国家/地区',
    PRIMARY KEY (role_id, login_time, game_id), -- 复合主键确保数据唯一性
    INDEX idx_login_time (login_time), -- 优化时间范围查询
    INDEX idx_game_id (game_id), -- 优化按游戏ID查询
    INDEX idx_country (country), -- 优化按国家统计
    INDEX idx_phone_model (phone_model) -- 优化按设备型号查询
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户登录日志记录表';

-- 示例数据插入语句
INSERT INTO user_login_logs (role_id, login_time, phone_model, game_id, country) VALUES
(1001, '2026-01-15 08:30:15', 'iPhone 15 Pro', 101, 'China'),
(1002, '2026-01-15 09:15:22', 'Samsung Galaxy S24', 101, 'USA'),
(1003, '2026-01-15 10:20:30', 'iPhone 14', 102, 'Japan'),
(1001, '2026-01-15 11:45:05', 'iPhone 15 Pro', 101, 'China'),
(1004, '2026-01-15 13:22:18', 'Xiaomi 14 Ultra', 103, 'China'),
(1002, '2026-01-16 08:50:45', 'Samsung Galaxy S24', 101, 'USA'),
(1005, '2026-01-16 14:10:22', 'Huawei Mate 60 Pro', 102, 'Canada'),
(1006, '2026-01-16 16:35:10', 'OPPO Find X7', 103, 'India'),
(1003, '2026-01-17 09:25:33', 'iPhone 14', 102, 'Japan'),
(1007, '2026-01-17 11:15:08', 'OnePlus 12', 101, 'Germany');

-- 示例查询语句

-- 1. 按时间段查询特定role_id的登录记录
SELECT * FROM user_login_logs 
WHERE role_id = 1001 
AND login_time BETWEEN '2026-01-15 00:00:00' AND '2026-01-16 23:59:59';

-- 2. 统计不同国家用户登录次数
SELECT country, COUNT(*) AS login_count 
FROM user_login_logs 
GROUP BY country 
ORDER BY login_count DESC;

-- 3. 分析特定game_id的用户登录设备分布
SELECT phone_model, COUNT(*) AS device_count 
FROM user_login_logs 
WHERE game_id = 101 
GROUP BY phone_model 
ORDER BY device_count DESC;

-- 4. 查询特定游戏在特定时间段内的每日登录人数
SELECT DATE(login_time) AS login_date, COUNT(DISTINCT role_id) AS unique_users 
FROM user_login_logs 
WHERE game_id = 101 
AND login_time BETWEEN '2026-01-15 00:00:00' AND '2026-01-17 23:59:59'
GROUP BY DATE(login_time)
ORDER BY login_date;

-- 5. 查询每个国家使用最多的前3种手机型号
SELECT country, phone_model, COUNT(*) AS usage_count 
FROM user_login_logs 
GROUP BY country, phone_model 
ORDER BY country, usage_count DESC;

-- 6. 查询特定用户在不同游戏的登录记录
SELECT game_id, COUNT(*) AS login_times, MIN(login_time) AS first_login, MAX(login_time) AS last_login
FROM user_login_logs 
WHERE role_id = 1001 
GROUP BY game_id;

-- 7. 统计每小时登录高峰时段（针对特定游戏）
SELECT HOUR(login_time) AS hour_of_day, COUNT(*) AS login_count
FROM user_login_logs 
WHERE game_id = 101
GROUP BY HOUR(login_time)
ORDER BY login_count DESC;

-- 8. 查询所有国家在最近7天的总登录次数
SELECT country, COUNT(*) AS total_logins
FROM user_login_logs
WHERE login_time >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY country
ORDER BY total_logins DESC;
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


-- ======================================
-- LEFT() 函数使用说明与示例
-- ======================================

-- LEFT() 函数是 SQL 中的字符串函数，用于从字符串的左侧提取指定数量的字符
-- 语法：LEFT(string, length)
-- 参数：
--   - string: 要提取字符的源字符串
--   - length: 要提取的字符数（必须为正整数）

-- 示例1: 提取手机型号的前5个字符（可用于设备品牌分析）
SELECT phone_model, LEFT(phone_model, 5) AS brand_prefix
FROM user_login_logs;

-- 示例2: 统计不同设备品牌的登录次数（假设品牌是型号的前几个字符）
SELECT LEFT(phone_model, 5) AS device_brand, COUNT(*) AS login_count
FROM user_login_logs
GROUP BY device_brand
ORDER BY login_count DESC;

-- 示例3: 按国家代码（前2个字符）统计登录次数（假设国家字段存储的是完整国家名+代码）
SELECT LEFT(country, 2) AS country_code, COUNT(*) AS login_count
FROM user_login_logs
GROUP BY country_code
ORDER BY login_count DESC;

-- 示例4: 提取登录时间的日期部分（另一种方式，与DATE()函数对比）
SELECT login_time, LEFT(login_time, 10) AS login_date
FROM user_login_logs;

-- 示例5: 结合其他函数使用LEFT()，如统计特定品牌在不同国家的登录情况
SELECT 
    country,
    LEFT(phone_model, 5) AS device_brand,
    COUNT(*) AS login_count
FROM user_login_logs
WHERE LEFT(phone_model, 5) IN ('iPhone', 'Samsu', 'Xiaom')
GROUP BY country, device_brand
ORDER BY country, login_count DESC;

-- 注意事项：
-- 1. 如果length参数为负数，在某些SQL数据库中会返回错误
-- 2. 如果length大于字符串长度，将返回整个字符串
-- 3. LEFT()函数在不同数据库系统中行为基本一致（MySQL、SQL Server、PostgreSQL等）


-- ======================================
-- RIGHT() 函数使用说明与示例
-- ======================================

-- RIGHT() 函数是 SQL 中的字符串函数，用于从字符串的右侧提取指定数量的字符
-- 语法：RIGHT(string, length)
-- 参数：
--   - string: 要提取字符的源字符串
--   - length: 要提取的字符数（必须为正整数）

-- 示例1: 提取手机型号的后5个字符（可用于设备型号后缀分析）
SELECT phone_model, RIGHT(phone_model, 5) AS model_suffix
FROM user_login_logs;

-- 示例2: 统计登录时间的小时分布（提取时间部分的小时分钟）
SELECT login_time, RIGHT(login_time, 8) AS time_part, RIGHT(login_time, 5) AS hour_minute
FROM user_login_logs;

-- 示例3: 按登录时间的小时统计登录次数
SELECT RIGHT(login_time, 8) AS login_hour, COUNT(*) AS login_count
FROM user_login_logs
GROUP BY login_hour
ORDER BY login_hour;

-- 示例4: 假设phone_model字段包含版本号后缀，提取后3位进行统计
SELECT phone_model, RIGHT(phone_model, 3) AS version_suffix, COUNT(*) AS count
FROM user_login_logs
GROUP BY phone_model, version_suffix
ORDER BY count DESC;

-- 示例5: 结合LEFT()和RIGHT()函数，提取登录时间的日期和小时部分
SELECT 
    login_time,
    LEFT(login_time, 10) AS login_date,
    RIGHT(login_time, 5) AS login_hour_minute
FROM user_login_logs;

-- 示例6: 统计不同国家的设备型号长度分布
SELECT 
    country,
    LENGTH(phone_model) AS model_length,
    COUNT(*) AS count
FROM user_login_logs
GROUP BY country, model_length
ORDER BY country, model_length;

-- 示例7: 查找特定后缀的设备型号
SELECT phone_model
FROM user_login_logs
WHERE RIGHT(phone_model, 2) = 'ro';

-- 注意事项：
-- 1. RIGHT()函数与LEFT()函数用法类似，但提取方向相反
-- 2. 同样支持与其他SQL函数结合使用
-- 3. 在不同数据库系统中行为基本一致
-- 4. 对于DATETIME类型，RIGHT()函数会先将其转换为字符串再进行提取
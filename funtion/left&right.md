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

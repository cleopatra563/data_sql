-- 完整的数据库导入脚本
-- 包含所有必要的表结构和示例数据

-- 创建用户登录日志表
CREATE TABLE IF NOT EXISTS user_login_logs (
    user_id INT NOT NULL COMMENT '用户ID',
    login_time DATETIME NOT NULL COMMENT '登录时间（精确到秒）',
    phone_model VARCHAR(100) NOT NULL COMMENT '手机型号',
    game_id INT NOT NULL COMMENT '游戏ID',
    country VARCHAR(50) NOT NULL COMMENT '国家/地区',
    PRIMARY KEY (user_id, login_time, game_id), -- 复合主键确保数据唯一性
    INDEX idx_login_time (login_time), -- 优化时间范围查询
    INDEX idx_game_id (game_id), -- 优化按游戏ID查询
    INDEX idx_country (country), -- 优化按国家统计
    INDEX idx_phone_model (phone_model) -- 优化按设备型号查询
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户登录日志记录表';

-- 创建用户任务完成表
CREATE TABLE IF NOT EXISTS user_task_completion (
    user_id INT NOT NULL COMMENT '用户ID',
    task_id INT NOT NULL COMMENT '任务ID',
    completion_time DATETIME NOT NULL COMMENT '任务完成时间',
    reward_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '任务奖励金额',
    PRIMARY KEY (user_id, task_id, completion_time), -- 复合主键确保数据唯一性
    INDEX idx_task_id (task_id), -- 优化按任务ID查询
    INDEX idx_completion_time (completion_time), -- 优化时间范围查询
    INDEX idx_user_task (user_id, task_id) -- 优化按用户和任务查询
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户任务完成记录表';

-- 插入用户登录日志示例数据
INSERT INTO user_login_logs (user_id, login_time, phone_model, game_id, country) VALUES
(1001, '2026-01-01 08:30:15', 'iPhone 15 Pro', 101, 'China'),
(1002, '2026-01-01 09:15:22', 'Samsung Galaxy S24', 101, 'USA'),
(1003, '2026-01-01 10:20:30', 'iPhone 14', 102, 'Japan'),
(1004, '2026-01-01 13:22:18', 'Xiaomi 14 Ultra', 103, 'China'),
(1005, '2026-01-01 14:45:05', 'Huawei Mate 60 Pro', 101, 'Canada'),
(1006, '2026-01-01 16:35:10', 'OPPO Find X7', 103, 'India'),
(1001, '2026-01-02 08:45:12', 'iPhone 15 Pro', 101, 'China'),
(1002, '2026-01-02 09:20:33', 'Samsung Galaxy S24', 101, 'USA'),
(1003, '2026-01-02 11:15:40', 'iPhone 14', 102, 'Japan'),
(1004, '2026-01-02 14:30:25', 'Xiaomi 14 Ultra', 103, 'China'),
(1005, '2026-01-03 08:55:18', 'Huawei Mate 60 Pro', 101, 'Canada'),
(1006, '2026-01-03 10:10:33', 'OPPO Find X7', 103, 'India'),
(1001, '2026-01-04 09:05:22', 'iPhone 15 Pro', 101, 'China'),
(1002, '2026-01-04 11:25:45', 'Samsung Galaxy S24', 101, 'USA'),
(1003, '2026-01-05 10:35:50', 'iPhone 14', 102, 'Japan'),
(1004, '2026-01-05 15:20:18', 'Xiaomi 14 Ultra', 103, 'China'),
(1005, '2026-01-06 09:15:33', 'Huawei Mate 60 Pro', 101, 'Canada'),
(1006, '2026-01-06 11:45:20', 'OPPO Find X7', 103, 'India'),
(1001, '2026-01-07 08:50:12', 'iPhone 15 Pro', 101, 'China'),
(1002, '2026-01-07 10:30:40', 'Samsung Galaxy S24', 101, 'USA'),
(1003, '2026-01-08 11:20:25', 'iPhone 14', 102, 'Japan'),
(1004, '2026-01-08 14:45:50', 'Xiaomi 14 Ultra', 103, 'China'),
(1005, '2026-01-09 09:25:33', 'Huawei Mate 60 Pro', 101, 'Canada'),
(1006, '2026-01-09 12:15:22', 'OPPO Find X7', 103, 'India'),
(1001, '2026-01-10 08:40:18', 'iPhone 15 Pro', 101, 'China'),
(1002, '2026-01-10 11:10:35', 'Samsung Galaxy S24', 101, 'USA'),
(1003, '2026-01-11 10:50:45', 'iPhone 14', 102, 'Japan'),
(1004, '2026-01-11 15:30:20', 'Xiaomi 14 Ultra', 103, 'China'),
(1005, '2026-01-12 09:05:30', 'Huawei Mate 60 Pro', 101, 'Canada'),
(1006, '2026-01-12 11:55:15', 'OPPO Find X7', 103, 'India'),
(1001, '2026-01-13 08:55:22', 'iPhone 15 Pro', 101, 'China'),
(1002, '2026-01-13 10:45:40', 'Samsung Galaxy S24', 101, 'USA'),
(1003, '2026-01-14 11:30:25', 'iPhone 14', 102, 'Japan'),
(1004, '2026-01-14 14:55:50', 'Xiaomi 14 Ultra', 103, 'China'),
(1005, '2026-01-15 09:15:33', 'Huawei Mate 60 Pro', 101, 'Canada'),
(1006, '2026-01-15 12:25:22', 'OPPO Find X7', 103, 'India'),
(1001, '2026-01-16 08:40:18', 'iPhone 15 Pro', 101, 'China'),
(1002, '2026-01-16 11:10:35', 'Samsung Galaxy S24', 101, 'USA'),
(1003, '2026-01-17 10:50:45', 'iPhone 14', 102, 'Japan'),
(1004, '2026-01-17 15:30:20', 'Xiaomi 14 Ultra', 103, 'China'),
(1005, '2026-01-18 09:05:30', 'Huawei Mate 60 Pro', 101, 'Canada'),
(1006, '2026-01-18 11:55:15', 'OPPO Find X7', 103, 'India'),
(1007, '2026-01-15 08:30:15', 'iPhone 13', 101, 'Australia'),
(1007, '2026-01-16 09:15:22', 'iPhone 13', 101, 'Australia'),
(1007, '2026-01-17 10:20:30', 'iPhone 13', 101, 'Australia'),
(1008, '2026-01-15 11:45:05', 'Samsung Galaxy S23', 102, 'UK'),
(1008, '2026-01-16 12:30:18', 'Samsung Galaxy S23', 102, 'UK'),
(1008, '2026-01-17 13:15:45', 'Samsung Galaxy S23', 102, 'UK'),
(1009, '2026-01-15 14:10:22', 'Xiaomi 13', 103, 'Germany'),
(1009, '2026-01-16 15:25:33', 'Xiaomi 13', 103, 'Germany'),
(1009, '2026-01-17 16:40:50', 'Xiaomi 13', 103, 'Germany'),
(1010, '2026-01-15 17:25:18', 'Huawei P60 Pro', 101, 'France'),
(1010, '2026-01-16 18:40:35', 'Huawei P60 Pro', 101, 'France'),
(1010, '2026-01-17 19:15:22', 'Huawei P60 Pro', 101, 'France'),
-- 添加一些间隔超过7天的登录记录，用于测试
(1011, '2026-01-01 08:30:15', 'iPhone 12', 101, 'Italy'),
(1011, '2026-01-15 09:15:22', 'iPhone 12', 101, 'Italy'), -- 间隔14天
(1012, '2026-01-01 10:20:30', 'Samsung Galaxy S22', 102, 'Spain'),
(1012, '2026-01-16 11:45:05', 'Samsung Galaxy S22', 102, 'Spain'), -- 间隔15天
(1013, '2026-01-02 13:22:18', 'Xiaomi 12', 103, 'Russia'),
(1013, '2026-01-17 14:10:22', 'Xiaomi 12', 103, 'Russia'), -- 间隔15天
(1014, '2026-01-03 16:35:10', 'OPPO Find X6', 101, 'Brazil'),
(1014, '2026-01-18 17:25:18', 'OPPO Find X6', 101, 'Brazil'); -- 间隔15天

-- 插入用户任务完成示例数据
INSERT INTO user_task_completion (user_id, task_id, completion_time, reward_amount) VALUES
(1001, 101, '2026-01-01 09:00:00', 10.00),
(1002, 101, '2026-01-01 09:30:00', 10.00),
(1003, 101, '2026-01-01 10:45:00', 10.00),
(1004, 101, '2026-01-01 14:00:00', 10.00),
(1005, 101, '2026-01-01 15:00:00', 10.00),
(1006, 101, '2026-01-01 17:00:00', 10.00),
(1001, 101, '2026-01-02 09:15:00', 10.00),
(1002, 101, '2026-01-02 09:45:00', 10.00),
(1003, 101, '2026-01-02 11:30:00', 10.00),
(1004, 101, '2026-01-02 14:45:00', 10.00),
(1005, 101, '2026-01-03 09:30:00', 10.00),
(1006, 101, '2026-01-03 10:30:00', 10.00),
(1001, 101, '2026-01-04 09:30:00', 10.00),
(1002, 101, '2026-01-04 11:45:00', 10.00),
(1003, 101, '2026-01-05 11:00:00', 10.00),
(1004, 101, '2026-01-05 15:45:00', 10.00),
(1005, 101, '2026-01-06 09:45:00', 10.00),
(1006, 101, '2026-01-06 12:30:00', 10.00),
(1001, 101, '2026-01-07 09:15:00', 10.00),
(1002, 101, '2026-01-07 10:45:00', 10.00),
(1003, 101, '2026-01-08 11:45:00', 10.00),
(1004, 101, '2026-01-08 15:15:00', 10.00),
(1005, 101, '2026-01-09 09:30:00', 10.00),
(1006, 101, '2026-01-09 12:45:00', 10.00),
(1001, 101, '2026-01-10 09:00:00', 10.00),
(1002, 101, '2026-01-10 11:30:00', 10.00),
(1003, 101, '2026-01-11 11:15:00', 10.00),
(1004, 101, '2026-01-11 15:45:00', 10.00),
(1005, 101, '2026-01-12 09:15:00', 10.00),
(1006, 101, '2026-01-12 12:15:00', 10.00),
(1001, 101, '2026-01-13 09:00:00', 10.00),
(1002, 101, '2026-01-13 10:55:00', 10.00),
(1003, 101, '2026-01-14 11:45:00', 10.00),
(1004, 101, '2026-01-14 15:15:00', 10.00),
(1005, 101, '2026-01-15 09:30:00', 10.00),
(1006, 101, '2026-01-15 12:30:00', 10.00),
(1001, 101, '2026-01-16 09:15:00', 10.00),
(1002, 101, '2026-01-16 11:30:00', 10.00),
(1003, 101, '2026-01-17 11:15:00', 10.00),
(1004, 101, '2026-01-17 15:45:00', 10.00),
(1005, 101, '2026-01-18 09:30:00', 10.00),
(1006, 101, '2026-01-18 12:15:00', 10.00),
(1007, 101, '2026-01-15 09:00:00', 10.00),
(1007, 101, '2026-01-16 09:30:00', 10.00),
(1007, 101, '2026-01-17 10:00:00', 10.00),
(1008, 101, '2026-01-15 12:15:00', 10.00),
(1008, 101, '2026-01-16 13:00:00', 10.00),
(1008, 101, '2026-01-17 13:45:00', 10.00),
(1009, 101, '2026-01-15 14:30:00', 10.00),
(1009, 101, '2026-01-16 15:45:00', 10.00),
(1009, 101, '2026-01-17 17:00:00', 10.00),
(1010, 101, '2026-01-15 17:45:00', 10.00),
(1010, 101, '2026-01-16 18:55:00', 10.00),
(1010, 101, '2026-01-17 19:30:00', 10.00),
-- 添加间隔超过7天后登录并完成任务的用户
(1011, 101, '2026-01-15 09:45:00', 10.00),
(1012, 101, '2026-01-16 12:15:00', 10.00),
(1013, 101, '2026-01-17 14:30:00', 10.00),
(1014, 101, '2026-01-18 18:00:00', 10.00);

-- 创建视图：任务参与率统计
CREATE VIEW v_task_participation_rate AS
SELECT 
    DATE(tc.completion_time) AS task_date,
    tc.task_id,
    COUNT(DISTINCT tc.user_id) AS participating_users,
    COUNT(DISTINCT ul.user_id) AS active_users,
    ROUND(COUNT(DISTINCT tc.user_id) / COUNT(DISTINCT ul.user_id) * 100, 2) AS participation_rate
FROM user_login_logs ul
LEFT JOIN user_task_completion tc ON ul.user_id = tc.user_id AND DATE(ul.login_time) = DATE(tc.completion_time)
WHERE ul.login_time BETWEEN '2026-01-01 00:00:00' AND '2026-01-31 23:59:59'
GROUP BY DATE(tc.completion_time), tc.task_id;

-- 创建存储过程：按日期范围统计任务参与率
DELIMITER //
CREATE PROCEDURE sp_task_participation_stats(
    IN p_start_date DATETIME,
    IN p_end_date DATETIME,
    IN p_task_id INT
)
BEGIN
    SELECT 
        DATE(tc.completion_time) AS task_date,
        tc.task_id,
        COUNT(DISTINCT tc.user_id) AS participating_users,
        COUNT(DISTINCT ul.user_id) AS active_users,
        ROUND(COUNT(DISTINCT tc.user_id) / COUNT(DISTINCT ul.user_id) * 100, 2) AS participation_rate
    FROM user_login_logs ul
    LEFT JOIN user_task_completion tc ON ul.user_id = tc.user_id AND DATE(ul.login_time) = DATE(tc.completion_time)
    WHERE ul.login_time BETWEEN p_start_date AND p_end_date AND tc.task_id = p_task_id
    GROUP BY DATE(tc.completion_time), tc.task_id
    ORDER BY task_date;
END //
DELIMITER ;

-- 输出导入完成信息
SELECT '数据库表结构和示例数据导入完成！' AS '导入状态';

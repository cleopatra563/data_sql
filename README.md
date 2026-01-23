# 月度订单总额统计项目

## 项目概述

本项目用于计算2025-2026年期间，每个月最后一天的不同国家订单总额。通过SQL查询对原始事件数据进行处理和聚合，最终生成包含月度总额的结果表。

## 数据来源

原始数据来自 `v_event_4` 表，包含以下关键字段：
- `#account_id`：账户ID
- `#event_time`：事件时间
- `$part_date`：分区日期
- `#zone_offset`：时区偏移
- `#country`：国家
- `#uuid`：设备ID
- `sub_game_name`：购买商品名称
- `game_id`：金额（需要转换为整数）

## SQL查询说明

### 核心逻辑

1. **数据筛选**：从 `v_event_4` 表中筛选出事件类型为 `game_end` 的记录，时间范围为 2025-12-29 至 2026-01-07。
2. **月度聚合**：按月份和国家分组，计算每个国家的月度订单总额。
3. **月末日期计算**：确定每个月的最后一天。
4. **结果关联**：将月度总额与对应月份的最后一天关联，生成最终结果。

### 完整SQL查询

```sql
-- 求2025~2026年，每个月最后一天的不同国家订单总额 
WITH recharge AS (
    SELECT 
        "#account_id" role_id,
        "#event_time" log_time,
        DATE("$part_date") log_date,
        "#zone_offset",
        "#country" country,
        "#uuid" AS device_id, -- 设备id 
        sub_game_name AS item_name, -- 购买商品 
        CAST(game_id AS INT) AS money,
        'CNY' AS money_type 
    FROM v_event_4 
    WHERE "$part_event" = 'game_end' 
    AND "$part_date" >= '2025-12-29' 
    AND "$part_date" <= '2026-01-07' 
),

-- 按月聚合，求出每个月订单总额
recharge_monthly AS (
    SELECT 
        DATE_TRUNC(log_date, MONTH) AS month_start,
        country,
        SUM(money) AS total_money 
    FROM recharge  
    GROUP BY month_start, country 
),

-- 计算每个月的最后一天
last_day AS (   
    SELECT 
        month_start,
        LAST_DAY_OF_MONTH(month_start) AS last_date   
    FROM recharge_monthly 
    GROUP BY month_start 
)

-- 每个月最后一天，不同国家的订单总额 
SELECT 
    t2.last_date,
    t1.country,
    t1.total_money 
FROM recharge_monthly t1 
JOIN last_day t2 
    ON t1.month_start = t2.month_start 
ORDER BY t2.last_date, t1.country
```

## 输出结果

查询结果存储在 `base_table/result.tsv` 文件中，格式为制表符分隔的值（TSV），包含以下列：

| 列名       | 描述                |
|------------|---------------------|
| `last_date`| 月份的最后一天      |
| `country`  | 国家                |
| `total_money` | 该国家的月度订单总额 |

### 输出示例

```
last_date   country total_money
2025/12/31  中国    5825
2025/12/31  印度    1710483
2025/12/31  印度尼西亚  2036937
2025/12/31  叙利亚  0
2025/12/31  土耳其  5639
...
```

## 使用方法

1. **准备数据**：确保 `v_event_4` 表包含所需的事件数据。
2. **调整日期范围**：根据需要修改SQL查询中的 `$part_date` 过滤条件。
3. **执行查询**：在支持SQL的环境中运行上述查询。
4. **查看结果**：查询结果将按照月份最后一天和国家排序，可导出为TSV格式查看。

## 注意事项

- **日期函数**：本查询使用 `DATE_TRUNC` 和 `LAST_DAY_OF_MONTH` 函数，具体实现可能因数据库系统而异。
- **数据类型**：确保 `game_id` 字段能够正确转换为整数类型。
- **时区处理**：查询中未显式处理时区，默认使用数据中的时区信息。

## 项目结构

```
d:\workflow\data_sql\
├── base_table\
│   └── result.tsv        # 输出结果文件
├── README.md             # 本文档
└── [SQL查询文件]          # 包含完整SQL查询的文件（可选）
<<<<<<< HEAD
```
=======
```
>>>>>>> 8d06fa7ba06bd167f75b77aa88c0667e3b07e6e3

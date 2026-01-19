# DATE_ADD() 函数使用说明

## 1. 函数概述

`DATE_ADD()` 是 MySQL 数据库中用于在日期或时间值上添加指定时间间隔的函数。它可以精确地计算未来的日期或时间，是处理日期时间数据的常用工具。

## 2. 语法

```sql
DATE_ADD(date, INTERVAL value unit)
```

## 3. 参数说明

| 参数 | 描述 |
|------|------|
| `date` | 要添加时间间隔的基础日期或时间值。可以是 DATE、DATETIME 或 TIMESTAMP 类型。 |
| `value` | 要添加的时间间隔值。可以是正数（向前计算）或负数（向后计算）。 |
| `unit` | 时间间隔的单位。MySQL 支持多种时间单位，如下表所示。 |

## 4. 支持的时间单位

MySQL `DATE_ADD()` 函数支持以下时间单位：

| 单位 | 描述 |
|------|------|
| `MICROSECOND` | 微秒 |
| `SECOND` | 秒 |
| `MINUTE` | 分钟 |
| `HOUR` | 小时 |
| `DAY` | 天 |
| `WEEK` | 周 |
| `MONTH` | 月 |
| `QUARTER` | 季度 |
| `YEAR` | 年 |
| `SECOND_MICROSECOND` | 秒.微秒 |
| `MINUTE_MICROSECOND` | 分钟.微秒 |
| `MINUTE_SECOND` | 分钟:秒 |
| `HOUR_MICROSECOND` | 小时.微秒 |
| `HOUR_SECOND` | 小时:秒 |
| `HOUR_MINUTE` | 小时:分钟 |
| `DAY_MICROSECOND` | 天.微秒 |
| `DAY_SECOND` | 天:秒 |
| `DAY_MINUTE` | 天:分钟 |
| `DAY_HOUR` | 天:小时 |
| `YEAR_MONTH` | 年-月 |

## 5. 示例

### 5.1 添加天数
```sql
-- 在当前日期基础上添加3天
SELECT DATE_ADD(NOW(), INTERVAL 3 DAY);

-- 在指定日期基础上添加10天
SELECT DATE_ADD('2021-08-01', INTERVAL 10 DAY);
-- 结果: 2021-08-11
```

### 5.2 添加负数天数（向前计算）
```sql
-- 在当前日期基础上减去5天（即5天前）
SELECT DATE_ADD(NOW(), INTERVAL -5 DAY);

-- 在指定日期基础上减去7天
SELECT DATE_ADD('2021-08-31', INTERVAL -7 DAY);
-- 结果: 2021-08-24
```

### 5.3 添加其他时间单位
```sql
-- 添加小时
SELECT DATE_ADD('2021-08-01 10:00:00', INTERVAL 2 HOUR);
-- 结果: 2021-08-01 12:00:00

-- 添加分钟
SELECT DATE_ADD('2021-08-01 10:00:00', INTERVAL 30 MINUTE);
-- 结果: 2021-08-01 10:30:00

-- 添加月份
SELECT DATE_ADD('2021-08-01', INTERVAL 1 MONTH);
-- 结果: 2021-09-01

-- 添加年份
SELECT DATE_ADD('2021-08-01', INTERVAL 2 YEAR);
-- 结果: 2023-08-01

-- 添加周数
SELECT DATE_ADD('2021-08-01', INTERVAL 2 WEEK);
-- 结果: 2021-08-15
```

### 5.4 复杂时间单位示例
```sql
-- 添加天和小时
SELECT DATE_ADD('2021-08-01 10:00:00', INTERVAL '1 5' DAY_HOUR);
-- 结果: 2021-08-02 15:00:00

-- 添加小时和分钟
SELECT DATE_ADD('2021-08-01 10:00:00', INTERVAL '3 45' HOUR_MINUTE);
-- 结果: 2021-08-01 13:45:00

-- 添加年和月
SELECT DATE_ADD('2021-08-01', INTERVAL '1 6' YEAR_MONTH);
-- 结果: 2023-02-01
```

## 6. 与 DATE_SUB() 函数的关系

`DATE_ADD()` 函数可以通过使用负数的时间间隔值来实现 `DATE_SUB()` 函数的功能（减去时间间隔）。例如：

```sql
-- 使用 DATE_SUB() 减去5天
SELECT DATE_SUB('2021-08-01', INTERVAL 5 DAY);

-- 使用 DATE_ADD() 减去5天（效果相同）
SELECT DATE_ADD('2021-08-01', INTERVAL -5 DAY);
```

两种方式得到的结果完全相同。

## 7. 在工作流示例中的应用

在之前的每日练习统计查询中，我们使用 `DATE_ADD()` 函数生成连续的日期序列：

```sql
WITH RECURSIVE date_range AS (
    SELECT '2021-08-01' AS practice_date
    UNION ALL
    SELECT DATE_ADD(practice_date, INTERVAL 1 DAY)
    FROM date_range
    WHERE practice_date < '2021-08-31'
)
```

这个递归查询从 '2021-08-01' 开始，每天添加1天，直到 '2021-08-31'，从而生成整个8月份的日期序列。

## 8. 注意事项

1. **日期溢出处理**：当添加时间间隔导致日期超出有效范围时，MySQL 会自动调整结果。例如：
   ```sql
   SELECT DATE_ADD('2021-01-31', INTERVAL 1 MONTH);
   -- 结果: 2021-02-28
   ```

2. **NULL 值处理**：如果输入的日期值为 NULL，函数将返回 NULL。

3. **时区影响**：当使用 DATETIME 或 TIMESTAMP 类型时，结果可能会受到数据库时区设置的影响。

4. **性能考虑**：在大表上使用 `DATE_ADD()` 函数时，应确保相关日期字段有适当的索引，以提高查询效率。

## 9. 总结

`DATE_ADD()` 函数是 MySQL 中处理日期时间数据的强大工具，它提供了灵活的时间间隔计算能力，可以满足各种日期时间处理需求。通过掌握其语法和用法，您可以轻松地进行日期时间的加减计算，实现复杂的业务逻辑。
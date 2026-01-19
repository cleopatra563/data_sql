# 子游戏关卡流失分析SQL处理流（Coze工作流搭建）

## 工作流概述
本工作流用于分析子游戏每个关卡的流失人数，采用模块化设计，分为三个核心步骤，确保流程简洁、高效、优雅。

---

## 步骤1：构建基础数据底表
**功能**：从源数据中提取并整合子游戏结束事件的核心数据

### 输入
- 数据源：`v_event_4`（游戏事件表）
- 时间范围参数：`start_date`、`end_date`
- 应用参数：`bundle_id`、`app_version_pattern`

### SQL模板
```sql
WITH base_data AS (
    SELECT 
        "#account_id" AS role_id, -- 角色ID
        sub_game_name, -- 子游戏名称
        game_id, -- 游戏ID
        "level", -- 关卡ID
        "#event_time" AS event_time, -- 游戏时间
        "$part_date" AS log_date -- 日期
    FROM v_event_4
    WHERE 
        "$part_event" = 'game_end' -- 筛选游戏结束事件
        AND "$part_date" BETWEEN {{start_date}} AND {{end_date}} -- 时间范围参数
        AND game_type != 999 -- 排除特定游戏类型
        AND "#bundle_id" IN ({{bundle_id}}) -- 应用包参数
        AND "#app_version" LIKE {{app_version_pattern}} -- 应用版本参数
)
SELECT * FROM base_data;
```

### 输出
- 基础数据底表：包含角色ID、游戏信息、关卡信息、事件时间和日期

---

## 步骤2：用户状态标记
**功能**：为每个用户-关卡组合标记流失状态

### 输入
- 步骤1的输出：基础数据底表

### SQL模板
```sql
WITH status_marked_data AS (
    SELECT 
        *, 
        -- 计算每个用户的最后游戏时间
        MAX(event_time) OVER (PARTITION BY role_id) AS last_log_time,
        -- 标记是否为最后一次游戏
        CASE 
            WHEN event_time = MAX(event_time) OVER (PARTITION BY role_id) THEN 1 
            ELSE 0 
        END AS is_churn -- 1: 流失，0: 未流失
    FROM (
        -- 步骤1的输出作为输入
        {{step1_output}}
    ) t
)
SELECT * FROM status_marked_data;
```

### 输出
- 带状态标记的数据流：新增`last_log_time`和`is_churn`字段

---

## 步骤3：聚合计算流失人数
**功能**：按游戏、关卡维度聚合计算流失人数

### 输入
- 步骤2的输出：带状态标记的数据流

### SQL模板
```sql
WITH churn_analysis AS (
    SELECT 
        log_date, -- 日期
        game_id, -- 游戏ID
        sub_game_name, -- 子游戏名称
        "level", -- 关卡ID
        -- 计算流失人数
        COUNT(DISTINCT role_id) FILTER (WHERE is_churn = 1) AS churn_count, 
        -- 计算该关卡总玩家数
        COUNT(DISTINCT role_id) AS total_players
    FROM (
        -- 步骤2的输出作为输入
        {{step2_output}}
    ) t
    GROUP BY log_date, game_id, sub_game_name, "level"
)
SELECT * FROM churn_analysis
ORDER BY log_date, game_id, sub_game_name, "level";
```

### 输出
- 最终分析结果：包含日期、游戏信息、关卡ID、流失人数和总玩家数

---

## 工作流参数配置（Coze）

| 参数名 | 类型 | 默认值 | 描述 |
|--------|------|--------|------|
| `start_date` | 字符串 | '2025-12-29' | 分析起始日期 |
| `end_date` | 字符串 | CURRENT_DATE | 分析结束日期 |
| `bundle_id` | 数组 | ['live.joyplay.offlinegame'] | 应用包ID列表 |
| `app_version_pattern` | 字符串 | '%1.8%' | 应用版本匹配模式 |

---

## 工作流优化建议

1. **性能优化**
   - 为大表添加适当索引：`v_event_4`表的`$part_event`、`$part_date`、`#account_id`字段
   - 使用分区表技术提高查询效率

2. **可扩展性**
   - 添加关卡类型、游戏类型等维度的过滤参数
   - 支持自定义流失定义（如N日流失）

3. **监控与告警**
   - 设置数据量异常告警（如某关卡流失人数突增）
   - 添加数据质量检查（如重复记录、缺失值处理）

---

## 输出示例

| log_date   | game_id | sub_game_name | level | churn_count | total_players |
|------------|---------|---------------|-------|-------------|---------------|
| 2025-12-29 | 1001    | 开心消消乐      | 1     | 150         | 1000          |
| 2025-12-29 | 1001    | 开心消消乐      | 2     | 200         | 850           |
| 2025-12-29 | 1001    | 开心消消乐      | 3     | 300         | 650           |
| 2025-12-30 | 1001    | 开心消消乐      | 1     | 180         | 1200          |

---

## 注意事项

1. **时间格式**：确保传入的日期参数格式与数据库兼容
2. **参数验证**：在工作流中添加参数验证逻辑，防止无效输入
3. **数据一致性**：定期检查源数据质量，确保分析结果可靠
4. **权限控制**：确保工作流有足够的数据库访问权限

---

## 扩展应用

本工作流可扩展用于以下场景：
- 多维度流失分析（如设备类型、用户等级）
- 流失预测模型的数据准备
- 游戏关卡优化效果评估
- 用户生命周期价值分析

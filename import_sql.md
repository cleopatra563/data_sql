# SQL数据导入指南

## 准备工作

我们已经为您准备好了完整的数据库导入脚本：`import.sql`

该脚本包含：
- `user_login_logs`表结构和示例数据
- `user_task_completion`表结构和示例数据
- 统计视图和存储过程

## 导入方法

### 方法一：使用MySQL命令行工具

1. **打开命令提示符**（Windows）或**终端**（Mac/Linux）

2. **连接到MySQL服务器**：
   ```bash
   mysql -u 用户名 -p 数据库名
   ```
   例如：`mysql -u root -p my_database`

3. **执行导入脚本**：
   ```bash
   SOURCE e:\自动化工作流\data_sql\import.sql;
   ```
   或从文件导入：
   ```bash
   mysql -u 用户名 -p 数据库名 < e:\自动化工作流\data_sql\import.sql
   ```

### 方法二：使用phpMyAdmin

1. 打开phpMyAdmin并登录
2. 创建一个新数据库（如果还没有）
3. 选择数据库 → 点击"导入"选项卡
4. 点击"选择文件"按钮，找到`import.sql`文件
5. 保持默认设置，点击"执行"按钮

### 方法三：使用MySQL Workbench

1. 打开MySQL Workbench并连接到数据库
2. 选择目标数据库
3. 点击"File" → "Run SQL Script"
4. 选择`import.sql`文件
5. 点击"Run"按钮

## 验证导入

导入完成后，可以执行以下查询验证数据：

```sql
-- 检查用户登录日志表
SELECT COUNT(*) FROM user_login_logs;

-- 检查用户任务完成表
SELECT COUNT(*) FROM user_task_completion;

-- 运行统计查询
SELECT * FROM v_task_participation_rate;

-- 执行存储过程
CALL sp_task_participation_stats('2026-01-01 00:00:00', '2026-01-31 23:59:59', 101);
```

## 注意事项

1. 确保MySQL服务已启动
2. 确保具有足够的权限创建表和插入数据
3. 如果数据库已存在同名表，脚本会自动跳过表创建（使用`CREATE TABLE IF NOT EXISTS`）
4. 导入过程中如果遇到任何错误，请检查MySQL版本是否兼容（建议使用MySQL 8.0+）

## 相关文件

- `import.sql` - 完整的数据库导入脚本
- `return_task.sql` - 原始查询脚本（简洁版）
- `return_task_v2.sql` - 优化版查询脚本

如有任何问题，请随时联系！
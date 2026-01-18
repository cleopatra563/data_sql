# MySQL命令行工具导入指南

## 步骤一：打开命令提示符

### Windows系统
1. 按下 `Win + R` 键打开运行对话框
2. 输入 `cmd` 并按回车键
3. 导航到SQL文件所在目录（可选）：
   ```bash
   cd e:\workflow\data_sql
   ```

### Mac/Linux系统
1. 打开终端应用程序
2. 导航到SQL文件所在目录（可选）：
   ```bash
   cd /path/to/your/sql/files
   ```

## 步骤二：连接到MySQL服务器

### 基本连接命令
```bash
mysql -u 用户名 -p
```

**参数说明：**
- `-u`：指定MySQL用户名（如root）
- `-p`：提示输入密码（安全起见，不建议直接在命令中输入密码）

**示例：**
```bash
mysql -u root -p
```

输入命令后，系统会提示您输入密码。输入密码后按回车键。

### 直接连接到特定数据库
```bash
mysql -u 用户名 -p 数据库名
```

**示例：**
```bash
mysql -u root -p my_database
```

### 指定端口和主机（如需要）
```bash
mysql -u 用户名 -p -h 主机名 -P 端口号 数据库名
```

**示例（连接到远程服务器）：**
```bash
mysql -u root -p -h 127.0.0.1 -P 3306 my_database
```

## 步骤三：创建数据库（如需要）

如果您还没有创建数据库，可以在连接后执行以下命令：

```sql
CREATE DATABASE IF NOT EXISTS my_database DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

然后切换到该数据库：

```sql
USE my_database;
```

## 步骤四：执行导入脚本

### 方法一：使用SOURCE命令

在MySQL命令行界面中执行：

```sql
SOURCE e:\workflow\data_sql\import.sql; SHOW WARINGINS;
```

**注意：** 路径必须是绝对路径，Windows系统使用反斜杠（\），Linux/Mac使用正斜杠（/）。

### 方法二：使用命令行重定向

在命令提示符（不是MySQL界面）中执行：

```bash
mysql -u root -p my_database < e:\workflow\data_sql\import.sql
```

**示例：**
```bash
mysql -u root -p my_database < e:\workflow\data_sql\import.sql
```

输入密码后，脚本将自动执行。

## 步骤五：验证导入结果

导入完成后，可以执行以下命令验证数据：

```sql
-- 检查用户登录日志表记录数
SELECT COUNT(*) AS total_login_records FROM user_login_logs;

-- 检查用户任务完成表记录数
SELECT COUNT(*) AS total_task_records FROM user_task_completion;

-- 查看前5条登录记录
SELECT * FROM user_login_logs LIMIT 5;

-- 查看前5条任务完成记录
SELECT * FROM user_task_completion LIMIT 5;

-- 运行统计查询
SELECT * FROM v_task_participation_rate LIMIT 10;

-- 执行存储过程
CALL sp_task_participation_stats('2026-01-01 00:00:00', '2026-01-31 23:59:59', 101);
```

## 常见问题与解决方案

### 问题1：权限错误
**错误信息：** `ERROR 1045 (28000): Access denied for user 'username'@'localhost' (using password: YES)`

**解决方案：**
- 确保用户名和密码正确
- 检查用户是否有创建表和插入数据的权限
- 如果是root用户，确保已正确配置权限

### 问题2：文件路径错误
**错误信息：** `ERROR 1064 (42000): You have an error in your SQL syntax;...`

**解决方案：**
- 使用绝对路径而不是相对路径
- 确保路径中的空格已正确处理（可以用引号括起来）
- Windows系统中使用双反斜杠或正斜杠

### 问题3：MySQL服务未启动
**错误信息：** `ERROR 2003 (HY000): Can't connect to MySQL server on 'localhost' (10061)`

**解决方案：**
- 启动MySQL服务
- Windows：`net start mysql`（以管理员身份运行命令提示符）
- Mac：`brew services start mysql`
- Linux：`sudo systemctl start mysql`

### 问题4：字符集问题
**错误信息：** `ERROR 1366 (HY000): Incorrect string value: '\xE6\xB5\x8B\xE8\xAF\x95' for column 'name' at row 1`

**解决方案：**
- 确保数据库使用utf8mb4字符集
- 在连接时指定字符集：`mysql -u 用户名 -p --default-character-set=utf8mb4 数据库名`

### 问题5：Show warnings disabled 提示
**错误信息：** `Show warnings disabled`

**解决方案：**
- 这是一个提示信息而非错误，表示警告信息被禁用了
- 在执行MySQL命令时添加`--show-warnings`参数启用警告显示
- 示例：
  ```bash
  mysql -u 用户名 -p --show-warnings 数据库名 < import.sql
  ```
  ```sql
  SOURCE import.sql; SHOW WARNINGS;
  ```

## 高级选项

### 显示导入进度
```bash
mysql -u 用户名 -p 数据库名 < import.sql | pv -l
```
**注意：** 需要安装pv工具（Linux/Mac）

### 导入时忽略错误
```bash
mysql -u 用户名 -p 数据库名 --force < import.sql
```

### 导入时显示详细信息
```bash
mysql -u 用户名 -p 数据库名 --verbose < import.sql
```

## 导入完成

导入成功后，您将看到类似以下的输出：

```
Query OK, 60 rows affected (0.02 sec)
Records: 60  Duplicates: 0  Warnings: 0

Query OK, 50 rows affected (0.01 sec)
Records: 50  Duplicates: 0  Warnings: 0

Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

Query OK, 1 row affected (0.00 sec)
```

现在您可以运行`return_task.sql`或`return_task_v2.sql`来查看统计结果了！

```bash
mysql -u 用户名 -p 数据库名 < e:\自动化工作流\data_sql\return_task.sql
```

或者在MySQL命令行中执行：

```sql
SOURCE e:\自动化工作流\data_sql\return_task.sql;
```
@echo off

REM 快速导入脚本
REM 请根据实际情况修改以下参数
set MYSQL_USER=root
set MYSQL_PASSWORD=root
set DATABASE_NAME=workflow_db

REM 检查MySQL服务是否启动
net start | findstr MySQL >nul
if %errorlevel% neq 0 (
    echo MySQL服务未启动，请先启动MySQL服务
    pause
    exit /b 1
)

REM 创建数据库（如果不存在）
echo 创建数据库...
mysql -u %MYSQL_USER% -p%MYSQL_PASSWORD% --show-warnings -e "CREATE DATABASE IF NOT EXISTS %DATABASE_NAME% DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

if %errorlevel% neq 0 (
    echo 创建数据库失败，请检查用户名和密码
    pause
    exit /b 1
)

REM 导入数据
echo 开始导入数据...
mysql -u %MYSQL_USER% -p%MYSQL_PASSWORD% --show-warnings %DATABASE_NAME% < "e:\workflow\data_sql\import.sql"

if %errorlevel% neq 0 (
    echo 导入数据失败
    pause
    exit /b 1
)

REM 验证导入结果
echo 验证导入结果...
mysql -u %MYSQL_USER% -p%MYSQL_PASSWORD% --show-warnings %DATABASE_NAME% -e "SELECT '用户登录日志记录数:', COUNT(*) FROM user_login_logs; SELECT '用户任务完成记录数:', COUNT(*) FROM user_task_completion;"

echo 导入完成！
pause

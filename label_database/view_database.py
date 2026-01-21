#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
数据库查看工具
用于查看game_competitor.db文件的内容
"""

import sqlite3

def view_database_structure(db_path):
    """查看数据库结构"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    print("=== 数据库结构 ===")
    
    # 获取所有表
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    
    for table in tables:
        table_name = table[0]
        print(f"\n--- 表: {table_name} ---")
        
        # 获取表结构
        cursor.execute(f"PRAGMA table_info({table_name});")
        columns = cursor.fetchall()
        print("列结构:")
        for col in columns:
            print(f"  {col[1]} ({col[2]})")
        
        # 获取表中的行数
        cursor.execute(f"SELECT COUNT(*) FROM {table_name};")
        row_count = cursor.fetchone()[0]
        print(f"\n表中记录数: {row_count}")
        
        # 获取前5条记录作为示例
        print("\n前5条记录示例:")
        cursor.execute(f"SELECT * FROM {table_name} LIMIT 5;")
        rows = cursor.fetchall()
        
        if rows:
            # 打印列名
            col_names = [col[1] if col[1] is not None else '' for col in cursor.description]
            print(f"  {' | '.join(col_names)}")
            print(f"  {'-' * (sum(len(name) for name in col_names) + 3 * (len(col_names) - 1))}")
            
            # 打印数据
            for row in rows:
                # 将所有值转换为字符串，处理None值
                row_str = [str(val) if val is not None else '' for val in row]
                print(f"  {' | '.join(row_str)}")
        else:
            print("  表为空")
    
    conn.close()

def main():
    """主函数"""
    db_path = 'game_competitor.db'
    
    try:
        view_database_structure(db_path)
        print("\n=== 打开数据库的其他方法 ===")
        print("1. 使用 DB Browser for SQLite (推荐)")
        print("   - 下载地址: https://sqlitebrowser.org/")
        print("   - 支持Windows/Mac/Linux")
        print("   - 图形界面，易于使用")
        print("\n2. 使用 SQLiteStudio")
        print("   - 下载地址: https://sqlitestudio.pl/")
        print("   - 支持Windows/Mac/Linux")
        print("   - 功能丰富的SQLite管理工具")
        print("\n3. 使用命令行")
        print("   - 安装sqlite3命令行工具")
        print("   - 运行命令: sqlite3 game_competitor.db")
        print("   - 在sqlite3提示符下可以执行SQL查询")
    except sqlite3.Error as e:
        print(f"打开数据库时出错: {e}")
        print(f"请确保数据库文件 '{db_path}' 存在于当前目录")

if __name__ == "__main__":
    main()
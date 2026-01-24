#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
验证爬虫数据是否正确存储到数据库
"""

import sqlite3
import json

def verify_database():
    """验证数据库中的数据"""
    conn = sqlite3.connect('game_competitor.db')
    cursor = conn.cursor()
    
    print("=== 验证游戏数据 ===")
    
    # 查询游戏数量
    cursor.execute("SELECT COUNT(*) FROM games")
    count = cursor.fetchone()[0]
    print(f"总游戏数量: {count}")
    
    # 查询前5个游戏
    cursor.execute("SELECT id, name, publisher, developer, platforms FROM games LIMIT 5")
    games = cursor.fetchall()
    
    print("\n前5个游戏信息:")
    for game in games:
        id_, name, publisher, developer, platforms = game
        print(f"ID: {id_}")
        print(f"  名称: {name}")
        print(f"  发行商: {publisher}")
        print(f"  开发商: {developer}")
        print(f"  平台: {json.loads(platforms) if platforms else []}")
    
    # 查询数据库表结构
    print("\n=== 数据库表结构 ===")
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    
    for table in tables:
        table_name = table[0]
        print(f"\n表: {table_name}")
        cursor.execute(f"PRAGMA table_info({table_name});")
        columns = cursor.fetchall()
        for column in columns:
            print(f"  {column[1]} ({column[2]})")
    
    conn.close()

if __name__ == "__main__":
    verify_database()

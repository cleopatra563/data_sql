#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
将数据库中的游戏数据导出到Excel文件
"""

import sqlite3
import pandas as pd
import json
from datetime import datetime

def export_games_to_excel(output_file: str = '游戏竞品数据.xlsx'):
    """从数据库导出游戏数据到Excel"""
    # 连接数据库
    conn = sqlite3.connect('game_competitor.db')
    
    try:
        # 查询游戏基本信息
        query = '''
            SELECT id, name, type, publisher, developer, release_date, 
                   platforms, package_id, store_url, official_website,
                   created_at, updated_at
            FROM games
        '''
        
        # 使用pandas读取数据
        df = pd.read_sql_query(query, conn)
        
        if df.empty:
            print("数据库中没有游戏数据")
            return
        
        # 处理platforms字段（JSON转字符串）
        df['platforms'] = df['platforms'].apply(lambda x: json.loads(x) if x else [])
        df['platforms'] = df['platforms'].apply(lambda x: ','.join(x))
        
        # 重命名字段为中文
        df_renamed = df.rename(columns={
            'id': '游戏ID',
            'name': '游戏名称',
            'type': '游戏类型',
            'publisher': '发行商',
            'developer': '开发商',
            'release_date': '发行日期',
            'platforms': '支持平台',
            'package_id': '包名/应用ID',
            'store_url': '商店链接',
            'official_website': '官网链接',
            'created_at': '创建时间',
            'updated_at': '更新时间'
        })
        
        # 调整列顺序
        columns_order = [
            '游戏ID', '游戏名称', '游戏类型', '发行商', '开发商', '发行日期',
            '支持平台', '包名/应用ID', '商店链接', '官网链接', '创建时间', '更新时间'
        ]
        df_renamed = df_renamed[columns_order]
        
        # 创建Excel写入器
        with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
            # 写入游戏数据
            df_renamed.to_excel(writer, sheet_name='游戏基本信息', index=False)
            
            # 格式化工作表
            worksheet = writer.sheets['游戏基本信息']
            
            # 调整列宽
            for column in worksheet.columns:
                max_length = 0
                column_letter = column[0].column_letter
                
                for cell in column:
                    try:
                        if len(str(cell.value)) > max_length:
                            max_length = len(str(cell.value))
                    except:
                        pass
                
                adjusted_width = min(max_length + 2, 50)
                worksheet.column_dimensions[column_letter].width = adjusted_width
        
        print(f"成功将 {len(df_renamed)} 条游戏数据导出到 {output_file}")
        
    except Exception as e:
        print(f"导出失败: {e}")
    finally:
        conn.close()

def export_detailed_data(output_file: str = '游戏竞品详细数据.xlsx'):
    """导出包含详细信息的游戏数据"""
    # 连接数据库
    conn = sqlite3.connect('game_competitor.db')
    
    try:
        # 查询游戏基本信息和详细信息的联合数据
        query = '''
            SELECT g.id, g.name, g.publisher, g.developer, g.platforms,
                   g.release_date, g.type, d.core_gameplay, d.art_style, d.technical_features
            FROM games g
            LEFT JOIN game_details d ON g.id = d.game_id
        '''
        
        df = pd.read_sql_query(query, conn)
        
        if df.empty:
            print("数据库中没有游戏数据")
            return
        
        # 处理platforms字段
        df['platforms'] = df['platforms'].apply(lambda x: json.loads(x) if x else [])
        df['platforms'] = df['platforms'].apply(lambda x: ','.join(x))
        
        # 重命名字段为中文
        df_renamed = df.rename(columns={
            'id': '游戏ID',
            'name': '游戏名称',
            'publisher': '发行商',
            'developer': '开发商',
            'platforms': '支持平台',
            'release_date': '发行日期',
            'type': '游戏类型',
            'core_gameplay': '核心玩法',
            'art_style': '美术风格',
            'technical_features': '技术特征'
        })
        
        # 创建Excel写入器
        with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
            df_renamed.to_excel(writer, sheet_name='游戏详细信息', index=False)
            
            # 调整列宽
            worksheet = writer.sheets['游戏详细信息']
            for column in worksheet.columns:
                max_length = 0
                column_letter = column[0].column_letter
                
                for cell in column:
                    try:
                        if len(str(cell.value)) > max_length:
                            max_length = len(str(cell.value))
                    except:
                        pass
                
                adjusted_width = min(max_length + 2, 50)
                worksheet.column_dimensions[column_letter].width = adjusted_width
        
        print(f"成功将 {len(df_renamed)} 条游戏详细数据导出到 {output_file}")
        
    except Exception as e:
        print(f"导出失败: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    # 安装必要的库
    try:
        import pandas
        import openpyxl
    except ImportError:
        print("正在安装必要的库...")
        import subprocess
        import sys
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas", "openpyxl"])
        print("库安装完成")
    
    print("1. 导出游戏基本信息到Excel")
    print("2. 导出游戏详细信息到Excel")
    choice = input("请选择操作 (1/2): ").strip()
    
    if choice == "1":
        export_games_to_excel()
    elif choice == "2":
        export_detailed_data()
    else:
        print("无效选择")

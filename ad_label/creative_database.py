#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
游戏素材数据库管理模块
用于存储和管理带标签的游戏素材信息
"""

import sqlite3
import json
import logging
from typing import Dict, List, Optional, Any
from datetime import datetime

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('CreativeDatabase')

class CreativeDatabase:
    """素材数据库管理类"""
    
    def __init__(self, db_file: str = 'creative_database.db'):
        self.db_file = db_file
        self.conn = sqlite3.connect(db_file)
        self.conn.row_factory = sqlite3.Row  # 允许通过列名访问
        self._create_tables()
    
    def _create_tables(self):
        """创建数据库表"""
        with self.conn:
            # 1. 素材表
            self.conn.execute('''
                CREATE TABLE IF NOT EXISTS creatives (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    creative_id TEXT NOT NULL UNIQUE,
                    platform TEXT NOT NULL,
                    title TEXT,
                    description TEXT,
                    call_to_action TEXT,
                    creative_type TEXT,
                    creative_url TEXT,
                    local_path TEXT,
                    impressions INTEGER,
                    countries TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            
            # 2. 标签表
            self.conn.execute('''
                CREATE TABLE IF NOT EXISTS tags (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL UNIQUE,
                    level INTEGER NOT NULL,
                    parent_id INTEGER,
                    category TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            
            # 3. 素材标签关联表
            self.conn.execute('''
                CREATE TABLE IF NOT EXISTS creative_tags (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    creative_id INTEGER NOT NULL,
                    tag_id INTEGER NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (creative_id) REFERENCES creatives (id),
                    FOREIGN KEY (tag_id) REFERENCES tags (id),
                    UNIQUE(creative_id, tag_id)
                )
            ''')
            
            # 4. 标签体系表（用于存储完整的标签树结构）
            self.conn.execute('''
                CREATE TABLE IF NOT EXISTS tag_system (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    level1 TEXT NOT NULL,
                    level2 TEXT NOT NULL,
                    level3 TEXT NOT NULL,
                    description TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(level1, level2, level3)
                )
            ''')
            
        logger.info("数据库表创建完成")
    
    def insert_creative(self, creative: Dict) -> int:
        """插入素材数据"""
        with self.conn:
            cursor = self.conn.execute('''
                INSERT OR REPLACE INTO creatives (
                    creative_id, platform, title, description, call_to_action,
                    creative_type, creative_url, local_path, impressions, countries
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                creative.get('id', ''),
                creative.get('platform', ''),
                creative.get('title', ''),
                creative.get('description', ''),
                creative.get('call_to_action', ''),
                creative.get('creative_type', ''),
                creative.get('creative_url', ''),
                creative.get('local_path', ''),
                creative.get('impressions', 0),
                json.dumps(creative.get('countries', [])) if creative.get('countries') else '[]'
            ))
            
            return cursor.lastrowid
    
    def insert_tag(self, name: str, level: int, parent_id: Optional[int] = None, category: Optional[str] = None) -> int:
        """插入标签数据"""
        with self.conn:
            cursor = self.conn.execute('''
                INSERT OR IGNORE INTO tags (name, level, parent_id, category)
                VALUES (?, ?, ?, ?)
            ''', (name, level, parent_id, category))
            
            # 获取标签ID
            if cursor.lastrowid == 0:
                # 标签已存在，查询ID
                cursor = self.conn.execute('SELECT id FROM tags WHERE name = ?', (name,))
                result = cursor.fetchone()
                if result:
                    return result[0]
            
            return cursor.lastrowid
    
    def insert_tag_system(self, level1: str, level2: str, level3: str, description: str = ''):
        """插入标签体系数据"""
        with self.conn:
            self.conn.execute('''
                INSERT OR IGNORE INTO tag_system (level1, level2, level3, description)
                VALUES (?, ?, ?, ?)
            ''', (level1, level2, level3, description))
    
    def insert_creative_tag(self, creative_id: int, tag_id: int):
        """建立素材和标签的关联"""
        with self.conn:
            self.conn.execute('''
                INSERT OR IGNORE INTO creative_tags (creative_id, tag_id)
                VALUES (?, ?)
            ''', (creative_id, tag_id))
    
    def save_tagged_creative(self, creative: Dict):
        """保存带标签的素材"""
        try:
            # 插入素材
            creative_id = self.insert_creative(creative)
            
            # 处理标签
            tags = creative.get('tags', {})
            if tags:
                for level1, level2_dict in tags.items():
                    # 插入一级标签
                    level1_id = self.insert_tag(level1, 1)
                    
                    for level2, level3_list in level2_dict.items():
                        # 插入二级标签
                        level2_id = self.insert_tag(level2, 2, level1_id, level1)
                        
                        for level3 in level3_list:
                            if level3 and level3 != '无':
                                # 插入三级标签
                                level3_id = self.insert_tag(level3, 3, level2_id, level2)
                                
                                # 建立素材和标签的关联
                                self.insert_creative_tag(creative_id, level3_id)
                                
                                # 保存到标签体系表
                                self.insert_tag_system(level1, level2, level3)
            
            logger.info(f"成功保存带标签的素材: {creative.get('title', '未知')}")
            return creative_id
            
        except Exception as e:
            logger.error(f"保存带标签的素材失败: {e}")
            return -1
    
    def get_creative_by_id(self, creative_id: int) -> Optional[Dict]:
        """根据ID获取素材"""
        cursor = self.conn.execute('SELECT * FROM creatives WHERE id = ?', (creative_id,))
        row = cursor.fetchone()
        
        if row:
            creative = dict(row)
            creative['countries'] = json.loads(creative['countries'])
            return creative
        
        return None
    
    def get_creatives_by_tag(self, tag_name: str, limit: int = 10) -> List[Dict]:
        """根据标签获取素材"""
        query = '''
            SELECT c.* FROM creatives c
            JOIN creative_tags ct ON c.id = ct.creative_id
            JOIN tags t ON ct.tag_id = t.id
            WHERE t.name = ?
            LIMIT ?
        '''
        
        cursor = self.conn.execute(query, (tag_name, limit))
        rows = cursor.fetchall()
        
        creatives = []
        for row in rows:
            creative = dict(row)
            creative['countries'] = json.loads(creative['countries'])
            creatives.append(creative)
        
        return creatives
    
    def get_tags_by_creative(self, creative_id: int) -> Dict:
        """根据素材ID获取所有标签"""
        query = '''
            SELECT t.*, ts.level1, ts.level2, ts.level3 FROM tags t
            JOIN creative_tags ct ON t.id = ct.tag_id
            LEFT JOIN tag_system ts ON t.name IN (ts.level1, ts.level2, ts.level3)
            WHERE ct.creative_id = ?
        '''
        
        cursor = self.conn.execute(query, (creative_id,))
        rows = cursor.fetchall()
        
        # 构建标签树
        tag_tree = {}
        for row in rows:
            row_dict = dict(row)
            
            if row_dict['level'] == 1:
                level1 = row_dict['name']
                tag_tree[level1] = {}
            elif row_dict['level'] == 2:
                level1 = row_dict['category']
                level2 = row_dict['name']
                if level1 not in tag_tree:
                    tag_tree[level1] = {}
                tag_tree[level1][level2] = []
            elif row_dict['level'] == 3:
                level1 = row_dict['level1']
                level2 = row_dict['level2']
                level3 = row_dict['name']
                if level1 not in tag_tree:
                    tag_tree[level1] = {}
                if level2 not in tag_tree[level1]:
                    tag_tree[level1][level2] = []
                if level3 not in tag_tree[level1][level2]:
                    tag_tree[level1][level2].append(level3)
        
        return tag_tree
    
    def get_all_tags(self, level: Optional[int] = None) -> List[Dict]:
        """获取所有标签"""
        if level:
            cursor = self.conn.execute('SELECT * FROM tags WHERE level = ? ORDER BY name', (level,))
        else:
            cursor = self.conn.execute('SELECT * FROM tags ORDER BY level, name')
        
        rows = cursor.fetchall()
        return [dict(row) for row in rows]
    
    def get_tag_system(self) -> Dict:
        """获取完整的标签体系"""
        cursor = self.conn.execute('SELECT * FROM tag_system ORDER BY level1, level2, level3')
        rows = cursor.fetchall()
        
        tag_system = {}
        for row in rows:
            level1 = row['level1']
            level2 = row['level2']
            level3 = row['level3']
            
            if level1 not in tag_system:
                tag_system[level1] = {}
            if level2 not in tag_system[level1]:
                tag_system[level1][level2] = []
            if level3 not in tag_system[level1][level2]:
                tag_system[level1][level2].append(level3)
        
        return tag_system
    
    def search_creatives(self, keyword: str, limit: int = 10) -> List[Dict]:
        """根据关键词搜索素材"""
        query = '''
            SELECT * FROM creatives
            WHERE title LIKE ? OR description LIKE ? OR call_to_action LIKE ?
            LIMIT ?
        '''
        
        keyword_pattern = f'%{keyword}%'
        cursor = self.conn.execute(query, (keyword_pattern, keyword_pattern, keyword_pattern, limit))
        rows = cursor.fetchall()
        
        creatives = []
        for row in rows:
            creative = dict(row)
            creative['countries'] = json.loads(creative['countries'])
            creatives.append(creative)
        
        return creatives
    
    def close(self):
        """关闭数据库连接"""
        self.conn.close()
        logger.info("数据库连接已关闭")

def main():
    """主函数"""
    logger.info("游戏素材数据库管理模块启动")
    
    try:
        # 创建数据库实例
        db = CreativeDatabase()
        
        # 测试数据
        test_creative = {
            'id': 'test_001',
            'platform': 'Facebook',
            'title': '原神全新版本上线',
            'description': '开放世界冒险游戏原神全新版本"枫丹"正式上线，免费下载体验',
            'call_to_action': '立即下载',
            'creative_type': 'video',
            'creative_url': 'https://example.com/genshin.mp4',
            'local_path': './creatives/genshin.mp4',
            'impressions': 100000,
            'countries': ['CN', 'US', 'JP'],
            'tags': {
                '阶段和目标': {
                    '素材阶段': ['首发期'],
                    '营销目标': ['拉新'],
                    '素材对应的目标用户': ['泛用户']
                },
                '内容主题': {
                    '核心玩法': ['战斗系统', '开放世界'],
                    '游戏特色': ['开放世界', '剧情驱动'],
                    '角色/IP': ['主角展示']
                }
            }
        }
        
        # 保存测试数据
        db.save_tagged_creative(test_creative)
        
        # 查询测试
        logger.info("\n=== 查询测试 ===")
        
        # 根据标签查询素材
        genshin_creatives = db.get_creatives_by_tag('原神', limit=5)
        logger.info(f"\n查询到 {len(genshin_creatives)} 个包含'原神'标签的素材")
        
        # 获取所有标签
        all_tags = db.get_all_tags()
        logger.info(f"\n数据库中共有 {len(all_tags)} 个标签")
        
        # 获取标签体系
        tag_system = db.get_tag_system()
        logger.info(f"\n标签体系包含 {len(tag_system)} 个一级标签")
        for level1, level2_dict in tag_system.items():
            logger.info(f"- {level1}: {len(level2_dict)} 个二级标签")
        
        db.close()
        
    except Exception as e:
        logger.error(f"数据库操作失败: {e}")

if __name__ == "__main__":
    main()

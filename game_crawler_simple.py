#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
游戏竞品库爬虫框架

功能：
1. 从主流应用商店爬取游戏信息
2. 支持App Store、Google Play、TapTap等平台
3. 模块化设计，易于扩展
4. 包含数据存储和分析功能
"""

import requests
import json
import time
import logging
import sqlite3
from datetime import datetime
from typing import Dict, List, Optional, Any
from urllib.parse import urljoin, urlencode

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('GameCrawler')

# 通用请求头
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8'
}

class DatabaseManager:
    """数据库管理类，用于存储爬取的游戏信息"""
    
    def __init__(self, db_file: str = 'game_competitor.db'):
        self.db_file = db_file
        self.conn = sqlite3.connect(db_file)
        self._create_tables()
    
    def _create_tables(self):
        """创建数据库表"""
        with self.conn:
            # 游戏基本信息表
            self.conn.execute('''
                CREATE TABLE IF NOT EXISTS games (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    type TEXT,
                    publisher TEXT,
                    developer TEXT,
                    release_date TEXT,
                    platforms TEXT,
                    package_id TEXT,
                    store_url TEXT,
                    official_website TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            
            # 游戏详细信息表
            self.conn.execute('''
                CREATE TABLE IF NOT EXISTS game_details (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    game_id INTEGER,
                    core_gameplay TEXT,
                    art_style TEXT,
                    technical_features TEXT,
                    FOREIGN KEY (game_id) REFERENCES games (id)
                )
            ''')
            
            # 运营数据表
            self.conn.execute('''
                CREATE TABLE IF NOT EXISTS game_metrics (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    game_id INTEGER,
                    date TEXT,
                    downloads INTEGER,
                    active_users INTEGER,
                    revenue REAL,
                    rating REAL,
                    cpi REAL,
                    ctr REAL,
                    region TEXT,
                    FOREIGN KEY (game_id) REFERENCES games (id)
                )
            ''')
    
    def insert_game(self, game_info: Dict) -> int:
        """插入游戏信息"""
        with self.conn:
            cursor = self.conn.execute('''
                INSERT INTO games (name, type, publisher, developer, release_date, 
                                  platforms, package_id, store_url, official_website)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                game_info.get('name', ''),
                game_info.get('type', ''),
                game_info.get('publisher', ''),
                game_info.get('developer', ''),
                game_info.get('release_date', ''),
                json.dumps(game_info.get('platforms', [])),
                game_info.get('package_id', ''),
                game_info.get('store_url', ''),
                game_info.get('official_website', '')
            ))
            return cursor.lastrowid
    
    def close(self):
        """关闭数据库连接"""
        self.conn.close()

class BaseCrawler:
    """基础爬虫类"""
    
    def __init__(self, name: str, base_url: str):
        self.name = name
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update(HEADERS)
    
    def request(self, url: str, params: Optional[Dict] = None, retry: int = 3) -> Optional[requests.Response]:
        """发送网络请求"""
        for i in range(retry):
            try:
                response = self.session.get(url, params=params, timeout=10)
                response.raise_for_status()
                return response
            except requests.RequestException as e:
                logger.error(f"[{self.name}] 请求失败 {url}: {e}, 重试 {i+1}/{retry}")
                time.sleep(2 ** i)
        return None
    
    def crawl_game_list(self, **kwargs) -> List[Dict]:
        """爬取游戏列表"""
        raise NotImplementedError
    
    def crawl_game_detail(self, game_id: str) -> Dict:
        """爬取游戏详情"""
        raise NotImplementedError

class AppStoreCrawler(BaseCrawler):
    """App Store爬虫"""
    
    def __init__(self):
        super().__init__("App Store", "https://itunes.apple.com")
    
    def crawl_game_list(self, category: str = "games", limit: int = 10) -> List[Dict]:
        """使用Apple Search API爬取游戏列表"""
        url = "https://itunes.apple.com/search"
        params = {
            'term': category,
            'media': 'software',
            'entity': 'software',
            'limit': limit,
            'country': 'us'
        }
        
        response = self.request(url, params=params)
        if not response:
            return []
        
        try:
            data = response.json()
            games = []
            for result in data.get('results', []):
                if result.get('primaryGenreName') == 'Games':
                    game = {
                        'id': result.get('trackId'),
                        'name': result.get('trackName'),
                        'developer': result.get('sellerName'),
                        'publisher': result.get('sellerName'),
                        'release_date': result.get('releaseDate'),
                        'platforms': ['iOS'],
                        'rating': result.get('averageUserRating'),
                        'store_url': result.get('trackViewUrl'),
                        'type': result.get('primaryGenreName')
                    }
                    games.append(game)
            return games
        except json.JSONDecodeError:
            logger.error("[App Store] 解析JSON失败")
            return []
    
    def crawl_game_detail(self, game_id: str) -> Dict:
        """爬取游戏详情"""
        url = "https://itunes.apple.com/lookup"
        params = {
            'id': game_id,
            'country': 'us'
        }
        
        response = self.request(url, params=params)
        if not response:
            return {}
        
        try:
            data = response.json()
            result = data.get('results', [])[0]
            return {
                'id': result.get('trackId'),
                'name': result.get('trackName'),
                'description': result.get('description'),
                'version': result.get('version'),
                'file_size': result.get('fileSizeBytes'),
                'requirements': result.get('requirements'),
                'screenshots': result.get('screenshotUrls', []),
                'artwork_url': result.get('artworkUrl100')
            }
        except (json.JSONDecodeError, IndexError):
            logger.error(f"[App Store] 解析游戏详情失败 (ID: {game_id})")
            return {}

class GooglePlayCrawler(BaseCrawler):
    """Google Play爬虫"""
    
    def __init__(self):
        super().__init__("Google Play", "https://play.google.com")
    
    def crawl_game_list(self, category: str = "GAME_ACTION", limit: int = 10) -> List[Dict]:
        """爬取Google Play游戏列表"""
        # 注意：Google Play没有公开的API，需要使用第三方服务或网页爬虫
        # 这里提供一个示例实现，实际使用时需要根据页面结构调整
        logger.warning("[Google Play] Google Play爬取需要使用第三方API或高级网页爬虫")
        return []
    
    def crawl_game_detail(self, game_id: str) -> Dict:
        """爬取游戏详情"""
        logger.warning("[Google Play] Google Play游戏详情爬取需要使用第三方API")
        return {}

class GameCrawlerManager:
    """游戏爬虫管理器"""
    
    def __init__(self):
        self.crawlers = {
            'appstore': AppStoreCrawler(),
            'googleplay': GooglePlayCrawler()
        }
        self.db = DatabaseManager()
    
    def get_crawler(self, platform: str) -> Optional[BaseCrawler]:
        """获取指定平台的爬虫"""
        return self.crawlers.get(platform.lower())
    
    def crawl_and_save(self, platform: str, category: str = "games", limit: int = 10):
        """爬取并保存游戏信息"""
        crawler = self.get_crawler(platform)
        if not crawler:
            logger.error(f"不支持的平台: {platform}")
            return
        
        logger.info(f"[{platform}] 开始爬取游戏列表 (分类: {category}, 数量: {limit})")
        games = crawler.crawl_game_list(category, limit)
        
        if not games:
            logger.warning(f"[{platform}] 未获取到游戏列表")
            return
        
        logger.info(f"[{platform}] 成功获取 {len(games)} 个游戏")
        
        # 保存到数据库
        for game in games:
            logger.info(f"[{platform}] 处理游戏: {game['name']}")
            game_id = self.db.insert_game(game)
            
            # 爬取详细信息
            detail = crawler.crawl_game_detail(game['id'])
            if detail:
                logger.info(f"[{platform}] 获取到游戏详情: {game['name']}")
    
    def close(self):
        """关闭数据库连接"""
        self.db.close()

def main():
    """主函数"""
    logger.info("游戏竞品库爬虫启动")
    
    # 创建爬虫管理器
    manager = GameCrawlerManager()
    
    try:
        # 爬取App Store游戏
        manager.crawl_and_save('appstore', category='games', limit=5)
        
        # 可以添加其他平台的爬取
        # manager.crawl_and_save('googleplay', category='GAME_ACTION', limit=5)
        
    finally:
        manager.close()
        logger.info("游戏竞品库爬虫结束")

if __name__ == "__main__":
    main()

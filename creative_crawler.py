#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
游戏素材收集爬虫
支持从主流广告平台获取游戏买量素材
"""

import requests
import json
import time
import logging
import os
import hashlib
from typing import Dict, List, Optional, Any
from abc import ABC, abstractmethod
from urllib.parse import urljoin, urlparse

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('CreativeCrawler')

# 通用请求头
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8'
}

class BaseCrawler(ABC):
    """广告平台爬虫基类"""
    
    def __init__(self, platform_name: str, base_url: str):
        self.platform_name = platform_name
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update(HEADERS)
    
    def request(self, url: str, params: Optional[Dict] = None, data: Optional[Dict] = None, 
                 retry: int = 3, timeout: int = 10) -> Optional[requests.Response]:
        """发送网络请求，支持重试"""
        for i in range(retry):
            try:
                response = self.session.get(url, params=params, data=data, timeout=timeout)
                response.raise_for_status()
                return response
            except requests.RequestException as e:
                logger.error(f"[{self.platform_name}] 请求失败 {url}: {e}, 重试 {i+1}/{retry}")
                time.sleep(2 ** i)
        return None
    
    @abstractmethod
    def crawl_creatives(self, keyword: str, limit: int = 10) -> List[Dict]:
        """爬取素材"""
        pass
    
    def download_creative(self, url: str, save_dir: str = './creatives') -> Optional[str]:
        """下载素材文件"""
        try:
            # 创建保存目录
            os.makedirs(save_dir, exist_ok=True)
            
            # 获取文件名
            parsed_url = urlparse(url)
            filename = os.path.basename(parsed_url.path)
            
            # 如果文件名不包含扩展名，添加默认扩展名
            if '.' not in filename:
                filename += '.jpg'  # 默认使用jpg扩展名
            
            # 下载文件
            response = self.session.get(url, stream=True)
            response.raise_for_status()
            
            # 保存文件
            save_path = os.path.join(save_dir, filename)
            with open(save_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            logger.info(f"[{self.platform_name}] 素材下载成功: {save_path}")
            return save_path
        except Exception as e:
            logger.error(f"[{self.platform_name}] 素材下载失败 {url}: {e}")
            return None

class FacebookCreativeCrawler(BaseCrawler):
    """Facebook广告素材爬虫"""
    
    def __init__(self):
        super().__init__("Facebook", "https://www.facebook.com")
    
    def crawl_creatives(self, keyword: str, limit: int = 10) -> List[Dict]:
        """使用Facebook Ads Library爬取素材"""
        # Facebook Ads Library API (需要申请API密钥)
        # 这里使用公开的Ads Library网页爬虫示例
        
        logger.info(f"[{self.platform_name}] 开始爬取关于 '{keyword}' 的素材")
        
        # 注意：实际使用需要申请Facebook API密钥
        # 这里返回模拟数据作为示例
        mock_creatives = [
            {
                'id': f'fb_{i}',
                'platform': 'Facebook',
                'ad_account': '游戏公司A',
                'creative_type': 'image',
                'creative_url': f'https://example.com/creative_{i}.jpg',
                'title': f'{keyword} 游戏广告 {i}',
                'description': f'{keyword} 全新版本，立即下载！',
                'call_to_action': '立即下载',
                'created_time': '2026-01-19T12:00:00+0000',
                'countries': ['US', 'CN'],
                'impressions': 100000 + i * 10000
            } for i in range(limit)
        ]
        
        logger.info(f"[{self.platform_name}] 成功获取 {len(mock_creatives)} 个素材")
        return mock_creatives

class GoogleAdsCrawler(BaseCrawler):
    """Google Ads素材爬虫"""
    
    def __init__(self):
        super().__init__("Google Ads", "https://ads.google.com")
    
    def crawl_creatives(self, keyword: str, limit: int = 10) -> List[Dict]:
        """使用Google Ads API爬取素材"""
        logger.info(f"[{self.platform_name}] 开始爬取关于 '{keyword}' 的素材")
        
        # 注意：实际使用需要申请Google Ads API密钥
        # 这里返回模拟数据作为示例
        mock_creatives = [
            {
                'id': f'google_{i}',
                'platform': 'Google Ads',
                'ad_account': '游戏公司B',
                'creative_type': 'video' if i % 2 == 0 else 'image',
                'creative_url': f'https://example.com/google_creative_{i}.{"mp4" if i % 2 == 0 else "jpg"}',
                'title': f'{keyword} 官方版',
                'description': f'玩 {keyword}，赢取丰厚奖励！',
                'call_to_action': '立即安装',
                'created_time': '2026-01-18T15:30:00+0000',
                'countries': ['US', 'JP', 'KR'],
                'impressions': 150000 + i * 15000
            } for i in range(limit)
        ]
        
        logger.info(f"[{self.platform_name}] 成功获取 {len(mock_creatives)} 个素材")
        return mock_creatives

class TikTokCreativeCrawler(BaseCrawler):
    """TikTok广告素材爬虫"""
    
    def __init__(self):
        super().__init__("TikTok", "https://www.tiktok.com")
    
    def crawl_creatives(self, keyword: str, limit: int = 10) -> List[Dict]:
        """爬取TikTok广告素材"""
        logger.info(f"[{self.platform_name}] 开始爬取关于 '{keyword}' 的素材")
        
        # 注意：实际使用需要处理TikTok的反爬机制
        # 这里返回模拟数据作为示例
        mock_creatives = [
            {
                'id': f'tiktok_{i}',
                'platform': 'TikTok',
                'ad_account': '游戏公司C',
                'creative_type': 'video',
                'creative_url': f'https://example.com/tiktok_creative_{i}.mp4',
                'title': f'{keyword} 热门游戏',
                'description': f'#{keyword} 超火玩法，快来试试！',
                'call_to_action': '下载游戏',
                'created_time': '2026-01-17T10:00:00+0000',
                'countries': ['CN', 'IN', 'ID'],
                'impressions': 200000 + i * 20000
            } for i in range(limit)
        ]
        
        logger.info(f"[{self.platform_name}] 成功获取 {len(mock_creatives)} 个素材")
        return mock_creatives

class CreativeCrawlerManager:
    """素材爬虫管理器"""
    
    def __init__(self):
        self.crawlers = {
            'facebook': FacebookCreativeCrawler(),
            'google': GoogleAdsCrawler(),
            'tiktok': TikTokCreativeCrawler()
        }
    
    def get_crawler(self, platform: str) -> Optional[BaseCrawler]:
        """获取指定平台的爬虫"""
        return self.crawlers.get(platform.lower())
    
    def crawl_all_platforms(self, keyword: str, limit: int = 5) -> List[Dict]:
        """爬取所有平台的素材"""
        all_creatives = []
        
        for platform, crawler in self.crawlers.items():
            try:
                creatives = crawler.crawl_creatives(keyword, limit)
                all_creatives.extend(creatives)
            except Exception as e:
                logger.error(f"爬取 {platform} 失败: {e}")
        
        logger.info(f"总共获取 {len(all_creatives)} 个素材")
        return all_creatives
    
    def download_creatives(self, creatives: List[Dict], save_dir: str = './creatives') -> List[Dict]:
        """下载素材文件"""
        for creative in creatives:
            platform = creative.get('platform')
            crawler = self.get_crawler(platform)
            if crawler:
                creative_url = creative.get('creative_url')
                if creative_url:
                    save_path = crawler.download_creative(creative_url, save_dir)
                    creative['local_path'] = save_path
        
        return creatives

def main():
    """主函数"""
    logger.info("游戏素材爬虫启动")
    
    # 创建爬虫管理器
    manager = CreativeCrawlerManager()
    
    try:
        # 爬取游戏素材
        keyword = "原神"
        creatives = manager.crawl_all_platforms(keyword, limit=2)
        
        # 下载素材
        # manager.download_creatives(creatives)
        
        # 打印素材信息
        logger.info(f"\n爬取到的素材信息:")
        for creative in creatives:
            logger.info(f"平台: {creative['platform']}")
            logger.info(f"  ID: {creative['id']}")
            logger.info(f"  标题: {creative['title']}")
            logger.info(f"  类型: {creative['creative_type']}")
            logger.info(f"  描述: {creative['description']}")
            logger.info(f"  行动号召: {creative['call_to_action']}")
            logger.info(f"  曝光量: {creative['impressions']}")
            logger.info(f"  国家: {', '.join(creative['countries'])}")
            logger.info(f"  URL: {creative['creative_url']}")
            logger.info("")
            
    except Exception as e:
        logger.error(f"爬虫运行失败: {e}")
    
    logger.info("游戏素材爬虫结束")

if __name__ == "__main__":
    main()

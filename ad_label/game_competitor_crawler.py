import requests
import json
import time
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any
from abc import ABC, abstractmethod
from urllib.parse import urljoin, urlencode
import random

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('GameCompetitorCrawler')

# 通用请求头
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8'
}

# 代理池（示例）
PROXIES = [
    # {'http': 'http://proxy1:8080', 'https': 'https://proxy1:8080'},
    # {'http': 'http://proxy2:8080', 'https': 'https://proxy2:8080'},
]

class BaseCrawler(ABC):
    """基础爬虫抽象类，定义通用接口"""
    
    def __init__(self, base_url: str, timeout: int = 10):
        self.base_url = base_url
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update(HEADERS)
    
    def _get_proxy(self):
        """获取随机代理"""
        if PROXIES:
            return random.choice(PROXIES)
        return None
    
    def _request(self, url: str, method: str = 'GET', params: Optional[Dict] = None, 
                 data: Optional[Dict] = None, retry: int = 3) -> Optional[requests.Response]:
        """发送网络请求，支持重试和代理"""
        for i in range(retry):
            try:
                proxy = self._get_proxy()
                response = self.session.request(
                    method=method,
                    url=url,
                    params=params,
                    data=data,
                    timeout=self.timeout,
                    proxies=proxy
                )
                response.raise_for_status()
                return response
            except requests.RequestException as e:
                logger.error(f"请求失败 {url}, 错误: {e}, 重试 {i+1}/{retry}")
                time.sleep(2 ** i)  # 指数退避
        return None
    
    @abstractmethod
    def crawl_game_info(self, game_id: str) -> Optional[Dict]:
        """爬取游戏基本信息"""
        pass
    
    @abstractmethod
    def crawl_game_list(self, category: str, page: int = 1) -> Optional[List[Dict]]:
        """爬取游戏列表"""
        pass

class TapTapCrawler(BaseCrawler):
    """TapTap应用商店爬虫"""
    
    def __init__(self):
        super().__init__("https://www.taptap.com")
    
    def crawl_game_list(self, category: str = "全部", page: int = 1) -> Optional[List[Dict]]:
        """爬取TapTap游戏列表"""
        # 直接爬取游戏分类页面
        url = f"https://www.taptap.com/category/{page}"
        
        response = self._request(url)
        if not response:
            return None
        
        try:
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(response.text, 'html.parser')
            
            games = []
            # 查找游戏列表容器
            game_list = soup.find('div', class_='taptap-category-card-list')
            if game_list:
                for item in game_list.find_all('a', class_='taptap-category-card-item'):
                    try:
                        # 提取游戏ID
                        game_url = item.get('href')
                        if game_url:
                            game_id = game_url.split('/')[-1]
                            
                        # 提取游戏名称
                        name_elem = item.find('div', class_='taptap-category-card-item__title')
                        name = name_elem.text.strip() if name_elem else ''
                        
                        # 提取评分
                        score_elem = item.find('div', class_='taptap-category-card-item__score')
                        score = score_elem.text.strip() if score_elem else ''
                        
                        # 提取游戏类型
                        type_elem = item.find('div', class_='taptap-category-card-item__tags')
                        game_type = type_elem.text.strip() if type_elem else ''
                        
                        game_info = {
                            'id': game_id,
                            'name': name,
                            'type': game_type,
                            'score': score,
                            'download_url': urljoin(self.base_url, game_url),
                            'image_url': item.find('img')['src'] if item.find('img') else ''
                        }
                        games.append(game_info)
                    except Exception as e:
                        logger.error(f"解析TapTap游戏项失败: {e}")
                        continue
            
            logger.info(f"从TapTap页面解析到 {len(games)} 个游戏")
            return games
        except Exception as e:
            logger.error(f"解析TapTap游戏列表失败: {e}")
            logger.debug(f"响应内容: {response.text[:200]}...")
            return None
    
    def crawl_game_info(self, game_id: str) -> Optional[Dict]:
        """爬取TapTap游戏详情"""
        url = f"https://www.taptap.com/app/{game_id}"
        response = self._request(url)
        if not response:
            return None
        
        # 这里需要使用BeautifulSoup解析HTML，提取游戏信息
        # 示例代码，实际需要根据页面结构调整
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # 安全提取元素文本
        def safe_get_text(element, default=''):
            if element:
                return element.text.strip()
            return default
        
        game_info = {
            'id': game_id,
            'name': safe_get_text(soup.find('h1', class_='game-name')),
            'description': safe_get_text(soup.find('div', class_='game-intro')),
            'publisher': safe_get_text(soup.find('div', class_='publisher')),
            'developer': safe_get_text(soup.find('div', class_='developer')),
            'rating': safe_get_text(soup.find('div', class_='rating')),
            'platforms': ['移动端'],  # TapTap主要是移动端游戏
            'url': url
        }
        
        return game_info

class AppStoreCrawler(BaseCrawler):
    """App Store爬虫"""
    
    def __init__(self):
        super().__init__("https://itunes.apple.com")
    
    def crawl_game_list(self, category: str = "games", page: int = 1) -> Optional[List[Dict]]:
        """爬取App Store游戏列表"""
        url = f"https://itunes.apple.com/us/genre/ios-{category}/id6014?mt=8"
        response = self._request(url)
        if not response:
            return None
        
        # 使用BeautifulSoup解析HTML
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(response.text, 'html.parser')
        
        games = []
        for item in soup.find_all('div', class_='grid3-column'):
            try:
                game_info = {
                    'name': item.find('a', class_='name').text.strip(),
                    'url': item.find('a', class_='name')['href'],
                    'developer': item.find('a', class_='developer').text.strip(),
                    'rating': item.find('span', class_='rating').text.strip()
                }
                games.append(game_info)
            except Exception as e:
                logger.error(f"解析App Store游戏项失败: {e}")
        
        return games
    
    def crawl_game_info(self, game_id: str) -> Optional[Dict]:
        """爬取App Store游戏详情"""
        # 使用Apple Search API获取游戏信息
        url = "https://itunes.apple.com/lookup"
        params = {
            'id': game_id,
            'country': 'us',
            'entity': 'software'
        }
        
        response = self._request(url, params=params)
        if not response:
            return None
        
        try:
            data = response.json()
            result = data.get('results', [])[0]
            
            game_info = {
                'id': result.get('trackId'),
                'name': result.get('trackName'),
                'developer': result.get('sellerName'),
                'publisher': result.get('sellerName'),
                'release_date': result.get('releaseDate'),
                'update_date': result.get('currentVersionReleaseDate'),
                'description': result.get('description'),
                'platforms': ['iOS'],
                'price': result.get('price'),
                'rating': result.get('averageUserRating'),
                'rating_count': result.get('userRatingCount'),
                'category': result.get('primaryGenreName'),
                'download_url': result.get('trackViewUrl'),
                'icon_url': result.get('artworkUrl100')
            }
            
            return game_info
        except (json.JSONDecodeError, IndexError):
            logger.error("解析App Store游戏详情失败")
            return None

class WeiboCrawler(BaseCrawler):
    """微博爬虫，获取游戏官方动态"""
    
    def __init__(self):
        super().__init__("https://m.weibo.cn")
    
    def crawl_game_list(self, category: str, page: int = 1) -> Optional[List[Dict]]:
        """微博不提供直接的游戏列表，此方法不实现"""
        return None
    
    def crawl_game_info(self, game_id: str) -> Optional[Dict]:
        """爬取微博官方账号信息"""
        url = f"https://m.weibo.cn/api/container/getIndex"
        params = {
            'type': 'uid',
            'value': game_id,
            'containerid': f"107603{game_id}"
        }
        
        response = self._request(url, params=params)
        if not response:
            return None
        
        try:
            data = response.json()
            user_info = data.get('data', {}).get('userInfo', {})
            
            weibo_info = {
                'id': user_info.get('id'),
                'name': user_info.get('screen_name'),
                'description': user_info.get('description'),
                'followers_count': user_info.get('followers_count'),
                'following_count': user_info.get('friends_count'),
                'posts_count': user_info.get('statuses_count')
            }
            
            return weibo_info
        except json.JSONDecodeError:
            logger.error("解析微博账号信息失败")
            return None
    
    def crawl_latest_posts(self, game_id: str, count: int = 10) -> Optional[List[Dict]]:
        """爬取最新微博动态"""
        url = f"https://m.weibo.cn/api/container/getIndex"
        params = {
            'type': 'uid',
            'value': game_id,
            'containerid': f"107603{game_id}",
            'count': count
        }
        
        response = self._request(url, params=params)
        if not response:
            return None
        
        try:
            data = response.json()
            posts = []
            for item in data.get('data', {}).get('cards', []):
                if item.get('card_type') == 9:
                    mblog = item.get('mblog', {})
                    post = {
                        'id': mblog.get('id'),
                        'content': mblog.get('text'),
                        'created_at': mblog.get('created_at'),
                        'comments_count': mblog.get('comments_count'),
                        'reposts_count': mblog.get('reposts_count'),
                        'attitudes_count': mblog.get('attitudes_count')
                    }
                    posts.append(post)
            return posts
        except json.JSONDecodeError:
            logger.error("解析微博动态失败")
            return None

class GameCompetitorCrawler:
    """游戏竞品爬虫主类，整合各个平台的爬虫"""
    
    def __init__(self):
        self.crawlers = {
            'taptap': TapTapCrawler(),
            'appstore': AppStoreCrawler(),
            'weibo': WeiboCrawler()
        }
    
    def get_crawler(self, platform: str) -> Optional[BaseCrawler]:
        """获取指定平台的爬虫"""
        return self.crawlers.get(platform.lower())
    
    def crawl_game_comprehensive(self, platform: str, game_id: str) -> Optional[Dict]:
        """爬取游戏综合信息"""
        crawler = self.get_crawler(platform)
        if not crawler:
            logger.error(f"不支持的平台: {platform}")
            return None
        
        return crawler.crawl_game_info(game_id)
    
    def crawl_game_list(self, platform: str, category: str = "全部", page: int = 1) -> Optional[List[Dict]]:
        """爬取指定平台的游戏列表"""
        crawler = self.get_crawler(platform)
        if not crawler:
            logger.error(f"不支持的平台: {platform}")
            return None
        
        return crawler.crawl_game_list(category, page)

if __name__ == "__main__":
    # 示例使用
    crawler = GameCompetitorCrawler()
    
    # 爬取TapTap游戏列表
    logger.info("爬取TapTap游戏列表...")
    taptap_games = crawler.crawl_game_list("taptap", page=1)
    if taptap_games:
        logger.info(f"获取到 {len(taptap_games)} 个TapTap游戏")
        for game in taptap_games[:3]:
            logger.info(f"游戏: {game['name']}, 分数: {game['score']}")
    
    # 爬取App Store游戏列表
    logger.info("\n爬取App Store游戏列表...")
    appstore_games = crawler.crawl_game_list("appstore", page=1)
    if appstore_games:
        logger.info(f"获取到 {len(appstore_games)} 个App Store游戏")
        for game in appstore_games[:3]:
            logger.info(f"游戏: {game['name']}, 开发者: {game['developer']}")
    
    # 爬取特定游戏详情
    logger.info("\n爬取特定游戏详情...")
    # 示例：爬取TapTap上的原神信息
    genshin_info = crawler.crawl_game_comprehensive("taptap", "168332")
    if genshin_info:
        logger.info(f"游戏名称: {genshin_info['name']}")
        logger.info(f"开发商: {genshin_info['developer']}")
        logger.info(f"评分: {genshin_info['rating']}")

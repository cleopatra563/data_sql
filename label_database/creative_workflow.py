#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
游戏素材自动打标工作流
整合素材收集、AI分析和数据存储功能
"""

import os
import sys
import json
import logging
import argparse
from typing import Dict, List, Optional

# 添加当前目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# 导入模块
from creative_crawler import CreativeCrawlerManager
from creative_tagging import CreativeTagger
from creative_database import CreativeDatabase

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('CreativeWorkflow')

class CreativeWorkflow:
    """素材打标工作流管理类"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.crawler_manager = None
        self.tagger = None
        self.database = None
    
    def initialize(self):
        """初始化工作流组件"""
        logger.info("初始化素材打标工作流...")
        
        # 1. 初始化爬虫管理器
        self.crawler_manager = CreativeCrawlerManager()
        logger.info("爬虫管理器初始化完成")
        
        # 2. 初始化标签提取器
        label_file = self.config.get('label_file', 'label_dict.md')
        self.tagger = CreativeTagger(label_file)
        logger.info("标签提取器初始化完成")
        
        # 3. 初始化数据库
        db_file = self.config.get('database_file', 'creative_database.db')
        self.database = CreativeDatabase(db_file)
        logger.info("数据库初始化完成")
        
        logger.info("工作流组件初始化完成")
    
    def crawl_creatives(self) -> List[Dict]:
        """爬取素材"""
        keyword = self.config.get('keyword', '游戏')
        limit = self.config.get('limit', 5)
        platforms = self.config.get('platforms', ['facebook', 'google', 'tiktok'])
        
        logger.info(f"开始爬取素材 - 关键词: {keyword}, 数量: {limit}, 平台: {', '.join(platforms)}")
        
        all_creatives = []
        
        # 遍历指定平台
        for platform in platforms:
            crawler = self.crawler_manager.get_crawler(platform)
            if crawler:
                try:
                    logger.info(f"爬取 {platform} 平台的素材")
                    creatives = crawler.crawl_creatives(keyword, limit)
                    all_creatives.extend(creatives)
                    logger.info(f"{platform} 平台爬取完成，获取 {len(creatives)} 个素材")
                except Exception as e:
                    logger.error(f"爬取 {platform} 平台失败: {e}")
            else:
                logger.warning(f"不支持的平台: {platform}")
        
        logger.info(f"所有平台爬取完成，共获取 {len(all_creatives)} 个素材")
        return all_creatives
    
    def tag_creatives(self, creatives: List[Dict]) -> List[Dict]:
        """为素材打标签"""
        logger.info(f"开始为 {len(creatives)} 个素材打标签")
        
        # 批量打标签
        tagged_creatives = self.tagger.batch_tag_creatives(creatives)
        
        logger.info(f"素材打标签完成，共处理 {len(tagged_creatives)} 个素材")
        return tagged_creatives
    
    def save_creatives(self, creatives: List[Dict]) -> List[int]:
        """保存素材到数据库"""
        logger.info(f"开始保存 {len(creatives)} 个素材到数据库")
        
        saved_ids = []
        for creative in creatives:
            creative_id = self.database.save_tagged_creative(creative)
            if creative_id > 0:
                saved_ids.append(creative_id)
        
        logger.info(f"素材保存完成，成功保存 {len(saved_ids)} 个素材")
        return saved_ids
    
    def export_results(self, output_file: str = 'creative_results.json'):
        """导出结果"""
        logger.info(f"开始导出结果到 {output_file}")
        
        # 这里可以扩展为导出到不同格式
        # 目前实现导出到JSON
        
        # 查询所有素材
        try:
            # 注意：这里需要修改数据库模块以支持查询所有素材
            # 目前使用搜索功能作为临时解决方案
            all_creatives = self.database.search_creatives('', limit=1000)
            
            # 为每个素材添加标签
            for creative in all_creatives:
                tags = self.database.get_tags_by_creative(creative['id'])
                creative['tags'] = tags
            
            # 保存到JSON文件
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(all_creatives, f, ensure_ascii=False, indent=2, default=str)
            
            logger.info(f"结果导出成功，共导出 {len(all_creatives)} 个素材")
            return True
            
        except Exception as e:
            logger.error(f"导出结果失败: {e}")
            return False
    
    def run(self):
        """运行完整工作流"""
        logger.info("开始运行素材打标工作流")
        
        try:
            # 1. 初始化组件
            self.initialize()
            
            # 2. 爬取素材
            creatives = self.crawl_creatives()
            if not creatives:
                logger.warning("未获取到素材，工作流终止")
                return False
            
            # 3. 为素材打标签
            tagged_creatives = self.tag_creatives(creatives)
            
            # 4. 保存到数据库
            saved_ids = self.save_creatives(tagged_creatives)
            if not saved_ids:
                logger.warning("未保存到素材，工作流终止")
                return False
            
            # 5. 导出结果
            export_file = self.config.get('export_file')
            if export_file:
                self.export_results(export_file)
            
            logger.info("素材打标工作流运行完成")
            return True
            
        except Exception as e:
            logger.error(f"工作流运行失败: {e}")
            return False
        
        finally:
            # 关闭数据库连接
            if self.database:
                self.database.close()
    
    def search_creatives(self, keyword: str, limit: int = 10) -> List[Dict]:
        """搜索素材"""
        if not self.database:
            logger.error("数据库未初始化")
            return []
        
        logger.info(f"搜索素材 - 关键词: {keyword}, 数量: {limit}")
        creatives = self.database.search_creatives(keyword, limit)
        
        # 为每个素材添加标签
        for creative in creatives:
            tags = self.database.get_tags_by_creative(creative['id'])
            creative['tags'] = tags
        
        return creatives
    
    def get_creatives_by_tag(self, tag_name: str, limit: int = 10) -> List[Dict]:
        """根据标签获取素材"""
        if not self.database:
            logger.error("数据库未初始化")
            return []
        
        logger.info(f"根据标签获取素材 - 标签: {tag_name}, 数量: {limit}")
        creatives = self.database.get_creatives_by_tag(tag_name, limit)
        
        # 为每个素材添加标签
        for creative in creatives:
            tags = self.database.get_tags_by_creative(creative['id'])
            creative['tags'] = tags
        
        return creatives
    
    def get_tag_system(self) -> Dict:
        """获取标签体系"""
        if not self.database:
            logger.error("数据库未初始化")
            return {}
        
        return self.database.get_tag_system()

def load_config(config_file: str) -> Dict:
    """加载配置文件"""
    if not os.path.exists(config_file):
        logger.warning(f"配置文件不存在: {config_file}")
        return {}
    
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        logger.info(f"配置文件加载成功: {config_file}")
        return config
    except Exception as e:
        logger.error(f"加载配置文件失败: {e}")
        return {}

def save_config(config: Dict, config_file: str = 'creative_config.json'):
    """保存配置文件"""
    try:
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        logger.info(f"配置文件保存成功: {config_file}")
        return True
    except Exception as e:
        logger.error(f"保存配置文件失败: {e}")
        return False

def main():
    """主函数"""
    # 解析命令行参数
    parser = argparse.ArgumentParser(description='游戏素材自动打标工作流')
    parser.add_argument('--config', type=str, default='creative_config.json', help='配置文件路径')
    parser.add_argument('--keyword', type=str, help='搜索关键词')
    parser.add_argument('--limit', type=int, help='爬取数量')
    parser.add_argument('--platforms', type=str, nargs='+', help='爬取平台')
    parser.add_argument('--export', type=str, help='导出文件路径')
    parser.add_argument('--action', type=str, default='run', choices=['run', 'search', 'tag'], help='执行动作')
    parser.add_argument('--search_keyword', type=str, help='搜索关键词')
    parser.add_argument('--tag_name', type=str, help='标签名称')
    
    args = parser.parse_args()
    
    # 加载配置文件
    config = load_config(args.config)
    
    # 更新配置
    if args.keyword:
        config['keyword'] = args.keyword
    if args.limit:
        config['limit'] = args.limit
    if args.platforms:
        config['platforms'] = args.platforms
    if args.export:
        config['export_file'] = args.export
    
    # 创建工作流实例
    workflow = CreativeWorkflow(config)
    
    if args.action == 'run':
        # 运行完整工作流
        workflow.run()
    elif args.action == 'search':
        # 搜索素材
        workflow.initialize()
        keyword = args.search_keyword or config.get('keyword', '')
        creatives = workflow.search_creatives(keyword, limit=10)
        print(json.dumps(creatives, ensure_ascii=False, indent=2, default=str))
    elif args.action == 'tag':
        # 根据标签获取素材
        workflow.initialize()
        tag_name = args.tag_name or ''
        if not tag_name:
            print("请提供标签名称")
            return
        creatives = workflow.get_creatives_by_tag(tag_name, limit=10)
        print(json.dumps(creatives, ensure_ascii=False, indent=2, default=str))
    
    logger.info("程序执行完成")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
游戏素材打标系统测试脚本
验证系统各个组件的功能
"""

import os
import sys
import json
import logging

# 添加当前目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('TestSystem')

def test_label_system():
    """测试标签系统"""
    logger.info("=== 测试标签系统 ===")
    
    from creative_tagging import LabelSystem
    
    try:
        label_system = LabelSystem('d:\\workflow\\data_sql\\label_dict.md')
        
        # 获取一级标签
        level1_labels = label_system.get_level1_labels()
        logger.info(f"一级标签数量: {len(level1_labels)}")
        logger.info(f"一级标签: {', '.join(level1_labels)}")
        
        # 获取二级标签示例
        if level1_labels:
            level2_labels = label_system.get_level2_labels(level1_labels[0])
            logger.info(f"\n{level1_labels[0]}下的二级标签: {len(level2_labels)}")
            logger.info(f"二级标签: {', '.join(level2_labels)}")
        
        # 获取三级标签示例
        if level1_labels and level2_labels:
            level3_labels = label_system.get_level3_labels(level1_labels[0], level2_labels[0])
            logger.info(f"\n{level2_labels[0]}下的三级标签: {len(level3_labels)}")
            logger.info(f"三级标签示例: {', '.join(level3_labels[:5])}")
        
        logger.info("标签系统测试通过")
        return True
        
    except Exception as e:
        logger.error(f"标签系统测试失败: {e}")
        return False

def test_tagging_system():
    """测试标签提取系统"""
    logger.info("\n=== 测试标签提取系统 ===")
    
    from creative_tagging import CreativeTagger
    
    try:
        tagger = CreativeTagger('d:\\workflow\\data_sql\\label_dict.md')
        
        # 测试素材
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
            'countries': ['CN', 'US', 'JP']
        }
        
        # 打标签
        tagged_creative = tagger.tag_creative(test_creative)
        
        # 输出结果
        logger.info("素材标签结果:")
        print(tagger.format_tags_for_prompt(tagged_creative))
        
        # 验证标签
        tags = tagged_creative.get('tags', {})
        if tags:
            logger.info("标签提取成功")
            return True
        else:
            logger.error("未提取到标签")
            return False
            
    except Exception as e:
        logger.error(f"标签提取系统测试失败: {e}")
        return False

def test_database():
    """测试数据库系统"""
    logger.info("\n=== 测试数据库系统 ===")
    
    from creative_database import CreativeDatabase
    
    try:
        db = CreativeDatabase('test_database.db')
        
        # 测试素材
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
                    '核心玩法': ['战斗系统'],
                    '游戏特色': ['开放世界'],
                    '角色/IP': ['主角展示']
                }
            }
        }
        
        # 保存素材
        creative_id = db.save_tagged_creative(test_creative)
        logger.info(f"保存素材成功，ID: {creative_id}")
        
        # 查询素材
        retrieved_creative = db.get_creative_by_id(creative_id)
        if retrieved_creative:
            logger.info("查询素材成功")
            logger.info(f"素材名称: {retrieved_creative.get('title')}")
        
        # 查询标签
        tags = db.get_tags_by_creative(creative_id)
        if tags:
            logger.info("查询标签成功")
            logger.info(f"标签数量: {len(tags)}")
        
        db.close()
        
        # 清理测试数据库
        if os.path.exists('test_database.db'):
            os.remove('test_database.db')
            logger.info("测试数据库已清理")
        
        logger.info("数据库系统测试通过")
        return True
        
    except Exception as e:
        logger.error(f"数据库系统测试失败: {e}")
        return False

def test_crawler():
    """测试爬虫系统"""
    logger.info("\n=== 测试爬虫系统 ===")
    
    from creative_crawler import CreativeCrawlerManager
    
    try:
        manager = CreativeCrawlerManager()
        
        # 测试爬取单个平台
        keyword = "原神"
        limit = 2
        
        # 获取爬虫
        tiktok_crawler = manager.get_crawler('tiktok')
        if tiktok_crawler:
            logger.info(f"测试TikTok爬虫，关键词: {keyword}, 数量: {limit}")
            creatives = tiktok_crawler.crawl_creatives(keyword, limit)
            logger.info(f"成功获取 {len(creatives)} 个素材")
            
            for creative in creatives:
                logger.info(f"- {creative.get('title')}")
            
            logger.info("爬虫系统测试通过")
            return True
        else:
            logger.error("未找到TikTok爬虫")
            return False
            
    except Exception as e:
        logger.error(f"爬虫系统测试失败: {e}")
        return False

def test_workflow():
    """测试完整工作流"""
    logger.info("\n=== 测试完整工作流 ===")
    
    from creative_workflow import CreativeWorkflow
    
    try:
        # 配置
        config = {
            'keyword': '原神',
            'limit': 1,
            'platforms': ['tiktok'],
            'label_file': 'd:\\workflow\\data_sql\\label_dict.md',
            'database_file': 'test_workflow.db',
            'export_file': 'test_workflow.json'
        }
        
        # 创建工作流
        workflow = CreativeWorkflow(config)
        
        # 初始化组件
        workflow.initialize()
        
        # 爬取素材
        creatives = workflow.crawl_creatives()
        if not creatives:
            logger.warning("未获取到素材")
        else:
            logger.info(f"爬取到 {len(creatives)} 个素材")
        
        # 打标签
        tagged_creatives = workflow.tag_creatives(creatives)
        logger.info(f"为 {len(tagged_creatives)} 个素材打标签")
        
        # 保存到数据库
        saved_ids = workflow.save_creatives(tagged_creatives)
        logger.info(f"保存 {len(saved_ids)} 个素材到数据库")
        
        # 导出结果
        if workflow.export_results(config['export_file']):
            logger.info("结果导出成功")
        
        workflow.database.close()
        
        # 清理测试文件
        if os.path.exists('test_workflow.db'):
            os.remove('test_workflow.db')
        if os.path.exists('test_workflow.json'):
            os.remove('test_workflow.json')
        
        logger.info("完整工作流测试通过")
        return True
        
    except Exception as e:
        logger.error(f"完整工作流测试失败: {e}")
        return False

def main():
    """主测试函数"""
    logger.info("游戏素材打标系统测试启动")
    
    tests = [
        ("标签系统", test_label_system),
        ("标签提取系统", test_tagging_system),
        ("数据库系统", test_database),
        ("爬虫系统", test_crawler),
        ("完整工作流", test_workflow)
    ]
    
    passed = 0
    failed = 0
    
    for test_name, test_func in tests:
        if test_func():
            passed += 1
        else:
            failed += 1
    
    logger.info(f"\n=== 测试结果 ===")
    logger.info(f"通过测试: {passed}")
    logger.info(f"失败测试: {failed}")
    
    if failed == 0:
        logger.info("所有测试通过！")
        return 0
    else:
        logger.error(f"测试失败，共 {failed} 个测试未通过")
        return 1

if __name__ == "__main__":
    sys.exit(main())

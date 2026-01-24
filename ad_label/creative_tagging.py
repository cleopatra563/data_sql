#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
游戏素材AI标签提取模块
基于label_dict.md标签体系实现自动打标
"""

import re
import json
import logging
import os
from typing import Dict, List, Optional, Any
import markdown
from bs4 import BeautifulSoup

# 配置日志
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('CreativeTagging')

class LabelSystem:
    """标签体系管理类"""
    
    def __init__(self, label_file: str):
        self.label_file = label_file
        self.label_tree = self._load_label_system()
    
    def _load_label_system(self) -> Dict:
        """从markdown文件加载标签体系"""
        label_tree = {}
        current_level1 = None
        current_level2 = None
        in_table = False
        
        try:
            with open(self.label_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # 直接从markdown文本解析
            for line in lines:
                line = line.strip()
                
                try:
                    # 查找一级标签
                    if '一级标签：' in line:
                        # 提取标签名称，如"阶段和目标"
                        level1_name = line.split('一级标签：')[-1].strip()
                        level1_name = re.sub(r'^[\d.]+\s*', '', level1_name)  # 移除数字前缀
                        level1_name = re.sub(r'[】\s]+$', '', level1_name)  # 移除末尾的额外字符
                        
                        # 只有当一级标签不存在时才创建新的，避免覆盖已有标签树
                        if level1_name not in label_tree:
                            label_tree[level1_name] = {}
                            logger.debug(f"找到一级标签: {level1_name}")
                        else:
                            logger.debug(f"跳过重复的一级标签: {level1_name}")
                        
                        current_level1 = level1_name
                        in_table = False
                    
                            # 检查是否是表格分隔线
                    if line.startswith('|') and ('---' in line or '-' in line):
                        in_table = True
                        logger.debug(f"在一级标签 '{current_level1}' 下找到表格分隔线")
                        continue
                    
                    # 处理表格内容行
                    if in_table and line.startswith('|'):
                        # 解析表格行
                        cells = [cell.strip() for cell in line.split('|')[1:-1]]
                        if len(cells) >= 2 and current_level1:
                            level2_cell = cells[0]
                            level3_cell = cells[1]
                            
                            # 如果第一列有值，说明是新的二级标签
                            if level2_cell and level2_cell not in ['-', '']:
                                current_level2 = level2_cell
                                label_tree[current_level1][current_level2] = []
                                logger.debug(f"从表格提取二级标签: {current_level2}")
                            
                            # 如果第二列有值，并且已经有了二级标签，就添加三级标签
                            if level3_cell and level3_cell not in ['-', ''] and current_level2:
                                label_tree[current_level1][current_level2].append(level3_cell)
                                logger.debug(f"从表格提取三级标签: {level3_cell}")
                    
                    # 如果遇到非表格行，结束表格解析
                    elif in_table and line and not line.startswith('|'):
                        in_table = False
                except Exception as e:
                    logger.warning(f"处理行时出错: {line}, 错误: {e}")
                    continue
            
            logger.info(f"成功加载标签体系，包含 {len(label_tree)} 个一级标签")
            return label_tree
            
        except Exception as e:
            logger.error(f"加载标签体系失败: {e}")
            import traceback
            logger.error(f"错误详情: {traceback.format_exc()}")
            return {}
    
    def get_all_labels(self) -> List[str]:
        """获取所有标签的列表"""
        all_labels = []
        for level1, level2_dict in self.label_tree.items():
            for level2, level3_list in level2_dict.items():
                all_labels.extend(level3_list)
        return all_labels
    
    def get_level1_labels(self) -> List[str]:
        """获取一级标签列表"""
        return list(self.label_tree.keys())
    
    def get_level2_labels(self, level1: str) -> List[str]:
        """获取指定一级标签下的二级标签列表"""
        return list(self.label_tree.get(level1, {}).keys())
    
    def get_level3_labels(self, level1: str, level2: str) -> List[str]:
        """获取指定一级和二级标签下的三级标签列表"""
        return self.label_tree.get(level1, {}).get(level2, [])

class AIAnalyzer:
    """AI素材分析器"""
    
    def __init__(self, label_system: LabelSystem):
        self.label_system = label_system
    
    def analyze_text(self, text_content: str) -> Dict:
        """分析文本内容，提取标签"""
        # 模拟NLP分析结果
        # 实际应用中可以替换为真实的NLP模型
        
        # 简单的关键词匹配示例
        all_labels = self.label_system.get_all_labels()
        matched_labels = []
        
        text = text_content.lower()
        for label in all_labels:
            if label.lower() in text:
                matched_labels.append(label)
        
        return {'matched_labels': matched_labels}
    
    def analyze_image(self, image_path: str) -> Dict:
        """分析图片内容，提取标签"""
        # 模拟计算机视觉分析结果
        # 实际应用中可以替换为真实的CV模型
        
        # 基于文件名的简单分析示例
        filename = os.path.basename(image_path).lower()
        
        analysis_result = {
            'scene': '游戏场景',
            'characters': ['游戏角色'],
            'visual_effects': ['特效'],
            'ui_elements': ['UI']
        }
        
        # 基于文件名的简单标签匹配
        if '战斗' in filename:
            analysis_result['scene'] = '战斗场景'
        elif '角色' in filename:
            analysis_result['characters'] = ['主角']
        elif '技能' in filename:
            analysis_result['visual_effects'] = ['技能特效']
        
        return analysis_result
    
    def analyze_video(self, video_path: str) -> Dict:
        """分析视频内容，提取标签"""
        # 模拟视频分析结果
        # 实际应用中可以替换为真实的视频分析模型
        
        analysis_result = {
            'duration': 15,  # 视频时长（秒）
            'scene_changes': 5,  # 场景切换次数
            'characters': ['主角', '敌人'],
            'visual_effects': ['技能特效', '战斗特效'],
            'audio_type': '背景音乐+音效',
            'cta_position': '结尾'
        }
        
        return analysis_result

class CreativeTagger:
    """素材标签提取器"""
    
    def __init__(self, label_file: str):
        self.label_system = LabelSystem(label_file)
        self.analyzer = AIAnalyzer(self.label_system)
    
    def tag_creative(self, creative: Dict) -> Dict:
        """为素材打标签"""
        logger.info(f"为素材打标签: {creative.get('title', '未知素材')}")
        
        # 初始化标签结果
        tags_result = {}
        
        # 获取所有标签层级
        level1_labels = self.label_system.get_level1_labels()
        
        # 调试：打印所有一级标签
        logger.debug(f"所有一级标签: {level1_labels}")
        
        # 初始化标签结构
        for level1 in level1_labels:
            tags_result[level1] = {}
            level2_labels = self.label_system.get_level2_labels(level1)
            
            # 调试：打印当前一级标签下的二级标签
            logger.debug(f"{level1} 下的二级标签: {level2_labels}")
            
            for level2 in level2_labels:
                tags_result[level1][level2] = []
        
        # 分析文本内容
        text_content = f"{creative.get('title', '')} {creative.get('description', '')} {creative.get('call_to_action', '')}"
        text_analysis = self.analyzer.analyze_text(text_content)
        keywords = text_content.lower()
        
        # 分析素材文件
        local_path = creative.get('local_path')
        if local_path and os.path.exists(local_path):
            if local_path.lower().endswith(('.jpg', '.jpeg', '.png', '.gif')):
                image_analysis = self.analyzer.analyze_image(local_path)
                logger.debug(f"图片分析结果: {image_analysis}")
            elif local_path.lower().endswith(('.mp4', '.avi', '.mov', '.flv')):
                video_analysis = self.analyzer.analyze_video(local_path)
                logger.debug(f"视频分析结果: {video_analysis}")
        
        # 使用更灵活的标签匹配方式
        # 阶段和目标
        if '阶段和目标' in tags_result:
            # 检查是否有素材阶段标签
            level2_labels = tags_result['阶段和目标'].keys()
            
            # 素材阶段
            if '素材阶段' in level2_labels:
                if '测试' in keywords:
                    tags_result['阶段和目标']['素材阶段'].append('测试期')
                elif '预注册' in keywords or '预约' in keywords:
                    tags_result['阶段和目标']['素材阶段'].append('预注册期')
                elif '首发' in keywords:
                    tags_result['阶段和目标']['素材阶段'].append('首发期')
                else:
                    tags_result['阶段和目标']['素材阶段'].append('长线运营期')
            
            # 营销目标
            if '营销目标' in level2_labels:
                if '下载' in keywords or '安装' in keywords:
                    tags_result['阶段和目标']['营销目标'].append('拉新')
                elif '活动' in keywords:
                    tags_result['阶段和目标']['营销目标'].append('促活')
            
            # 目标用户
            if '目标用户' in level2_labels:
                if '免费' in keywords:
                    tags_result['阶段和目标']['目标用户'].append('泛用户')
                else:
                    tags_result['阶段和目标']['目标用户'].append('精准用户')
        
        # 内容主题
        if '内容主题' in tags_result:
            level2_labels = tags_result['内容主题'].keys()
            
            # 核心玩法
            if '核心玩法' in level2_labels:
                if '战斗' in keywords:
                    tags_result['内容主题']['核心玩法'].append('战斗系统')
                if '收集' in keywords or '养成' in keywords:
                    tags_result['内容主题']['核心玩法'].append('收集养成')
            
            # 游戏特色
            if '游戏特色' in level2_labels:
                if '开放世界' in keywords:
                    tags_result['内容主题']['游戏特色'].append('开放世界')
                if '多人' in keywords:
                    tags_result['内容主题']['游戏特色'].append('多人联机')
        
        # 表现形式
        if '表现形式' in tags_result:
            level2_labels = tags_result['表现形式'].keys()
            
            # 节奏控制
            if '节奏控制' in level2_labels:
                if '快节奏' in keywords:
                    tags_result['表现形式']['节奏控制'].append('快节奏剪辑')
                else:
                    tags_result['表现形式']['节奏控制'].append('慢节奏叙事')
            
            # 视觉风格
            if '视觉风格' in level2_labels:
                if '写实' in keywords:
                    tags_result['表现形式']['视觉风格'].append('写实风格')
                elif '卡通' in keywords:
                    tags_result['表现形式']['视觉风格'].append('卡通风格')
        
        # 转化策略
        if '转化策略' in tags_result:
            level2_labels = tags_result['转化策略'].keys()
            
            # CTA位置
            if 'CTA位置' in level2_labels:
                if '立即下载' in keywords or '立即安装' in keywords:
                    tags_result['转化策略']['CTA位置'].append('结尾CTA')
            
            # 风险降低
            if '风险降低' in level2_labels:
                if '免费' in keywords:
                    tags_result['转化策略']['风险降低'].append('免费下载')
            
            # 紧迫感
            if '紧迫感' in level2_labels:
                if '限时' in keywords:
                    tags_result['转化策略']['紧迫感'].append('限时折扣')
        
        # 技术特征
        if '技术特征' in tags_result:
            level2_labels = tags_result['技术特征'].keys()
            
            # 素材类型
            if '素材类型' in level2_labels:
                creative_type = creative.get('creative_type', '')
                if creative_type == 'video':
                    tags_result['技术特征']['素材类型'].append('视频')
                elif creative_type == 'image':
                    tags_result['技术特征']['素材类型'].append('图片')
        
        # 移除空标签并添加默认值
        for level1, level2_dict in tags_result.items():
            for level2, level3_list in level2_dict.items():
                if not level3_list:
                    level2_dict[level2] = ['无']
        
        creative['tags'] = tags_result
        logger.info("素材打标完成")
        return creative
    
    def batch_tag_creatives(self, creatives: List[Dict]) -> List[Dict]:
        """批量为素材打标签"""
        tagged_creatives = []
        for creative in creatives:
            try:
                tagged_creative = self.tag_creative(creative)
                tagged_creatives.append(tagged_creative)
            except Exception as e:
                logger.error(f"为素材打标签失败: {e}")
        
        return tagged_creatives
    
    def format_tags_for_prompt(self, creative: Dict) -> str:
        """将标签格式化为Prompt所需的格式"""
        tags = creative.get('tags', {})
        if not tags:
            return "未获取到标签"
        
        formatted = ""
        
        for level1, level2_dict in tags.items():
            formatted += f"【{level1}】\n"
            for level2, level3_list in level2_dict.items():
                formatted += f"- {level2}: {', '.join(level3_list)}\n"
            formatted += "\n"
        
        return formatted

def main():
    """主函数"""
    logger.info("游戏素材AI标签提取模块启动")
    
    try:
        # 创建标签提取器
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
            'local_path': './creatives/genshin.mp4'
        }
        
        # 打标签
        tagged_creative = tagger.tag_creative(test_creative)
        
        # 输出结果
        logger.info("\n素材标签结果:")
        print(tagger.format_tags_for_prompt(tagged_creative))
        
    except Exception as e:
        logger.error(f"标签提取模块运行失败: {e}")

if __name__ == "__main__":
    main()

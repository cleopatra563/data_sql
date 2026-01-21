from creative_workflow import CreativeWorkflow

# 创建工作流实例
workflow = CreativeWorkflow()

# 配置参数
workflow.config = {
    'keywords': ['原神', '王者荣耀'],
    'platforms': ['tiktok'],
    'max_creatives': 10
}

# 运行工作流
workflow.run()
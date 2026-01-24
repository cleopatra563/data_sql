from creative_tagging import CreativeTagger

# 创建标签提取器
tagger = CreativeTagger('label_dict.md')

# 测试素材
creative = {
    'title': '原神全新版本上线',
    'description': '开放世界冒险游戏原神全新版本"枫丹"正式上线，免费下载体验',
    'creative_type': 'video'
}

# 打标签
tagged_creative = tagger.tag_creative(creative)

# 查看结果
print(tagger.format_tags_for_prompt(tagged_creative))
# Git 操作清单

日常开发工作流中必备Git命令的综合指南。


## 目录

1. [仓库创建与初始化](#1-仓库创建与初始化)
2. [初始设置与配置](#2-初始设置与配置)
3. [提交操作](#3-提交操作)
4. [推送操作](#4-推送操作)
5. [拉取操作](#5-拉取操作)
6. [获取操作](#6-获取操作)
7. [合并操作](#7-合并操作)
8. [其他实用命令](#8-其他实用命令)

## 1. 仓库创建与初始化

### 1.1 初始化新的本地仓库

**语法：**
```bash 
git init
```

**说明：** 在当前目录初始化一个新的Git仓库，创建`.git`目录。这是任何新Git项目的起点。

**使用场景：** 从头开始一个新项目

### 1.2 克隆现有远程仓库

**语法：**
```bash
git clone <远程仓库URL> [本地目录名称]
```

**选项：**
- `<远程仓库URL>`: 远程仓库的URL（HTTPS或SSH）
- `[本地目录名称]`: 本地目录的可选名称（默认为仓库名称）

**示例：**
```bash
git clone https://github.com/username/repository.git my-project
```

**说明：** 将远程仓库的完整副本（包括所有历史记录和分支）下载到本地机器。

**使用场景：** 首次参与现有项目的开发

## 2. 初始设置与配置

### 2.1 配置用户身份

**语法：**
```bash
# 全局配置（适用于所有仓库）
git config --global user.name "你的姓名"
git config --global user.email "your.email@example.com"

# 本地配置（仅适用于当前仓库）
git config user.name "你的姓名"
git config user.email "your.email@example.com"
```

**说明：** 设置将与你的Git提交关联的用户名和电子邮件地址。

**使用场景：** 首次设置Git或为不同项目使用不同身份

### 2.2 验证配置

**语法：**
```bash
# 查看所有配置设置
git config --list

# 查看特定配置设置
git config user.name
```

**说明：** 显示当前的Git配置设置。

**使用场景：** 确认身份设置是否正确

### 2.3 添加远程仓库

**语法：**
```bash
git remote add <远程名称> <远程URL>
```

**示例：**
```bash
git remote add origin https://github.com/username/repository.git
```

**说明：** 将本地仓库连接到具有指定名称（通常为`origin`）的远程仓库。

**使用场景：** 将本地仓库链接到新创建的远程仓库

### 2.4 列出远程仓库

**语法：**
```bash
git remote -v
```

**说明：** 显示所有配置的远程仓库及其URL。

**使用场景：** 验证远程仓库连接

## 3. 提交操作

### 3.1 检查工作目录状态

**语法：**
```bash
git status
```

**说明：** 显示工作目录和暂存区的当前状态，显示修改的文件、暂存区状态等。

**使用场景：** 定期检查更改状态

### 3.2 暂存更改

**语法：**
```bash
# 暂存特定文件
git add <文件路径>

# 暂存所有修改的文件
git add .

# 暂存所有修改的文件（包括忽略列表中的文件）
git add --all

# 交互式暂存更改
git add -p
```

**示例：**
```bash
git add src/index.js
git add .
```

**说明：** 将文件从工作目录添加到暂存区，准备提交。

**使用场景：** 选择要包含在下次提交中的更改

### 3.3 取消暂存

**语法：**
```bash
git reset HEAD <文件路径>
```

**示例：**
```bash
git reset HEAD src/index.js
```

**说明：** 将文件从暂存区移除，但保留工作目录中的修改。

**使用场景：** 意外暂存了错误的文件

### 3.4 创建提交

**语法：**
```bash
git commit -m "提交信息"

# 使用文本编辑器编写扩展提交信息
git commit
```

**选项：**
- `-m "提交信息"`: 内联指定提交信息
- 省略`-m`以打开文本编辑器编写多行提交信息

**示例：**
```bash
git commit -m "实现用户认证功能"
```

**说明：** 将暂存区的更改提交到本地仓库。

**使用场景：** 保存工作并提供有意义的更改描述

### 3.5 查看提交历史

**语法：**
```bash
# 查看完整提交历史
git log

# 查看简洁的提交历史
git log --oneline

# 查看带更改内容的提交历史
git log -p

# 查看特定文件的提交历史
git log -- <文件路径>
```

**示例：**
```bash
git log --oneline
git log -p src/index.js
```

**说明：** 以各种格式显示本地仓库的提交历史记录。

**使用场景：** 查看过去的更改或查找特定提交

## 4. 推送操作

### 4.1 将本地提交推送到远程

**语法：**
```bash
git push <远程名称> <分支名称>

# 推送并设置上游分支（首次推送）
git push -u <远程名称> <分支名称>
```

**示例：**
```bash
git push origin master
git push -u origin feature/authentication
```

**说明：** 将本地提交发送到指定的远程仓库和分支。

**使用场景：** 与团队共享更改或备份到远程

### 4.2 推送所有分支

**语法：**
```bash
git push --all <远程名称>
```

**示例：**
```bash
git push --all origin
```

**说明：** 将所有本地分支推送到指定的远程仓库。

**使用场景：** 与协作者共享多个分支

### 4.3 处理推送拒绝（非快进）

**问题：** 当本地分支落后于远程分支时

**解决方案：**
```bash
# 首先获取并合并远程更改
git pull <远程名称> <分支名称>
# 然后推送你的更改
git push <远程名称> <分支名称>
```

**说明：** 在推送自己的更改之前，先更新本地分支以包含远程更改。

**使用场景：** 当其他人已将更改推送到同一分支时解决推送冲突

## 5. 拉取操作

### 5.1 拉取远程更改

**语法：**
```bash
git pull <远程名称> <分支名称>

# 从跟踪的上游分支拉取
git pull
```

**示例：**
```bash
git pull origin master
git pull
```

**说明：** 从远程仓库获取更改并将它们合并到当前分支。

**使用场景：** 使用最新的远程更改更新本地分支

### 5.2 使用变基拉取

**语法：**
```bash
git pull --rebase <远程名称> <分支名称>
```

**示例：**
```bash
git pull --rebase origin master
```

**说明：** 获取远程更改并将本地提交重新应用在它们之上，创建线性提交历史。

**使用场景：** 维护干净、线性的提交历史

### 5.3 解决拉取冲突

**步骤：**
1. 识别冲突文件：
   ```bash
   git status
   ```

2. 检查文件中的冲突（Git用特殊符号标记冲突）：
   ```
   <<<<<<< HEAD
   本地更改
   =======
   远程更改
   >>>>>>> origin/master
   ```

3. 编辑文件解决冲突，删除冲突标记

4. 暂存已解决的文件：
   ```bash
   git add <冲突文件>
   ```

5. 完成拉取：
   ```bash
   git commit
   ```

**使用场景：** 当本地更改与远程更改冲突时

### 5.4 中止失败的拉取

**语法：**
```bash
git merge --abort
```

**说明：** 取消失败的拉取/合并操作，并将分支恢复到拉取前的状态。

**使用场景：** 当无法解决冲突并需要重新开始时

## 6. 获取操作

### 6.1 获取远程更改

**语法：**
```bash
git fetch <远程名称>

# 从所有远程获取
git fetch --all
```

**示例：**
```bash
git fetch origin
git fetch --all
```

**说明：** 从远程仓库下载更改，但不将它们合并到当前分支。

**使用场景：** 在不影响本地工作的情况下检查远程更改

### 6.2 列出远程分支

**语法：**
```bash
git branch -r

# 列出所有分支（本地和远程）
git branch -a
```

**说明：** 显示所有远程分支（或包括本地分支的所有分支）。

**使用场景：** 发现协作者创建的新分支

### 6.3 检出远程分支

**语法：**
```bash
git checkout -b <本地分支名称> <远程名称>/<远程分支名称>
```

**示例：**
```bash
git checkout -b feature/ui origin/feature/ui
```

**说明：** 创建跟踪远程分支的本地分支。

**使用场景：** 处理协作者创建的分支

### 6.4 比较本地和远程分支

**语法：**
```bash
git diff <本地分支> <远程名称>/<远程分支>
```

**示例：**
```bash
git diff master origin/master
```

**说明：** 显示本地分支与相应远程分支之间的差异。

**使用场景：** 在拉取之前了解缺少的更改

## 7. 合并操作

### 7.1 检出目标分支

**语法：**
```bash
git checkout <目标分支>
```

**示例：**
```bash
git checkout master
```

**说明：** 切换到要合并到的分支。

**使用场景：** 准备将功能分支合并到主分支

### 7.2 合并源分支

**语法：**
```bash
git merge <源分支>
```

**示例：**
```bash
git merge feature/authentication
```

**说明：** 将源分支合并到当前分支。

**使用场景：** 将完成的功能集成到主分支

### 7.3 使用提交信息合并

**语法：**
```bash
git merge --no-ff -m "合并分支 '<分支名称>'" <分支名称>
```

**示例：**
```bash
git merge --no-ff -m "合并分支 'feature/authentication'" feature/authentication
```

**说明：** 即使可能进行快进合并，也会创建合并提交，保留分支历史。

**使用场景：** 在提交历史中保持清晰的分支关系

### 7.4 解决合并冲突

**步骤：**
1. 识别冲突文件：
   ```bash
   git status
   ```

2. 编辑文件解决冲突（删除Git冲突标记）

3. 暂存已解决的文件：
   ```bash
   git add <冲突文件>
   ```

4. 完成合并：
   ```bash
   git commit -m "解决合并冲突"
   ```

**使用场景：** 合并具有冲突更改的分支时

### 7.5 中止合并

**语法：**
```bash
git merge --abort
```

**说明：** 取消当前合并操作，并将分支恢复到合并前的状态。

**使用场景：** 无法解决冲突并需要重新开始时

### 7.6 查看合并历史

**语法：**
```bash
git log --graph --oneline --decorate
```

**说明：** 以图形方式显示提交历史中的分支合并。

**使用场景：** 了解项目的分支和合并历史

## 8. 其他实用命令

### 8.1 创建新分支

**语法：**
```bash
git checkout -b <新分支名称>
```

**示例：**
```bash
git checkout -b feature/payment-system
```

**说明：** 创建一个新分支并切换到该分支。

**使用场景：** 开始开发新功能或修复bug

### 8.2 在分支之间切换

**语法：**
```bash
git checkout <分支名称>
```

**示例：**
```bash
git checkout master
git checkout feature/authentication
```

**说明：** 切换到指定的分支。

**使用场景：** 在多个分支上工作

### 8.3 删除本地分支

**语法：**
```bash
git branch -d <分支名称>

# 强制删除（即使未合并）
git branch -D <分支名称>
```

**示例：**
```bash
git branch -d feature/old-feature
git branch -D feature/broken-feature
```

**说明：** 删除本地分支（默认安全删除，使用`-D`强制删除）。

**使用场景：** 清理已完成或废弃的分支

### 8.4 删除远程分支

**语法：**
```bash
git push <远程名称> --delete <分支名称>
```

**示例：**
```bash
git push origin --delete feature/obsolete-feature
```

**说明：** 从远程仓库删除分支。

**使用场景：** 移除远程上不再需要的分支

### 8.5 显示文件差异

**语法：**
```bash
# 显示工作目录中的差异
git diff

# 显示工作目录与暂存区之间的差异
git diff --staged

# 显示两个提交之间的差异
git diff <提交哈希1> <提交哈希2>
```

**示例：**
```bash
git diff
git diff --staged
git diff a1b2c3d e4f5g6h
```

**说明：** 显示不同阶段文件之间的差异。

**使用场景：** 在暂存或提交前查看更改

### 8.6 撤销最后一次提交（保留更改）

**语法：**
```bash
git reset HEAD~1
```

**说明：** 撤销最后一次提交，但将更改保留在暂存区。

**使用场景：** 更正提交消息或向后一次提交添加更多更改

### 8.7 撤销最后一次提交（丢弃更改）

**语法：**
```bash
git reset --hard HEAD~1
```

**说明：** 撤销最后一次提交并丢弃所有更改。

**使用场景：** 恢复引入错误的提交

## 工作流示例

以下是一个典型的Git工作流，结合了许多这些命令：

1. **开始一个新功能：**
   ```bash
   git checkout master
   git pull
   git checkout -b feature/new-feature
   ```

2. **进行更改并提交：**
   ```bash
   # 编辑文件
   git status
   git add .
   git commit -m "实现新功能"
   ```

3. **获取并合并最新更改：**
   ```bash
   git fetch origin
   git checkout master
   git merge origin/master
   git checkout feature/new-feature
   git merge master
   ```

4. **推送到远程：**
   ```bash
   git push -u origin feature/new-feature
   ```

5. **合并到master：**
   ```bash
   git checkout master
   git merge feature/new-feature
   git push
   git branch -d feature/new-feature
   ```

这个清单按照典型开发工作流的逻辑顺序组织，便于在日常开发任务中参考和使用。
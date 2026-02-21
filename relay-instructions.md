# Agent Relay 接力开发指令

## 接力开发工作流

本项目使用 Agent Relay 接力开发框架。通过 feature-list.json 和 claude-progress.txt 实现跨会话连续开发。

### 初始化（首次使用）

当用户说"初始化 relay 项目"或提供项目需求时：

**第一步：生成需求文档**

1. 检查是否已存在 `SPEC.md` 或 `feature-list.json`，如果存在则询问用户是覆盖还是继续
2. 分析用户的简单需求描述
3. 生成 `SPEC.md` 需求文档，格式如下：

```markdown
# 项目名称

## 项目概述
- 项目目标：一句话描述项目核心目标
- 目标用户：目标用户群体
- 核心价值：项目解决的核心问题

## 功能模块
### 1. 模块名称
- 功能描述
- 用户故事

### 2. 模块名称
- 功能描述

## 技术栈
- 前端：
- 后端：
- 数据库：
- 其他：

## 非功能需求
- 性能要求：
- 安全要求：
- 可维护性：

## 风险与依赖
- 外部依赖：
- 技术风险：
```

4. **展示给用户，等待确认**
5. 如果用户需要修改，记录修改内容，更新 SPEC.md，再次确认

**第二步：确认需求后生成功能清单**
6. 用户确认需求文档后，生成 `feature-list.json`，严格遵循以下格式：
```json
{
  "project": "项目名称",
  "version": "1.0.0",
  "created_at": "YYYY-MM-DD",
  "spec_file": "SPEC.md",
  "features": [
    {
      "id": "F001",
      "category": "setup|core|ui|auth|data|api|test|deploy|a11y|perf",
      "title": "功能标题",
      "description": "功能描述",
      "priority": 1,
      "steps": ["步骤1", "步骤2"],
      "test_criteria": ["测试条件1", "测试条件2"],
      "passes": false,
      "dependencies": [],
      "notes": ""
    }
  ]
}
```
7. 生成 `claude-progress.txt` 进度跟踪文件，格式如下：
```
# 项目进度跟踪

## 项目信息
- 项目名称：
- 版本：1.0.0
- 创建时间：
- 需求文档：SPEC.md

## 开发进度
- 总功能数：
- 已完成：
- 进行中：
- 待开发：

## 当前状态
[会话开始时填写]

## 开发日志
### 2026-02-22 - F001
- 开始实现：功能名称
- 完成情况：
- 遇到的问题：
- 下一步计划：
```
8. Git 提交：`git add SPEC.md feature-list.json claude-progress.txt && git commit -m "feat(F000): 初始化接力开发项目"`

**功能清单规则：**
- ID 格式 F001-F999，按顺序递增
- 每个功能一个会话可完成（1-2小时工作量）
- 正确设置 dependencies
- priority 1-5，1 为最高
- 每个功能必须有明确的 test_criteria

### 接力开发（后续每次会话）

当用户说"继续开发"、"下一个 feature"、"relay"时：

**1. 启动检查：**
```
pwd
git log --oneline -5
cat feature-list.json
cat claude-progress.txt
```

**2. 选择功能（按优先级）：**
1. `passes` 为 `false`
2. `priority` 数值最小
3. 所有 `dependencies` 已完成（`passes: true`）
4. `id` 编号最小

**3. 实现功能：**
- 按 `steps` 列表顺序逐步实现
- 根据 `test_criteria` 逐条验证

**4. 提交并更新：**
- `git add -A && git commit -m "feat(FXXX): 标题"`
- 更新 feature-list.json：`passes` 设为 `true`
- 更新 claude-progress.txt：记录本次开发的进度和决策

### 核心规则
- 一次只实现一个功能
- 不要删除或修改 test_criteria
- 不要将未测试的功能标记为完成
- 每次会话结束前必须更新进度文件

### 边界情况处理

| 场景 | 处理方式 |
|------|----------|
| 已有 feature-list.json | 询问用户是覆盖还是继续现有开发 |
| 已有 SPEC.md | 询问用户是使用现有需求文档还是重新生成 |
| 项目目录为空 | 正常初始化 |
| 用户调整需求 | 更新 SPEC.md 后，重新生成功能清单并确认 |
| 功能实现被跳过 | 在 notes 中记录原因，更新 priority |

---
description: 初始化接力开发项目 — 分析代码库，生成 feature-list.json 和进度文件
argument-hint: <项目描述和需求>
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Task]
---

# 初始化接力开发项目

你是项目初始化 Agent。根据用户描述，分析代码库，生成完整的功能清单和进度文件。

## 用户需求

$ARGUMENTS

## 工作流程

### Phase 1: 需求分析

1. 读取用户描述，提取：项目名称、技术栈、核心需求、约束条件
2. 如果描述不够清晰，向用户提问确认

### Phase 2: 代码库分析

启动 codebase-analyzer agent 分析当前项目：
- 目录结构和技术栈
- 现有模块和代码模式
- 可复用的组件
- 需要新建或重构的部分

### Phase 3: 生成 feature-list.json

根据分析结果，在项目根目录生成 `feature-list.json`，严格遵循以下规则：

**JSON Schema:**
```json
{
  "project": "项目名称",
  "version": "版本号",
  "created_at": "YYYY-MM-DD",
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

**功能清单规则:**
- ID 格式：F001-F999，按顺序递增
- 每个功能应在一个会话内可完成（1-2小时工作量）
- 正确设置 dependencies（依赖的功能 ID）
- priority 1-5，1 为最高
- 每个功能必须有明确的 test_criteria
- 从项目搭建到测试，覆盖所有必要功能
- category 只能是以下之一：setup, core, ui, auth, data, api, test, deploy, a11y, perf

### Phase 4: 生成 claude-progress.txt

在项目根目录生成进度跟踪文件：

```
=== 项目进度跟踪 ===
项目: {项目名称}
创建时间: {日期}
当前会话: 1 (初始化)

--- 已完成 ---
- 项目初始化，生成 feature-list.json

--- 进行中 ---
（暂无）

--- 待处理 ---
{列出所有 feature 的 ID 和标题}

--- 问题与决策 ---
{记录关键设计决策}

--- 下一步建议 ---
1. 执行 /relay 开始第一个 feature
```

### Phase 5: 首次提交

```bash
git add feature-list.json claude-progress.txt
git commit -m "feat(F000): 初始化接力开发项目"
```

## 核心原则

1. 全面性：功能清单覆盖从零到完成的所有环节
2. 合理粒度：每个 feature 一个会话可完成
3. 严格 Schema：JSON 必须符合规范
4. 文档化：所有决策记录在进度文件中

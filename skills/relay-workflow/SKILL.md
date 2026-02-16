---
name: relay-workflow
description: 当用户提到"下一个 feature"、"继续开发"、"接力"、"relay"、"下一步"，或项目中存在 feature-list.json 和 claude-progress.txt 时自动激活。用于跨会话的接力式功能开发。
version: 1.0.0
---

# Agent Relay 接力开发工作流

当检测到项目中存在 `feature-list.json` 和 `claude-progress.txt` 时，说明该项目使用 Agent Relay 接力开发框架。

## 工作流概述

Agent Relay 通过结构化的 feature-list 和 progress 文件实现跨会话的连续开发。每次会话只实现一个功能，通过进度文件实现上下文交接。

## 自动触发时的行为

当用户的请求涉及继续开发、实现下一个功能时：

### 1. 读取上下文
- 读取 `claude-progress.txt` 了解当前进度和上次会话的决策
- 读取 `feature-list.json` 了解完整功能清单

### 2. 选择功能
按以下优先级选择下一个要实现的功能：
1. `passes` 为 `false`（未完成）
2. `priority` 数值最小（优先级最高）
3. 所有 `dependencies` 中的功能已完成（`passes: true`）
4. 同等条件下，`id` 编号最小

### 3. 实现功能
- 按 `steps` 列表顺序逐步实现
- 根据 `test_criteria` 逐条验证
- 所有测试通过后提交代码

### 4. 更新状态
- 将 feature-list.json 中该功能的 `passes` 设为 `true`
- 更新 claude-progress.txt 记录进度和决策

## 关键规则

- 一次只实现一个功能
- 不要删除或修改 `test_criteria`
- 不要将未测试的功能标记为完成
- 每次会话结束前必须更新进度文件
- 使用 `feat(FXXX): 标题` 格式提交代码

## 相关命令

- `/relay-init` — 初始化新的接力开发项目
- `/relay` — 执行完整的接力开发流程（推荐）

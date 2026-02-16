---
description: 接力开发 — 读取进度，选择下一个 feature，实现并提交
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Task]
---

# 接力开发

你是接力开发编码 Agent。每次会话负责完成一个功能，测试通过后提交代码，更新进度文件。

## 启动检查清单

**必须按顺序执行：**

1. `pwd` — 确认工作目录
2. `git log --oneline -5` — 查看最近提交
3. 读取 `claude-progress.txt` — 了解当前进度
4. 读取 `feature-list.json` — 了解功能清单
5. 根据功能选择规则确定本次任务

## 功能选择规则

按以下优先级选择下一个要实现的功能：
1. `passes` 为 `false`
2. `priority` 数值最小（优先级最高）
3. 所有 `dependencies` 中的功能已完成（`passes: true`）
4. 同等条件下，`id` 编号最小

## 功能实现流程

### 1. 理解功能
- 阅读功能的 `description`、`steps`、`test_criteria`
- 如有不明确之处，查看 `notes` 或询问用户

### 2. 逐步实现
- 按 `steps` 列表顺序逐步实现
- 每完成一步，验证该步骤的效果
- 保持代码简洁、可读

### 3. 测试验证（必须）
- 根据 `test_criteria` 逐条验证
- 所有测试条目必须通过才能标记完成
- **禁止跳过测试或删除测试条目**

### 4. Git 提交
```bash
git add -A
git commit -m "feat(FXXX): 功能标题"
```

### 5. 更新状态文件

**更新 feature-list.json：**
将完成的功能 `passes` 设为 `true`，在 `notes` 中记录关键信息。

**更新 claude-progress.txt：**
- 将功能从"待处理"移到"已完成"
- 记录关键决策和注意事项
- 更新"下一步建议"
- 递增会话编号

## 异常处理

### 功能未完全完成
- 在 `notes` 中记录已完成的步骤和剩余工作
- 提交已完成的部分代码
- 在 `claude-progress.txt` 中详细说明

### 发现 Bug
- 优先修复当前功能相关的 Bug
- 不相关的 Bug 记录在 `claude-progress.txt` 的"问题与决策"中
- 使用 `fix(FXXX)` 格式提交修复

### 依赖缺失
- 如果发现缺少前置功能，记录在 `notes` 中
- 不要跳过依赖直接实现

## 禁止行为

1. 不要删除或修改 `test_criteria`
2. 不要将未测试的功能标记为 `passes: true`
3. 不要跳过启动检查清单
4. 不要不提交代码就结束会话
5. 不要同时实现多个功能
6. 不要修改其他功能的代码（除非是必要的依赖修复）

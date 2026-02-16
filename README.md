# Agent Relay - AI Agent 接力开发框架

## 解决什么问题

AI Agent（如 Claude）在长对话中会丢失上下文记忆。当一个会话结束后，下一个会话的 Agent 完全不知道之前做了什么。

Agent Relay 通过**结构化的进度文件和功能清单**解决这个问题：
- 每个会话结束时，Agent 将工作进度写入文件
- 下一个会话启动时，Agent 读取这些文件恢复上下文
- 功能清单确保开发按计划推进，不遗漏、不重复

就像接力赛跑一样，每个 Agent 接过"接力棒"继续前进。

## 安装

作为 Claude CLI Plugin 安装（一次性）：

```bash
claude plugin install /path/to/agent-relay
```

## 使用方式

### 初始化项目

在任何项目目录下启动 Claude CLI，输入：

```
/relay-init 基于 Claude SDK 重构代码审查 Agent，Go + anthropic-sdk-go
```

Claude 会自动：
1. 分析当前代码库
2. 生成 `feature-list.json`（功能清单）
3. 生成 `claude-progress.txt`（进度文件）
4. 首次 Git 提交

### 接力开发

后续每次新会话，输入：

```
/relay
```

Claude 会自动：
1. 读取进度文件，恢复上下文
2. 按优先级和依赖选择下一个功能
3. 逐步实现并测试
4. 提交代码，更新进度

重复 `/relay` 直到所有功能完成。

### 自然语言触发

也可以直接说：

```
继续开发下一个 feature
```

Skill 会自动识别项目中的 relay 文件并按工作流执行。

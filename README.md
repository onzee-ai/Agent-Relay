# Agent Relay - AI Agent 接力开发框架

## 解决什么问题

AI Agent 在长对话中会丢失上下文。Agent Relay 通过结构化的 feature-list 和 progress 文件实现跨会话连续开发。

## 安装

```bash
# 对任何 git 项目执行
bash /path/to/agent-relay/install.sh /path/to/your-project
```

脚本会自动检测 git root，把 relay 工作流指令写入 CLAUDE.md。

## 使用

### 初始化（首次）

```bash
cd /path/to/your-project
claude
```

在 Claude CLI 中说：
```
初始化 relay 项目，我要做一个 xxx，技术栈是 xxx
```

Claude 会自动按 CLAUDE.md 中的指令生成 feature-list.json 和 claude-progress.txt。

### 接力开发（后续每次新会话）

```
继续开发
```

Claude 自动：读进度 → 选 feature → 实现 → 测试 → 提交 → 更新进度。

## 文件说明

| 文件 | 说明 |
|------|------|
| `install.sh` | 安装脚本，把 relay 指令写入目标项目的 CLAUDE.md |
| `relay-instructions.md` | CLAUDE.md 模板，包含完整的 relay 工作流指令 |

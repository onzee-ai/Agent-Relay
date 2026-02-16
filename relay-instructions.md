# Agent Relay 接力开发指令

## 接力开发工作流

本项目使用 Agent Relay 接力开发框架。通过 feature-list.json 和 claude-progress.txt 实现跨会话连续开发。

### 初始化（首次使用）

当用户说"初始化 relay 项目"或提供项目需求时：

1. 分析用户需求和现有代码库
2. 生成 `feature-list.json`，严格遵循以下格式：
```json
{
  "project": "项目名称",
  "version": "1.0.0",
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
3. 生成 `claude-progress.txt` 进度跟踪文件
4. Git 提交：`git add feature-list.json claude-progress.txt && git commit -m "feat(F000): 初始化接力开发项目"`

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
- 更新 claude-progress.txt：记录进度和决策

### 核心规则
- 一次只实现一个功能
- 不要删除或修改 test_criteria
- 不要将未测试的功能标记为完成
- 每次会话结束前必须更新进度文件

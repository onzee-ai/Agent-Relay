# Agent Relay 接力开发指令

## 接力开发工作流

本项目使用 Agent Relay 接力开发框架。通过模块化的 feature-list.json 和 claude-progress.txt 实现跨会话连续开发。

## 项目结构

支持两种项目模式：

### 模式 A：单项目模式
适用于中小型项目（<30 个功能）
```
project/
├── CLAUDE.md
├── SPEC.md
├── feature-list.json
└── claude-progress.txt
```

### 模式 B：多模块模式（推荐大型项目）
适用于大型项目（>30 个功能）
```
project/
├── CLAUDE.md
├── SPEC.md
├── feature-list.json          # 总览清单
└── modules/
    ├── module-name-1/
    │   ├── SPEC.md           # 模块需求文档
    │   ├── feature-list.json # 模块功能清单
    │   └── progress.txt
    └── module-name-2/
        └── ...
```

---

### 初始化（首次使用）

当用户说"初始化 relay 项目"或提供项目需求时：

**第一步：判断项目规模**

1. 询问用户项目规模：
   - "这是一个大型项目吗？需要分模块吗？"
   - 或者让用户选择：单项目 / 多模块

2. 根据选择进入不同流程

**第二步：单项目模式**

如果用户选择单项目：
1. 生成 `SPEC.md` 需求文档
2. 等待用户确认
3. 生成 `feature-list.json`
4. 询问提交语言
5. Git 提交

**第三步：多模块模式**

如果用户选择多模块：

1. **顶层初始化**：
   - 生成顶层 `SPEC.md`（项目总体需求）
   - 生成顶层 `feature-list.json`（仅包含模块列表）
   - 提交

2. **模块初始化**：
   - 对每个模块重复"单项目模式"流程
   - 每个模块独立生成 SPEC.md 和 feature-list.json
   - 模块功能完成后更新到顶层清单

---

## 功能清单格式

### 顶层 feature-list.json（多模块模式）
```json
{
  "project": "项目名称",
  "version": "1.0.0",
  "created_at": "YYYY-MM-DD",
  "mode": "multi-module",
  "spec_file": "SPEC.md",
  "commit_lang": "zh",
  "modules": [
    {
      "id": "M001",
      "name": "模块名称",
      "path": "modules/模块目录名",
      "description": "模块描述",
      "status": "pending|active|completed",
      "total_features": 0,
      "completed_features": 0
    }
  ],
  "features": []  // 保留用于顶层里程碑
}
```

### 模块内 feature-list.json
```json
{
  "project": "模块名称",
  "parent": "父项目名称",
  "parent_path": "..",
  "version": "1.0.0",
  "created_at": "YYYY-MM-DD",
  "mode": "single",
  "spec_file": "SPEC.md",
  "commit_lang": "zh",
  "features": [
    {
      "id": "M001-F001",
      "category": "setup|core|ui|auth|data|api|test|deploy|a11y|perf",
      "title": "功能标题",
      "description": "功能描述",
      "priority": 1,
      "steps": ["步骤1", "步骤2"],
      "test_criteria": ["测试条件1", "测试条件2"],
      "test_type": "manual|auto|build",
      "test_command": "测试命令（可选）",
      "passes": false,
      "dependencies": [],
      "notes": ""
    }
  ]
}
```

---

## 接力开发（后续每次会话）

当用户说"继续开发"、"下一个 feature"、"relay"时：

**1. 启动检查：**
```
pwd
git log --oneline -5
# 判断当前在顶层还是模块目录
ls -la
cat feature-list.json
```

**2. 判断当前层级：**
- 如果在顶层 → 查看模块进度
- 如果在模块目录 → 查看模块内功能进度

**3. 选择功能（按优先级）：**
1. 当前模块内 `passes` 为 `false`
2. `priority` 数值最小
3. 所有 `dependencies` 已完成

**4. 实现功能：**
- 按 `steps` 列表顺序逐步实现
- 根据 `test_criteria` 逐条验证
- 如果 `test_type` 为 `auto`，运行 `test_command` 验证

**5. 提交并更新：**
- 使用选择的语言提交
- 更新 feature-list.json：`passes` 设为 `true`
- 如果是模块内更新，同步更新顶层进度

---

## 核心规则

- 一次只实现一个功能
- 不要删除或修改 test_criteria
- 不要将未测试的功能标记为完成
- 每次会话结束前必须更新进度文件
- 多模块模式下，顶层模块状态自动同步

## 边界情况处理

| 场景 | 处理方式 |
|------|----------|
| 已有 feature-list.json | 询问用户是覆盖还是继续 |
| 已有 SPEC.md | 询问用户是使用还是重新生成 |
| 用户调整需求 | 更新 SPEC.md 后重新生成功能清单 |
| 功能实现被跳过 | 在 notes 中记录原因，更新 priority |
| 模块间有依赖 | 在顶层 feature-list.json 中记录模块依赖 |
| 大型项目构建时间长 | 使用增量构建，仅验证改动部分 |

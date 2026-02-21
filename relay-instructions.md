# Agent Relay 接力开发指令 (Cocos 游戏开发版)

## 接力开发工作流

本项目使用 Agent Relay 接力开发框架。通过模块化的 feature-list.json 和 claude-progress.txt 实现跨会话连续开发。

**本版本专为 Cocos 游戏开发优化**，支持：
- Cocos Creator 项目自检
- 已有项目新模块开发
- 游戏特有资源管理

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

## Cocos 特有配置

在生成 `feature-list.json` 时，需要添加 Cocos 相关配置：

```json
{
  "project_type": "cocos-game",
  "cocos_version": "3.x",
  "build_platforms": ["ios", "android", "web"],
  "engine_path": "engine/",
  "auto_check": true,
  "check_on_commit": true
}
```

### Cocos 自检配置

每个功能可以配置自检方式：

```json
{
  "id": "F001",
  "title": "功能名称",
  "cocos_check": {
    "enabled": true,
    "methods": ["build-test", "scene-load", "console-error"],
    "build_target": "web",
    "scene": "assets/scenes/TestScene.fire",
    "timeout": 60000
  }
}
```

**自检方法：**
| 方法 | 说明 |
|------|------|
| `build-test` | 执行 Cocos 构建，检查构建是否成功 |
| `scene-load` | 加载指定场景，检查是否报 Error |
| `console-error` | 检查控制台是否有 Error 级别日志 |
| `custom` | 运行自定义检查脚本 |

---

### 初始化（首次使用）

当用户说"初始化 relay 项目"或提供项目需求时：

**第一步：判断项目类型**

1. 询问用户：
   - "这是 Cocos 项目吗？"
   - "这是一个新项目还是已有项目？"

2. 根据回答选择流程

**第二步：新项目初始化**

如果用户选择新项目：
1. 生成 `SPEC.md` 需求文档（包含 Cocos 相关配置）
2. 等待用户确认
3. 生成 `feature-list.json`（添加 Cocos 自检配置）
4. 询问提交语言
5. Git 提交

**第三步：已有项目初始化**

如果用户选择已有项目：
1. 分析现有项目结构：
   - 检查 Cocos 版本
   - 检查现有模块
   - 检查构建配置
2. 询问用户要开发的新模块
3. 生成新模块的 `SPEC.md` 和 `feature-list.json`
4. 追加到现有项目（不覆盖原有文件）

---

## 功能清单格式

### Cocos 项目 feature-list.json
```json
{
  "project": "项目名称",
  "project_type": "cocos-game",
  "cocos_version": "3.8",
  "version": "1.0.0",
  "created_at": "YYYY-MM-DD",
  "mode": "single|multi-module",
  "spec_file": "SPEC.md",
  "commit_lang": "zh",
  "auto_check": true,
  "features": [
    {
      "id": "F001",
      "category": "setup|core|ui|scene|audio|animation|network|data|ai|test|deploy",
      "title": "功能标题",
      "description": "功能描述",
      "priority": 1,
      "steps": ["步骤1", "步骤2"],
      "test_criteria": ["测试条件1", "测试条件2"],
      "test_type": "manual|auto|cocos",
      "passes": false,
      "dependencies": [],
      "cocos_check": {
        "enabled": true,
        "methods": ["scene-load"],
        "scene": "assets/scenes/TestScene.fire",
        "timeout": 30000
      },
      "notes": ""
    }
  ]
}
```

### 模块内 feature-list.json
```json
{
  "project": "模块名称",
  "parent": "父项目名称",
  "parent_path": "..",
  "project_type": "cocos-game",
  "version": "1.0.0",
  "created_at": "YYYY-MM-DD",
  "mode": "single",
  "spec_file": "SPEC.md",
  "commit_lang": "zh",
  "features": [
    {
      "id": "M001-F001",
      "category": "setup|core|ui|scene|audio|animation|network|data|ai|test|deploy",
      "title": "功能标题",
      "description": "功能描述",
      "priority": 1,
      "steps": ["步骤1", "步骤2"],
      "test_criteria": ["测试条件1", "测试条件2"],
      "test_type": "manual|auto|cocos",
      "cocos_check": {
        "enabled": true,
        "methods": ["build-test", "scene-load"],
        "build_target": "web",
        "scene": "assets/scenes/ModuleScene.fire",
        "timeout": 60000
      },
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
ls -la
cat feature-list.json
```

**2. 检查 Cocos 环境：**
```
# 检查 Cocos 引擎是否存在
ls -la $COCOS_ENGINE_PATH 2>/dev/null || echo "未找到 Cocos 引擎"

# 检查项目配置
cat project.json | grep "engine"
```

**3. 选择功能（按优先级）：**
1. 当前模块内 `passes` 为 `false`
2. `priority` 数值最小
3. 所有 `dependencies` 已完成

**4. 实现功能：**
- 按 `steps` 列表顺序逐步实现
- 根据 `test_criteria` 逐条验证

**5. Cocos 自检（关键）：**
- 如果 `cocos_check.enabled` 为 `true`
- 根据配置的方法进行自检：

```
# 构建测试
cocos build --platform web --quiet

# 场景加载测试
# 1. 在编辑器中打开场景
# 2. 检查是否有 Error 日志
# 3. 检查是否有组件加载失败

# 控制台检查
# 1. 运行项目
# 2. 检查控制台输出
# 3. 确认无 Error 级别日志
```

**6. 提交并更新：**
- 使用选择的语言提交
- 更新 feature-list.json：`passes` 设为 `true`
- 如果是模块内更新，同步更新顶层进度

---

## 已有项目添加新模块

当用户说"在已有项目中添加新模块"时：

**1. 分析现有项目：**
- 检查项目类型
- 检查现有模块
- 了解项目技术栈

**2. 与用户确认新模块需求：**
- 模块名称
- 模块功能
- 与现有模块的关系

**3. 创建模块结构：**
```
project/
├── modules/
│   └── new-module/
│       ├── SPEC.md
│       └── feature-list.json
```

**4. 初始化模块：**
- 生成模块需求文档
- 生成模块功能清单
- 提交

---

## Cocos 自检详细流程

### 构建测试
```bash
# Web 平台构建测试
cocos build --platform web --quiet
if [ $? -eq 0 ]; then
  echo "构建成功"
else
  echo "构建失败，检查错误日志"
  # 显示构建日志中的 Error
fi
```

### 场景加载测试
1. 在 Cocos Editor 中打开场景
2. 等待场景加载完成
3. 检查 Hierarchy 面板
4. 检查 Console 面板是否有 Error

### 运行时检查
1. 运行预览
2. 观察控制台输出
3. 检查是否有以下错误：
   - `Cannot read property 'xxx' of undefined`
   - `Failed to load resource`
   - `JS: Error: ...`

### 自检结果记录
```json
{
  "id": "F001",
  "check_result": {
    "timestamp": "YYYY-MM-DD HH:mm:ss",
    "methods": ["scene-load"],
    "passed": true,
    "errors": [],
    "warnings": []
  }
}
```

---

## 核心规则

- 一次只实现一个功能
- 不要删除或修改 test_criteria
- 不要将未测试的功能标记为完成
- **Cocos 项目必须进行自检后才能标记为完成**
- 每次会话结束前必须更新进度文件
- 多模块模式下，顶层模块状态自动同步
- 已有项目添加新模块时，不影响原有代码

## 边界情况处理

| 场景 | 处理方式 |
|------|----------|
| 已有 feature-list.json | 询问用户是覆盖还是继续 |
| 已有 SPEC.md | 询问用户是使用还是重新生成 |
| 用户调整需求 | 更新 SPEC.md 后重新生成功能清单 |
| 功能实现被跳过 | 在 notes 中记录原因，更新 priority |
| 模块间有依赖 | 在顶层 feature-list.json 中记录模块依赖 |
| Cocos 构建失败 | 记录错误到 notes，标记 passes 为 false |
| 已有项目添加模块 | 仅创建模块目录，不修改原有文件 |
| 自检超时 | 增加 timeout 或标记为手动验证 |

## Cocos 场景创建限制

### 已知限制

Cocos Creator 场景文件 (.scene) 存在以下创建限制：

1. **UUID 依赖**：场景文件依赖内置资源的 UUID，不知道这些 UUID 无法正确创建
2. **复杂引用结构**：场景包含 `__id__`、`__type__` 等内部引用
3. **版本差异**：Cocos 2.x 和 3.x 的 API 有差异（如 `cc.GameManager` 在 3.x 不存在）

### 自动化解决方案（推荐）

已提供自动化场景创建脚本，AI 可以通过运行脚本自动创建场景：

**使用流程：**

1. **AI 创建脚本**：在 `assets/Script/` 目录下创建场景脚本
2. **AI 配置脚本**：设置脚本的属性（位置、颜色等）
3. **运行验证**：在 Cocos Editor 中运行场景验证
4. **保存场景**：手动保存场景文件

**已提供的脚本：**

| 脚本 | 功能 | 使用方式 |
|------|------|----------|
| `SimpleSceneCreator.ts` | 创建基础场景（地面+摄像机+灯光） | 挂载到节点，自动创建 |
| `SceneAnalyzer.ts` | 分析现有场景结构 | 运行后查看控制台输出 |
| `SceneGenerator.ts` | 通用场景生成器 | 配置后自动生成 |

**使用 SimpleSceneCreator 示例：**

```typescript
// AI 创建脚本后，用户在 Editor 中：
// 1. 创建空节点
// 2. 挂载 SimpleSceneCreator 组件
// 3. 运行场景
// 4. 保存为 .scene 文件
```

### 手动解决方案（备选）

当自动化方案不可用时：

**方案 1：基于模板复制**
1. 先在 Cocos Editor 中手动创建一个基础场景
2. 让 AI 分析这个场景的 JSON 结构
3. 基于该结构修改创建新场景

**方案 2：只创建脚本 + 手动绑定**
1. AI 只创建 TypeScript 脚本
2. 在 Cocos Editor 中手动创建场景并绑定脚本
3. 记录到功能清单中

### 工作流调整

当功能需要创建场景时：
1. 首先尝试使用 `SimpleSceneCreator.ts` 自动化方案
2. 如果失败，在 steps 中标注需要的节点和组件
3. 在 notes 中记录场景配置参数

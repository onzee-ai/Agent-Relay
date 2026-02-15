# Agent Relay - AI Agent 接力开发框架

## 解决什么问题

AI Agent（如 Claude）在长对话中会丢失上下文记忆。当一个会话结束后，下一个会话的 Agent 完全不知道之前做了什么。

Agent Relay 通过**结构化的进度文件和功能清单**解决这个问题：
- 每个会话结束时，Agent 将工作进度写入文件
- 下一个会话启动时，Agent 读取这些文件恢复上下文
- 功能清单确保开发按计划推进，不遗漏、不重复

就像接力赛跑一样，每个 Agent 接过"接力棒"继续前进。

## 安装

```bash
# 1. 克隆本仓库
git clone <仓库地址> agent-relay
cd agent-relay

# 2. 安装到你的项目
./install.sh /path/to/your-project
```

安装脚本会将框架文件注入到目标项目中，无需手动复制。

## 框架结构

安装后，你的项目目录结构如下：

```
your-project/
├── CLAUDE.md                  ← Agent 指令文件（每次会话必读）
├── feature-list.json          ← 功能清单（项目的开发蓝图）
├── claude-progress.txt        ← 进度跟踪（会话间的交接文档）
└── agent-relay/
    ├── prompts/
    │   ├── initializer-agent.md   ← 初始化 Agent 提示词
    │   └── coding-agent.md        ← 编码 Agent 提示词
    ├── scripts/
    │   ├── init-dev.sh            ← 开发环境启动脚本
    │   ├── start-session.sh       ← 会话启动检查
    │   └── end-session.sh         ← 会话结束检查
    └── schema/
        └── feature-schema.json    ← 功能清单 JSON Schema
```

## 完整工作流程

### 阶段一：项目初始化

使用初始化 Agent 提示词启动第一次会话：

```
请阅读 agent-relay/prompts/initializer-agent.md 作为你的系统提示词。
我要创建一个 [项目描述]，技术栈是 [技术栈]。
请帮我分析需求并生成功能清单。
```

初始化 Agent 会：
1. 与你讨论项目需求
2. 生成完整的 `feature-list.json`
3. 搭建项目基础结构
4. 配置开发环境脚本
5. 完成首次 Git 提交

### 阶段二：接力开发

后续每次会话使用编码 Agent 提示词：

```
请阅读 agent-relay/prompts/coding-agent.md 作为你的系统提示词。
请执行会话启动检查，然后开始实现下一个功能。
```

编码 Agent 会：
1. 执行启动检查清单
2. 自动选择下一个要实现的功能
3. 逐步实现并测试
4. 提交代码并更新进度
5. 执行结束检查

重复此过程，直到所有功能完成。

## 功能清单详解

### JSON 格式

每个功能包含以下字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 功能 ID，格式 `F001`-`F999` |
| `category` | string | 功能分类 |
| `title` | string | 功能标题 |
| `description` | string | 功能描述 |
| `priority` | integer | 优先级 1-5，1 最高 |
| `steps` | array | 实现步骤列表 |
| `test_criteria` | array | 测试标准列表 |
| `passes` | boolean | 是否通过测试 |
| `dependencies` | array | 依赖的功能 ID |
| `notes` | string | 备注信息 |

### 功能分类

| 分类 | 说明 |
|------|------|
| `setup` | 项目搭建与配置 |
| `core` | 核心业务逻辑 |
| `ui` | 用户界面 |
| `auth` | 认证与授权 |
| `data` | 数据管理 |
| `api` | API 接口 |
| `test` | 测试 |
| `deploy` | 部署 |
| `a11y` | 无障碍访问 |
| `perf` | 性能优化 |

### 功能选择规则

Agent 按以下优先级自动选择下一个功能：
1. `passes` 为 `false`
2. `priority` 数值最小
3. 所有 `dependencies` 已完成
4. `id` 编号最小

## 进度文件详解

`claude-progress.txt` 是会话间的交接文档，包含以下部分：

- **已完成**：已实现并通过测试的功能
- **进行中**：当前正在实现的功能
- **待处理**：引用 feature-list.json
- **问题与决策**：开发过程中的重要决策和遇到的问题
- **下一步建议**：为下一个会话提供的建议

### 示例（3 个会话后）

```
=== 项目进度跟踪 ===
项目: my-web-app
创建时间: 2026-02-16
当前会话: 4

--- 已完成 ---
- F001: 项目基础结构搭建 (会话 1)
- F002: 开发服务器配置 (会话 2)
- F003: 基础页面布局 (会话 3)

--- 进行中 ---
（暂无）

--- 待处理 ---
参见 feature-list.json

--- 问题与决策 ---
- 会话 1: 选择 Vite 作为构建工具，因为启动速度快
- 会话 2: 开发服务器端口改为 5173（默认端口被占用）
- 会话 3: 使用 CSS Grid 实现响应式布局

--- 下一步建议 ---
1. 实现 F004: 导航栏组件
2. 注意移动端适配
```

## 会话管理脚本

### start-session.sh - 会话启动检查

```bash
bash agent-relay/scripts/start-session.sh
```

自动执行：显示工作目录、最近提交、进度文件、功能统计、启动开发环境。

### end-session.sh - 会话结束检查

```bash
bash agent-relay/scripts/end-session.sh
```

自动检查：未提交的更改、进度文件更新时间、功能完成统计。

### init-dev.sh - 开发环境启动

```bash
bash agent-relay/scripts/init-dev.sh
```

幂等脚本：检查依赖、启动开发服务器、健康检查。首次使用前需编辑顶部配置区域。

## 最佳实践

1. **一次一个功能**：每个会话只实现一个功能，保持专注
2. **E2E 测试必须通过**：不要跳过测试，不要删除测试条目
3. **小步提交**：完成一个功能就提交，不要积累大量更改
4. **及时更新进度**：每次提交后更新 `claude-progress.txt`
5. **记录决策**：重要的技术决策写入进度文件的"问题与决策"
6. **不要跳过检查清单**：启动和结束检查确保上下文完整传递
7. **依赖顺序**：严格按照依赖关系实现功能，不要跳过

## 常见问题与故障排除

| 问题 | 解决方案 |
|------|----------|
| 开发服务器启动失败 | 检查 `init-dev.sh` 顶部配置，确认端口未被占用 |
| 功能清单 JSON 解析错误 | 使用 `schema/feature-schema.json` 验证格式 |
| Agent 不读取进度文件 | 确保在提示词中要求 Agent 先执行启动检查清单 |
| 依赖安装失败 | 检查 `init-dev.sh` 中的 `INSTALL_CMD` 配置 |
| 健康检查超时 | 增大 `MAX_WAIT` 值，或检查 `HEALTH_CHECK_URL` |
| Agent 跳过测试 | 在提示词中强调必须通过 `test_criteria` 所有条目 |
| 进度文件未更新 | 在会话结束前运行 `end-session.sh` 检查 |
| Git 提交格式不对 | 参考 CLAUDE.md 中的提交规范 |

## 自定义与扩展

### 适配不同技术栈

编辑 `agent-relay/scripts/init-dev.sh` 顶部配置区域：

```bash
# Python 项目
INSTALL_CMD="pip install -r requirements.txt"
DEV_CMD="python manage.py runserver"
DEV_SERVER_PORT=8000

# Go 项目
INSTALL_CMD="go mod download"
DEV_CMD="go run main.go"
DEV_SERVER_PORT=8080
```

### 自定义功能分类

编辑 `agent-relay/schema/feature-schema.json` 中的 `category` 枚举值，添加项目特有的分类。

### 多 Agent 协作（未来）

当前框架支持单 Agent 接力开发。未来版本计划支持：
- 多 Agent 并行开发不同功能
- Agent 间的冲突检测与解决
- 自动化代码审查 Agent

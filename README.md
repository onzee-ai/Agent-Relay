# Agent Relay - AI Agent 接力开发框架

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/onzee-ai/Agent-Relay)](https://github.com/onzee-ai/Agent-Relay/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/onzee-ai/Agent-Relay)](https://github.com/onzee-ai/Agent-Relay/network)

解决 AI Agent 在长对话中丢失上下文的问题。通过结构化的需求文档和功能清单实现跨会话连续开发。

## 核心特性

- **跨会话连续开发**：基于 SPEC.md、feature-list.json 和 claude-progress.txt 实现
- **需求确认流程**：AI 生成需求文档 → 用户确认 → 生成功能清单
- **自动化工作流**：自动选择功能、实现、测试、提交、更新进度
- **一键安装**：自动检测 git root，写入 CLAUDE.md
- **多模块支持**：支持大型项目分层管理（推荐 30+ 功能使用）

## 安装

```bash
# 对任意 git 项目执行
bash /path/to/agent-relay/install.sh /path/to/your-project

# 或远程安装
curl -sL https://raw.githubusercontent.com/onzee-ai/Agent-Relay/main/install.sh | bash -s /path/to/your-project

# 安装后可以使用 relay.sh 命令行工具
cp /path/to/agent-relay/relay.sh /usr/local/bin/relay
```

## 卸载

```bash
bash /path/to/agent-relay/install.sh --uninstall /path/to/your-project
```

## 检查状态

```bash
bash /path/to/agent-relay/install.sh --check /path/to/your-project
```

## 命令行工具 (relay.sh)

安装后可以使用 `relay.sh` 命令行工具管理多项目：

```bash
relay.sh              # 交互模式
relay.sh list         # 列出所有项目
relay.sh add <path>  # 添加项目
relay.sh switch <name> # 切换项目
relay.sh status       # 查看项目状态
relay.sh progress     # 查看开发进度
```

## 使用

### 首次初始化

```bash
cd /path/to/your-project
claude
```

告诉 Claude：
> 初始化 relay 项目，我要做一个 xxx

**流程：**
1. AI 生成 `SPEC.md` 需求文档 → 展示给用户确认
2. 用户确认需求后，生成功能清单
3. Claude 自动生成：
   - `SPEC.md` - 需求文档
   - `feature-list.json` - 功能清单
   - `claude-progress.txt` - 进度跟踪

### 后续接力开发

每次新会话只需说：
> 继续开发

Claude 自动：读进度 → 选 feature → 实现 → 测试 → 提交 → 更新进度

### 多模块模式（大型项目）

对于大型项目（>30 个功能），推荐使用多模块模式：

```
project/
├── SPEC.md                      # 项目总需求文档
├── feature-list.json            # 顶层模块清单
└── modules/
    ├── module-1/
    │   ├── SPEC.md             # 模块需求文档
    │   └── feature-list.json   # 模块功能清单
    └── module-2/
        └── ...
```

初始化时，AI 会询问用户选择"单项目"或"多模块"模式。

使用 `relay.sh progress` 可以查看所有模块的总体进度。

## 文件说明

| 文件 | 说明 |
|------|------|
| `install.sh` | 安装/卸载/检查脚本 |
| `relay.sh` | 命令行工具（可选安装） |
| `relay-instructions.md` | CLAUDE.md 模板，包含完整的接力工作流指令 |
| `SPEC.md` | 需求文档（初始化时生成，需用户确认） |
| `feature-list.json` | 功能清单（确认需求后生成） |
| `claude-progress.txt` | 进度跟踪文件 |

## 工作原理

1. **初始化**：用户简单描述需求 → AI 生成 SPEC.md 需求文档 → 用户确认
2. **生成清单**：确认需求后，生成 feature-list.json 功能清单
3. **选择功能**：按优先级和依赖关系自动选择下一个可实现的功能
4. **实现**：按步骤列表逐步实现，逐条验证测试条件
5. **提交**：Git 提交，更新功能状态为已完成

## 核心规则

- 一次只实现一个功能
- 不删除或修改 test_criteria
- 未测试通过的功能不标记为完成
- 每次会话结束前更新进度文件

## 边界情况

| 场景 | 处理方式 |
|------|----------|
| 已有 feature-list.json | 询问用户是覆盖还是继续 |
| 已有 SPEC.md | 询问用户是使用还是重新生成 |
| 用户调整需求 | 更新 SPEC.md 后重新生成功能清单 |

## 贡献

欢迎贡献！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目。

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 行为准则

请阅读 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) 了解社区行为准则。

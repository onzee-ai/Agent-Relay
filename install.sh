#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Agent Relay - 安装脚本
# 用法: ./install.sh /path/to/your-project
# ============================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_banner() {
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════╗"
  echo "  ║     Agent Relay 安装程序             ║"
  echo "  ║     AI Agent 接力开发框架            ║"
  echo "  ╚══════════════════════════════════════╝"
  echo -e "${NC}"
}

print_banner

# 获取目标路径
TARGET_PATH="${1:-}"
if [[ -z "$TARGET_PATH" ]]; then
  echo -e "${YELLOW}请输入目标项目路径:${NC}"
  read -r TARGET_PATH
fi

if [[ -z "$TARGET_PATH" ]]; then
  echo -e "${RED}错误: 未提供目标项目路径${NC}"
  echo "用法: ./install.sh /path/to/your-project"
  exit 1
fi

# 解析为绝对路径
TARGET_PATH="$(cd "$TARGET_PATH" 2>/dev/null && pwd)" || {
  echo -e "${RED}错误: 路径不存在 - $TARGET_PATH${NC}"
  exit 1
}

echo -e "${BLUE}目标项目: ${BOLD}$TARGET_PATH${NC}"
echo ""

# Step 1: 创建 agent-relay 目录
RELAY_DIR="$TARGET_PATH/agent-relay"
if [[ -d "$RELAY_DIR" ]]; then
  echo -e "${YELLOW}警告: $RELAY_DIR 已存在，将覆盖内容${NC}"
fi
mkdir -p "$RELAY_DIR"

# Step 2: 复制框架文件
echo -e "${GREEN}[1/5]${NC} 复制 prompts/ ..."
cp -r "$SCRIPT_DIR/prompts" "$RELAY_DIR/"

echo -e "${GREEN}[2/5]${NC} 复制 scripts/ ..."
cp -r "$SCRIPT_DIR/scripts" "$RELAY_DIR/"

echo -e "${GREEN}[3/5]${NC} 复制 schema/ ..."
cp -r "$SCRIPT_DIR/schema" "$RELAY_DIR/"

# Step 3: 复制模板到项目根目录
echo -e "${GREEN}[4/5]${NC} 复制模板文件到项目根目录 ..."

for f in CLAUDE.md feature-list.json claude-progress.txt; do
  if [[ -f "$TARGET_PATH/$f" ]]; then
    echo -e "  ${YELLOW}跳过 $f (已存在)${NC}"
  else
    cp "$SCRIPT_DIR/templates/$f" "$TARGET_PATH/$f"
    echo -e "  ${GREEN}已创建 $f${NC}"
  fi
done

# Step 4: 设置脚本可执行权限
echo -e "${GREEN}[5/5]${NC} 设置脚本权限 ..."
chmod +x "$RELAY_DIR/scripts/"*.sh

echo ""
echo -e "${GREEN}${BOLD}安装完成!${NC}"
echo ""

# 显示安装结果
echo -e "${CYAN}已安装到项目的文件结构:${NC}"
echo "  $TARGET_PATH/"
echo "  ├── CLAUDE.md              (Agent 指令文件)"
echo "  ├── feature-list.json      (功能清单)"
echo "  ├── claude-progress.txt    (进度跟踪)"
echo "  └── agent-relay/"
echo "      ├── prompts/           (Agent 提示词)"
echo "      ├── scripts/           (会话管理脚本)"
echo "      └── schema/            (JSON Schema)"
echo ""

# 下一步指南
echo -e "${BOLD}下一步:${NC}"
echo -e "  1. 编辑 ${CYAN}CLAUDE.md${NC} 填写项目信息"
echo -e "  2. 编辑 ${CYAN}agent-relay/scripts/init-dev.sh${NC} 配置开发环境"
echo -e "  3. 使用 ${CYAN}agent-relay/prompts/initializer-agent.md${NC} 启动初始化会话"
echo ""

# Git 建议
if command -v git &>/dev/null && git -C "$TARGET_PATH" rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  echo -e "${YELLOW}检测到 Git 仓库，建议提交新文件:${NC}"
  echo "  cd $TARGET_PATH"
  echo "  git add agent-relay/ CLAUDE.md feature-list.json claude-progress.txt"
  echo '  git commit -m "chore: 添加 Agent Relay 接力开发框架"'
  echo ""
fi

echo -e "${GREEN}祝你开发顺利!${NC}"

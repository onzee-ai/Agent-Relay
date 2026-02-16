#!/usr/bin/env bash
set -euo pipefail

# Agent Relay - 一键安装
# 用法: curl -sL <url> | bash -s /path/to/your-project
# 或者: bash install.sh /path/to/your-project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "用法: bash install.sh /path/to/your-project"
  exit 1
fi

TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "路径不存在: $TARGET"; exit 1; }

# 自动检测 git root
GIT_ROOT="$(cd "$TARGET" && git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "错误: $TARGET 不在 git 仓库中"
  exit 1
}

echo "目标项目: $GIT_ROOT"

# 复制 CLAUDE.md（如果不存在则创建，如果存在则追加 relay 指令）
if [[ -f "$GIT_ROOT/CLAUDE.md" ]]; then
  if grep -q "Agent Relay" "$GIT_ROOT/CLAUDE.md" 2>/dev/null; then
    echo "CLAUDE.md 已包含 Agent Relay 指令，跳过"
  else
    echo "" >> "$GIT_ROOT/CLAUDE.md"
    cat "$SCRIPT_DIR/relay-instructions.md" >> "$GIT_ROOT/CLAUDE.md"
    echo "已追加 Agent Relay 指令到 CLAUDE.md"
  fi
else
  cp "$SCRIPT_DIR/relay-instructions.md" "$GIT_ROOT/CLAUDE.md"
  echo "已创建 CLAUDE.md"
fi

echo ""
echo "安装完成！"
echo ""
echo "使用方式:"
echo "  cd $GIT_ROOT"
echo "  claude"
echo "  > 初始化 relay 项目，需求是 xxx"
echo ""
echo "后续每次新会话:"
echo "  > 继续开发"

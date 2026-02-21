#!/usr/bin/env bash
set -euo pipefail

# Agent Relay - 一键安装
# 用法:
#   bash install.sh /path/to/your-project    # 安装
#   bash install.sh --uninstall /path/to/your-project  # 卸载
#   bash install.sh --check /path/to/your-project  # 检查状态

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELAY_MARKER="Agent Relay"

usage() {
  echo "Agent Relay - 一键安装"
  echo ""
  echo "用法:"
  echo "  bash install.sh <path>              # 安装到指定项目"
  echo "  bash install.sh --uninstall <path> # 卸载"
  echo "  bash install.sh --check <path>     # 检查安装状态"
  echo ""
  echo "示例:"
  echo "  bash install.sh /path/to/your-project"
  echo "  curl -sL https://raw.githubusercontent.com/your-repo/agent-relay/main/install.sh | bash -s /path/to/your-project"
}

check_installed() {
  local target="$1"
  local git_root

  git_root="$(cd "$target" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" || return 1

  if [[ -f "$git_root/CLAUDE.md" ]] && grep -q "$RELAY_MARKER" "$git_root/CLAUDE.md" 2>/dev/null; then
    echo "已安装"
    return 0
  else
    echo "未安装"
    return 1
  fi
}

do_install() {
  local target="$1"
  local git_root

  git_root="$(cd "$target" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "错误: $target 不是有效的 git 仓库"
    exit 1
  }

  echo "目标项目: $git_root"

  # 检查是否已安装
  if [[ -f "$git_root/CLAUDE.md" ]] && grep -q "$RELAY_MARKER" "$git_root/CLAUDE.md" 2>/dev/null; then
    echo "CLAUDE.md 已包含 Agent Relay 指令，已安装"
    return 0
  fi

  # 复制 CLAUDE.md（如果不存在则创建，如果存在则追加 relay 指令）
  if [[ -f "$git_root/CLAUDE.md" ]]; then
    echo "" >> "$git_root/CLAUDE.md"
    cat "$SCRIPT_DIR/relay-instructions.md" >> "$git_root/CLAUDE.md"
    echo "已追加 Agent Relay 指令到 CLAUDE.md"
  else
    cp "$SCRIPT_DIR/relay-instructions.md" "$git_root/CLAUDE.md"
    echo "已创建 CLAUDE.md"
  fi

  echo ""
  echo "安装完成！"
  echo ""
  echo "使用方式:"
  echo "  cd $git_root"
  echo "  claude"
  echo "  > 初始化 relay 项目，需求是 xxx"
  echo ""
  echo "后续每次新会话:"
  echo "  > 继续开发"
}

do_uninstall() {
  local target="$1"
  local git_root

  git_root="$(cd "$target" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "错误: $target 不是有效的 git 仓库"
    exit 1
  }

  if [[ ! -f "$git_root/CLAUDE.md" ]]; then
    echo "CLAUDE.md 不存在，无需卸载"
    return 0
  fi

  # 备份原文件
  cp "$git_root/CLAUDE.md" "$git_root/CLAUDE.md.bak"

  # 移除 Agent Relay 相关内容
  # 使用 sed 删除从 "# Agent Relay" 到下一个 "#" 之前的内容
  sed -i '' "/$RELAY_MARKER/,/^#/{ /^#.*$/!d; }" "$git_root/CLAUDE.md"
  sed -i '' "/$RELAY_MARKER/d" "$git_root/CLAUDE.md"

  # 清理空行和临时文件
  sed -i '' '/^$/d' "$git_root/CLAUDE.md"

  # 如果文件为空或只有标题，删除
  if [[ ! -s "$git_root/CLAUDE.md" ]]; then
    rm "$git_root/CLAUDE.md"
    echo "已删除 CLAUDE.md（原文件已备份为 CLAUDE.md.bak）"
  else
    echo "已从 CLAUDE.md 移除 Agent Relay 指令（原文件已备份为 CLAUDE.md.bak）"
  fi

  echo ""
  echo "卸载完成！"
}

# 主逻辑
case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  -u|--uninstall)
    TARGET="${2:-}"
    if [[ -z "$TARGET" ]]; then
      echo "错误: 缺少路径参数"
      usage
      exit 1
    fi
    TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "路径不存在: $TARGET"; exit 1; }
    do_uninstall "$TARGET"
    ;;
  -c|--check)
    TARGET="${2:-}"
    if [[ -z "$TARGET" ]]; then
      echo "错误: 缺少路径参数"
      usage
      exit 1
    fi
    TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "路径不存在: $TARGET"; exit 1; }
    check_installed "$TARGET"
    ;;
  "")
    echo "错误: 缺少路径参数"
    usage
    exit 1
    ;;
  *)
    TARGET="$(cd "$1" 2>/dev/null && pwd)" || { echo "路径不存在: $1"; exit 1; }
    do_install "$TARGET"
    ;;
esac

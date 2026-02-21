#!/usr/bin/env bash
set -eo pipefail

# Agent Relay - 一键安装
# 用法:
#   bash install.sh /path/to/your-project    # 安装
#   bash install.sh --uninstall /path/to/your-project  # 卸载
#   bash install.sh --check /path/to/your-project  # 检查状态
#   bash install.sh --update /path/to/your-project  # 更新到最新版本

# 处理 BASH_SOURCE 在 pipe 模式下可能 unbound 的问题
if [[ -z "${BASH_SOURCE[0]:-}" ]]; then
  BASH_SOURCE="$0"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELAY_MARKER="Agent Relay"
RELAY_VERSION="1.0.0"

usage() {
  echo "Agent Relay - 一键安装 (v$RELAY_VERSION)"
  echo ""
  echo "用法:"
  echo "  bash install.sh <path>              # 安装到指定项目"
  echo "  bash install.sh --uninstall <path> # 卸载"
  echo "  bash install.sh --check <path>     # 检查安装状态"
  echo "  bash install.sh --update <path>    # 更新到最新版本"
  echo ""
  echo "示例:"
  echo "  bash install.sh /path/to/your-project"
  echo "  curl -sL https://raw.githubusercontent.com/onzee-ai/Agent-Relay/main/install.sh | bash -s /path/to/your-project"
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

  # 检查是否有 relay-instructions.md，如果没有则尝试下载
  local instructions_file="$SCRIPT_DIR/relay-instructions.md"
  if [[ ! -f "$instructions_file" ]]; then
    echo "正在从 GitHub 下载 relay-instructions.md..."
    instructions_file="$git_root/relay-instructions.md"
    curl -sL "https://raw.githubusercontent.com/onzee-ai/Agent-Relay/main/relay-instructions.md" -o "$instructions_file" || {
      echo "错误: 无法下载 relay-instructions.md"
      exit 1
    }
  fi

  # 复制 CLAUDE.md（如果不存在则创建，如果存在则追加 relay 指令）
  if [[ -f "$git_root/CLAUDE.md" ]]; then
    echo "" >> "$git_root/CLAUDE.md"
    cat "$instructions_file" >> "$git_root/CLAUDE.md"
    echo "已追加 Agent Relay 指令到 CLAUDE.md"
  else
    cp "$instructions_file" "$git_root/CLAUDE.md"
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

  # 移除 Agent Relay 相关内容（跨平台兼容）
  # 使用 awk 删除从 "# Agent Relay" 开始的所有行直到下一个以 # 开头的行之前
  awk '/^# Agent Relay/{skip=1; next} skip && /^#/{skip=0} !skip' "$git_root/CLAUDE.md" > "$git_root/CLAUDE.md.tmp" && mv "$git_root/CLAUDE.md.tmp" "$git_root/CLAUDE.md"

  # 清理空行
  sed -i '' '/^$/d' "$git_root/CLAUDE.md" 2>/dev/null || sed -i '/^$/d' "$git_root/CLAUDE.md"

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

do_update() {
  local target="$1"
  local git_root

  git_root="$(cd "$target" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "错误: $target 不是有效的 git 仓库"
    exit 1
  }

  # 检查是否已安装
  if [[ ! -f "$git_root/CLAUDE.md" ]] || ! grep -q "$RELAY_MARKER" "$git_root/CLAUDE.md" 2>/dev/null; then
    echo "未安装 Agent Relay，请先运行安装命令"
    exit 1
  fi

  echo "目标项目: $git_root"
  echo "正在更新..."

  # 备份原文件
  cp "$git_root/CLAUDE.md" "$git_root/CLAUDE.md.bak"

  # 移除旧的 Agent Relay 指令
  awk '/^# Agent Relay/{skip=1; next} skip && /^#/{skip=0} !skip' "$git_root/CLAUDE.md" > "$git_root/CLAUDE.md.tmp" && mv "$git_root/CLAUDE.md.tmp" "$git_root/CLAUDE.md"

  # 清理空行
  sed -i '' '/^$/d' "$git_root/CLAUDE.md" 2>/dev/null || sed -i '/^$/d' "$git_root/CLAUDE.md"

  # 添加新的指令
  if [[ -s "$git_root/CLAUDE.md" ]]; then
    echo "" >> "$git_root/CLAUDE.md"
  fi
  cat "$SCRIPT_DIR/relay-instructions.md" >> "$git_root/CLAUDE.md"

  echo "已更新到最新版本（原文件已备份为 CLAUDE.md.bak）"
  echo ""
  echo "更新完成！"
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
  -U|--update)
    TARGET="${2:-}"
    if [[ -z "$TARGET" ]]; then
      echo "错误: 缺少路径参数"
      usage
      exit 1
    fi
    TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "路径不存在: $TARGET"; exit 1; }
    do_update "$TARGET"
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

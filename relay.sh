#!/usr/bin/env bash
set -euo pipefail

# Agent Relay - 命令行工具
# 用法:
#   relay.sh              # 交互模式
#   relay.sh init        # 初始化项目
#   relay.sh next       # 继续下一个功能
#   relay.sh progress    # 查看进度
#   relay.sh status     # 查看状态
#   relay.sh add <path> # 添加项目
#   relay.sh list       # 列出项目
#   relay.sh switch <name> # 切换项目

RELAY_VERSION="1.0.0"
RELAY_DIR="${HOME}/.relay"
PROJECTS_FILE="${RELAY_DIR}/projects.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 确保目录存在
mkdir -p "$RELAY_DIR"

# 工具函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 获取当前项目
get_current_project() {
  if [[ ! -f "$PROJECTS_FILE" ]]; then
    echo ""
    return
  fi
  python3 -c "
import json
with open('${PROJECTS_FILE}', 'r') as f:
    data = json.load(f)
    print(data.get('current', ''))
" 2>/dev/null || echo ""
}

# 获取项目路径
get_project_path() {
  local name="$1"
  if [[ ! -f "$PROJECTS_FILE" ]]; then
    echo ""
    return
  fi

  # 提取当前项目的 path
  local path
  path=$(python3 -c "
import json
with open('${PROJECTS_FILE}', 'r') as f:
    data = json.load(f)
    for p in data.get('projects', []):
        if p.get('name') == '${name}':
            print(p.get('path', ''))
            break
" 2>/dev/null) || echo ""

  echo "$path"
}

# 检查项目是否安装 relay
check_relay_installed() {
  local project_path="$1"
  if [[ -f "$project_path/CLAUDE.md" ]] && grep -q "Agent Relay" "$project_path/CLAUDE.md"; then
    return 0
  fi
  return 1
}

# 显示进度条
show_progress_bar() {
  local current=$1
  local total=$2
  local width=20

  local percent=$((current * 100 / total))
  local filled=$((width * current / total))
  local empty=$((width - filled))

  printf "["
  printf "%${filled}s" | tr ' ' '█'
  printf "%${empty}s" | tr ' ' '░'
  printf "] %d%%" "$percent"
}

# 格式化功能列表
format_features() {
  local project_path="$1"
  local feature_file="$project_path/feature-list.json"

  if [[ ! -f "$feature_file" ]]; then
    log_warn "未找到 feature-list.json"
    return
  fi

  # 使用 Python 解析 JSON
  python3 -c "
import json
with open('${feature_file}', 'r') as f:
    data = json.load(f)
    features = data.get('features', [])
    total = len(features)
    completed = sum(1 for f in features if f.get('passes', False))

    print()
    percent = int(completed * 100 / total) if total > 0 else 0
    print(f'项目进度: [{chr(9608) * int(20 * completed / total)}{chr(9600) * (20 - int(20 * completed / total))}] {percent}% ({completed}/{total} 功能)')
    print()

    for f in features:
        fid = f.get('id', '')
        title = f.get('title', '')
        passes = f.get('passes', False)
        marker = '✓' if passes else '○'
        print(f'  {marker} {fid} {title}')
"
}

# 显示项目列表
cmd_list() {
  if [[ ! -f "$PROJECTS_FILE" ]]; then
    log_warn "暂无项目，请先添加项目: relay.sh add <path>"
    return
  fi

  local current
  current=$(get_current_project)

  echo ""
  echo "=== 项目列表 ==="
  echo ""

  # 使用 Python 解析 JSON
  python3 -c "
import json
with open('${PROJECTS_FILE}', 'r') as f:
    data = json.load(f)
    current = data.get('current', '')
    for p in data.get('projects', []):
        name = p.get('name', '')
        path = p.get('path', '')
        marker = '  ' if name != current else '* '
        status = '未安装'
        import os
        if os.path.exists(os.path.join(path, 'CLAUDE.md')):
            with open(os.path.join(path, 'CLAUDE.md'), 'r') as cf:
                if 'Agent Relay' in cf.read():
                    status = '已安装'
        print(f'{marker}{name} ({status})')
        print(f'    {path}')
        print()
"
}

# 添加项目
cmd_add() {
  local path="${1:-}"

  if [[ -z "$path" ]]; then
    log_error "请提供项目路径: relay.sh add <path>"
    exit 1
  fi

  # 解析为绝对路径
  path="$(cd "$path" 2>/dev/null && pwd)" || {
    log_error "路径不存在: $path"
    exit 1
  }

  # 检查是否是 git 仓库
  if ! git -C "$path" rev-parse --git-dir >/dev/null 2>&1; then
    log_error "不是有效的 git 仓库: $path"
    exit 1
  fi

  # 获取项目名
  local name
  name=$(basename "$path")

  # 如果 projects.json 不存在，创建
  if [[ ! -f "$PROJECTS_FILE" ]]; then
    echo '{"projects":[],"current":""}' > "$PROJECTS_FILE"
  fi

  # 检查是否已存在
  if grep -q "\"name\": \"$name\"" "$PROJECTS_FILE"; then
    log_warn "项目已存在: $name"
    return
  fi

  # 添加项目
  local temp_file="${PROJECTS_FILE}.tmp"
  local today
  today=$(date +%Y-%m-%d)

  # 使用 jq 或手动添加
  if command -v jq &>/dev/null; then
    local new_project
    new_project=$(jq -n \
      --arg name "$name" \
      --arg path "$path" \
      --arg date "$today" \
      '{"name":$name,"path":$path,"last_access":$date,"status":"active"}')

    jq --argjson project "$new_project" '.projects += [$project] | .current = $project.name' "$PROJECTS_FILE" > "$temp_file" && mv "$temp_file" "$PROJECTS_FILE"
  else
    # 手动添加（无 jq 时）
    sed -i '' "s/\"projects\":\[/\"projects\":[{\"name\":\"$name\",\"path\":\"$path\",\"last_access\":\"$today\",\"status\":\"active\"},/" "$PROJECTS_FILE"
    sed -i '' "s/\"current\":\"\"/\"current\":\"$name\"/" "$PROJECTS_FILE"
  fi

  log_success "已添加项目: $name"
  log_info "项目路径: $path"

  # 询问是否安装
  if ! check_relay_installed "$path"; then
    echo ""
    read -p "是否安装 Agent Relay? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      local script_dir
      script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
      bash "${script_dir}/install.sh" "$path"
    fi
  fi
}

# 切换项目
cmd_switch() {
  local name="${1:-}"

  if [[ -z "$name" ]]; then
    log_error "请提供项目名: relay.sh switch <name>"
    exit 1
  fi

  if [[ ! -f "$PROJECTS_FILE" ]]; then
    log_error "暂无项目"
    exit 1
  fi

  if ! grep -q "\"name\": \"$name\"" "$PROJECTS_FILE"; then
    log_error "项目不存在: $name"
    exit 1
  fi

  sed -i '' "s/\"current\": \"[^\"]*\"/\"current\": \"$name\"/" "$PROJECTS_FILE"
  log_success "已切换到项目: $name"
}

# 查看状态
cmd_status() {
  local current
  current=$(get_current_project)

  if [[ -z "$current" ]]; then
    log_warn "未选择项目，请先添加: relay.sh add <path>"
    return
  fi

  local path
  path=$(get_project_path "$current")

  echo ""
  echo "=== 项目状态 ==="
  echo ""
  echo "当前项目: $current"
  echo "项目路径: $path"

  if check_relay_installed "$path"; then
    echo -e "安装状态: ${GREEN}已安装${NC}"
  else
    echo -e "安装状态: ${RED}未安装${NC}"
  fi

  # 显示 feature 进度
  if [[ -f "$path/feature-list.json" ]]; then
    format_features "$path"
  fi
}

# 查看进度
cmd_progress() {
  local current
  current=$(get_current_project)

  if [[ -z "$current" ]]; then
    log_warn "未选择项目"
    return
  fi

  local path
  path=$(get_project_path "$current")

  echo ""
  echo "=== $current 进度 ==="

  if [[ -f "$path/feature-list.json" ]]; then
    format_features "$path"
  else
    log_warn "未找到 feature-list.json，请先初始化项目"
    return
  fi

  echo ""
  echo "下一步建议: 运行 'claude' 并说 '继续开发'"
}

# 交互模式
cmd_interactive() {
  echo ""
  echo "========================================"
  echo "     Agent Relay v${RELAY_VERSION}"
  echo "========================================"
  echo ""

  local current
  current=$(get_current_project)

  if [[ -z "$current" ]]; then
    echo "欢迎使用 Agent Relay!"
    echo ""
    echo "尚未添加项目，请选择操作:"
    echo "  1. 添加新项目"
    echo "  2. 退出"
    echo ""
    read -p "请选择 (1-2): " -n 1 -r
    echo ""
    case $REPLY in
      1)
        echo ""
        read -p "请输入项目路径: " path
        cmd_add "$path"
        ;;
      2)
        exit 0
        ;;
    esac
  else
    local path
    path=$(get_project_path "$current")

    echo "当前项目: $current"
    echo ""
    echo "请选择操作:"
    echo "  1. 继续开发 (claude)"
    echo "  2. 查看进度"
    echo "  3. 查看状态"
    echo "  4. 切换项目"
    echo "  5. 添加新项目"
    echo "  6. 退出"
    echo ""
    read -p "请选择 (1-6): " -n 1 -r
    echo ""
    case $REPLY in
      1)
        echo "请运行: cd $path && claude"
        echo "然后说: 继续开发"
        ;;
      2)
        cmd_progress
        ;;
      3)
        cmd_status
        ;;
      4)
        cmd_list
        echo ""
        read -p "请输入项目名: " name
        cmd_switch "$name"
        ;;
      5)
        read -p "请输入项目路径: " path
        cmd_add "$path"
        ;;
      6)
        exit 0
        ;;
    esac
  fi
}

# 显示帮助
show_help() {
  echo "Agent Relay v${RELAY_VERSION}"
  echo ""
  echo "用法: relay.sh <command> [options]"
  echo ""
  echo "命令:"
  echo "  relay.sh              交互模式"
  echo "  relay.sh init        初始化当前项目"
  echo "  relay.sh next       继续下一个功能"
  echo "  relay.sh progress   查看进度"
  echo "  relay.sh status     查看状态"
  echo "  relay.sh add <path> 添加项目"
  echo "  relay.sh list       列出所有项目"
  echo "  relay.sh switch <name> 切换项目"
  echo "  relay.sh -h, --help 显示帮助"
}

# 主逻辑
case "${1:-}" in
  -h|--help)
    show_help
    exit 0
    ;;
  list|ls)
    cmd_list
    ;;
  add)
    cmd_add "${2:-}"
    ;;
  switch|use)
    cmd_switch "${2:-}"
    ;;
  status)
    cmd_status
    ;;
  progress|prog)
    cmd_progress
    ;;
  interactive|i|"")
    cmd_interactive
    ;;
  *)
    log_error "未知命令: $1"
    show_help
    exit 1
    ;;
esac

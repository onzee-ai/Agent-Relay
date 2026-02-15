#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 会话启动检查脚本
# 用法: bash agent-relay/scripts/start-session.sh
# ============================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${CYAN}${BOLD}=== 会话启动检查 ===${NC}"
echo ""

# 1. 工作目录
echo -e "${GREEN}[1/5]${NC} 工作目录: $PROJECT_ROOT"
echo ""

# 2. 最近 Git 提交
echo -e "${GREEN}[2/5]${NC} 最近 Git 提交:"
if git rev-parse --is-inside-work-tree &>/dev/null; then
  git log --oneline -5 2>/dev/null || echo "  （暂无提交记录）"
else
  echo "  （非 Git 仓库）"
fi
echo ""

# 3. 进度文件
echo -e "${GREEN}[3/5]${NC} 项目进度:"
if [[ -f "$PROJECT_ROOT/claude-progress.txt" ]]; then
  cat "$PROJECT_ROOT/claude-progress.txt"
else
  echo -e "  ${YELLOW}claude-progress.txt 不存在${NC}"
fi
echo ""

# 4. 功能清单统计
echo -e "${GREEN}[4/5]${NC} 功能清单统计:"
if [[ -f "$PROJECT_ROOT/feature-list.json" ]]; then
  TOTAL=$(grep -c '"id"' "$PROJECT_ROOT/feature-list.json" 2>/dev/null || echo 0)
  DONE=$(grep -c '"passes": true' "$PROJECT_ROOT/feature-list.json" 2>/dev/null || echo 0)
  REMAINING=$((TOTAL - DONE))
  echo "  总计: $TOTAL | 已完成: $DONE | 剩余: $REMAINING"
  echo ""
  echo "  待完成功能:"
  # 使用 python 或 grep 提取待完成功能
  grep -B5 '"passes": false' "$PROJECT_ROOT/feature-list.json" \
    | grep '"id"\|"title"' \
    | paste - - \
    | sed 's/.*"id": "\(.*\)".*/  \1/' \
    | head -10 2>/dev/null || echo "  （解析失败，请直接查看 feature-list.json）"
else
  echo -e "  ${YELLOW}feature-list.json 不存在${NC}"
fi
echo ""

# 5. 启动开发环境
echo -e "${GREEN}[5/5]${NC} 启动开发环境 ..."
bash "$SCRIPT_DIR/init-dev.sh"

echo ""
echo -e "${CYAN}${BOLD}=== 检查完成，开始工作 ===${NC}"

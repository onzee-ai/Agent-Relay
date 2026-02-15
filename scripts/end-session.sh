#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 会话结束检查脚本
# 用法: bash agent-relay/scripts/end-session.sh
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${CYAN}${BOLD}=== 会话结束检查 ===${NC}"
echo ""

# 1. 检查未提交的更改
echo -e "${GREEN}[1/3]${NC} Git 状态检查:"
if git rev-parse --is-inside-work-tree &>/dev/null; then
  CHANGES=$(git status --porcelain 2>/dev/null)
  if [[ -n "$CHANGES" ]]; then
    echo -e "  ${RED}警告: 存在未提交的更改!${NC}"
    echo "$CHANGES" | head -10
    echo ""
    echo -e "  ${YELLOW}请提交后再结束会话${NC}"
  else
    echo -e "  ${GREEN}所有更改已提交${NC}"
  fi
else
  echo "  （非 Git 仓库）"
fi
echo ""

# 2. 检查进度文件更新
echo -e "${GREEN}[2/3]${NC} 进度文件检查:"
if [[ -f "$PROJECT_ROOT/claude-progress.txt" ]]; then
  MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$PROJECT_ROOT/claude-progress.txt" 2>/dev/null \
    || stat -c "%y" "$PROJECT_ROOT/claude-progress.txt" 2>/dev/null | cut -d. -f1)
  echo -e "  最后更新: $MODIFIED"
else
  echo -e "  ${YELLOW}claude-progress.txt 不存在${NC}"
fi
echo ""

# 3. 功能完成统计
echo -e "${GREEN}[3/3]${NC} 功能完成统计:"
if [[ -f "$PROJECT_ROOT/feature-list.json" ]]; then
  TOTAL=$(grep -c '"id"' "$PROJECT_ROOT/feature-list.json" 2>/dev/null || echo 0)
  DONE=$(grep -c '"passes": true' "$PROJECT_ROOT/feature-list.json" 2>/dev/null || echo 0)
  if [[ $TOTAL -gt 0 ]]; then
    PCT=$((DONE * 100 / TOTAL))
    echo -e "  完成进度: ${DONE}/${TOTAL} (${PCT}%)"
  else
    echo "  暂无功能条目"
  fi
else
  echo -e "  ${YELLOW}feature-list.json 不存在${NC}"
fi
echo ""

echo -e "${CYAN}${BOLD}=== 会话结束 ===${NC}"

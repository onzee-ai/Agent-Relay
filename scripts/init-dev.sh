#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 开发环境启动脚本（幂等）
# 用法: bash agent-relay/scripts/init-dev.sh
# ============================================================

# === 配置区域（根据项目修改） ===
DEV_SERVER_PORT=3000
HEALTH_CHECK_URL="http://localhost:${DEV_SERVER_PORT}"
INSTALL_CMD="npm install"
DEV_CMD="npm run dev"
PID_FILE=".dev-server.pid"
MAX_WAIT=30
# ================================

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 定位项目根目录（从 agent-relay/scripts/ 向上两级）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${GREEN}[init-dev]${NC} 项目根目录: $PROJECT_ROOT"

# Step 1: 检查并安装依赖
echo -e "${GREEN}[Step 1]${NC} 检查项目依赖 ..."
if [[ -f "package.json" ]]; then
  if [[ ! -d "node_modules" ]]; then
    echo -e "${YELLOW}安装 npm 依赖 ...${NC}"
    $INSTALL_CMD
  else
    echo -e "${GREEN}依赖已安装${NC}"
  fi
elif [[ -f "requirements.txt" ]]; then
  if ! pip list 2>/dev/null | grep -q "$(head -1 requirements.txt | cut -d= -f1)" 2>/dev/null; then
    echo -e "${YELLOW}安装 Python 依赖 ...${NC}"
    pip install -r requirements.txt
  else
    echo -e "${GREEN}依赖已安装${NC}"
  fi
elif [[ -f "go.mod" ]]; then
  echo -e "${YELLOW}安装 Go 依赖 ...${NC}"
  go mod download
else
  echo -e "${YELLOW}未检测到已知的依赖管理文件${NC}"
fi

# Step 2: 检查开发服务器是否已运行
echo -e "${GREEN}[Step 2]${NC} 检查开发服务器 ..."
if [[ -f "$PID_FILE" ]]; then
  OLD_PID=$(cat "$PID_FILE")
  if kill -0 "$OLD_PID" 2>/dev/null; then
    echo -e "${GREEN}开发服务器已在运行 (PID: $OLD_PID)${NC}"
    exit 0
  else
    echo -e "${YELLOW}清理过期 PID 文件${NC}"
    rm -f "$PID_FILE"
  fi
fi

# Step 3: 启动开发服务器
echo -e "${GREEN}[Step 3]${NC} 启动开发服务器 ..."
nohup $DEV_CMD > /tmp/dev-server.log 2>&1 &
DEV_PID=$!
echo "$DEV_PID" > "$PID_FILE"
echo -e "${GREEN}开发服务器已启动 (PID: $DEV_PID)${NC}"

# Step 4: 健康检查
echo -e "${GREEN}[Step 4]${NC} 等待服务器就绪 ..."
WAITED=0
while [[ $WAITED -lt $MAX_WAIT ]]; do
  if curl -s -o /dev/null -w "%{http_code}" "$HEALTH_CHECK_URL" 2>/dev/null | grep -q "200\|301\|302"; then
    echo -e "${GREEN}服务器就绪! ${HEALTH_CHECK_URL}${NC}"
    exit 0
  fi
  sleep 1
  WAITED=$((WAITED + 1))
  echo -ne "\r  等待中 ... ${WAITED}s / ${MAX_WAIT}s"
done

echo ""
echo -e "${RED}警告: 服务器在 ${MAX_WAIT}s 内未就绪${NC}"
echo -e "${YELLOW}请检查日志: tail -f /tmp/dev-server.log${NC}"
exit 1

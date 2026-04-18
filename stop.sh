#!/bin/bash
# ============================================================
#  DDI 管理系统 - 停止脚本
#  用法: ./stop.sh [-k|--kill]
#    -k, --kill  - 强制杀死进程 (SIGKILL)
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PID_FILE="$SCRIPT_DIR/ddi.pid"
APP_NAME="ddi_system"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FORCE_KILL=false
if [ "$1" = "-k" ] || [ "$1" = "--kill" ]; then
    FORCE_KILL=true
fi

stop_by_pid() {
    local pid=$1
    echo -e "${YELLOW}[停止] 正在终止进程 (PID: $pid)...${NC}"

    if [ "$FORCE_KILL" = true ]; then
        kill -9 "$pid" 2>/dev/null
    else
        kill "$pid" 2>/dev/null
    fi

    # 等待进程退出
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        if [ $i -ge 10 ]; then
            echo -e "${RED}[警告] 进程未响应，正在强制终止...${NC}"
            kill -9 "$pid" 2>/dev/null
            break
        fi
        sleep 1
        i=$((i + 1))
    done

    rm -f "$PID_FILE"
    echo -e "${GREEN}[成功] 服务已停止${NC}"
}

stop_by_name() {
    echo -e "${YELLOW}[停止] 通过进程名查找并终止...${NC}"

    # 查找 gunicorn 或 manage.py runserver 进程
    PIDS=$(pgrep -f "gunicorn.*ddi_system.wsgi" 2>/dev/null || true)

    if [ -z "$PIDS" ]; then
        # 尝试查找开发服务器
        PIDS=$(pgrep -f "manage.py.*runserver.*8000" 2>/dev/null || true)
    fi

    if [ -z "$PIDS" ]; then
        echo -e "${YELLOW}[信息] 未找到运行中的服务${NC}"
        return 0
    fi

    for pid in $PIDS; do
        if [ "$FORCE_KILL" = true ]; then
            kill -9 "$pid" 2>/dev/null
        else
            kill "$pid" 2>/dev/null
        fi
        echo -e "  已发送信号 -> PID: $pid"
    done

    # 杀死整个进程组（gunicorn master + workers）
    if [ "$FORCE_KILL" = false ]; then
        pkill -f "gunicorn.*ddi_system.wsgi" 2>/dev/null || true
    else
        pkill -9 -f "gunicorn.*ddi_system.wsgi" 2>/dev/null || true
    fi

    rm -f "$PID_FILE"
    echo -e "${GREEN}[成功] 服务已停止${NC}"
}

# 主逻辑
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   DDI 管理系统 - 停止服务${NC}"
echo -e "${GREEN}============================================${NC}"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        stop_by_pid "$PID"
    else
        echo -e "${YELLOW}[警告] PID 文件存在但进程不存在 (PID: $PID)，清理后按名称查找...${NC}"
        rm -f "$PID_FILE"
        stop_by_name
    fi
else
    stop_by_name
fi

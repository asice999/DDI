#!/bin/bash
# ============================================================
#  DDI 管理系统 - 启动脚本
#  用法: ./start.sh [dev|prod]
#    dev   - 开发模式 (Django runserver, 默认)
#    prod  - 生产模式 (Gunicorn)
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="ddi_system"
PID_FILE="$SCRIPT_DIR/ddi.pid"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/gunicorn.log"
HOST="0.0.0.0"
PORT="8000"
WORKERS=4

MODE="${1:-dev}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检查是否已运行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo -e "${RED}[错误] 应用已在运行 (PID: $OLD_PID)，请先执行 ./stop.sh 停止${NC}"
        exit 1
    else
        echo -e "${YELLOW}[警告] 发现残留 PID 文件，正在清理...${NC}"
        rm -f "$PID_FILE"
    fi
fi

# 检查虚拟环境
if [ -d "venv" ]; then
    echo -e "${CYAN}[信息] 检测到虚拟环境，正在激活...${NC}"
    source venv/bin/activate
elif [ -d ".venv" ]; then
    echo -e "${CYAN}[信息] 检测到虚拟环境，正在激活...${NC}"
    source .venv/bin/activate
fi

# 执行数据库迁移（可选，安全起见）
echo -e "${CYAN}[信息] 检查数据库迁移...${NC}"
python manage.py migrate --run-syncdb 2>/dev/null || true

case "$MODE" in
    dev)
        echo ""
        echo -e "${GREEN}============================================${NC}"
        echo -e "${GREEN}   DDI 管理系统 - 开发模式启动${NC}"
        echo -e "${GREEN}============================================${NC}"
        echo -e "  地址: ${CYAN}http://${HOST}:${PORT}${NC}"
        echo -e "  模式: ${YELLOW}Django Development Server${NC}"
        echo -e "  日志: ${CYAN}控制台输出${NC}"
        echo -e "${GREEN}============================================${NC}"
        echo -e "  按 ${YELLOW}Ctrl+C${NC} 停止服务"
        echo ""

        # 开发模式：前台运行，方便调试
        python manage.py runserver ${HOST}:${PORT}
        ;;

    prod)
        # 创建日志目录
        mkdir -p "$LOG_DIR"

        echo ""
        echo -e "${GREEN}============================================${NC}"
        echo -e "${GREEN}   DDI 管理系统 - 生产模式启动${NC}"
        echo -e "${GREEN}============================================${NC}"
        echo -e "  地址: ${CYAN}http://${HOST}:${PORT}${NC}"
        echo -e "  模式: ${YELLOW}Gunicorn (${WORKERS} workers)${NC}"
        echo -e "  日志: ${CYAN}$LOG_FILE${NC}"
        echo -e "  PID:  ${CYAN}$PID_FILE${NC}"
        echo -e "${GREEN}============================================${NC}"
        echo -e "  执行 ${YELLOW}./stop.sh${NC} 停止服务"
        echo ""

        # 生产模式：后台运行 Gunicorn
        exec gunicorn \
            --bind ${HOST}:${PORT} \
            --workers $WORKERS \
            --worker-class gthread \
            --threads 4 \
            --timeout 120 \
            --keep-alive 5 \
            --max-requests 1000 \
            --max-requests-jitter 50 \
            --access-logfile "$LOG_FILE" \
            --error-logfile "$LOG_FILE" \
            --pid "$PID_FILE" \
            --daemon \
            ddi_system.wsgi:application

        sleep 1

        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                echo -e "${GREEN}[成功] 服务已启动 (PID: $PID)${NC}"
                echo -e "${CYAN}[提示] 查看日志: tail -f $LOG_FILE${NC}"
            else
                echo -e "${RED}[错误] 服务启动失败，请检查日志: $LOG_FILE${NC}"
                exit 1
            fi
        else
            echo -e "${RED}[错误] PID 文件未生成，启动可能失败${NC}"
            exit 1
        fi
        ;;

    *)
        echo -e "${RED}用法: $0 [dev|prod]${NC}"
        echo -e "  ${CYAN}dev${NC}  - 开发模式 (默认, Django runserver)"
        echo -e "  ${CYAN}prod${NC} - 生产模式 (Gunicorn 后台运行)"
        exit 1
        ;;
esac

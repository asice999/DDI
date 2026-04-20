#!/bin/sh
set -e

# 等待数据库（本例使用SQLite，无需等待）
# 执行迁移
python manage.py makemigrations --noinput
python manage.py migrate --noinput

# 初始化数据（若init_data.py存在）
if [ -f init_data.py ]; then
    python init_data.py
fi

# 启动 Gunicorn
exec gunicorn ddi_system.wsgi:application --bind 0.0.0.0:8000 --workers 4

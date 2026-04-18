"""仪表盘模块 - URL路由配置"""

from django.urls import path
from .views import index

app_name = 'dashboard'

urlpatterns = [
    path('', index, name='index'),  # 首页仪表盘
]

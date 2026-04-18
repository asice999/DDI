"""审计日志模块 - URL路由配置"""

from django.urls import path
from .views import OperationLogListView

app_name = 'logs'

urlpatterns = [
    path('', OperationLogListView.as_view(), name='operation_log'),  # 操作日志列表
]

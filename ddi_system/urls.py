"""
DDI管理系统 - 根URL配置
将各业务模块的URL分发到对应的子路由
"""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),          # Django管理后台
    path('accounts/', include('accounts.urls')),  # 账户管理
    path('dashboard/', include('dashboard.urls')),  # 仪表盘
    path('ipam/', include('ipam.urls')),      # IP地址管理
    path('dns/', include('dnsmgr.urls')),     # DNS管理
    path('dhcp/', include('dhcpmgr.urls')),   # DHCP管理
    path('devices/', include('devices.urls')),  # 设备管理
    path('logs/', include('logs.urls')),       # 审计日志
    path('', include('dashboard.urls')),       # 首页（根路径跳转仪表盘）
]

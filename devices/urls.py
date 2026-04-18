"""设备管理模块 - URL路由配置"""

from django.urls import path
from .views import (
    DeviceListView, DeviceDetailView, DeviceCreateView, DeviceUpdateView, DeviceDeleteView,
    link_device_to_ip
)

app_name = 'devices'

urlpatterns = [
    path('', DeviceListView.as_view(), name='device_list'),              # 设备列表
    path('create/', DeviceCreateView.as_view(), name='device_create'),   # 创建设备
    path('<int:pk>/', DeviceDetailView.as_view(), name='device_detail'), # 设备详情
    path('<int:pk>/edit/', DeviceUpdateView.as_view(), name='device_edit'),   # 编辑设备
    path('<int:pk>/delete/', DeviceDeleteView.as_view(), name='device_delete'), # 删除设备
    path('<int:device_pk>/link-ip/<int:ip_pk>/', link_device_to_ip, name='link_ip'),  # 关联IP
]

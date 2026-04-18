"""账户管理模块 - URL路由配置"""

from django.urls import path
from .views import (
    login_view, logout_view,
    UserListView, UserCreateView, UserUpdateView, UserDeleteView,
    RoleListView, LoginLogListView, reset_password
)

app_name = 'accounts'

urlpatterns = [
    path('login/', login_view, name='login'),           # 登录页
    path('logout/', logout_view, name='logout'),         # 登出
    path('users/', UserListView.as_view(), name='user_list'),  # 用户列表
    path('users/create/', UserCreateView.as_view(), name='user_create'),  # 创建用户
    path('users/<int:pk>/edit/', UserUpdateView.as_view(), name='user_edit'),  # 编辑用户
    path('users/<int:pk>/delete/', UserDeleteView.as_view(), name='user_delete'),  # 删除用户
    path('users/<int:pk>/reset-password/', reset_password, name='reset_password'),  # 重置密码
    path('roles/', RoleListView.as_view(), name='role_list'),  # 角色列表
    path('login-log/', LoginLogListView.as_view(), name='login_log'),  # 登录日志
]

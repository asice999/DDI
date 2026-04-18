"""
公共日志工具 - 操作日志记录
提供 log_operation 函数，被各模块调用以记录用户操作审计日志
"""

import logging
from django.contrib.auth import get_user_model

logger = logging.getLogger(__name__)
User = get_user_model()


def log_operation(user, operation_type, module, obj_type, old_value='', new_value=''):
    """
    记录操作日志 - 全局审计入口，各模块调用此函数记录操作
    
    Args:
        user: 操作用户对象
        operation_type: 操作类型 (新增/修改/删除/导入/导出/登录/退出/分配/释放/标记/关联/重置密码等)
        module: 操作模块 (ipam/dns/dhcp/devices/accounts/IPAM-探测等)
        obj_type: 操作对象类型 (region/vlan/subnet/ip/zone/record/service/user等)
        old_value: 变更前内容（用于审计对比）
        new_value: 变更后内容（用于审计对比）
    """
    try:
        from logs.models import OperationLog
        OperationLog.objects.create(
            user=user,
            module=module,
            action=operation_type,
            object_type=obj_type,
            old_value=old_value[:1000] if old_value else '',  # 截断防止超长
            new_value=new_value[:1000] if new_value else '',  # 截断防止超长
            ip_address=''  # 可通过middleware设置客户端IP
        )
    except Exception as e:
        logger.error(f"记录操作日志失败: {e}")

#!/bin/bash
# ------------------------------------------------------------
# 删除审计用户脚本
# 作者：Pony
# 用途：安全删除审计用户及相关配置
# ------------------------------------------------------------

# 输入要删除的用户名
read -p "请输入要删除的审计用户名: " AUDIT_USER

# 1️⃣ 检查用户是否存在
if ! id "$AUDIT_USER" &>/dev/null; then
    echo "用户 $AUDIT_USER 不存在。"
    exit 1
fi

# 2️⃣ 检查用户是否有正在运行的进程
USER_PROCESSES=$(pgrep -u "$AUDIT_USER")
if [ -n "$USER_PROCESSES" ]; then
    echo "⚠️ 用户 $AUDIT_USER 有正在运行的进程:"
    ps -u "$AUDIT_USER"
    read -p "是否终止这些进程并继续删除用户？(y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" ]]; then
        echo "已取消删除操作。"
        exit 1
    fi
    sudo pkill -u "$AUDIT_USER"
    echo "已终止 $AUDIT_USER 的所有进程。"
fi

# 3️⃣ 删除 sudo 权限文件（如果存在）
SUDOERS_FILE="/etc/sudoers.d/$AUDIT_USER"
if [ -f "$SUDOERS_FILE" ]; then
    rm -f "$SUDOERS_FILE"
    echo "已删除 sudo 权限文件: $SUDOERS_FILE"
fi

# 4️⃣ 删除用户及家目录
userdel -r "$AUDIT_USER"
if [ $? -eq 0 ]; then
    echo "✅ 用户 $AUDIT_USER 已成功删除，家目录已清理。"
else
    echo "❌ 删除用户 $AUDIT_USER 失败，请检查权限。"
fi

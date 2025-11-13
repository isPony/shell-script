#!/bin/bash

TARGET_TZ="Asia/Hong_Kong"

echo "当前时区检查中..."

# 获取当前时区
if command -v timedatectl >/dev/null 2>&1; then
    CURRENT_TZ=$(timedatectl | grep "Time zone" | awk '{print $3}')
else
    # 备用方式（没有 timedatectl 的旧系统）
    CURRENT_TZ=$(readlink /etc/localtime | sed 's|/usr/share/zoneinfo/||')
fi

echo "当前时区: $CURRENT_TZ"

# 判断是否需要修改
if [ "$CURRENT_TZ" = "$TARGET_TZ" ]; then
    echo "当前已经是香港时区（$TARGET_TZ），无需修改。"
    exit 0
fi

echo "正在切换时区为: $TARGET_TZ"

# 修改方式 1：使用 timedatectl
if command -v timedatectl >/dev/null 2>&1; then
    sudo timedatectl set-timezone "$TARGET_TZ"
else
    # 修改方式 2：软链接到 zoneinfo
    sudo ln -sf "/usr/share/zoneinfo/$TARGET_TZ" /etc/localtime
    echo "$TARGET_TZ" | sudo tee /etc/timezone >/dev/null 2>&1
fi

echo "时区已更新为:"
timedatectl 2>/dev/null || date

exit 0

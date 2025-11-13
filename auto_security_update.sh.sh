#!/bin/bash
#
# 通用 Linux 安全更新脚本
# 兼容 CentOS / RHEL / AlmaLinux / Rocky / Ubuntu / Debian / Amazon Linux / Aliyun Linux
# 日志文件：/var/log/security_update.log

LOG_FILE="/var/log/security_update.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

echo "[$DATE] ===== Starting security update =====" | tee -a $LOG_FILE

# 检测发行版
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "无法识别系统类型。" | tee -a $LOG_FILE
    exit 1
fi

# 执行更新逻辑
case "$DISTRO" in
    centos|rhel|almalinux|rocky|fedora|alinux)
        if command -v dnf >/dev/null 2>&1; then
            echo "[$DATE] Detected DNF-based system: $DISTRO" | tee -a $LOG_FILE
            dnf makecache -y >> $LOG_FILE 2>&1
            dnf upgrade-minimal --security -y >> $LOG_FILE 2>&1
        elif command -v yum >/dev/null 2>&1; then
            echo "[$DATE] Detected YUM-based system: $DISTRO" | tee -a $LOG_FILE
            yum makecache fast -y >> $LOG_FILE 2>&1
            yum update-minimal --security -y >> $LOG_FILE 2>&1
        else
            echo "[$DATE] 未检测到 yum/dnf。" | tee -a $LOG_FILE
            exit 1
        fi
        ;;
    amzn)
        echo "[$DATE] Detected Amazon Linux" | tee -a $LOG_FILE
        yum update-minimal --security -y >> $LOG_FILE 2>&1
        ;;
    ubuntu|debian)
        echo "[$DATE] Detected Debian/Ubuntu system" | tee -a $LOG_FILE
        apt update -y >> $LOG_FILE 2>&1
        # 仅更新安全补丁
        SEC_UPDATES=$(apt list --upgradable 2>/dev/null | grep security | cut -d/ -f1)
        if [ -n "$SEC_UPDATES" ]; then
            apt install --only-upgrade -y $SEC_UPDATES >> $LOG_FILE 2>&1
        else
            echo "[$DATE] No security updates available." | tee -a $LOG_FILE
        fi
        ;;
    *)
        echo "[$DATE] Unsupported system: $DISTRO" | tee -a $LOG_FILE
        exit 1
        ;;
esac

echo "[$DATE] ===== Security update completed =====" | tee -a $LOG_FILE

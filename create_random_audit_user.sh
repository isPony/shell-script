#!/bin/bash
# ------------------------------------------------------------
# 自动创建随机审计账户（只读权限）
# 作者：Pony
# 用途：PCI DSS 审计
# ------------------------------------------------------------

# 1️⃣ 生成随机用户名（audit + 4位随机数）
RANDOM_SUFFIX=$((RANDOM % 10000))
AUDIT_USER="audit$RANDOM_SUFFIX"

# 2️⃣ 生成随机强密码（12位）
AUDIT_PASS=$(openssl rand -base64 12 | tr -d /=+ | cut -c1-12)

echo "=== 创建审计用户 ==="
echo "用户名: $AUDIT_USER"
echo "密码: $AUDIT_PASS"

# 3️⃣ 创建用户并设置密码
useradd -m -s /bin/bash "$AUDIT_USER"
echo "$AUDIT_USER:$AUDIT_PASS" | chpasswd

# 4️⃣ 创建 SSH 目录并设置权限
SSH_DIR="/home/$AUDIT_USER/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
chown -R "$AUDIT_USER:$AUDIT_USER" "$SSH_DIR"

echo "如果有 SSH 公钥，可以添加到 $AUTHORIZED_KEYS"

# 5️⃣ 配置只读 sudo 权限
SUDOERS_FILE="/etc/sudoers.d/$AUDIT_USER"
cat > "$SUDOERS_FILE" <<EOF
$AUDIT_USER ALL=(ALL) NOPASSWD: /bin/cat, /bin/ls, /usr/bin/grep, /usr/bin/journalctl, /usr/bin/tail, /usr/bin/less
EOF
chmod 440 "$SUDOERS_FILE"

# 6️⃣ 启用命令历史带时间戳
if ! grep -q "HISTTIMEFORMAT" /etc/profile; then
    echo 'export HISTTIMEFORMAT="%F %T "' >> /etc/profile
fi

# 7️⃣ SSH 配置：允许新用户登录，保留 root
SSHD_CONFIG="/etc/ssh/sshd_config"
cp "$SSHD_CONFIG" "$SSHD_CONFIG.bak.$(date +%F_%T)"

if ! grep -q "^AllowUsers" "$SSHD_CONFIG"; then
    echo "AllowUsers root $AUDIT_USER" >> "$SSHD_CONFIG"
else
    sed -i "s/^AllowUsers.*/& $AUDIT_USER/" "$SSHD_CONFIG"
fi

systemctl restart sshd

# 8️⃣ 输出结果
echo "✅ 审计账户创建成功！"
echo "用户名: $AUDIT_USER"
echo "密码: $AUDIT_PASS"
echo "SSH 公钥文件: $AUTHORIZED_KEYS"
echo "只读 sudo 权限文件: $SUDOERS_FILE"

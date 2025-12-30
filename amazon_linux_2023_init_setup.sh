#!/bin/bash
set -e

# ------------------------------
# 1. 设置时区为香港
# ------------------------------
current_tz=$(timedatectl show -p Timezone --value)
echo "当前时区: $current_tz"

if [ "$current_tz" != "Asia/Hong_Kong" ]; then
    echo "设置时区为 Hong Kong..."
    sudo timedatectl set-timezone Asia/Hong_Kong
    echo "时区已设置为: $(timedatectl show -p Timezone --value)"
else
    echo "时区已是 Hong Kong，无需修改"
fi

# ------------------------------
# 2. 安装 Docker
# ------------------------------
echo "更新系统并安装 Docker..."
sudo dnf -y update

# 安装必要工具
sudo dnf -y install dnf-utils

# 添加 Docker 官方仓库
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装 Docker CE
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 启动并设置开机自启
sudo systemctl enable --now docker

# 验证安装
docker_version=$(docker --version)
echo "Docker 已安装: $docker_version"

# ------------------------------
# 3. 创建 Docker 挂载目录
# ------------------------------
DOCKER_MOUNT_DIR="/root/documents/docker"
echo "创建 Docker 挂载目录: $DOCKER_MOUNT_DIR"
sudo mkdir -p $DOCKER_MOUNT_DIR
sudo chown root:root $DOCKER_MOUNT_DIR
echo "目录创建完成: $DOCKER_MOUNT_DIR"

echo "初始化设置完成！"

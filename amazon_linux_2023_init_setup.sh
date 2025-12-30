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
# 2. 安装 Docker（使用 Amazon Linux 2023 推荐方式）
# ------------------------------
echo "更新系统程序包..."
sudo yum update -y

echo "安装 Docker..."
sudo yum install -y docker

echo "启动 Docker 服务..."
sudo service docker start

echo "将 ec2-user 添加到 docker 组..."
sudo usermod -a -G docker ec2-user

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

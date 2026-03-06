#!/bin/bash
set -e

echo "==== 更新系统 ===="
sudo dnf update -y

echo "==== 安装必要工具（跳过 curl 冲突） ===="
sudo dnf install -y git tar

echo "==== 卸载旧 Docker（如果有） ===="
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || true

echo "==== 安装 Amazon Linux 官方 Docker ===="
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker

echo "==== 验证 Docker 和 Compose ===="
docker version
docker compose version

echo "==== 安装最新 buildx ===="
sudo mkdir -p /usr/lib/docker/cli-plugins
sudo curl -L https://github.com/docker/buildx/releases/download/v0.32.1/buildx-v0.32.1.linux-amd64 \
    -o /usr/lib/docker/cli-plugins/docker-buildx
sudo chmod +x /usr/lib/docker/cli-plugins/docker-buildx
sudo systemctl restart docker

echo "==== 验证 buildx ===="
docker buildx version

echo "==== 克隆 Sentry self-hosted 仓库 ===="
cd ~
git clone https://github.com/getsentry/self-hosted.git
cd self-hosted

echo "==== 运行 Sentry 安装脚本 ===="
./install.sh

echo "==== 启动 Sentry ===="
docker compose up -d

echo "==== 部署完成 ===="
echo "访问 Sentry Web 界面: http://<你的服务器IP>:9000"
echo "第一次运行会要求你创建管理员账号"
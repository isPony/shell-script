#!/bin/bash
# ------------------------------------------------------------------
# OWASP Dependency-Check Docker 扫描脚本
# 扫描目录：~/Documents/docker/dependency-check/src
# 报告目录：~/Documents/docker/dependency-check/report
# 缓存目录：~/Documents/docker/dependency-check/data
# ------------------------------------------------------------------

# 设置宿主机路径
BASE_DIR=~/Documents/docker/dependency-check
SRC_DIR=$BASE_DIR/src
REPORT_DIR=$BASE_DIR/report
DATA_DIR=$BASE_DIR/data

# 创建目录（如果不存在）
mkdir -p "$SRC_DIR"
mkdir -p "$REPORT_DIR"
mkdir -p "$DATA_DIR"

# Docker 镜像
IMAGE=owasp/dependency-check:latest

# 检查 Docker 镜像是否存在，如果不存在拉取
if ! docker image inspect $IMAGE >/dev/null 2>&1; then
    echo "[INFO] 拉取 Docker 镜像 $IMAGE ..."
    docker pull $IMAGE
fi

# 扫描命令
echo "[INFO] 开始扫描 JAR / 文件夹..."
docker run --rm \
    -v "$SRC_DIR":/src \
    -v "$REPORT_DIR":/report \
    -v "$DATA_DIR":/usr/share/dependency-check/data \
    $IMAGE \
    --updateonly

docker run --rm \
    -v "$SRC_DIR":/src \
    -v "$REPORT_DIR":/report \
    -v "$DATA_DIR":/usr/share/dependency-check/data \
    $IMAGE \
    --scan /src \
    --format ALL \
    --out /report

echo "[INFO] 扫描完成，报告生成在：$REPORT_DIR"
echo "  HTML: $REPORT_DIR/dependency-check-report.html"
echo "  JSON: $REPORT_DIR/dependency-check-report.json"
echo "  XML:  $REPORT_DIR/dependency-check-report.xml"

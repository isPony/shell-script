#!/bin/bash
# ------------------------------------------------------------------
# OWASP Dependency-Check Docker 扫描脚本（已支持 NVD API Key）
#
# 扫描目录：~/Documents/docker/dependency-check/src
# 报告目录：~/Documents/docker/dependency-check/report
# 缓存目录：~/Documents/docker/dependency-check/data
# ------------------------------------------------------------------

set -e

# =========================
# 基础配置
# =========================
BASE_DIR=~/Documents/docker/dependency-check
SRC_DIR="$BASE_DIR/src"
REPORT_DIR="$BASE_DIR/report"
DATA_DIR="$BASE_DIR/data"

# Docker 镜像
IMAGE="owasp/dependency-check:latest"

# ⚠️ 必填：NVD API Key
NVD_API_KEY="3c3e4919-86b6-41ec-96ca-73cb8a20aeff"

# =========================
# 目录准备
# =========================
mkdir -p "$SRC_DIR" "$REPORT_DIR" "$DATA_DIR"

# =========================
# 镜像检查
# =========================
if ! docker image inspect $IMAGE >/dev/null 2>&1; then
  echo "[INFO] Docker 镜像不存在，正在拉取 $IMAGE ..."
  docker pull $IMAGE
fi

# =========================
# 更新漏洞库
# =========================
echo "[INFO] 更新 NVD 漏洞库（使用 API Key）..."
docker run --rm \
  -v "$DATA_DIR":/usr/share/dependency-check/data \
  $IMAGE \
  --updateonly \
  --nvdApiKey "$NVD_API_KEY"

# =========================
# 执行扫描
# =========================
echo "[INFO] 开始扫描 $SRC_DIR ..."
docker run --rm \
  -v "$SRC_DIR":/src \
  -v "$REPORT_DIR":/report \
  -v "$DATA_DIR":/usr/share/dependency-check/data \
  $IMAGE \
  --scan /src \
  # --format ALL \
  --format HTML \
  --out /report \
  --project "dependency-check-docker-scan" \
  --nvdApiKey "$NVD_API_KEY"

# =========================
# 完成提示
# =========================
echo "[INFO] 扫描完成 ✅"
echo "报告目录：$REPORT_DIR"
echo " - HTML: dependency-check-report.html"
# echo " - JSON: dependency-check-report.json"
# echo " - XML : dependency-check-report.xml"

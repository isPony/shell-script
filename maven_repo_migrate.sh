#!/bin/bash
# ============================================
# 云效 Maven 仓库迁移脚本（macOS 版）
# 自动生成 artifacts.csv 并迁移
# 兼容非 Nexus API
# ============================================

set -e

SRC_REPO_URL="https://packages.aliyun.com/62df57581a358b4399af7d62/maven/2257597-release-xz5cbh"
SRC_USERNAME="62df5556b6715a75405564e2"
SRC_PASSWORD="Ev)Wejeq)[no"

DST_REPO_URL="https://packages.aliyun.com/68f5e557e6c3e0425dbd10e4/maven/2605549-release-xoslms"
DST_USERNAME="68f5e4d161f5dcc420b126a2"
DST_PASSWORD="Yf2CcQ]cFN1U"


CSV_FILE="artifacts.csv"

# --------------------------------------------
# 1. 自动生成 artifacts.csv
# --------------------------------------------
echo "🔍 正在扫描源仓库中的制品..."

# 获取源仓库的索引页（目录结构）
# 注意：如果仓库开启了目录索引，下面命令可用
# 否则你需要提供 artifact 列表（或者从本地构建机器上扫描）
curl -u "${SRC_USERNAME}:${SRC_PASSWORD}" -s "${SRC_REPO_URL}" > repo_index.html

# 从 HTML 提取所有 .jar 下载链接
grep -Eo 'href="[^"]+\.jar"' repo_index.html | sed 's/href="//;s/"//' > jar_list.txt

if [ ! -s jar_list.txt ]; then
  echo "❌ 没有在仓库索引中找到 .jar 文件，请检查仓库 URL 或权限。"
  exit 1
fi

# 生成 CSV
echo "groupId,artifactId,version,download_url" > "${CSV_FILE}"
while read -r url; do
  filename=$(basename "$url")
  artifactId=$(echo "$filename" | cut -d'-' -f1)
  version=$(echo "$filename" | cut -d'-' -f2 | sed 's/.jar//')
  echo ",${artifactId},${version},${SRC_REPO_URL}${url}" >> "${CSV_FILE}"
done < jar_list.txt

echo "✅ 已生成 ${CSV_FILE} ($(wc -l < ${CSV_FILE}) 行)"
echo "--------------------------------------------"

# --------------------------------------------
# 2. 迁移 JAR 文件
# --------------------------------------------
echo "🚀 开始迁移制品..."

tail -n +2 "${CSV_FILE}" | while IFS=',' read -r group artifact version url; do
  file_name="${artifact}-${version}.jar"

  echo "⬇️  下载 ${artifact}:${version}"
  curl -u "${SRC_USERNAME}:${SRC_PASSWORD}" -s -L -o "${file_name}" "${url}"

  echo "⬆️  上传到目标仓库..."
  curl -u "${DST_USERNAME}:${DST_PASSWORD}" \
       -T "${file_name}" \
       "${DST_REPO_URL}${artifact}/${version}/${file_name}"

  echo "✅ 已迁移 ${artifact}-${version}"
  rm -f "${file_name}"
  echo "--------------------------------------------"
done

echo "🎉 所有制品迁移完成！"

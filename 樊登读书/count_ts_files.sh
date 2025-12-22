#!/bin/bash

# 定义主目录
MAIN_DIR="./"

# 检查主目录是否存在
if [ ! -d "$MAIN_DIR" ]; then
    echo "主目录 '$MAIN_DIR' 不存在，请检查后再运行脚本。"
    exit 1
fi

# 遍历当前目录下的所有子目录
for SUBDIR in "$MAIN_DIR"/*; do
    # 检查是否为目录
    if [ -d "$SUBDIR" ]; then
        # 检查是否存在名为 "视频" 的子文件夹
        VIDEO_DIR="$SUBDIR/视频"
        if [ -d "$VIDEO_DIR" ]; then
            # 统计 .ts 文件数量
            TS_COUNT=$(find "$VIDEO_DIR" -maxdepth 1 -type f -name "*.ts" | wc -l)
            # 提取文件夹名称
            FOLDER_NAME=$(basename "$SUBDIR")
            # 打印结果
            echo "$FOLDER_NAME-$TS_COUNT"
        fi
    fi
done
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
            echo "找到 '视频' 文件夹: $VIDEO_DIR"

            # 创建一个临时文件列表
            FILE_LIST="$VIDEO_DIR/file_list.txt"
            > "$FILE_LIST"  # 清空文件列表

            # 查找 '视频' 文件夹中的 .ts 文件
            for TS_FILE in "$VIDEO_DIR"/*.ts; do
                if [ -f "$TS_FILE" ]; then
                    # 使用 realpath 获取文件的绝对路径，并正确处理特殊字符
                    ABS_PATH=$(realpath "$TS_FILE")
                    echo "file '$ABS_PATH'" >> "$FILE_LIST"
                fi
            done

            # 检查是否有 .ts 文件
            if [ ! -s "$FILE_LIST" ]; then
                echo "未找到 .ts 文件，跳过: $VIDEO_DIR"
                rm -f "$FILE_LIST"
                continue
            fi

            # 定义输出文件名为 "视频.mp4"
            OUTPUT_FILE="$VIDEO_DIR/视频.mp4"

            # 合并并转换为 MP4
            echo "开始合并 .ts 文件到 MP4: $OUTPUT_FILE"
            ffmpeg -f concat -safe 0 -i "$FILE_LIST" -c:v libx264 -c:a aac -strict experimental "$OUTPUT_FILE" -y

            # 检查结果
            if [ $? -eq 0 ]; then
                echo "合并完成: $OUTPUT_FILE"

                # 移动视频.mp4 到上一层目录
                PARENT_DIR=$(dirname "$VIDEO_DIR")
                mv "$OUTPUT_FILE" "$PARENT_DIR/"
                echo "已将 '视频.mp4' 移动到: $PARENT_DIR"

                # 删除 "视频" 文件夹及其内容
                echo "正在删除 '视频/' 文件夹..."
                rm -rf "$VIDEO_DIR"
                echo "删除完成: $VIDEO_DIR"
            else
                echo "合并失败: $VIDEO_DIR"
            fi

            # 删除临时文件列表
            rm -f "$FILE_LIST"
        fi
    fi
done

echo "所有任务完成。"
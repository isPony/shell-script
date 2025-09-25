#!/bin/bash
# webp2jpg.sh - 将指定目录下的 webp 图片批量转换为 jpg

# 让用户输入目录路径
read -rp "请输入需要转换图片的目录路径: " target_dir

# 判断目录是否存在
if [ ! -d "$target_dir" ]; then
    echo "错误: 目录不存在: $target_dir"
    exit 1
fi

# 进入目标目录
cd "$target_dir" || exit 1

# 检查工具
if command -v convert >/dev/null 2>&1; then
    echo "使用 ImageMagick (convert) 进行转换..."
    for img in *.webp; do
        [ -e "$img" ] || continue
        out="${img%.webp}.jpg"
        echo "Converting $img -> $out"
        convert "$img" -background white -alpha remove -quality 90 "$out"
    done
elif command -v dwebp >/dev/null 2>&1; then
    echo "使用 dwebp 进行转换..."
    for img in *.webp; do
        [ -e "$img" ] || continue
        out="${img%.webp}.jpg"
        echo "Converting $img -> $out"
        dwebp "$img" -o "$out"
    done
else
    echo "错误: 需要安装 ImageMagick (convert) 或 libwebp (dwebp)"
    exit 1
fi

echo "转换完成！输出文件在目录: $target_dir"

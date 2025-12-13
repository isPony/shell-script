#!/bin/bash

# 批量创建并推送代码仓库
# 放在需要批量提交的目录下
# code/
# ├── batch_git_create_and_push_debug.sh
# ├── repo1
# ├── repo2

set -euo pipefail

CODE_DIR="."
GITHUB_ORG="HS-Homsom"
VISIBILITY="private"

echo "🔍 开始批量处理代码仓库..."

for dir in "$CODE_DIR"/*; do
  [ -d "$dir" ] || continue

  repo_name=$(basename "$dir")

  # 跳过脚本所在目录（保险）
  [ "$repo_name" = "." ] && continue

  echo
  echo "======================================"
  echo "📦 仓库: $repo_name"
  echo "======================================"

  if gh repo view "$GITHUB_ORG/$repo_name" >/dev/null 2>&1; then
    echo "✅ GitHub 仓库已存在"
  else
    echo "🚀 创建 GitHub 仓库..."
    gh repo create "$GITHUB_ORG/$repo_name" --$VISIBILITY --confirm
  fi

  cd "$dir"

  if [ ! -d ".git" ]; then
    echo "🔧 git init"
    git init
  fi

  if ! git remote | grep -q origin; then
    echo "🔗 添加 remote origin"
    git remote add origin git@github.com:${GITHUB_ORG}/${repo_name}.git
  fi

  if [ -z "$(git status --porcelain)" ]; then
    echo "⚠️ 没有可提交的文件，跳过"
    cd - >/dev/null
    continue
  fi

  git add .
  git commit -m "first commit"
  git branch -M main
  git push -u origin main

  echo "✅ 推送完成: $repo_name"

  cd - >/dev/null
done

echo
echo "🎉 所有仓库真实推送完成"

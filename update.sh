#!/bin/bash

# 检查是否设置了 GITHUB_TOKEN 环境变量
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: Please set the GITHUB_TOKEN environment variable with your GitHub personal access token."
  exit 1
fi

# GitHub 仓库和文件路径信息
REPO="MoeDove-LLC/Bird2-Config"
BRANCH="main"  # 你可以将 main 替换为实际分支名
FILES=("neighbor.conf" "predefined.conf")
DEST_DIR="/etc/bird/functions"

# 确保目标目录存在
mkdir -p "$DEST_DIR"

# 下载并替换文件
for FILE in "${FILES[@]}"; do
  echo "Downloading $FILE..."
  
  curl -H "Authorization: token $GITHUB_TOKEN" -L \
       "https://raw.githubusercontent.com/$REPO/$BRANCH/node/functions/$FILE" \
       -o "$DEST_DIR/$FILE"
  
  if [ $? -eq 0 ]; then
    echo "$FILE downloaded successfully and replaced in $DEST_DIR."
  else
    echo "Failed to download $FILE."
  fi
done

echo "All files processed."

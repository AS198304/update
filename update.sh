#!/bin/bash

# 检查是否设置了环境变量 GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
  echo "错误: 请先设置 GITHUB_TOKEN 环境变量。"
  echo "例如: export GITHUB_TOKEN=your_personal_access_token"
  exit 1
fi

# 设置 GitHub 仓库 URL
REPO_URL="https://github.com/your_username/your_private_repo.git"

# 提取用户名和仓库名
USERNAME=$(echo "$REPO_URL" | cut -d'/' -f4)
REPO_NAME=$(echo "$REPO_URL" | cut -d'/' -f5 | cut -d'.' -f1)

# 使用带有 Token 的 URL 克隆或更新仓库
AUTH_URL="https://$GITHUB_TOKEN@github.com/$USERNAME/$REPO_NAME.git"

if [ -d "$REPO_NAME" ]; then
  echo "仓库已存在，正在更新..."
  cd "$REPO_NAME" && git pull "$AUTH_URL"
else
  echo "仓库不存在，正在克隆..."
  git clone "$AUTH_URL"
fi

# 清除本地 URL 中的 Token（推荐）
cd "$REPO_NAME" || exit
if [ -d ".git" ]; then
  git remote set-url origin "$REPO_URL"
  echo "已将远程 URL 恢复为安全版本。"
else
  echo "错误：无法找到 .git 文件夹，远程 URL 未更改。"
fi

# 判断网络接口是否包含 vrf
if ip a | grep -q "vrf"; then
  TARGET_DIR="vrf_node"
else
  TARGET_DIR="node"
fi

# 设置源目录和目标目录
SRC_DIR="$REPO_NAME/$TARGET_DIR"
DEST_DIR="/etc/bird"

# 检查目录是否存在
if [ ! -d "$SRC_DIR" ]; then
  echo "错误：源目录 $SRC_DIR 不存在。"
  exit 1
fi

# 替换 functions/ 和 tools/
for folder in functions tools; do
  if [ -d "$SRC_DIR/$folder" ]; then
    rm -rf "$DEST_DIR/$folder"
    cp -r "$SRC_DIR/$folder" "$DEST_DIR/"
    echo "$folder 文件夹已更新。"
  else
    echo "警告：$SRC_DIR/$folder 不存在，跳过更新。"
  fi
done

# 替换 version.txt
if [ -f "$SRC_DIR/version.txt" ]; then
  cp "$SRC_DIR/version.txt" "$DEST_DIR/"
  echo "version.txt 已更新。"
else
  echo "警告：$SRC_DIR/version.txt 不存在，跳过更新。"
fi

# 更新 bird.conf 文件中的 include 部分
BIRD_CONF="$DEST_DIR/bird.conf"
SRC_BIRD_CONF="$SRC_DIR/bird.conf"

if [ -f "$SRC_BIRD_CONF" ] && [ -f "$BIRD_CONF" ]; then
  awk '/include/ {print $0; next} 1' "$SRC_BIRD_CONF" > /tmp/bird.conf.updated
  mv /tmp/bird.conf.updated "$BIRD_CONF"
  echo "bird.conf 已更新 include 部分。"
else
  echo "警告：bird.conf 更新失败，源或目标文件缺失。"
fi

# 提示完成
birdc c
echo "操作完成。"

#!/bin/bash

# 设置下载链接
download_url="https://codeload.github.com/MoeDove-LLC/Bird2-Config/zip/refs/tags/v1.5.0?token=BDJNIQDXHNVLDDSH6S2QL6TFWMDXS"

# 设置本地解压目录
extract_dir="Bird2-Config-1.5.0"

# 设置目标目录
target_dir="/etc/bird"

# 下载文件
wget $download_url -O bird2-config.zip

# 解压文件
unzip bird2-config.zip -d $extract_dir

# 复制文件到目标目录
cp -r $extract_dir/Bird2-Config-1.5.0/node/functions $target_dir
cp -r $extract_dir/Bird2-Config-1.5.0/node/tools $target_dir
cp $extract_dir/Bird2-Config-1.5.0/node/version.txt $target_dir
cp $extract_dir/Bird2-Config-1.5.0/node/bird.conf $target_dir

birdc c

# 清理临时文件
rm -rf bird2-config.zip $extract_dir

echo "脚本执行完成。"

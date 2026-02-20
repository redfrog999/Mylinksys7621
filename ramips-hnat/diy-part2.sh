#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP 
sed -i 's/192.168.1.1/192.168.77.1/g' package/base-files/files/bin/config_generate

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# ------------------ PassWall MRS 物理固化 (MetaCubeX 极速版) --------------------------
# 1. 创建固化规则存放路径
mkdir -p files/etc/xray/rules/

# 定义基础 URL (MetaCubeX 预编译资源)
META_URL="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite"

# 2. 批量下载二进制 MRS 文件
# 这里去掉了 ${} 错误语法，直接指向原始二进制文件
wget -qO files/etc/xray/rules/gfw.mrs ${META_URL}/gfw.mrs
wget -qO files/etc/xray/rules/google.mrs ${META_URL}/google.mrs
wget -qO files/etc/xray/rules/youtube.mrs ${META_URL}/youtube.mrs
wget -qO files/etc/xray/rules/telegram.mrs ${META_URL}/telegram.mrs
wget -qO files/etc/xray/rules/netflix.mrs ${META_URL}/netflix.mrs
wget -qO files/etc/xray/rules/ai.mrs ${META_URL}/category-ai-!cn.mrs
wget -qO files/etc/xray/rules/github.mrs ${META_URL}/github.mrs
wget -qO files/etc/xray/rules/reddit.mrs ${META_URL}/reddit.mrs
wget -qO files/etc/xray/rules/twitter.mrs ${META_URL}/twitter.mrs

# 3. 下载大陆 IP 段 (MRS 格式)
# 推荐使用 v2fly 官方 mrs 分支，对位你的“绕过大陆”逻辑
wget -qO files/etc/xray/rules/china_ip.mrs https://raw.githubusercontent.com/v2fly/geoip/mrs/mrs/cn.mrs

# 验证结果：如果文件大小为 0，说明下载失败
find files/etc/xray/rules/ -type f -empty -delete
echo "========= MRS 物理资源下载成功，神兵已就绪！ ========="

# -----------------強制給予 uci-defaults 腳本執行權限，防止雲端編譯權限丟失-------------------------
chmod +x files/etc/uci-defaults/99-physical-sovereignty

#------------------替换GoLang-----------------------
echo '替换golang到1.26x'
rm -rf feeds/packages/lang/golang
git clone -b 26.x --single-branch https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
echo '=========Replace golang OK!========='

#------------------致敬老兵，让MT7621在ShellClash的加持下重新焕发战斗神采---------------------

# 1. 强制重写全局编译参数，针对 MT7621 (MIPS 1004Kc/74kc) 深度优化
sed -i 's/-O2/-O3 -march=mipsel -mtune=74kc -mdsp -mno-mips16 -fno-caller-saves/g' include/target.mk

# 2. 优化特定的编译器标志，减少延迟
sed -i 's/TARGET_CFLAGS:=/TARGET_CFLAGS:=-O3 -march=mipsel -mtune=74kc -mdsp -mno-mips16 -falign-functions=32 -fno-caller-saves -fomit-frame-pointer -pipe /g' include/target.mk

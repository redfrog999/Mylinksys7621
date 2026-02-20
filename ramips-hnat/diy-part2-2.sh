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
sed -i 's/192.168.1.1/10.0.10.1/g' package/base-files/files/bin/config_generate

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# ------------------PassWall 重构MRS版--------------------------
# 1. 创建固化规则存放路径
mkdir -p files/etc/xray/rules/
# 2. 从可靠源下载预编译的二进制 MRS 文件 (这里以精简版为例)
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/gfw.mrs}/gfw.mrs -O files/etc/xray/rules/gfw.mrs
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/google.mrs}/google.mrs -O files/etc/xray/rules/google.mrs
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/youtube.mrs}/youtube.mrs -O files/etc/xray/rules/youtube.mrs
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/telegram.mrs}/telegram.mrs -O files/etc/xray/rules/telegram.mrs
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/netflix.mrs}/netflix.mrs -O files/etc/xray/rules/netflix.mrs
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-ai-!cn.mrs}/ai.mrs -O files/etc/xray/rules/ai.mrs
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/github.mrs}/github.mrs -O files/etc/xray/rules/github.mrs
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/reddit.mrs}/reddit.mrs -O files/etc/xray/rules/reddit.mrs
wget ${https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/twitter.mrs}/twitter.mrs -O files/etc/xray/rules/twitter.mrs
# 下载大陆 IP 段 (MRS 格式)
wget https://github.com/v2fly/geoip/releases/latest/download/cn.mrs -O files/etc/xray/rules/china_ip.mrs
wget https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/cn.mrs

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

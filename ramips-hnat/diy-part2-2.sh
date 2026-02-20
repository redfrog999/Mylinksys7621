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

# 修正 MIPS 下 Sing-Box 的编译环境变量
# 强制让编译工具链使用更稳定的指令集对齐
sed -i 's/GO_PKG_VARS:=/GO_PKG_VARS:=CGO_ENABLED=0 /g' feeds/passwall_packages/sing-box/Makefile

# ------------------ Passwall Sing-Box SRS 物理固化版 --------------------------
# 1. 创建 Sing-Box 专用规则路径
mkdir -p files/usr/share/sing-box/

# 定义 SRS 资源源 (SagerNet 官方规则集)
SRS_URL="https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set"
IP_URL="https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set"

# 2. 下载核心分流 SRS (对应你之前的 AI/Google/YouTube 需求)
for tag in google youtube microsoft telegram netflix github twitter reddit; do
    wget -qO files/usr/share/sing-box/geosite-${tag}.srs ${SRS_URL}/geosite-${tag}.srs
done

# 3. 下载专项：AI (OpenAI/Anthropic) 和 GFW
wget -qO files/usr/share/sing-box/geosite-openai.srs ${SRS_URL}/geosite-openai.srs
wget -qO files/usr/share/sing-box/geosite-gfw.srs ${SRS_URL}/geosite-gfw.srs

# 4. 下载中国 IP 段 SRS (用于分流大陆流量)
wget -qO files/usr/share/sing-box/geoip-cn.srs ${IP_URL}/geoip-cn.srs
wget -qO files/usr/share/sing-box/geosite-cn.srs ${SRS_URL}/geosite-cn.srs

# 验证结果：如果文件大小为 0，说明下载失败
find files/usr/share/sing-box/ -type f -empty -delete
echo "========= Sing-Box SRS 物理资源下载成功！ ========="

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

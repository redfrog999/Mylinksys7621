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

# ------------------PassWall 重构MRS版--------------------------
# 进入配置目录 (假定你在源码根目录)
mkdir -p files/etc/xray/rules/

# 1. 下载转译工具 (xray-core)
# 注意：我们用 x86_64 版本的 xray 来处理 rules
wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip -q Xray-linux-64.zip -d xray_tmp
chmod +x xray_tmp/xray

# 2. 获取原始数据源 (.dat)
wget https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
wget https://github.com/v2fly/domain-list-community/releases/latest/download/geosite.dat

# 3. 开始“锻造”：将重型 dat 拆解为轻量 mrs
# 导出中国 IP 段 (用于绕过大陆)
./xray_tmp/xray _v2dat unpack geoip -o files/etc/xray/rules/ -f cn geoip.dat
mv files/etc/xray/rules/geoip_cn.mrs files/etc/xray/rules/china_ip.mrs

# 导出 GFW 基础列表
./xray_tmp/xray _v2dat unpack geosite -o files/etc/xray/rules/ -f gfw geosite.dat
mv files/etc/xray/rules/geosite_gfw.mrs files/etc/xray/rules/gfw.mrs

# 导出你要求的 AI/视频 专项列表 (Google, YouTube, Telegram, Netflix)
for tag in google youtube telegram netflix openai twitter reddit github ai; do
    ./xray_tmp/xray _v2dat unpack geosite -o files/etc/xray/rules/ -f $tag geosite.dat
    # 统一命名格式
    mv files/etc/xray/rules/geosite_${tag}.mrs files/etc/xray/rules/${tag}.mrs
done

# 4. 彻底清理垃圾，保持编译机环境整洁
rm -rf xray_tmp Xray-linux-64.zip geoip.dat geosite.dat

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

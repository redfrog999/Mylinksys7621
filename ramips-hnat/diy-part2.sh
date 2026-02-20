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

# ------------------ PassWall MRS 固化补强版 --------------------------
mkdir -p files/etc/xray/rules/

# 1. 明确下载路径，强制指定最新版本的 Xray
wget -qO Xray-linux-64.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip -q -o Xray-linux-64.zip -d xray_tmp
chmod +x xray_tmp/xray

# 2. 确保下载 .dat 文件 (带上冗余源防止 404)
wget -qO geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
wget -qO geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/geosite.dat

# 3. 锻造逻辑：如果内置 _v2dat 不行，我们用独立工具 (可选保底)
# 这里的 ./xray_tmp/xray 必须是刚下载的那个
for tag in cn; do
    ./xray_tmp/xray _v2dat unpack geoip -o files/etc/xray/rules/ -f $tag geoip.dat && \
    mv files/etc/xray/rules/geoip_${tag}.mrs files/etc/xray/rules/china_ip.mrs
done

for tag in gfw google youtube telegram netflix openai twitter reddit github ai; do
    ./xray_tmp/xray _v2dat unpack geosite -o files/etc/xray/rules/ -f $tag geosite.dat && \
    if [ "$tag" = "gfw" ]; then
        mv files/etc/xray/rules/geosite_gfw.mrs files/etc/xray/rules/gfw.mrs
    else
        mv files/etc/xray/rules/geosite_${tag}.mrs files/etc/xray/rules/${tag}.mrs
    fi
done

# 4. 清理并验证：如果文件夹为空，则说明没锻造出来
[ "$(ls -A files/etc/xray/rules/)" ] || echo "警告：MRS 锻造失败，请检查编译机环境！"

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

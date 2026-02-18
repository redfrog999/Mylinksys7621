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
sed -i 's/192.168.1.1/192.168.68.1/g' package/base-files/files/bin/config_generate

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# 強制給予 uci-defaults 腳本執行權限，防止雲端編譯權限丟失
chmod +x files/etc/uci-defaults/99-physical-sovereignty

echo '替换golang到1.26x'
rm -rf feeds/packages/lang/golang
git clone -b 26.x --single-branch https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
echo '=========Replace golang OK!========='

#致敬老兵，让MT7621在ShellClash的加持下重新焕发战斗神采

# 1. 强制重写全局编译参数，针对 MT7621 (MIPS 1004Kc/74kc) 深度优化
sed -i 's/-O2/-O3 -march=mipsel -mtune=74kc -mdsp -mno-mips16 -fno-caller-saves/g' include/target.mk

# 2. 优化特定的编译器标志，减少延迟
sed -i 's/TARGET_CFLAGS:=/TARGET_CFLAGS:=-O3 -march=mipsel -mtune=74kc -mdsp -mno-mips16 -fno-caller-saves -fomit-frame-pointer -pipe /g' include/target.mk

# 3. 增强内存管理和 F2FS 挂载的鲁棒性 (针对你的 55GB 硬盘红利)
echo 'CONFIG_F2FS_FS=y' >> .config
echo 'CONFIG_F2FS_STAT_FS=y' >> .config
echo 'CONFIG_F2FS_FS_XATTR=y' >> .config

# 4. 确保 HNAT (PPE) 在内核层面全量开启
echo 'CONFIG_NET_MEDIATEK_SOC_HNAT=y' >> .config

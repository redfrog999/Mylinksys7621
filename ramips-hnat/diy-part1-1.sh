#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i "/helloworld/d" "feeds.conf.default"
#echo "src-git helloworld https://github.com/fw876/helloworld.git" >> "feeds.conf.default"

# Add a feed source
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall.git;main" >> "feeds.conf.default"

# 添加插件源码
#sed -i '$a src-git kiddin9 https://github.com/redfrog999/kiddin9-openwrt-packages' feeds.conf.default
sed -i '$a src-git-full kenzo https://github.com/NicolasMe9907/openwrt-packages' feeds.conf.default
#sed -i 's/+firewall/+uci-firewall/g' feeds/luci/applications/luci-app-firewall/Makefile
#sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default


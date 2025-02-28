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

echo "开始 DIY1 配置……"
echo "========================="

# Uncomment a feed source
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
# sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default
sed -i '1i src-git kenzo https://github.com/redfrog999/openwrt-packages' feeds.conf.default
# sed -i '$a src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main' feeds.conf.default
# sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' feeds.conf.default
# sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
# sed -i '$a src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2.git;main' feeds.conf.default
# sed -i '$a src-git kucat https://github.com/sirpdboy/luci-theme-kucat.git;js' feeds.conf.default
# sed -i '$a src-git luci-app-advancedplus https://github.com/sirpdboy/luci-app-advancedplus.git;main' feeds.conf.default

# rm -rf target/linux/ramips
# svn export https://github.com/padavanonly/immortalwrt/trunk/target/linux/ramips target/linux/ramips

# 修改系统版本（界面显示）
VERSION=${GITHUB_WORKSPACE}/immortalwrt/version
VERSION_TEXT=$(head -n 1 ${VERSION} | tr -d ' \r\n')
if [ -n "$VERSION_TEXT" ]; then
        sed -i "/^VERSION_NUMBER:=.*SNAPSHOT/s/SNAPSHOT/${VERSION_TEXT}/" include/version.mk
fi


echo "========================="
echo " DIY1 配置完成……"

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

# Modify default IP 默认IP由0.1修改为1.1
sed -i 's/192.168.0.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# ------------------PassWall 科学上网--------------------------
# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,pdnsd-alt,chinadns-ng,dns2socks,dns2tcp,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview}
# 核心库
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages
rm -rf package/passwall-packages/{shadowsocks-rust,v2ray-geodata}
merge_package v5 https://github.com/sbwml/openwrt_helloworld package/passwall-packages shadowsocks-rust v2ray-geodata
# app
rm -rf feeds/luci/applications/{luci-app-passwall,luci-app-ssr-libev-server}
# git clone https://github.com/lwb1978/openwrt-passwall package/passwall-luci
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall-luci
# ------------------------------------------------------------

# golang 1.25
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
echo '=========Replace golang OK!========='

#!/bin/bash

PKG_PATCH="$GITHUB_WORKSPACE/wrt/package/"

# mihomo
if [ -d *"mihomo"* ]; then
        git clone https://$github/redfrog999/OpenWrt-mihomo  package/new/openwrt-mihomo
        mkdir -p files/etc/mihomo/run/ui
        
        curl -Lso files/etc/mihomo/run/Country.mmdb https://$github/NobyDa/geoip/raw/release/Private-GeoIP-CN.mmdb
        curl -Lso files/etc/mihomo/run/GeoIP.dat https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat
        curl -Lso files/etc/mihomo/run/GeoSite.dat https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
        curl -Lso metacubexd-gh-pages.tar.gz https://$github/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.tar.gz
        
        tar zxf metacubexd-gh-pages.tar.gz
        mv metacubexd-gh-pages files/etc/mihomo/run/ui/metacubexd
        
	      cd $PKG_PATCH && echo "mihomo data has been updated!"
       
fi

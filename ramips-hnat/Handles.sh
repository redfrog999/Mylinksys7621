#!/bin/bash

PKG_PATCH="$GITHUB_WORKSPACE/wrt/package/"

# mihomo
if [ -d *"mihomo"* ]; then
        git clone https://github.com/redfrog999/OpenWrt-mihomo  package/new/openwrt-mihomo
        mkdir -p files/etc/mihomo/run/ui
        
        curl -Lso files/etc/mihomo/run/Country.mmdb https://github.com/NobyDa/geoip/raw/release/Private-GeoIP-CN.mmdb
        curl -Lso files/etc/mihomo/run/GeoIP.dat https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat
        curl -Lso files/etc/mihomo/run/GeoSite.dat https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
        curl -Lso metacubexd-gh-pages.tar.gz https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.tar.gz
        
        tar zxf metacubexd-gh-pages.tar.gz
        mv metacubexd-gh-pages files/etc/mihomo/run/ui/metacubexd
        
        cd $PKG_PATCH && echo "mihomo data has been updated!"
       
fi

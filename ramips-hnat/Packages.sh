#!/bin/bash

#更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ./feeds/luci/ -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/ -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

UPDATE_PACKAGE "tinyfilemanager" "muink/luci-app-tinyfilemanager" "master"

UPDATE_PACKAGE "design" "kenzok78/luci-theme-design" "js"
UPDATE_PACKAGE "luci-app-advancedplus" "sirpdboy/luci-app-advancedplus" "main"
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "js"
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "master"

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local NEW_VER=$2
	local NEW_HASH=$3
	local PKG_FILE=$(find ./feeds/packages/*/$PKG_NAME/ -type f -name "Makefile" 2>/dev/null)

	if [ -f "$PKG_FILE" ]; then
		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" $PKG_FILE)
		if dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" $PKG_FILE
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" $PKG_FILE
			echo "$PKG_NAME ver has updated!"
		else
			echo "$PKG_NAME ver is latest!"
		fi
	else
		echo "$PKG_NAME not found!"
	fi
}

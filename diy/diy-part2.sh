#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# ================================================================
# DIY编译⬇⬇⬇
# ================================================================
# 集成config
wget -qO- https://raw.githubusercontent.com/Kwonelee/iStoreOS-Actions/refs/heads/main/files/etc/rc.local > package/base-files/files/etc/rc.local

# 复制设备树文件
mkdir -p target/linux/rockchip/dts/rk3399
cp -f $GITHUB_WORKSPACE/armv8/dts/rk3399/rk3399-emb-3531.dts target/linux/rockchip/dts/rk3399/

# 移除要替换的包
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/third_party/luci-app-LingTiGameAcc
rm -rf feeds/luci/applications/luci-app-filebrowser

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package/new
  cd .. && rm -rf $repodir
}

# 常见插件
git_sparse_clone main https://github.com/ophub/luci-app-amlogic luci-app-amlogic
git_sparse_clone main https://github.com/sbwml/openwrt_pkgs filebrowser luci-app-filebrowser-go luci-app-ramfree
FB_VERSION="$(curl -s https://github.com/filebrowser/filebrowser/tags | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | sed 's/^v//')"
sed -i "s/2.31.2/$FB_VERSION/g" package/new/filebrowser/Makefile

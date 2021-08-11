---
layout: post
title:  "Buildroot 筆記"
date:   2021-08-11 16:05:00 +0800
tags:
  - buildroot
  - post
---



# 介紹

Buildroot是一簡化且自動化處理產生corss-compilation toolchain, root filesystem, Linux Kernel, bootloader的工具，便於開發embedded system。

Host: 主機、宿主，一般而言就是我們的PC、Notebook
Target: 目標設備

<!--more-->

## 安裝Buildroot必須的packages:

- Build tools:
  - `which`
  - `sed`
  - `make` (version 3.81 or any later)
  - `binutils`
  - `build-essential` (only for Debian based systems)
  - `gcc` (version 2.95 or any later)
  - `g++` (version 2.95 or any later)
  - `bash`
  - `patch`
  - `gzip`
  - `bzip2`
  - `perl` (version 5.8.7 or any later)
  - `tar`
  - `cpio`
  - `python` (version 2.6 or any later)
  - `unzip`
  - `rsync`
  - `file` (must be in `/usr/bin/file`)
  - `bc`
- Source fetching tools:
  - `wget`

## 可選是否要安裝的packages:

- - `ncurses5` to use the *menuconfig* interface
  - `qt4` to use the *xconfig* interface(sudo apt-get install qt4-qmake libqt4-dev)
  - `glib2`, `gtk2` and `glade2` to use the *gconfig* interface
- Source fetching tools:
  - `bazaar`
  - `cvs`
  - `git`
  - `mercurial`
  - `rsync`
  - `scp`
  - `subversion`
- Java-related packages:
  - The `javac` compiler
  - The `jar` tool
- Documentation generation tools:
  - `asciidoc`, version 8.6.3 or higher
  - `w3m`
  - `python` with the `argparse` module (automatically present in 2.7+ and 3.2+)
  - `dblatex` (required for the pdf manual only)
- Graph generation tools:
  - `graphviz` to use *graph-depends* and *<pkg>-graph-depends*
  - `python-matplotlib` to use *graph-build*

空間夠的話，建議全部一起安裝，例如git或graphviz(make graph-depends時會用到)又或python都很常用。

## Quick Start:

首先我們需要產生一個 **.config**檔，可使用下面四種指令，用圖形化的視窗來設定:

1. make menuconfig最基本也是最多人用的

2. make nconfig 新的圖形介面

3. make xconfig Qt-based的圖形介面

4. make gconfig GTK-based的圖形介面

只是畫面不同，重點在設定完，會在目前目錄下(也就是top-level的目錄)產生一個**.config**檔(隱藏檔)，這裡面有你設定好的設定，之後也可直接更改此檔來做設定。設定完後下make，沒意外的話，一切就會自動完成。

要注意的是，這裡不能在top-level資料夾下 make -jN的指令，一般我們會在4核下的cpu 裡下make -j8來進行多工的處理，可是Buildroot不支援在top-level的並行處理。取而代之的是使用BR2_JLEVEL。這選項告訴Buildroot在每個獨立的package裡下make -jN，例如修改**.config**的BR2_JLEVEL=8。

### make的流程:

- download source files (as required);
- configure, build and install the cross-compilation toolchain, or simply import an external toolchain;
- configure, build and install selected target packages;
- build a kernel image, if selected;
- build a bootloader image, if selected;
- create a root filesystem in selected formats.

最後結果輸出在output資料夾。

### output資料夾內容:

images => kernel image,bootloader, root filesystem images等等

build => 所有下載或自定義build好的packages

staging => 這資料包含一些研發工具，用來compile libraries and applications給target使用

target => 目標設備的root filesystem範本，依照手冊說明，不包含dev，因為make的時後並   

​                 不是用root啟動，這裡比較奇怪，我沒有下sudo make，可是target底下也是有dev這資料夾?  

​                  也有可能是之前有下過sudo make，而資料夾未被移除?

host => 主機上bulidroot所需的工具

graphs => 如果下make graph*-de*pends等輔助指令，可產生package的相依性、生成的size、   

​                   build的時間等等資訊，會放在這個資料夾裡



# 設定

## Cross-compilation toolchain:

### Buildroot 提供兩種toolchain設定:

#### 1. internal toolchain backend

> 使用Buildroot自帶的toolchain，支援uClibc-ng, glibc and musl，需選擇Linux kernel headers、
>
> C Library、GCC compiler、binutils等工具和版本。

#### 2. external toolchain backend

> 有三個方式可選:
>
> > (1) Use a predefined externel toolchain profilw
> >
> > > 讓Buildroot去下載安裝
> >
> > (2) Use a predefined externel toolchain profile
> >
> > > 告訴Buildroot這toolchain放在系統那邊，不要去下載安裝
> >
> > (3) Use a completely externel toolchain
> >
> > > 通常這是指晶片商提供的toolchain，我們需要指定Toolchain path,Toolchain prefix and External toolchain C library。
> > >
> > > 一般而言會提供一個設定檔，執行這個檔案，例如 make XXXX_defconfig。再執行make menuconfig，會看到在menu
> > >
> > > 中已經設好了，唯一要手動的是，path和prefix。如果build的時後顯示找不到toolchain，大多是這兩個參數設錯。
> > >
> > > **例如:**
> > > BR2_TOOLCHAIN_EXTERNAL_PATH="/home/<user>/<work directory>/armv7-marvell-linux-gnueabihf/"
> > >
> > > BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX="arm-marvell-linux-gnueabihf"
> > >
> > > **BusyBox:**
> > > 可用default的BusyBox設定或使用BR2_PACKAGE_BUSYBOX_CONFIG這個參數來讀取已定義好的設定。
> > >
> > > 也可使用 make busybox-menuconfig 來編輯BusyBox。
> > >
> > > **uClibc:**
> > > 和BusyBox類似，使用BR2_UCLIBC_CONFIG來讀取已定義好的設定。
> > >
> > > 也可使用 make uclibc-menuconfig 來編輯BusyBox。
> > >
> > > **Linux kernel:**
> > > 使用BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG來讀取已定義好的設定
> > > 使用BR2_LINUX_KERNEL_USE_DEFCONFIG來使用default值
> > > 使用 make linux-menuconfig 來編輯
> > >
> > > **Barebox:**
> > > U-Boot二代，使用上和Linux kernel類似
> > > 使用BR2_LINUX_TARGET_BAREBOX_USE_CUSTOM_CONFIG來讀取已定義好的設定
> > > 使用BR2_LINUX_TARGET_BAREBOX_USE_DEFCONFIG來使用default值
> > > 使用 make barebox-menuconfig 來編輯
> > >
> > > **U-Boot:**
> > > U-Boot板本要2015.04以上
> > > 使用BR2_LINUX_TARGET_UBOOT_USE_CUSTOM_CONFIG來讀取已定義好的設定
> > > 使用BR2_LINUX_TARGET_UBOOT_USE_DEFCONFIG來使用default值
> > > 使用 make uboot-menuconfig 來編輯
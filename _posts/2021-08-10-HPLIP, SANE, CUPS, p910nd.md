---
layout: post
title:  "HPLIP, SANE, CUPS, p910nd"
date:   2021-08-10 14:52:00 +0800
tags:
  - usb
  - printer
  - post
title_variable: "example"
---
### HPLIP、SANE、CUPS、p910nd

**介紹：**  

-   HPLIP是HP針對HP掃描器、印表機提供的Linux OpenSource驅動程式組合包。
-   SANE是Linux上的掃描器的軟體，裡面包含了網路掃描、掃描的前端軟體介面、掃描器驅動程式。
-   CUPS、p910nd都是Linux上的列印伺服器，p910nd是non-spooling的列印伺服器，CUPS則是spooling伺服器。

<!--more-->

**p910nd與CUPS區別和兩者架構：**  
**p910nd：**  
參考：  
[\[Oleg/Lly/CDMA@wifi\] p910nd 列印伺服器(無spool)](http://digiland.tw/viewtopic.php?id=926)  

從參考的作者文中可以知道，  
p910nd的安裝，主要2個步驟：  

1.  確定Linux Kernel內USB Printer有支援
2.  p910nd daemon有啟動，並指定Port、USB Printer的Device File

步驟完成，p910nd就會動了，而且p910nd需求極小，  
幾乎沒有相依太多library就能動作。  

再看看下面這個參考：  
[DD-WRT Printer Sharing](http://www.dd-wrt.com/wiki/index.php/Printer_Sharing#Workstation_setup)  

裡面描述了p910nd安裝外，也描述了Client端的安裝，  
包括CUPS、Linux、Windows、MacOSX的安裝介紹。  

簡單白話的說，  
p910nd本身只是USB<->Socket的轉譯器，  
它不負責印表機溝通，從Socket來的資料直接轉入USB當中，  
因此所有印表機的溝通，列印資料的轉譯，都要由Client端負責，  
印表機工作的排程，則要由印表機自己負責。  

因此p910nd優點是library相依性低，也不需要複雜的額外工作，  
至於Client端，  
Windows直接有原廠的驅動程式，  
Linux直接有CUPS搭配HPLIP就能達成，  
macOSX看起來也是有驅動程式，目前試驗HP不行。  

**CUPS：**  
直接看系統方塊圖([wiki](http://en.wikipedia.org/wiki/CUPS))：  

[![](http://1.bp.blogspot.com/-KiPXp0m60S4/VLE7OhJgIrI/AAAAAAAAD9c/bSeV9oIOVyA/s1600/CUPS-block-diagram.png)](http://1.bp.blogspot.com/-KiPXp0m60S4/VLE7OhJgIrI/AAAAAAAAD9c/bSeV9oIOVyA/s1600/CUPS-block-diagram.png)


CUPS是一整套完整的列印伺服器程式，  
裡面包含了使用者管理、列印語言轉譯、列印Queue、網路列印...等多個功能。  

我們單從CUPS的系統方塊圖來看，  
它前面提供了各種檔案格式的轉譯器，轉譯成PostScript，  
中間能將PostScript轉譯成各種列印語言，像是PCL...等，  
後面CUPS backend又能串接包括本機的USB、SerialPort...等，網路的IPP、網路芳鄰、AppleTalk...等網路介面。  

因此可以知道它是非常龐大的列印系統，  
從前端應用程式的檔案開始，就一路透過它層層處理，最後一樣透過它送到印表機上。  

優點當然是系統功能完整，但缺點就是相依的library多，  
程式的設定項目多比較複雜，  
在小型系統上就比較不方便移植，  
因此比較早期的OpenWRT、DD-WRT都只支援p910nd，  

較新的版本則已經有提供cups，

自行移植則會遇到比較多的編譯問題，我自己最後編譯出來，執行後，網頁點幾下還是會segfault。

  

**SANE：**

SANE是Linux上最主要的掃描器解決方案，可能也是唯一的解決方案，

有支援Linux的掃描器，大概都是提供SANE的驅動程式。

  

SANE分前端(frontend)和後端(backend)，

SANE frontend主要提供給應用程式，送掃描動作給SANE；

SANE backend主要就是SANE介面界接掃描器的驅動程式。

  

SANE有提供一個特別的SANE frontend，叫做net，

它能讓SANE能透過網路接收SANE的掃描動作，達成網路控制掃描器掃描。

  

**HPLIP：**

前面提這麼多，原因是HPLIP相依的東西很多，

上述幾個是最關鍵的幾個。

  

參考：

[HPLIP Technical Overview](http://hplipopensource.com/node/128)

  

直接看參考中的系統方塊圖：

[![](http://hplip.sourceforge.net/images/hplip_architecture.png)](http://hplip.sourceforge.net/images/hplip_architecture.png)

  

拆開來看HPLIP各項元件，我們先只看掃描器部份，看hp-scan那個垂直的部份。

  

在HPLIP中，HP的掃描器是透過SANE支援的。

**hp-scan：**

hp-scan是HPLIP提供的掃描器工具程式，但hp-scan實際上是個SANE frontend，

就是透過SANE backend掃描。

  

**libsane-hpaio：**

HPLIP提供了libsane-hpaio這個SANE backend用的延伸library，

libsane-hpaio讓SANE backend透過它來操作HP掃描器，

我不很確定裡面有沒有包含驅動程式，或是否有包含部份的驅動程式，

但這個library非常重要，SANE需要靠它才能操作HP掃描器，

在SANE中，它被稱為hpaio的SANE backend。

  

**hpmud：**

HPLIP實際操作HP印表機、掃描器的I/O library，

所有的工作都透過這個library傳遞給USB或網路(網路印表機、網路掃描器時)，

它的下層，就是USB library或Socket，直接連結印表機、掃描器。

  

**D-Bus：**

掃描器這路看完後，我們來看D-BUS。

在HPLIP中，各個應用程式和元件間溝通都是透過D-BUS，

這些應用程式包括掃描器左邊那幾個小顆的，

包括hp-systray、hp-toolbox、hp-sendfax這幾個工具程式，

還有libsane-hpaio這個SANE backend。

  

這些元件和程式的溝通都透過D-Bus，

而D-Bus本身在HPLIP則是透過hp/hpfax backend管理。

  

關於D-Bus，這邊不多介紹，簡單的說，它是Linux上IPC的一種，

各應用程式可以透過D-Bus互相溝通，

典型的例子是，播放程式透過D-Bus提供出播放音樂的資訊，

Skype這類的通訊軟體透過D-Bus可以得到並顯示你正在播放的音樂資訊。

  

**部份總結：**

到目前為止，

先整理下HPLIP做了什麼？搞了哪些元件？要在小系統上編譯，需要編譯哪些東西？

1.

HPLIP最核心的I/O主要是hpmud，負責最終和硬體通訊

  

2.

HPLIP使用SANE做為掃描器核心，要能掃描，除了SANE要ok之外，

hpaio backend要確定ok，並有放置在SANE backend的目錄內

  

3.

hp-scan只是個SANE frontend，不用管它，用其他SANE程式效果一樣

  

4.

D-Bus在HPLIP是各程式的溝通平台，單純使用掃描功能，不用管它

  

5.

如果搭配p910nd，到目前為止的資訊已經足夠了，其他元件都只跟列印和CUPS相關

  

**HPLIP與CUPS：**

前面CUPS提到，CUPS架構很大，CUPS中間有許多轉譯器提供各種轉譯，

HPLIP針對CUPS實做了hpcups、hpcupsfax...等幾個轉譯器，

接收了從CUPS收到的列印資料(應該是PostScript)後，

透過這些轉譯器轉譯，送給hp/hpfax backend，再透過hpmud送到印表機。

  

這裡我比較不清楚的地方是，

轉譯器轉譯後，是直接在轉譯器內送到hp/hpfax backend，

還是轉譯器轉譯後，回到CUPS，再由CUPS送到hp/hpfax backend進行列印，

這是圖上沒有表示的部份。

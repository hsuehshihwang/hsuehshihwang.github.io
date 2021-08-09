---
layout: post
title:  "USB的種類(OHCI、UHCI、EHCI、XHCI)"
date:   2021-08-09 11:34:00 +0800
tags:
  - usb
  - post
---

### USB的種類(OHCI、UHCI、EHCI、XHCI)

**_USB(Universal Serial Bus)_**通用串列匯流排：USB1.1規格支援兩種速率：低速(low speed)1.5Mbps和全速(full speed)12Mbps.  

<!--more-->

**_USB2.0_**規格除了支援原有的兩種速度外，還額外支援高速(high speed)480Mbps。  

**_USB3.0_**支援全雙工，比USB 2.0多了數個觸點，並採用發送列表區段來進行資料發包。USB 3.0暫定的供電標準為900mA，且理論上有支援光纖傳輸的潛力。USB 3.0設計的「Super Speed」傳輸速度為5Gbit/s，理論資料傳輸速度為625MByte/s。  

OHCI、UHCI都是USB1.1的介面標準，而EHCI是對應USB2.0的介面標準，最新的xHC則是USB3.0的介面標準。  

1. **_OHCI（Open Host Controller Interface）_**是支援**USB1.1**的標準，但它不僅僅是針對USB，還支援其他的一些介面，比如它還支援Apple的火線（Firewire，IEEE 1394）介面。與UHCI相比，OHCI的硬體複雜，硬體做的事情更多，所以實現對應的軟體驅動的任務，就相對較簡單。主要用於非x86的USB，如擴展卡、嵌入式開發板的USB主控。  
  
2. **_UHCI（Universal Host Controller Interface）_**，**_是Intel主導的對USB1.0、1.1的介面標準_**，與OHCI不相容。UHCI的軟體驅動的任務重，需要做得比較複雜，但可以使用較便宜、較簡單的硬體的USB控制器。Intel和VIA使用UHCI，而其餘的硬體提供商使用OHCI。  

3\. **_EHCI（Enhanced Host Controller Interface）_**，是Intel主導的**_USB2.0_**的介面標準。EHCI僅提供USB2.0的高速功能，而依靠UHCI或OHCI來提供對全速（full-speed）或低速（low-speed）設備的支援。  

4\. **_xHCI（eXtensible Host Controller Interface）_**，是最新最火的**_USB3.0_**的介面標準，它在速度、節能、虛擬化等方面都比前面3中有了較大的提高。xHCI 支援所有種類速度的USB設備（USB 3.0 SuperSpeed, USB 2.0 High-speed, USB 1.1 Low-speed and Full-speed）。  

**USB1.1 ---> (Low-Speed and Full-Speed)**  
**USB2.0 ---> High Speed**  
**USB3.0 ---> Super Speed**


## Driver sources
For 6.1.y, drivers were cloned from a number of maintained Realtek repos
A summary.

**rtl8723du**
5.10.y/ 6.1.y
- http://github.com/lwfinger/rtl8723du  
    Added a Kconfig  
    Fixed Makefile to ensure TopDIR points to $(src)

6.6.y
- Obsolete (covered by rtw88 driver)

**rtl88x2bu**  
- http://github.com/cilynx/rtl88x2bu  
        
**rtl8821cu**  
- http://github.com/morrownr/8821cu-20210118  
    Cloned into rtl8821cu

**rtl8812au**  
5.10.y/ 6.1.y
- Armbian build patches

6.6.y
- https://github.com/morrownr/8812au-20210629
    Cloned into rtl8812au

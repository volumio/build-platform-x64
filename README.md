# Build the Volumio x86 linux kernel
Copyright (c) 2022, 2023, 24 Gé Koerkamp / volumio@bluewin.ch
 
## **Intro**
This script is used for building the necessary x86 platform files, which includes kernel, firmware, scripts etc. It does NOT build an image.  
This is default set to kernel 6.1.y, but can still be used to build platform files with kernel 5.10.y  
See the config.x86 in the config directory.

## **Prerequisites**

This build process has been tested on Debia Buster (Debian 10), Ubuntu 22.04 and Ubuntu 23.10  
Some prerequisite packages may already have been installed during the OS install. Make sure you have the following.
You will need the following minimal packages (including the ones you would need for Volumio building):

```
build-essential ca-certificates curl debootstrap dosfstools git jq kpartx libssl-dev lz4 lzop md5deep multistrap
parted patch pv qemu-user-static qemu-utils squashfs-tools u-boot-tools wget xz-utils zip 
kmod flex cpio libncurses5-dev libelf-dev libssl-dev bison rsync libncurses-dev debhelper
```

## History
See at the end of this document.

## **Kernel Build Process**

### Clone the build repository

```
git clone https://github.com/gkkpch/build-x86-platform --depth 1
```
### Run the build process

```
cd build-x86-platform
./mkplatform.sh
```

## **Patching**

**```config.x86 parameter PATCH_KERNEL```**  
When set to "yes" (active), the build process will supply kernel patching, the kernel will not be compiled.
This allows you to test patching until the result is OK.  
Disable ```PATCH_KERNEL``` when done.

After cloning/ updating the kernel, platform repos and after applying current volumio patches, the build process reaches a break-point and displays:
```
[ .. ] Now ready for additional sources and patches
[ .... ] Workfolder <workfolder> will be used to create the patch file
[ .... ] Press [Enter] key to resume ...
```
At this point new patches can be made in the kernel tree.  
When you're ready, or did not have any patches, press ```[Enter]```.  
* Without patches, the process ends here.  
* With patches, you will be prompted to enter a name for a patch file, which will also be used as a commit message.   
Please use a meaningfull name, refer to the existing patch names as examples.   
The patch will automatically be prefixed with a sequence number (the highest existing prefix number, incremented by 1), extension ```.patch``` will also be added to the name.  
You can change/ correct the name later, but be carefull with the sequence number.  
The sequence number ensures that patches are applied in the patched order (a patch could be a patch on top o another).     
Check the patch and when correct, move it to the ```build-x86-platform/patch``` folder.   
From here the patch will be used in the kernel build process. Patches (still) in the work folder have no effect.  
You can clear the work folder afterwards.  

### New kernel sources

Keep these in folder ```build-x86-platform/sources``` for later reference, grouped by kernel version.

### Kernel configuration
**```config.x86 parameter CONFIGURE_KERNEL```**  
When set to "yes". the kernel configuration settings can be modified, the menuconfig dialogue will appear.  
Configuration modifications will be saved in ```/platform-x86/packages-buster/amd64-volumio-min-<kernelbranch>_defconfig``` and reused with future kernel compiles.

a## **Add support for a current Release Candidate kernel**
Release Candidate kernels are not part of the ```linux-stable``` repo.  
The compilation of such a kernel requires
* manually clone the current kernel repo after checking the current rc name (e.g. 6.3-rc7):
```
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux-6.3-rc7
```

* modification of ```./config/x86.conf```
    * comment the current kernel branch
    ```
    #KERNELBRANCH="6.1.y"
    ```

    * add a new one, e.g.
    ```
    KERNELBRANCH="6.3-rc7"
    ```

Next you need to create a kernel configuration file for the ```-rc``` kernel.
Copy the last known ```amd64-volumio-min..._defconfig``` and name it (as an example) ```amd64-volumio_min_6.3-rc7_defconfig```.   

For the sources and patches, follow the instructions below (support for a new kernel).

**Important** Custom patches will not be allowed.

## **Add support for a new major kernel**
It is advised to use LTS kernels whenever possible. Once Volumio is working with an LTS version, you will have years of support to come. This kernel build process will keep maintenance effort to a minimum.
* Create the new ```./sources/<kernelbranch>``` folder.
* Create the new ```./patches/<kernelbranch>``` folder.
* Build the kernel first without patching or configuration chnages.
For the patch-process, use the relevant patch sources from a **previous** ```./patches/<major-kernelversion/``` (the closest version you have) to the new patches folder. 
    * Note: Some of the existing patches for Wireless Drivers may not apply anymore. E.g. kernels 6.2.y and 6.3-rc7 already include more Realtek chip support. As an example,  RTL8822BU is supported out-of-the-box (and a few more). Please check for duplicates by comparing the ```Kconfig``` files in Realtek folders like ```rtw88``` and ```rtw99```. Just copy the remaining custom patches. 
    * re-apply the patches one-by-one using the patch-process as described above. Be aware, that patching or compiling may not always work.
    * some may be mismatched a few lines in case the source was changed in the new kernel version.
    * in case the patch does not apply anymore because of errors in custom sources, consult the internet and apply the necessary fixes or replace the patch & source. This is not always trivial.  

* Modify ```./config/x86.conf```
    * comment the current kernel branch
    ```
    #KERNELBRANCH="6.1.y"
    ```

    * add a new one, e.g.
    ```
    KERNELBRANCH="6.2.y"
    ```

    * modify the previous kernelbranch
    ```
    KERNELBRANCH_PREV="6.1.y"
    ```

    * See "kernel configuration" above, new kernels usually have support for new hardware, notably ethernet, wireless and bluetooth devices, but also touchscreens etc. In case you know some, make sure to enable them. In all other cases, you may have to rely on feedback from users. Don't forget to add corresponding firmware when needed.
    
* Start the build process.

## **Firmware Maintenance**

There are two situations
* you wish to add a particular new or missing firmware binary and leave the rest as is
* you wish to add a complete new linux-firmware from kernel.org

## Add a new or missing firmware binary

Try to find out what is needed and then clone repo ```git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git```
```
cd firmware
git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git new-fw
```
This will give you the latest stable firmware repo in directory ```new-fw```.

Unpack the current linux-firmware tarball in firmware (on 20230104 this was firmware-20231216).
```
cd firmware
tar xfJ linux-fw-20221216.tar.xz
```
This gives you the current firmware tree in ```lib```.

Locate the new firmware and place it at the exact same location in the current tree.
Example:
```
cd firmware
cp new-fw/rtlwifi/rtl8188efw.bin lib/firmware/rtlwifi
```

Create a new linux-firmware tarball, note the name and the different date.
Only overwrite an existing one when you add something which was missing.
```
cd firmware
tar cfJ linux-fw-20230104.tar.xz ./lib
```
Remove the temp folders
```
rm -r new-fw
rm -r lib
```

In case you added new firmware (not missing stuff), open ```config/config.x86``` and add the date of the new firmware tarball (in this case "20230104") to the list of firmware releases.
```
LINUX_FW_REL=("20211027" "20221216" "20230104")
```
in both cases, start the merge script in the build-x86-platform root folder
```
./mergefirmware.sh
```
The new tarball will be copied to platform-x86

## New firmware-linux from kernel.org

This is a little trickier and more time-consuming.
The firmware from kernel.org is too big to use as-is, it needs cutting out the unnecessary firmware.
The best way to do this is to clone the firmware repo as shown above, but do this in a directory outside the build-x86-platform.

Now comes to tedious part. Compare the contents of the current firmware tarball in firmware. On 20230104 this was ```linux-fw-20221216``` and start with removing all directories in the new firmware repo which are not in the current one, unless you are sure it is a new one that matters (graphics, wifi). 
Do the same for the files in the root folder of the new firmware repo, keep the matching ones but also new binaries starting with "ar", "ath", "iwlwifi", "mt", "rt". When unsure, keep it.

Then bring this new folder in a "lib/firmware" structure (like the current one) and pack it to a tarball linux-fw-<dat>.tar.xz, where date is kernel.org's release date (should be visible when doing a ```git tag -l``` (it is the last one).

Add the new date to config/config.x86 and start the merge (see above)

## History

|Date|Author|Change
|---|---|---|
|20220218|gkkpch|Initial version
|20220404|gkkpch|Use for kernel 5.10.y LTS with github.com/volumio/platform-x86 
|20230103|gkkpch|Add kernel 6.1.y LTS support
|||Add support for Realtek RTL88x2BU/ RTL8821CU/ RTL8723DU
|||Add support for i2c-cht341-usb
|20230104|gkkpch|Moved firmware files from platform-x86 to ./firmware
|||Merged the 4 different tarballs into a single firmware tarball, script ```mergefirmware.sh``` added.  
|TODO|TODO|Remove the remainders in platform-x86 once the build recipe modification have been merged 
|20230118|gkkpch|Support future release candidate kernels for testing
|20230330|gkkpch|Kernel 6.1.y LTS: bump to version 6.1.22
|||Kernel 6.1.y LTS: add wireless support for RTL8812AU
|||Kernel 6.1.y LTS: add BT support for Ugreen BT 5.0 (VID/PID: 0x2b89:0x8761)
|||Kernel 5.10.y LTS: pulling version 5.10.178 
|||Kernel 6.1.y LTS: pulling version 6.1.25
|||Kernel 6.1.y LTS: patch to re-enable touchscreen on Toshiba Satellite Mini Click"
|20230731|gkkpch|Kernel 6.1.y LTS: remove previous touchscreen patch (now obsolete)
|||Kernel 6.1.y LTS: adapt usb audio patch to fit modified quirks.c
|20230807|gkkpch|Ubuntu >=21.04 compresses .deb files with zstd. Repack them with xz compressed files, otherwise they cannot be processed with Volumio's build server with Debian 10
|20230828|gkkpch|Switched to kernel 6.1.y LTS as default
|||Kernel 5.10.y: bumped to 5.10.192, frozen as of 20231208
|||Kernel 6.1 y LTS: bumped to 6.1.49
|||Firmware: added version from 20230804
|20231030|gkkpch|Preparations for kernel 6.6.y (waiting for 6.6.y LTS)
|20231108|gkkpch|Kernel 6.1 y LTS: bumped to 6.1.62, frozen as of 20231208
|20231208|gkkpch|Kernel 6.6.y LTS: bumped to 6.6.5
|||Moved to Volumio repo
|20231220|gkkpch|Documented the re-factored patching process
|20231220|gkkpch|Remove commit-id from .deb package names"
|20241127|gkkpch|Preparations for kernel 6.12.y (waiting for 6.12.y LTS)
|20241128|gkkpch|Added DSD patches (from 6.6 plus a new one)
|||Firmware: added version from 20241110
<br />
<br />
<br />
<br />
<sub> January 2023/ Gé koerkamp
<br />ge.koerkamp@gmail.com
<br />04.01.2023 v1.0
<br />08.12.2023 v1.1


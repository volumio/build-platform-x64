#!/bin/bash

get_kernel_repo() {
if [ ! -d  $KERNELDIR ]; then
  log "Kernel directory does not exist, cloning from kernel.org"
  git clone ${KERNELREPO} ${KERNELDIR} -b linux-${KERNELBRANCH}
fi
}

get_platform_repo() {
  log "Getting the latest x86 platform files"
  if [ -d ${PLATFORMDIR} ]; then
    log "Platform folder exists, update" "info"
    pushd ${PLATFORMDIR} 1> /dev/null 2>&1
    git pull
    popd 1> /dev/null 2>&1
  else
    log "Platform folder does not exist, cloning the repo" "info"
    git clone ${PLATFORMREPO} --depth 1
  fi
}

clean_previous_builds() {
  KVER=$(cat Makefile| grep "^VERSION = " | awk -F "= " '{print $2}')
  KPATCH=$(cat Makefile| grep -e "^PATCHLEVEL = " | awk -F "= " '{print $2}')
  KSUB=$(cat Makefile| grep -e "^SUBLEVEL = " | awk -F "= " '{print $2}')
  KVERPREV=${KVER}.$KPATCH.$KSUB$LOCALVERSION

  log "Previous versions"
  log "Kernel version ${KVER}" "info"
  log "Kernel patch ${KPATCH}" "info"
  log "Kernel sub version ${KSUB}" "info"
  log "Previous build version ${KVERPREV}" "info"

  log "Removing previous build versions from the build folder"
  [[ -d ../$KERNELDIR.orig ]] && rm -r ../$KERNELDIR.orig
  [[ -d ../$KERNELDIR/debian ]] && rm -r ../$KERNELDIR/debian

  log "Removing old build versions from the platform folder"
  set -- $SRC/config/amd64*${KVERPREV}*_defconfig
  if [ -f "$1" ]; then
    rm $SRC/config/amd64*${KVERPREV}*_defconfig
  fi
  set -- $SRC/debs/linux-*${KVERPREV}*.deb
  if [ -f "$1" ]; then
    rm $SRC/debs/linux-*${KVER}.${KPATCH}.${KSUB}*.deb
  fi

}

get_latest_kernel() {
  log "Getting the latest kernel version"
  if [[ ! $KERNELBRANCH =~ "-rc" ]]; then
    log "Resetting the kernel repo" "info"
      git fetch origin
      git reset --hard origin/linux-$KERNELBRANCH
      git clean -ffdx 1> /dev/null 2>&1
      git pull
  else
    log "$KERNELBRANCH is a release candidate, up-to-date"
  fi  

  KVER=$(cat Makefile| grep "^VERSION = " | awk -F "= " '{print $2}')
  KPATCH=$(cat Makefile| grep -e "^PATCHLEVEL = " | awk -F "= " '{print $2}')
  KSUB=$(cat Makefile| grep -e "^SUBLEVEL = " | awk -F "= " '{print $2}')
  KERNELVER=${KVER}.$KPATCH.$KSUB$LOCALVERSION
  echo ${KERNELVER} > ${SRC}/VERSION

  log "Current versions"
  log "Kernel version ${KVER}" "cfg"
  log "Kernel patch ${KPATCH}" "cfg"
  log "Kernel sub version ${KSUB}" "cfg"

  echo 1 > .version
  log "Debian packages version number used:" "$KERNELVER-$(<.version)"
  touch .scmversion
}

add_additional_sources() {
  :
}

add_user_patches() {
  if [ ! -d ${SRC}/patches/${KERNELBRANCH} ] ; then
    log "No existing patches found" "wrn"
  else
    FILES=${SRC}/patches/${KERNELBRANCH}/*.patch
    if [ "$(echo ${FILES})" == "${SRC}/patches/${KERNELBRANCH}/*.patch" ]; then
      log "No existing patches found" "wrn"
    else  
      NUMFILES=$(echo $FILES | awk -F' ' '{print NF}')
      log "Number of existing patches to apply:" "${NUMFILES}"
      shopt -s nullglob
      for f in ${FILES}
        do
          log "Appying $f" "info"
          git apply $f 1> /dev/null 2>&1
        done
      git add * 1> /dev/null 2>&1
      git commit -m "Added existing Volumio patches" 1> /dev/null 2>&1
    fi  
  fi
}


patch_kernel() {
   if [[ ! $KERNELBRANCH =~ "-rc" ]]; then   
      log "Now ready for additional sources and patches"
      log "Workfolder ${PATCHWORKDIR} will be used when creating a patch file" "info"
      RESUMEPROMPT=$(log "Press [Enter] key to resume ..." "info")
      read -p "${RESUMEPROMPT}"
      [ -d $PATCHWORKDIR/${KERNELBRANCH} ] || mkdir -p $PATCHWORKDIR/${KERNELBRANCH}
      
      PENDING_COMMIT=$(git status | grep -o 'nothing to commit')
      if [ ! "${PENDING_COMMIT}" == "nothing to commit" ]; then
         git add * 1> /dev/null 2>&1
         log "Add a meaningfull name for the patchfile after the prompt"
         log "Note: whitespaces will be replaced by '-'" "info"
         echo -n "Your filename > " 
         read COMMITMSG
 	 COMMITMSG=$(echo $COMMITMSG | sed 's/ /-/g')
         git commit -m ${COMMITMSG} 1> /dev/null 2>&1
         NUMFILES=$((NUMFILES+1))
         git format-patch --start-number ${NUMFILES} -1 HEAD -o ${PATCHWORKDIR}/${KERNELBRANCH} 1> /dev/null 2>&1
         log "New patchfile:" "$(printf '%04d' ${NUMFILES})-${COMMITMSG}.patch"
         log "$(git log -1)" 
         log "Check it and move it to $PATCHDIR/${KERNELBRANCH}" "info"
      else
         log "No modifications were found, no new patch file was created..." "wrn"   
      fi   
   else
      log "${KERNELBRANCH} is a release candidate, cannot create patches" "error"
   fi
}


prep_kernel_config() {
  log "Adding the default amd64-volumio-min kernel configuration" "info"
  if [ -f ${SRC}/config/${KERNELCONFIG} ]; then
    cp ${SRC}/config/${KERNELCONFIG} ${KERNELDIR}/arch/x86/configs/${KERNELCONFIG}
  else
    if [ -z ${KERNELBRANCH_PREV} ]; then
    echo "Previous: " ${KERNELBRANCH_PREV}
      log "Previous kernel branch not specified in config.x86, aborting" "err"
      exit 255
    fi
    if [ -f "${SRC}/config/amd64-volumio-min-${KERNELBRANCH_PREV}_defconfig" ]; then
      log "Custom kernel configuration file does not exist, copy from last compiled kernel configuration"
      cp ${SRC}/config/amd64-volumio-min-${KERNELBRANCH_PREV}_defconfig ${KERNELDIR}/arch/x86/configs/${KERNELCONFIG}
    else
      log "Default kernel configuration not found, aborting" "err"
      exit 255
    fi
  fi
  log "Preparing volumio kernel config file"
  make clean
  log "Using configuration ${KERNELDIR}/arch/x86/configs/${KERNELCONFIG}" "info"
  make ${KERNELCONFIG}
  log "Saving .config to defconfig"
  make savedefconfig
}
  
configure_kernel() {
  if [ "${CONFIGURE_KERNEL}" == "yes" ]; then
     log "Starting kernel configuration menu" "info"
     make menuconfig
     log "Saving .config to defconfig"
     make savedefconfig
     echo "Copying defconfig to volumio kernel config"
     cp defconfig ${KERNELDIR}/arch/x86/configs/${KERNELCONFIG}
  fi   
}

compile_kernel() {
  log "Copying volumio kernel config to platform folder (history)"
  cp defconfig $SRC/config/amd64-volumio-min-${KERNELVER}-`date +%Y.%m.%d-%H.%M`_defconfig
  if [ "${CONFIGURE_KERNEL}" == "yes" ]; then
     cp defconfig $SRC/config/amd64-volumio-min-${KERNELBRANCH}_defconfig
  fi
  
  log "Compiling kernel ${KERNELVER}"
  start=$(date +%s.%N)
  make -j$(nproc) deb-pkg KDEB_PKGVERSION=$(make kernelversion)
}

backup_to_storage() {

  HEADERS=$(ls ../linux-headers*.deb)
  IMAGE=$(ls ../linux-image*.deb)

  log "Check if .deb packages were compressed with ZSTD, re-pack it for usage with Debian 10" "info"
  # if one is zstd compressed, all are (Ubuntu >= 21.04, Debian >= 12)
  ar -x $HEADERS
  if [ -f "control.tar.zst" ]; then

    log "Re-packing $HEADERS"
    # Uncompress zstd files an re-compress them using xz
    zstd -d < control.tar.zst | xz -v > control.tar.xz
    zstd -d < data.tar.zst | xz -v > data.tar.xz
    rm $HEADERS
    ar r $HEADERS debian-binary control.tar.xz data.tar.xz
    rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst

    log "Re-packing $IMAGE"
    ar -x $IMAGE
    zstd -d < control.tar.zst | xz -v > control.tar.xz
    zstd -d < data.tar.zst | xz -v > data.tar.xz
    rm $IMAGE
    ar r $IMAGE debian-binary control.tar.xz data.tar.xz
    rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst
  fi

  log "backup the .deb files"
  [[ ! -d ${SRC}/debs ]] && mkdir -p ${SRC}/debs
  rsync --remove-source-files -rq ../*.deb "$SRC/debs"
  find ../ -maxdepth 1 -type f -name 'linux-*' -delete

  log "Please do not add the .deb files to the 'build-platform-x64 repo" "warn"
  log "Just keep them local in case you wish to re-create the platform files" "warn"
  cd ..
}

create_platform() {

  if [ ! -d ${SRC}/debs ]; then
    log ".deb files are missing, re-run 'mkplatform.sh' first" "err"
    exit
  fi

  HEADERS=$(ls ${SRC}/debs/linux-headers*.deb)
  IMAGE=$(ls ${SRC}/debs/linux-image*.deb)
  LIBC=$(ls ${SRC}/debs/linux-libc*.deb)

  if [ ! -f ${HEADERS} ] || [ ! -f ${IMAGE} ] || [ ! -f ${LIBC} ]; then
    log "Not all packages available, re-run 'mkplatform.sh' first" "err"
    exit
  fi   

  if [ ! -d ${PLATFORMDIR} ]; then
    log "Platform files are missing, re-run 'mkplatform.sh' first" "err"
    exit
  fi

  cd ${PLATFORMDIR}
  rm -r firmware*
  rm -rf $DEVICE

  log "Copy relevant firmware version(s)"
  for fw in ${VOLUMIO_BUILD_FIRMWARE[*]}; do
    firmware_path="${SRC}/firmware/firmware-${fw}.tar.xz"
    chunk_prefix="${firmware_path}.part_"

    if ls "${chunk_prefix}"* &>/dev/null; then
      log "Copying chunked firmware for ${fw}"
      cp "${chunk_prefix}"* .
    elif [[ -f "${firmware_path}" ]]; then
      split_file_if_needed "${firmware_path}"
      if ls "${chunk_prefix}"* &>/dev/null; then
        log "Firmware was split after size check, copying chunks for ${fw}"
        cp "${chunk_prefix}"* .
      else
        log "Copying unchunked firmware for ${fw}"
        cp "${firmware_path}" "firmware-${fw}.tar.xz"
      fi
    else
      log "Missing firmware archive or chunks for ${fw}" "err"
      exit 1
    fi
  done  

  mkdir -p ${DEVICE}
  log "Extract linux headers .deb" 
  dpkg-deb -x $HEADERS ${DEVICE}

  log "Extract linux image .deb" 
  dpkg-deb -x $IMAGE ${DEVICE}
  log "Remove unused /etc"
  rm -r ${DEVICE}/etc
  cp $SRC/VERSION ${PLATFORMDIR}

  log "Extract linux libc .deb" 
  dpkg-deb -x $LIBC ${DEVICE}

  log "Cleanup unused folders"
  rm -rf ${DEVICE}/DEBIAN
  rm -f ${DEVICE}/lib/modules/build

  log "Copy volumio utility scripts"
  cp -pdR "${SRC}/utilities/" ${DEVICE}

  log "Compress ${DEVICE}"
  tar cfJ ${DEVICE}.tar.xz ./${DEVICE}

  # Use shared helper to split if oversized
  split_file_if_needed "${DEVICE}.tar.xz"

  rm -rf $DEVICE
}

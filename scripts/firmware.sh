#!/bin/bash



concatenate_firmware() {

LINUX_FIRMWARE="${LINUX_FW_PREFIX}${1}.tar.xz"
log "Unpacking Linux Firmware $LINUX_FIRMWARE..."

tar xfJ $LINUX_FIRMWARE
exit
for firmware in ${VOLUMIO_FW[*]};
  do
    log "Unpacking/merging ${firmware}"
    tar xfJ ${firmware}.tar.xz
  done


tar xfJ $LINUX_FIRMWARE 

}    

log "Using these configuration parameters" ""
log "LINUX_FW_REL:" "${LINUX_FW_REL[*]}" "cfg"
log "LINUX_FW_PREFIX:" "${LINUX_FW_PREFIX}" "cfg"
log "VOLUMIO_FW:" "${VOLUMIO_FW[*]}" "cfg"

cd ${SRC}/firmware

log "Start processing"
for firmware_release in ${LINUX_FW_REL[*]}; 
  do
    concatenate_firmware $firmware_release
    log "Creating merged firmware-$firmware_release.tar.xz, this can take a minute..."
    tar cfJ firmware-$firmware_release.tar.xz ./lib
    rm -r lib
exit
  done

log "Done" "info"
exit 0

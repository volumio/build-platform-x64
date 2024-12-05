#!/bin/bash
#
# Copyright (c) 2022, 2023 Gé Koerkamp / ge(dot)koerkamp(at)volum##(dot)com
#
# This script is used for building the linux firmware used for Volumio 3.
#
#

SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
# check for whitespace in ${SRC} and exit for safety reasons
grep -q "[[:space:]]" <<<"${SRC}" && { echo "\"${SRC}\" contains whitespaces, this is not supported. Aborting." "err" >&2 ; exit 1 ; }

source "${SRC}"/scripts/helpers.sh
source ${SRC}/config/config.x86

concatenate_firmware() {

LINUX_FIRMWARE="${LINUX_FW_PREFIX}${1}.tar.xz"
log "Unpacking Linux Firmware $LINUX_FIRMWARE..."
tar xfJ $LINUX_FIRMWARE 
log "Done ${LINUX_FW_PREFIX}${1}" "okay"
for firmware in ${VOLUMIO_FW[*]};
  do
    log "Unpacking/merging ${firmware}"
    tar xfJ ${firmware}.tar.xz
    log "Done ${firmware}" "okay"
  done

}    

log "Merging firmware, using these configuration parameters"
log "LINUX_FW_REL: ${LINUX_FW_REL[*]}" "cfg"
log "LINUX_FW_PREFIX: ${LINUX_FW_PREFIX}" "cfg"
log "VOLUMIO_FW: ${VOLUMIO_FW[*]}" "cfg"
log "PLATFORMDIR: ${PLATFORMDIR}" "cfg"

cd ${SRC}/firmware

log "Start processing" "info"
for firmware_release in ${LINUX_FW_REL[*]}; 
  do
    concatenate_firmware $firmware_release
    log "Creating merged firmware-$firmware_release.tar.xz, this can take a minute..."
    tar cfJ ${SRC}/firmware/firmware-$firmware_release.tar.xz ./lib
    log "Done firmware-$firmware_release" "okay"
    rm -r lib
  done

log "Merge done, firmware updated in ${SRC}/firmware" "okay"
exit 0



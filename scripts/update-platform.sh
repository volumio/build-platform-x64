#!/bin/bash

STARTTIME="$(date +%s.%N)" 

log "Using these configuration parameters" "info"
log "INSTALL_MOD_STRIP: ${INSTALL_MOD_STRIP}" "cfg"
log "KERNELDIR        : ${KERNELDIR}" "cfg"
log "CONFIGURE_KERNEL : ${CONFIGURE_KERNEL}" "cfg"
log "PATCHDIR         : ${PATCHDIR}" "cfg"
log "PATCH_KERNEL     : ${PATCH_KERNEL}" "cfg"
log "PATCHWORKDIR     : ${PATCHWORKDIR}" "cfg"
log "PLATFORMDIR      : ${PLATFORMDIR}" "cfg"

log "KERNELREPO       : ${KERNELREPO}" "cfg"
log "KERNELBRANCH_PREV: ${KERNELBRANCH_PREV}" "cfg"
log "KERNELBRANCH     : ${KERNELBRANCH}" "cfg"
log "LOCALVERSION     : ${LOCALVERSION}" "cfg"

source "${SRC}"/scripts/functions.sh

create_platform

log "Build platform files completed" "okay"
dur=$(echo "$(date +%s.%N) - ${STARTTIME}" | bc)
log "$(printf 'Execution time: %.6f seconds\n' $dur)"

exit

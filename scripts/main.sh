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

get_kernel_repo
get_platform_repo

cd $KERNELDIR
clean_previous_builds

get_latest_kernel

add_additional_sources

add_user_patches

if [ "${PATCH_KERNEL}" == "yes" ]; then
   patch_kernel
   exit
fi

prep_kernel_config

configure_kernel

compile_kernel

backup_to_storage

create_platform

log "Build platform files completed" "okay"
dur=$(echo "$(date +%s.%N) - ${STARTTIME}" | bc)
log "$(printf 'Execution time: %.6f seconds\n' $dur)"

exit




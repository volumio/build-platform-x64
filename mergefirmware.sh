#!/bin/bash
#
# Copyright (c) 2022, 2023 Gé Koerkamp / ge(dot)koerkamp(at)volum##(dot)com
#
# This script is used for building the linux firmware used for Volumio 3.
#

SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# check for whitespace in ${SRC} and exit for safety reasons
grep -q "[[:space:]]" <<<"${SRC}" && { echo "\"${SRC}\" contains whitespaces, this is not supported. Aborting." "err" >&2 ; exit 1 ; }

source "${SRC}/scripts/helpers.sh"
source "${SRC}/config/config.x64"

concatenate_firmware() {
  local firmware_id="$1"
  local base_path="${LINUX_FW_PREFIX}${firmware_id}.tar.xz"

  # Use shared helper to detect and reassemble chunks if needed
  reassemble_chunks_if_needed "${base_path}"
  log "Unpacking Linux Firmware ${REASSEMBLED_PATH}..."
  tar xfJ "${REASSEMBLED_PATH}"
  log "Done ${firmware_id}" "okay"

  for firmware in ${VOLUMIO_FW[*]}; do
    log "Unpacking/merging ${firmware}"
    tar xfJ "${firmware}.tar.xz"
    log "Done ${firmware}" "okay"
  done
}

log "Merging firmware, using these configuration parameters"
log "LINUX_FW_REL: ${LINUX_FW_REL[*]}" "cfg"
log "LINUX_FW_PREFIX: ${LINUX_FW_PREFIX}" "cfg"
log "VOLUMIO_FW: ${VOLUMIO_FW[*]}" "cfg"
log "PLATFORMDIR: ${PLATFORMDIR}" "cfg"

cd "${SRC}/firmware" || { log "Failed to cd into firmware directory" "err"; exit 1; }

log "Start processing" "info"

for firmware_release in ${LINUX_FW_REL[*]}; do
  concatenate_firmware "${firmware_release}"

  output_file="${SRC}/firmware/firmware-${firmware_release}.tar.xz"
  log "Creating merged ${output_file}, this can take a minute..."
  tar cfJ "${output_file}" ./lib
  log "Done firmware-${firmware_release}" "okay"

  # Use shared helper to split file if too large
  split_file_if_needed "${output_file}"

  rm -r lib
done

log "Merge done, firmware updated in ${SRC}/firmware" "okay"
exit 0

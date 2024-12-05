#!/bin/bash
#
# Copyright (c) 2022, 2023 Gé Koerkamp / ge(dot)koerkamp(at)volum##(dot)com
#
# This script is used for building the x86 kernel used for Volumio 3.
#
# Prerequisites: build-essential linux-source bc kmod cpio flex cpio libncurses5-dev libelf-dev
#

SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "${SRC}"/scripts/helpers.sh

# check for whitespace in ${SRC} and exit for safety reasons
grep -q "[[:space:]]" <<<"${SRC}" && { log "\"${SRC}\" contains whitespaces, this is not supported. Aborting." "err" >&2 ; exit 1 ; }

log "Reading config"
# shellcheck source=config/config.x86
source "${SRC}"/config/config.x86

log "Start processing"
# shellcheck source=scripts/main.sh
source "${SRC}"/scripts/main.sh



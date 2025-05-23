#!/bin/bash
#
#  This script moves screenshots, created by the 'prtsc' button in '/root', to
#  the more accessible location '/data/INTERNAL/screenshots'.
#  The script is part of Volumio's "move_screenshot.service"

SCROT_DIR=/root
TARGET_DIR=/data/INTERNAL/screenshots

mkdir -p $TARGET_DIR

while true; do
  set -- $SCROT_DIR/*.png
  if [ -f "$1" ]; then
    cp $SCROT_DIR/*.png $TARGET_DIR
    ls -l $TARGET_DIR
    rm $SCROT_DIR/*.png
    chown volumio:volumio $TARGET_DIR/*
    chmod 755 $TARGET_DIR/*.png
  fi
  sleep 1
done


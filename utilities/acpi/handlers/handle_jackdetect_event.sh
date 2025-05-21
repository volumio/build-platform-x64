#!/bin/bash

SUPPORTED_CODECS="bytcr-rt5640|cht-bsw-rt5672"
CODEC=$(aplay -l | egrep -o "${SUPPORTED_CODECS}" | head -1)

if [ -z "$CODEC" ]; then
  logger  "jackdetect.sh: No supported codec detected, exiting"
  exit
fi

logger "$1 $CODEC"

case $1 in
  "jack/headphone HEADPHONE unplug")
    /usr/bin/alsaucm -c $CODEC set _verb HiFi set _enadev Speaker
    ;;
  "jack/headphone HEADPHONE plug")
    /usr/bin/alsaucm -c $CODEC set _verb HiFi set _enadev Headphones
    ;;
esac

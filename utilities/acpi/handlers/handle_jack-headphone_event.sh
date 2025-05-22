#!/bin/bash

EVENT_ID="$1"
SUPPORTED_CODECS="bytcr-rt5640|cht-bsw-rt5672"
CODEC=$(aplay -l | egrep -o "${SUPPORTED_CODECS}" | head -1)

if [ -z "$CODEC" ]; then
  logger  "handle_jack-headphone_event.sh: No supported codec detected, exiting"
  exit
fi

logger "$3 $CODEC"
set  -- $EVENT_ID
case $3 in
  "unplug")
    /usr/bin/alsaucm -c $CODEC set _verb HiFi set _enadev Speaker
    ;;
  "plug")
    /usr/bin/alsaucm -c $CODEC set _verb HiFi set _enadev Headphones
    ;;
esac

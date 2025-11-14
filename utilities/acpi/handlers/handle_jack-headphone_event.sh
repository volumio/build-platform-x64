s#!/bin/bash

EVENT_ID="$1"
SUPPORTED_CODECS="bytcr-rt5640|cht-bsw-rt5672|HDA Intel"
CODEC=$(aplay -l | egrep -o "${SUPPORTED_CODECS}" | head -1)

if [ -z "$CODEC" ]; then
  logger  "handle_jack-headphone_event.sh: No supported codec detected, exiting"
  exit
fi

set  -- $EVENT_ID
case $CODEC in
  "HDA Intel")
    TARGET=$(aplay -l | grep "Generic Analog" | head -1)
    CARDNO=$( echo $TARGET | awk -F':' '{print $1}' | awk -F' ' '{print $2}')
    logger "Cardno: $CARDNO"
    amixer -c 0 set 'Auto-Mute Mode' Disabled
    case $3 in
      "unplug")
	logger "unplug Headphone, unmute Speaker"
	amixer -c $CARDNO "Speaker" unmute
        amixer -c $CARDNO "Headphone" mute
        ;;
      "plug")
        logger "plug Headphone, mute Speaker"
        amixer -c $CARDNO "Speaker" mute
        amixer -c $CARDNO "Headphone" unmute
        ;;
    esac    
    ;;
  *)    
    case $3 in
      "unplug")
        /usr/bin/alsaucm -c $CODEC set _verb HiFi set _enadev Speaker
        ;;
      "plug")
        /usr/bin/alsaucm -c $CODEC set _verb HiFi set _enadev Headphones
        ;;
    esac
    ;;
esac

#!/bin/bash

for CARD in /sys/class/sound/card*; do
  CARDNO=$(cat $CARD/number)
  if [ -f /proc/asound/card$CARDNO/usbid ]; then
    MIXER=$(amixer -c $CARDNO scontrols | awk -F"Simple mixer control " '{print (substr($2, 2, length($2) - 4))}')
  else
    MIXER="Master"
  fi  
  if [ ! -z "$MIXER" ]; then  
     /usr/bin/amixer -c $CARDNO set "$MIXER" toggle
  fi  
done
exit 0

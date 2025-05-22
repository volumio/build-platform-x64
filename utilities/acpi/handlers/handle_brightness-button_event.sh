#!/usr/bin/bash

# $1 is ACPI event

set -e
export DISPLAY=:0.0

EVENT_ID="$1"
STEP=0.05
CONNECTED_DISPLAY=$(xrandr | grep " connected" | cut -f1 -d" ")
CURRENT_BRIGHTNESS=$(xrandr --verbose --current | grep ^"$CONNECTED_DISPLAY" -A5 | tail -n1 )
CURRENT_BRIGHTNESS="${CURRENT_BRIGHTNESS##* }"  # Get brightness numerical figure with decimal place

set  -- $EVENT_ID
case $2 in
  "BRTUP")
    NEW_BRIGHTNESS=$( echo $CURRENT_BRIGHTNESS + $STEP | bc )
    if [ "$CURRENT_BRIGHTNESS" = "1.0" ]; then
      echo "Max brightness reached" >> /tmp/event.log
      NEW_BRIGHTNESS="1.0" # max brightness reached
    else
      NEW_BRIGHTNESS=$( echo $CURRENT_BRIGHTNESS + $STEP | bc )
    fi
    ;;

  "BRTDN")
    NEW_BRIGHTNESS=$( echo $CURRENT_BRIGHTNESS - $STEP | bc )
    if [ "$CURRENT_BRIGHTNESS" = "0.050" ]; then
      NEW_BRIGHTNESS="0.050" # min brightness reached
    else
      NEW_BRIGHTNESS=$( echo $CURRENT_BRIGHTNESS - $STEP | bc )
    fi
    ;;
esac

xrandr --output $CONNECTED_DISPLAY --brightness $NEW_BRIGHTNESS
exit 0

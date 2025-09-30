#!/usr/bin/env bash

# $1 is ACPI event (like BRTUP / BRTDN)
set -e
export DISPLAY=:0.0

EVENT_ID="$1"
STEP=0.05   # step for software brightness (xrandr)

CONNECTED_DISPLAY=$(xrandr | grep " connected" | cut -f1 -d" ")

# Detect hardware backlight interface (first found)
BACKLIGHT_DIR=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n1)
if [ -n "$BACKLIGHT_DIR" ]; then
  MAX=$(cat "$BACKLIGHT_DIR/max_brightness")
  HW_STEP=$(echo $MAX / 20 | bc)  # step for hardware brightness units
fi

set -- $EVENT_ID
case $2 in
  "BRTUP")
    if [ -n "$BACKLIGHT_DIR" ]; then
      CUR=$(cat "$BACKLIGHT_DIR/brightness")
      NEW=$(( CUR + HW_STEP ))
      [ "$NEW" -gt "$MAX" ] && NEW=$MAX
      echo "$NEW" | sudo tee "$BACKLIGHT_DIR/brightness" > /dev/null 
      echo "HW Brightness UP → $NEW/$MAX" >> /tmp/event.log
    else
      CUR=$(xrandr --verbose --current | grep ^"$CONNECTED_DISPLAY" -A5 | grep Brightness | awk '{print $2}')
      NEW=$(echo "$CUR + $STEP" | bc)
      [ "$(echo "$NEW > 1.0" | bc)" -eq 1 ] && NEW=1.0
      xrandr --output "$CONNECTED_DISPLAY" --brightness "$NEW"
      echo "SW Brightness UP → $NEW" >> /tmp/event.log
    fi
    ;;
  "BRTDN")
    if [ -n "$BACKLIGHT_DIR" ]; then
      CUR=$(cat "$BACKLIGHT_DIR/brightness")
      NEW=$(( CUR - HW_STEP ))
      [ "$NEW" -lt 10 ] && NEW=10
      echo "$NEW" | sudo tee "$BACKLIGHT_DIR/brightness" >/dev/null
      echo "HW Brightness DOWN → $NEW/$MAX" >> /tmp/event.log
    else
      CUR=$(xrandr --verbose --current | grep ^"$CONNECTED_DISPLAY" -A5 | grep Brightness | awk '{print $2}')
      NEW=$(echo "$CUR - $STEP" | bc)
      [ "$(echo "$NEW < 0.05" | bc)" -eq 1 ] && NEW=0.05
      xrandr --output "$CONNECTED_DISPLAY" --brightness "$NEW"
      echo "SW Brightness DOWN → $NEW" >> /tmp/event.log
    fi
    ;;
esac

exit 0

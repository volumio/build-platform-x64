#!/bin/bash
CODEC_RT5640="bytcr-rt5640"
CODEC_RT5651="bytcr-rt5651"
CODEC_RT5672="cht-bsw-rt5672"
CODEC_ES8316="bytcht-es8316"

SUPPORTED_ALSAUCM_CODECS="$CODEC_RT5640,$CODEC_RT5651,$CODEC_RT5672,$CODEC_ES8316"

echo $SUPPORTED_ALSAUCM_CODECS
for CARD in /sys/class/sound/card*; do
  CARDNO=$(cat $CARD/number)
  echo "Card number: " $CARDNO
  if [ -f /proc/asound/card$CARDNO/usbid ]; then
    MIXER=$(amixer -c $CARDNO scontrols | awk -F"Simple mixer control " '{print (substr($2, 2, length($2) - 4))}')
    echo "Mixer: " $MIXER
    /usr/bin/amixer -c $CARDNO set "$MIXER" toggle
  else
    echo "Checking CODEC"
    CODEC=$(cat /proc/asound/card$CARDNO/id)
    CODEC=$(aplay -l | grep $CODEC | awk -F'[][]' '{print $2; exit}')
    echo "Real $CODEC"
    if [[ "$SUPPORTED_ALSAUCM_CODECS" == *"$CODEC"* ]]; then
      echo "Found $CODEC OK"
      case $CODEC in
        $CODEC_RT5640 | $CODEC_RT5672)
          echo "Codec RT5640/RT5672"
          mixer_ctl_headphone=$(amixer -c $CARDNO get "Headphone" | grep "Mono: Playback" |awk '{print $3}')
          mixer_ctl_headphone_output=$(amixer -c $CARDNO get "Headphone Output" | grep "Mono: Playback" |awk '{print $3}')
          if [ ! -z "${mixer_ctl_headphone}" ]; then
            echo "Headphone"
            onoff=${mixer_ctl_headphone}
            HEADPHONE_MIXER="Headphone"
          else
            echo "Headphone Output"
            onoff=${mixer_ctl_headphone_output}
            HEADPHONE_MIXER="Headphone Output"
          fi
          /usr/bin/amixer -c $CARDNO set "$HEADPHONE_MIXER" toggle
          /usr/bin/amixer -c $CARDNO set "Speaker" toggle
        ;;
        $CODEC_RT5651 | $CODEC_ES8613)
          MIXER="Headphone"
        ;;
      esac
    else
      /usr/bin/amixer -c $CARDNO set "Master" toggle
    fi
  fi
done

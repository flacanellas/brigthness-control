#!/bin/bash
#
# Brightness Control for debian systems
# Author: Francisca Cañellas 
# Email: francisca.leonor.alejandra.c@gmail.com

AUTHOR_NAME="Francisca Cañellas"
AUTHOR_EMAIL="francisca.leonor.alejandra.c@gmail.com"

# INSTALATION INFO
THIS_FILE="$(basename $0)"
INSTALLATION_PATH="/usr/bin/"

# DEVICES CLASSES LAYER INFO
BACKLIGHT_DRIVER_FOLDER="/sys/class/backlight/intel_backlight";
BRIGHTNESS_MAX=$(cat ${BACKLIGHT_DRIVER_FOLDER}/max_brightness)
BRIGHTNESS_DEVICE="${BACKLIGHT_DRIVER_FOLDER}/brightness"

function show_help {
  echo "Brightness Controll 0.1"
  echo -e "\nWrote by ${AUTHOR_NAME}"
  echo "Email: ${AUTHOR_EMAIL}"
  echo -e "\nUsage: brightness-control [[i|install]|brightness percent(1~100)|[h|help]]"
  echo "- number in range 1~100: Set brightness percent."
  echo "- h|help:                Show help menu."
  echo "- i|install:             Install this file at ${INSTALLATION_PATH} folder. (Only works once.)"
}

function setBrightness {
  # check range
  if [ $1 -gt 0 ] && [ $1 -lt 101 ] ; then
    echo $(( ($1  * ${BRIGHTNESS_MAX}) / 100 )) > ${BRIGHTNESS_DEVICE}
  else
    echo "[Error] brightness out of range 0~100!"
  fi
} 

# process options
case $1 in
  [0-9]*) setBrightness $1;;
  "h"|"help"|"-h"|"--help"|*) show_help;;
esac

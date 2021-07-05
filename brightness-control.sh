#!/bin/bash
#
# Brightness Control for debian systems
# Author: Francisca Cañellas 
# Email: francisca.leonor.alejandra.c@gmail.com

AUTHOR_NAME="Francisca Cañellas"
AUTHOR_EMAIL="francisca.leonor.alejandra.c@gmail.com"

# INSTALATION INFO
THIS_FILE="$(basename $0)"
INSTALLATION_PATH="/usr/bin"

# DEVICES CLASSES LAYER INFO
DRIVER="intel_backlight"
BACKLIGHT_DRIVER_FOLDER="/sys/class/backlight/${DRIVER}";
BRIGHTNESS_MAX=$(cat ${BACKLIGHT_DRIVER_FOLDER}/max_brightness)
BRIGHTNESS_DEVICE="${BACKLIGHT_DRIVER_FOLDER}/brightness"

function install {
    if [[ $(pwd) != ${INSTALLATION_PATH} ]] ; then
        # CHECK ROOT PRIVILEDGES
        if [[ "$UID" -ne 0 ]] ; then
            echo "[Info] I need root priviledges to change brightness!"
        else
            install_path="${INSTALLATION_PATH}/${THIS_FILE/.sh/}"
            echo -n "Installing..."
            cp ${THIS_FILE} $install_path
            echo "[OK]"
            echo "Installed at: '$install_path'"
        fi
    fi
}

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
    # CHECK RANGE OVERLOAD 
    if [[ $1 -gt 0 && $1 -lt 101 ]] ; then
        # CHECK ROOT PRIVILEDGES
        if [[ "$UID" -ne 0 ]] ; then
            echo "[Info] I need root priviledges to change brightness!"
        else
            echo $(( ($1  * ${BRIGHTNESS_MAX}) / 100 )) > ${BRIGHTNESS_DEVICE}
        fi
    else
        echo "[Error] brightness out of range 0~100!"
    fi
} 

# PROCESS OPTIONS
case $1 in
    [0-9]*) setBrightness $1;;
    "i"|"install"|"-i"|"--install") install;;
    "h"|"help"|"-h"|"--help"|*) show_help;;
esac

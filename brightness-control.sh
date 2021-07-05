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

function uninstall {
    # CHECK ROOT PRIVILEDGES
    if [[ "$UID" -ne 0 ]] ; then
        echo "[Info] I need root priviledges to change brightness!"
    else
        echo -n "Uninstalling..."
        exec_path=$(which ${THIS_FILE})
        rm $exec_path
        echo "[OK]"
    fi
}

function install {
    # INSTALL
    if [[ $(dirname $0) != ${INSTALLATION_PATH} ]] ; then
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
    else
        echo -e "[Info] Already installed!\n"
        show_help
    fi
}

function show_help {
    echo "Brightness Controll"
    echo -e "\nWrote by ${AUTHOR_NAME}"
    echo "Email: ${AUTHOR_EMAIL}"
    echo -e "\nUsage: brightness-control [--[install|uninstall]|INTEGER(1~100)|[h|help]]"
    echo "INTEGER in range 1~100: Set brightness percent."
    echo "-[h|help]:              Show help menu."
    echo "--install:              Install at '${INSTALLATION_PATH}/' folder. (Only works once.)"
    echo "--uninstall:            Uninstall from '${INSTALLATION_PATH}/'. (Only works once.)"
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
    "--install") install;;
    "--uninstall") uninstall;;
    "h"|"help"|"-h"|"--help"|*) show_help;;
esac

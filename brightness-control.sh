#!/bin/bash
#
# Brightness Control for debian systems
# Author: Francisca Cañellas 
# Email: francisca.leonor.alejandra.c@gmail.com

# AUTHOR INFO
AUTHOR_NAME="Francisca Cañellas"
AUTHOR_EMAIL="francisca.leonor.alejandra.c@gmail.com"

# DEBUG INFO
# SHOW INFO MESSAGES
INFO=1
# SHOW DEBUG MESSAGES
VERBOSE=0

# INSTALATION INFO
THIS_FILE="$(basename $0)"
INSTALLATION_PATH="/usr/bin"

# DEVICES CLASSES LAYER INFO
DRIVER="intel_backlight"
BACKLIGHT_DRIVER_FOLDER="/sys/class/backlight/${DRIVER}";
BRIGHTNESS_MAX=$(cat ${BACKLIGHT_DRIVER_FOLDER}/max_brightness)
BRIGHTNESS_DEVICE="${BACKLIGHT_DRIVER_FOLDER}/brightness"
BRIGHTNESS_CURR_VAL=$(cat ${BACKLIGHT_DRIVER_FOLDER}/actual_brightness)

# DEVICES VALUES IN PORCENT
# THIS METHOD DO NOT APROXIMATE TO FLOOR INTEGER
# BRIGHTNESS_CURR_PERCENT_VAL=$(( ($BRIGHTNESS_CURR_VAL * 100) / $BRIGHTNESS_MAX ))
BRIGHTNESS_CURR_PERCENT_VAL=$(bc <<< "scale=1; x=( (${BRIGHTNESS_CURR_VAL} * 100) / ${BRIGHTNESS_MAX}); scale=0; x=(x/1)+1; if (x > 100) x= 100; x")
BRIGHTNESS_REMAINING_PERCENT_VAL=$(( 100 - $BRIGHTNESS_CURR_PERCENT_VAL ))

# DEFAULT SETTINGS
BRIGHTNESS_CTRL_DEFAULT_STEP=10

function uninstall {
    # CHECK ROOT PRIVILEDGES
    if [[ "$UID" -ne 0 ]] ; then
        echo "I need root priviledges to change brightness!"
    else
        [[ $INFO -ge 1 ]] && echo -n "[Info] Uninstalling..."
        exec_path=$(which ${THIS_FILE/.sh/})
        rm $exec_path
        [[ $INFO -ge 1 ]] && echo "[OK]"
    fi
}

function install {
    # INSTALL
    if [[ $(dirname $0) != ${INSTALLATION_PATH} ]] ; then
        # CHECK ROOT PRIVILEDGES
        if [[ "$UID" -ne 0 ]] ; then
            echo "I need root priviledges to change brightness!"
        else
            install_path="${INSTALLATION_PATH}/${THIS_FILE/.sh/}"
            [[ $INFO -ge 1 ]] && echo -n "[Info] Installing..."
            cp ${THIS_FILE} $install_path
            [[ $INFO -ge 1 ]] && echo "[OK]"
            [[ $INFO -ge 1 ]] && echo "[Info] Installed at: '$install_path'"
        fi
    else
        [[ $INFO -ge 1 ]] && echo -e "[Info] Already installed!\n"
        show_help
    fi
}

function reinstall {
    # CHECK ROOT PRIVILEDGES
    if [[ "$UID" -ne 0 ]] ; then
        echo "I need root priviledges to change brightness!"
    else
        install_path="${INSTALLATION_PATH}/${THIS_FILE/.sh/}"
        if [[ -e $install_path ]] ; then
             uninstall
             install
        else
            install $0
        fi
    fi
}

function show_help {
    echo "Brightness Controll"
    echo -e "\nWrote by ${AUTHOR_NAME}"
    echo "Email: ${AUTHOR_EMAIL}"
    echo -e "\nUsage: brightness-control [--[install|uninstall]|INTEGER(1~100)|[h|help]]"
    echo ""
    echo "INTEGER in range 1~100: Set brightness percent."
    echo ""
    echo "-[h|help]:              Show help menu."
    echo "--install:              Install at '${INSTALLATION_PATH}/' folder. (Only works once.)"
    echo "--reinstall:            Run Uninstall and Install process or just install (first time)."
    echo "--show:                 Show current brightness."
    echo "--uninstall:            Uninstall from '${INSTALLATION_PATH}/'. (Only works once.)"
    echo ""
    echo "Internal modificable variables:"
    echo "- INFO=1:                       Show [Info] messages."
    echo "- VERBOSE=0:                    Show [Debug] messages."
    echo "- INSTALLATION_PATH:            Setup installation folder on system."
    echo "- BRIGHTNESS_CTRL_DEFAULT_STEP: Setup default step for --up/down options."
    echo ""
    echo "Enviroment variables:"
    echo "- BRIGHTNESS_CTRL_STEP: Setup step for --up/down options from /home/USER_NAME/.bashrc"
    echo "                        (Override internal 'BRIGHTNESS_CTRL_DEFAULT_STEP' variable)."
}

function setBrightness {
    # CHECK ROOT PRIVILEDGES
    if [[ "$UID" -ne 0 ]] ; then
        echo "I need root priviledges to change brightness!"
    else
        # SET BRIGHTNESS UP/DOWN WITHOUT INTEGER PARAMETER
        if [[ -n $1 && $1 =~ ^(\+|\-)$ ]] ; then
            # CHECK FOR INCREMENT PARAMETER
            if [[ -z $2 ]] ; then
                # USE DEFAULT STEP VARIABLE
                if [[ -z "${BRIGHTNESS_CTRL_STEP}" ]] ; then 
                    [[ $VERBOSE -eq 1 ]] && echo "[Debug] setting default brightness step to ${BRIGHTNESS_CTRL_DEFAULT_STEP}!"
                    B_STEP=$BRIGHTNESS_CTRL_DEFAULT_STEP
                # USE ENVIROMENT VARIABLE
                else
                    [[ $VERBOSE -eq 1 ]] && echo "[Debug] using enviroment variable 'BRIGHTNESS_CTRL_STEP'!"
                    B_STEP=$BRIGHTNESS_CTRL_STEP
                fi
            # USE #2 PARAMETER
            else
                B_STEP=$2
            fi

            # FIX STEP LOWER TO 1
            if [[ $B_STEP -lt 1 ]] ; then
                B_STEP=1
                [[ $VERBOSE -eq 1 ]] && echo "[Debug] Step under minimun parameter, fixed to 1%!"
            fi

            # INCREMENTING/DECREMENTING
            case $1 in
                "+")
                    _ACTION="Increasing"

                    # FIX STEP GREATER THAN BRIGHTNESS REMAINING
                    if [[ $B_STEP -ge $BRIGHTNESS_REMAINING_PERCENT_VAL ]] ; then
                        B_STEP=$BRIGHTNESS_REMAINING_PERCENT_VAL
                        [[ $VERBOSE -eq 1 ]] && echo "[Debug] Step exeeds maximun brightness value to increase, fixed to ${B_STEP}%!"
                    fi

                    # CALCULATE BRIGHTNESS FINAL PERCENT 
                    B_STEP=$(( $BRIGHTNESS_CURR_PERCENT_VAL + $B_STEP ))
                    ;;
                "-")
                    _ACTION="reducing"
                    
                    # FIX STEP GREATER/EQUAL THAN CURRENT BRIGHTNESS
                    # REDUCE ALL BRIGHTNESS TO 1%
                    if [[ $B_STEP -ge $BRIGHTNESS_CURR_PERCENT_VAL ]] ; then
                        B_STEP=1
                        [[ $VERBOSE -eq 1 ]] && echo "[Debug] Step exeeds current maximun brightness value to reduce, fixed to ${B_STEP}%!"
                    
                    # CALCULATE BRIGHTNESS TO FINAL PERCENT
                    else
                        B_STEP=$(( $BRIGHTNESS_CURR_PERCENT_VAL - $B_STEP ))
                    fi
                    ;;
            esac

            [[ $INFO -ge 1 ]] && echo -n "[Info] ${_ACTION} brightness to ${B_STEP}%..."
            _b=$(( ($BRIGHTNESS_MAX * $B_STEP) / 100 ))

            # SET BRIGHTNESS
            echo $_b > $BRIGHTNESS_DEVICE
            [[ $INFO -ge 1 ]] && echo "[OK]"
        # CHECK RANGE OVERLOAD 
        elif [[ $1 -ge 1 && $1 -lt 101 ]] ; then
            echo $(( ($1  * ${BRIGHTNESS_MAX}) / 100 )) > ${BRIGHTNESS_DEVICE}
        else
            echo "[Error] Brightness out of range 1~100!"
        fi
    fi

} 

function show {
    echo "Current Brightness: ${BRIGHTNESS_CURR_PERCENT_VAL}%"
}

# REQUEST FOR SUDO
if [[ $EUID != 0 ]] ; then
    sudo -E "$0" "$@"
    exit
fi

# PROCESS OPTIONS
case $1 in
    [0-9]*) setBrightness $1;;
    "--up") setBrightness "+" $2;;
    "--down") setBrightness "-" $2;;
    "--install") install;;
    "--reinstall") reinstall;;
    "--show") show;;
    "--uninstall") uninstall;;
    "h"|"help"|"-h"|"--help"|*) show_help;;
esac

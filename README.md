### Dev note

I think there are all my needs covered... in this script.<br>
I have laptops with radeon and nvidia GPUs, but I don't have enough time to support it.<br>
Because I don't use that laptops anymore. (They are backup machines).

# Brightness Control
A debian based system tool for screen brightness controll.

***Note:*** *Only for intel graphics.*

# Setup installation path

**Default path**: `/usr/bin`

## Open file

* Vim: `vim ./brightness-control.sh` <br>
* Gedit: `gedit ./brightness-control.sh`<br>
* Nano: `nano ./brightness-control.sh`

## Setup install path 

Set **'INSTALLATION_PATH'** variable to your preffer path.

# Install

***Note:*** *If you want to change default install path, please see *Setup install path* above!*

`./brightness-control --install`

# Uninstall

* `./brightness-control.sh --uninstall`
* `brightness-control --uninstall` (once installed)

# Reinstall

Remove and install script (or just install the first time).

`./brightness-control.sh --reinstall`

# Usage (after installation)

## Show help

* `brightness-control`
* `brightness-control --help`

## Set brightness to value (in range 1%~100%)

`brightness-control value`

## Show current brightness

`brightness-control --show`

## Setup brightness up/down

***Note:*** *This option read enviroment variable `BRIGHTNESS_CTRL_STEP` or (when undefined)
      internal `BRIGHTNESS_CTRL_DEFAULT_STEP`.*

* `brightness-control --up`
* `brightness-control --down`

# Enviroment Variables

***Note:*** *Setup this at `/home/USER_FOLDER/.bashrc`*

## BRIGHTNESS_CTRL_STEP:

Control how much much change screen brightness with `--down` and `--up` options.

`export BRIGHTNESS_CTRL_STEP=STEP_VALUE`

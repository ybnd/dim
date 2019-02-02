# dim

`xrandr` brightness settings shorthand for multiple monitors.
Doesn't work under `wayland`.

#### Setup

Copy `.dim` into your home directory and change the `display` parameter to match your monitor setup (as seen in `xrandr`); the script runs `xrandr --output <monitor> --brightness <brightness>` for all the monitors you specify.

#### Usage

* Show the current brightness value: `dim.sh`
* Set a brightness value: `dim.sh 0.5` or `dim.sh -b 0.5`
* Increment the current brightness value: `dim.sh -d 0.25`
* Decrement the current brightness value: `dim.sh -d -0.25`








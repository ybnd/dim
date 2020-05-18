#!/bin/bash

# Requirements:
#   - install ddcutil
#   - install i2c-tools ~ i2c-dev module must be running (modprobe i2c-dev, add to /etc/modules-load.d/modules.conf to load on boot)
#   - make an i2c group (groupadd i2c)
#   - add user to i2c group (usermod -aG i2c $user) and make sure that the i2c group has rw access to /dev/i2c-*
#   - add udev rule: cp /usr/share/ddcutil/data/45-ddcutil-i2c.rules /etc/udev/rules.d

# todo: add help
# todo: combine ddcutil / xrandr / wayland into one script
#			-> common argument parsing
#			-> configure checks which approach can be used (ddcutil - gnome - xrandr) & 
# todo: deal with uninitialized ~/.config/dim


# Read ~/.dim
brightness=$(awk -F "=" '/brightness/ {print $2}' ~/.config/dim)


if [[ $1 =~ ^[0-9]+$ ]] ;
then
    # If first argument is numeric, just set that as the brightness
    brightness=$1
else
    # Parse commandline arguments & get new brightness value    
    while getopts ":configure:" opt; do
        case $opt in
        	configure)
        		# todo: doesn't work...
        	
        		# configure displays (this takes too long to do every time the command runs)
        		# get i2c bus numbers ~ ddcutil & write to ~/.config/dim
        		let DISPLAY=$(ddcutil detect | sed -rn 's/.*\/dev\/i2c-([[:digit:]])/\1/p' | tr '\n' ',' | sed '$s/,$/\n/')
				sed -i "s/^display=.*/display=$DISPLAY/" ~/.config/dim
				;;
        esac
    done
fi
let "dbrightness = $brightness"  # todo: what is this and why

declare -a DISPLAY
IFS=", " read -a DISPLAY <<< "$(awk -F "=" '/display/ {print $2}' ~/.config/dim)"

for b in "${DISPLAY[@]}"
do
	ddcutil -b $b setvcp 10 $dbrightness &  # apply in parallel!
done

# Write the new brightness to ~/.config/dim
sed -i "s/^brightness=.*/brightness=$brightness/" ~/.config/dim
echo "brightness=$brightness"

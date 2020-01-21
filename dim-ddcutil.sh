#!/bin/bash

# Requirements:
#   - install ddcutil
#   - install i2c-tools ~ i2c-dev module must be running (modprobe i2c-dev, add to /etc/modules-load.d/modules.conf to load on boot)
#   - make an i2c group (groupadd i2c)
#   - add user to i2c group (usermod -aG i2c $user) and make sure that the i2c group has rw access to /dev/i2c-*
#   - add udev rule: cp /usr/share/ddcutil/data/45-ddcutil-i2c.rules /etc/udev/rules.d


# Read ~/.dim
brightness=$(awk -F "=" '/brightness/ {print $2}' ~/.dim)
prev_brightness=$brightness
display0=$(awk -F "=" '/display0/ {print $2}' ~/.dim)
display1=$(awk -F "=" '/display1/ {print $2}' ~/.dim)   # todo: should handle arbitrary nuùber of displays
                                                        # todo: if not set in ~/.dim, try to query ddcutil, or at least warn the user


if [[ $1 =~ ^[0-9]+$ ]] ;
then
    # If first argument is numeric, just set that as the brightness
    brightness=$1
else
    # Parse commandline arguments & get new brightness value    
    while getopts ":b:d:e:i:" opt; do
        case $opt in
            b)
                brightness=$OPTARG
                ;;
            d)            
                brightness=$(echo "$brightness + $OPTARG" | bc) #bash can't parse floating-point!            
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
            :)
                echo "Option $OPTARG requires an argument" >&2
                exit 1
                ;;
        esac
    done
fi
let "dbrightness = $brightness"

# Send DDC in parallel
# todo: should reformat this to handle more than 2 displays in a readable way while stil running all displays in parallel
ddcutil -b $display0 setvcp 10 $dbrightness &ddcutil -b $display1 setvcp 10 $dbrightness &&disown  # Look up i2c bus(es) for display!

# Write the new brightness to ~/.dim
sed -i "s/^brightness=$prev_brightness/brightness=$brightness/" ~/.dim

echo "brightness=$brightness"

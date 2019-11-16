#!/bin/bash

# Requirements:
#   - install ddcutil
#   - install i2c-tools ~ i2c-dev module must be running (modprobe i2c-dev, add to /etc/modules-load.d/modules.conf to load on boot)
#   - make an i2c group
#   - add user to i2c group (usermod -aG i2c $user) and make sure that the i2c group has rw access to /dev/i2c-*

# Reset option argument environment variable
OPTIND=1

# Read ~/.dim
brightness=$(awk -F "=" '/brightness/ {print $2}' ~/.dim)
prev_brightness=$brightness
display=$(awk -F "=" '/display/ {print $2}' ~/.dim)

set_ext=true
set_int=true
continue=true


if [[ $1 =~ ^[0-9]+$ ]] ;
then
    # If first argument is numeric, just set that as the brightness
    brightness=$1
elif [ $1 == "x" ]
then
    set_ext=false
    set_int=false
                
    gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 0>" > /dev/null

    continue=false
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
            e)
                brightness=$OPTARG
                set_int=false
                ;;
            i)dim 
                brightness=$OPTARG
                set_ext=false
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

if $continue; then
    # Scale the brightness for GNOME
    gzero=10
    let "gbrightness = $gzero + $brightness*(100-$gzero)/100"
    let "dbrightness = $brightness / 5 * 2"
    
    if (( $gbrightness > 100)) ;
    then 
        gbrightness=100
    fi

    if $set_ext; then
        ddcutil -b 8 setvcp 10 $dbrightness   # Look up i2c bus for display!
    fi

    if $set_int; then
        gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 $gbrightness>" > /dev/null
    fi

    # Write the new brightness to ~/.dim
    sed -i "s/^brightness=$prev_brightness/brightness=$brightness/" ~/.dim

    echo "brightness=$brightness"
fi

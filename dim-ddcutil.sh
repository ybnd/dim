#!/bin/bash

# Requirements:
#   - install ddcutil
#   - install i2c-tools ~ i2c-dev module must be running (modprobe i2c-dev, add to /etc/modules-load.d/modules.conf to load on boot)
#   - make an i2c group
#   - add user to i2c group (usermod -aG i2c $user) and make sure that the i2c group has rw access to /dev/i2c-*

# Reset option argument environment variable


# Read ~/.dim
brightness=$(awk -F "=" '/brightness/ {print $2}' ~/.dim)
prev_brightness=$brightness
display=$(awk -F "=" '/display/ {print $2}' ~/.dim)


brightness=$1

let "dbrightness = $brightness / 5 * 2"

# Send DDC in parallel
ddcutil -b 7 setvcp 10 $dbrightness &ddcutil -b 8 setvcp 10 $dbrightness  # Look up i2c bus(es) for display!

# Write the new brightness to ~/.dim
sed -i "s/^brightness=$prev_brightness/brightness=$brightness/" ~/.dim

echo "brightness=$brightness"

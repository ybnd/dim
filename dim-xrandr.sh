#!/bin/bash

# Reset option argument environment variable
OPTIND=1

# Read ~/.dim
brightness=$(awk -F "=" '/brightness/ {print $2}' ~/.dim)
prev_brightness=$brightness
display=$(awk -F "=" '/display/ {print $2}' ~/.dim)


if [[ $1 =~ ^[0-9]+([.][0-9]+)?$ ]] ;
then
    # If first argument is numeric, just set that as the brightness
    brightness=$1
else
    # Parse commandline arguments & get new brightness value    
    while getopts ":b:d:" opt; do
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

echo "brightness=$brightness"

# Set the new brightness value for all monitors listed in ~/.dim
OIFS=$IFS
IFS=','
for d in $display
do
    xrandr --output $d --brightness $brightness
done
IFS=$OIFS    

# Write the new brightness to ~/.dim
sed -i "s/^brightness=$prev_brightness/brightness=$brightness/" ~/.dim

#!/bin/bash

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "---- Welcome to Temperature Controller ----"
read -p "Enter Relay Pin: " relay_pin
read -p "Enter Temp Sensor Pin: " tempsensor_pin
read -p "Enter the desired temperature (deg. C): " set_temperature
echo "~~~ Starting the controller ~~~"
echo "Press Ctr+C to terminate"

echo "$relay_pin" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/"gpio$relay_pin"/value

# enabling one-wire interface
if grep -q dtoverlay=w1-gpio /boot/config.txt; 
then
    echo "dtoverlay=w1-gpio"
else
    text="
    dtoverlay=w1-gpio"
    sudo sh -c "echo '${text}'>>/boot/config.txt"
    echo "Appended dtoverlay=w1-gpio to /boot/config.txt"
    echo "Please Reboot your Pi. Exiting..."
    exit 1
fi

while true
do
    data=$(cat /sys/bus/w1/devices/28-*/temperature)

    if [[ data -lt (set_temperature*1000)]]
    then
        echo "1" > /sys/class/gpio/"gpio$relay_pin"/value
        if [[ data -gt (set_temperature*1000 + 500)]]
        then
            echo "0" > /sys/class/gpio/"gpio$relay_pin"/value
        fi
    fi

    echo "$(echo "scale=1;$data/1000"|bc)"" $(awk 'BEGIN { print "\xc2\xb0C"; }')"
    echo "relay status: " cat /sys/class/gpio/"gpio$relay_pin"/value
    sleep 1s
done

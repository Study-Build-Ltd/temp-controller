#!/bin/bash

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "---- Welcome to Temperature Controller ----"
read -p "Enter Relay Pin: " relay_pin
read -p "Enter Temp Sensor Pin: " tempsensor_pin
read -p "Enter the desired temperature (deg. C): " set_temperature
echo "~~~ Starting the controller ~~~"
echo "Press Ctr+C to terminate"

echo relay_pin > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio17/value

while true
do

    data=$(cat /sys/bus/w1/devices/28-*/temperature)
    echo "$(echo "scale=1;$data/1000"|bc)"" $(awk 'BEGIN { print "\xc2\xb0C"; }')"
    sleep 1s
done

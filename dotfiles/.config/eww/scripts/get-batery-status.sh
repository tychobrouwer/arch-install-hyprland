#!/bin/sh

if [[ ! -d "/sys/class/power_supply" ]]; then
  echo 0
else
  FILES=$(ls /sys/class/power_supply/BAT*/status)
  
  cat ${FILES[0]}
fi

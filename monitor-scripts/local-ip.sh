#!/bin/bash
wlan=$(</var/dashboard/services/wifi)

ethernet=$(ip address show eth0 | grep "inet " | egrep -o "inet [^.]+.[^.]+.[^.]+.[^/]+" | sed -e "s/inet //")
ethernet="eth0: "$ethernet

cat /dev/null > /var/dashboard/statuses/local-ip

if [[ $wlan != 'disabled' ]]; then
  wifi=$(ip address show wlan0 | grep "inet " | egrep -o "inet [^.]+.[^.]+.[^.]+.[^/]+" | sed -e "s/inet //")
  wifi="wlan0: "$wifi
fi

if [[ $ethernet != "eth0: " ]]; then
  echo $ethernet" /" > /var/dashboard/statuses/local-ip
fi

if [[ $wlan != 'disabled' ]]; then
  echo $wifi >> /var/dashboard/statuses/local-ip
fi

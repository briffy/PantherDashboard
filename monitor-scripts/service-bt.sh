#!/bin/bash
status=$(cat /var/dashboard/services/BT | tr -d "\n")

if [[ $status == 'stop' ]]; then
  sudo /opt/gateway_config/bin/gateway_config advertise off
  echo 'stopping' > /var/dashboard/services/BT
fi

if [[ $status == 'start' ]]; then
  sudo /opt/gateway_config/bin/gateway_config advertise on
  echo 'starting' > /var/dashboard/services/BT
fi

if [[ $status == 'starting' ]]; then
  advertise_status=$(sudo /opt/gateway_config/bin/gateway_config advertise status | tr -d "\n")
  if [[ $advertise_status == on ]]; then
    echo 'running' > /var/dashboard/services/BT
  fi
fi

if [[ $status == 'stopping' ]]; then
  advertise_status=$(sudo /opt/gateway_config/bin/gateway_config advertise status | tr -d "\n")
  if [[ $advertise_status == off ]]; then
    echo 'disabled' > /var/dashboard/services/BT
  fi
fi

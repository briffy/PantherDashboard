#!/bin/bash
status=$(cat /var/dashboard/services/BT | tr -d "\n")
pantherx_ver=$(cat /var/dashboard/statuses/pantherx_ver)

if [[ "$pantherx_ver" = "X1" ]]; then
    gateway_config_path="/opt/gateway_config"
fi

if [[ "$pantherx_ver" = "X2" ]]; then
    gateway_config_path="/opt/panther-x2/gateway_config"
fi


if [[ $status == 'stop' ]]; then
  sudo ${gateway_config_path}/bin/gateway_config advertise off
  echo 'stopping' > /var/dashboard/services/BT
fi

if [[ $status == 'start' ]]; then
  sudo ${gateway_config_path}/bin/gateway_config advertise on
  echo 'starting' > /var/dashboard/services/BT
fi

if [[ $status == 'starting' ]]; then
  advertise_status=$(sudo ${gateway_config_path}/bin/gateway_config advertise status | tr -d "\n")
  if [[ $advertise_status == on ]]; then
    echo 'running' > /var/dashboard/services/BT
  fi
fi

if [[ $status == 'stopping' ]]; then
  advertise_status=$(sudo ${gateway_config_path}/bin/gateway_config advertise status | tr -d "\n")
  if [[ $advertise_status == off ]]; then
    echo 'disabled' > /var/dashboard/services/BT
  fi
fi

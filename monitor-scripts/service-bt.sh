#!/bin/bash
status=$(cat /var/dashboard/services/BT | tr -d "\n")

if [[ $status == 'stop' ]]; then
  bash /opt/gateway_config/bin/gateway_config advertise off
  echo 'stopping' > /var/dashboard/services/BT
fi

if [[ $status == 'start' ]]; then
  bash /opt/gateway_config/bin/gateway_config advertise on > /etc/monitor-scripts/bt.log
  echo 'starting' > /var/dashboard/services/BT
fi

if [[ $status == 'starting' ]]; then
  advertise_status=$(bash /opt/gateway_config/bin/gateway_config advertise status | tr -d "\n")
  if [[ $advertise_status == on ]]; then
    echo 'running' > /var/dashboard/services/BT
  fi
fi

if [[ $status == 'stopping' ]]; then
  advertise_status=$(bash /opt/gateway_config/bin/gateway_config advertise status | tr -d "\n")
  if [[ $advertise_status == off ]]; then
    echo 'disabled' > /var/dashboard/services/BT
  fi
fi

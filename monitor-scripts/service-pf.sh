#!/bin/bash
status=$(cat /var/dashboard/services/PF | tr -d "\n")

if [[ $status == 'stop' ]]; then
  systemctl stop lora-pkt-fwd.service
  echo 'disabled' > /var/dashboard/services/PF
fi

if [[ $status == 'start' ]]; then
  systemctl start lora-pkt-fwd.service
  echo 'starting' > /var/dashboard/services/PF
fi

if [[ $status == 'starting' ]]; then
  pid=$(sudo pgrep lora_pkt_+)
  if [[ $pid ]]; then
    echo 'running' > /var/dashboard/services/PF
  fi
fi

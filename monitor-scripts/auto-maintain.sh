#!/bin/bash
service=$(cat /var/dashboard/services/auto-maintain | tr -d '\n')

if [[ $service == 'enabled' ]]; then
  bash /etc/monitor-scripts/helium-statuses.sh &> /dev/null
  current_docker_status=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}")
  pubkey=$(cat /var/dashboard/statuses/animal_name)
  pantherx_ver=$(cat /var/dashboard/statuses/pantherx_ver)

  if [[ ! $current_docker_status =~ 'Up' ]]; then
    echo "[$(date)] Problems with docker, trying to start..." >> /var/dashboard/logs/auto-maintain.log
    docker start helium-miner
    sleep 1m
    current_docker_status=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}")
    uptime=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}" | grep -Po "Up [0-9]* seconds" | sed 's/ seconds//' | sed 's/Up //')

    if [[ ! $current_docker_status =~ 'Up' ]] || [[ $uptime != '' && $uptime -le 55 ]]; then
      echo "[$(date)] Still problems with docker, trying a miner update..." >> /var/dashboard/logs/auto-maintain.log
      echo 'start' > /var/dashboard/services/miner-update
      bash /etc/monitor-scripts/miner-update.sh
      sleep 1m
      current_docker_status=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}")
      uptime=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}" | grep -Po "Up [0-9]* seconds" | sed 's/ seconds//' | sed 's/Up //')

      if [[ ! $current_docker_status =~ 'Up' || $uptime != '' && $uptime -le 55 ]]; then
        echo "[$(date)] STILL problems with docker, trying a blockchain clear..." >> /var/dashboard/logs/auto-maintain.log
        echo 'start' > /var/dashboard/services/clear-blockchain
        bash /etc/monitor-scripts/clear-blockchain.sh
        sleep 1m
      fi
    fi
  fi

  if [[ ! $pubkey ]]; then
    echo "[$(date)] Your public key is missing, trying a refresh..." >> /var/dashboard/logs/auto-maintain.log
    bash /etc/monitor-scripts/pubkeys.sh
  fi

  if [[ ! $pantherx_ver ]]; then
    echo "[$(date)] Your pantherx version is missing, trying a refresh..." >> /var/dashboard/logs/auto-maintain.log
    bash /etc/monitor-scripts/pantherx_ver_check.sh
  fi
fi

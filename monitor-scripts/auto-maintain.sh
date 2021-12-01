#!/bin/bash
service=$(cat /var/dashboard/services/auto-maintain | tr -d '\n')

if [[ $service == 'enabled' ]]; then
  bash /etc/monitor-scripts/update-check.sh &> /dev/null
  bash /etc/monitor-scripts/miner-version-check.sh &> /dev/null
  bash /etc/monitor-scripts/helium-statuses.sh &> /dev/null
  current_docker_status=$(sudo docker ps -a -f name=miner --format "{{ .Status }}")
  current_info_height=$(cat /var/dashboard/statuses/infoheight)
  live_height=$(cat /var/dashboard/statuses/current_blockheight)
  snap_height=$(wget -q https://helium-snapshots.nebra.com/latest.json -O - | grep -Po '\"height\": [0-9]*' | sed 's/\"height\": //')
  pubkey=$(cat /var/dashboard/statuses/animal_name)

  if [[ ! $current_docker_status =~ 'Up' ]]; then
    echo "[$(date)] Problems with docker, trying to start..." >> /var/dashboard/logs/auto-maintain.log
    docker start miner
    sleep 1m
    current_docker_status=$(sudo docker ps -a -f name=miner --format "{{ .Status }}")
    uptime=$(sudo docker ps -a -f name=miner --format "{{ .Status }}" | grep -Po "Up [0-9]* seconds" | sed 's/ seconds//' | sed 's/Up //')

    if [[ ! $current_docker_status =~ 'Up' ]] || [[ $uptime != '' && $uptime -le 55 ]]; then
      echo "[$(date)] Still problems with docker, trying a miner update..." >> /var/dashboard/logs/auto-maintain.log
      echo 'start' > /var/dashboard/services/miner-update
      bash /etc/monitor-scripts/miner-update.sh
      sleep 1m
      current_info_height=$(cat /var/dashboard/statuses/infoheight)
      current_docker_status=$(sudo docker ps -a -f name=miner --format "{{ .Status }}")
      uptime=$(sudo docker ps -a -f name=miner --format "{{ .Status }}" | grep -Po "Up [0-9]* seconds" | sed 's/ seconds//' | sed 's/Up //')

      if [[ ! $current_docker_status =~ 'Up' || $uptime != '' && $uptime -le 55 ]]; then
        echo "[$(date)] STILL problems with docker, trying a blockchain clear..." >> /var/dashboard/logs/auto-maintain.log
        echo 'start' > /var/dashboard/services/clear-blockchain
        bash /etc/monitor-scripts/clear-blockchain.sh
        sleep 1m
        current_info_height=$(cat /var/dashboard/statuses/infoheight)
      fi
    fi
  fi
  if [[ $live_height ]] && [[ $snap_height ]]; then
    let "snapheight_difference = $live_height - $snap_height"
  fi

  if [[ $live_height ]] && [[ $current_info_height ]]; then
    let "blockheight_difference = $live_height - $current_info_height"
  fi

  if [[ $blockheight_difference -ge 500 ]]; then
    echo "[$(date)] Big difference in blockheight, doing a fast sync..." >> /var/dashboard/logs/auto-maintain.log
    wget https://helium-snapshots.nebra.com/snap-$snap_height -O /home/pi/hnt/miner/snap/snap-latest
    docker exec miner miner repair sync_pause
    docker exec miner miner repair sync_cancel
    docker exec miner miner snapshot load /var/data/snap/snap-latest
    sleep 2m
    sync_state=$(docker exec miner miner repair sync_state)

    if [[ $sync_state == 'sync active' ]]; then
      docker exec miner miner repair sync_resume
    else
      sleep 2m
      docker exec miner miner repair sync_resume
    fi
  fi

  if [[ ! $pubkey ]]; then
    echo "[$(date)] Your public key is missing, trying a refresh..." >> /var/dashboard/logs/auto-maintain.log
    bash /etc/monitor-scripts/pubkeys.sh
  fi
fi

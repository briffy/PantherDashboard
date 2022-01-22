#!/bin/bash
service=$(cat /var/dashboard/services/fastsync | tr -d '\n')

if [[ $service == 'start' ]]; then
  echo 'running' > /var/dashboard/services/fastsync
  sudo /opt/a_eur.sh
fi

if [[ $service == 'running' ]]; then
  sync_state=$(docker exec helium-miner miner repair sync_state)
  if [[ $sync_state != 'sync active' ]]; then
    docker exec helium-miner miner repair sync_resume
    echo 'stopped' > /var/dashboard/services/fastsync
  fi
fi

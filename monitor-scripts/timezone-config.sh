#!/bin/bash
file=/var/dashboard/timezone_config

if [ -f "$file" ]; then
  timezone=`cat $file`
  timedatectl set-timezone $timezone
  rm -f $file
  currentdockerstatus=$(docker ps -a -f name=helium-miner --format "{{ .Status }}")
  if [[ $currentdockerstatus =~ 'Up' ]]; then
    currentbinds=$(docker inspect --format "{{.HostConfig.Binds}}" helium-miner)
    if [[ $currentbinds =~ '/etc/timezone' ]]; then
      docker restart helium-miner
    else
      docker rm -f helium-miner
      /etc/monitor-scripts/auto-maintain.sh
    fi
  fi
fi

#!/bin/bash
service=$(cat /var/dashboard/services/auto-update | tr -d '\n')

if [[ $service == 'enabled' ]]; then
  if [[ $dashboard_version != $latest_dashboard_version ]]; then
    echo "[$(date)] Dashboard is out of date (why don't you love me?), trying a dashboard update..." >> /var/dashboard/logs/auto-update.log
    echo 'start' > /var/dashboard/services/dashboard-update
    bash /etc/monitor-scripts/dashboard-update.sh
  fi

  if [[ $miner_version ]] && [[ $latest_miner_version ]]; then
    if [[ $miner_version != $latest_miner_version ]]; then
      echo "[$(date)] Miner is out of date, trying a miner update..." >> /var/dashboard/logs/auto-update.log
      echo 'start' > /var/dashboard/services/miner-update
      bash /etc/monitor-scripts/miner-update.sh
    fi
  fi
fi

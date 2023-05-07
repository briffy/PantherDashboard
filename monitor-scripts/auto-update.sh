#!/bin/bash
service=$(cat /var/dashboard/services/auto-update | tr -d '\n')
bash /etc/monitor-scripts/update-check.sh &> /dev/null
bash /etc/monitor-scripts/miner-version-check.sh &> /dev/null

dashboard_version=$(cat /var/dashboard/version | tr -d '\n')
latest_dashboard_version=$(cat /var/dashboard/update | tr -d '\n')

miner_version=$(cat /var/dashboard/statuses/current_miner_version | tr -d '\n')
latest_miner_version=$(cat /var/dashboard/statuses/latest_miner_version | tr -d '\n')

if [[ $service == 'enabled' ]]; then
  if [[ $dashboard_version != $latest_dashboard_version ]]; then
    echo "[$(date)] Dashboard is out of date (why don't you love me?), trying a dashboard update..." >> /var/dashboard/logs/auto-update.log
    echo 'start' > /var/dashboard/services/dashboard-update
    bash /etc/monitor-scripts/dashboard-update.sh
  fi

  if [[ $latest_miner_version ]]; then
    if [[ $miner_version != $latest_miner_version ]]; then
      echo "[$(date)] Miner is out of date, trying a miner update..." >> /var/dashboard/logs/auto-update.log
      echo 'start' > /var/dashboard/services/miner-update
      bash /etc/monitor-scripts/miner-update.sh
    fi
  fi

  # Check and update gateway-rs configuration file
  echo "bfa7d6eaae706a2342ea2155d9ea3a8a  /root/helium/overlay/settings.toml" | md5sum -c
  retval=$?
  if [[ $retval -ne 0 ]]; then
    cp -f /var/dashboard/config/settings.toml /root/helium/overlay/settings.toml
    docker restart helium-miner
  fi
fi

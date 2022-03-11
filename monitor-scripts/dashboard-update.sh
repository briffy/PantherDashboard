#!/bin/bash
name="dashboard-update"
service=$(cat /var/dashboard/services/dashboard-update | tr -d '\n')

# Fix invalid status when boot finish
if [[ $service == 'running' ]]; then
  if [[ ! -f /tmp/dashboard-$name-flag ]]; then
    echo 'stopped' > /var/dashboard/services/$name
  fi
fi

if [[ $service == 'start' ]]; then
  touch /tmp/dashboard-$name-flag
  echo 'running' > /var/dashboard/services/$name
  wget https://raw.githubusercontent.com/Panther-X/PantherDashboard/main/update.sh -O - | sudo bash
fi

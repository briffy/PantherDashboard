#!/bin/bash
if test -f /var/dashboard/branch; then
  BRANCH=`cat /var/dashboard/branch`
else
  BRANCH='main'
fi

wget --no-cache https://raw.githubusercontent.com/Panther-X/PantherDashboard/${BRANCH}/latest_miner_version -O /var/dashboard/statuses/latest_miner_version
docker ps --format "{{.Image}}" --filter "name=helium-miner" | grep -Po "miner-arm64_.*" > /var/dashboard/statuses/current_miner_version

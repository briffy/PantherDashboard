#!/bin/bash
name="miner-update"
service=$(cat /var/dashboard/services/$name | tr -d '\n')
version=$(cat /var/dashboard/statuses/latest_miner_version | tr -d '\n')
pantherx_ver=$(cat /var/dashboard/statuses/pantherx_ver)

if [[ "$pantherx_ver" = "X1" ]]; then
    miner_data_path="/opt/miner_data"
fi

if [[ "$pantherx_ver" = "X2" ]]; then
    miner_data_path="/opt/panther-x2/miner_data"
fi

# Fix invalid status when boot finish
if [[ $service == 'running' ]]; then
  if [[ ! -f /tmp/dashboard-$name-flag ]]; then
    echo 'stopped' > /var/dashboard/services/$name
  fi
fi

if [[ $service == 'start' ]]; then
  touch /tmp/dashboard-$name-flag
  echo 'running' > /var/dashboard/services/$name
  echo 'Stopping currently running docker...' > /var/dashboard/logs/$name.log
  docker stop helium-miner >> /var/dashboard/logs/$name.log
  currentdockerstatus=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}")
  if [[ $currentdockerstatus =~ 'Exited' || $currentdockerstatus == '' ]]; then
    echo 'Removing currently running docker...' >> /var/dashboard/logs/$name.log
    docker rm helium-miner
    echo 'Acquiring and starting latest docker version...' >> /var/dashboard/logs/$name.log
    docker image pull quay.io/team-helium/miner:$version >> /var/dashboard/logs/$name.log
    mkdir -p ${miner_data_path}/log
    docker run -d --init --ulimit nofile=64000:64000 --restart always --publish 127.0.0.1:1680:1680/udp --publish 44158:44158/tcp --name helium-miner --mount type=bind,source=${miner_data_path},target=/var/data --mount type=bind,source=${miner_data_path}/log,target=/var/log/miner --device /dev/i2c-1  --privileged -v /var/run/dbus:/var/run/dbus -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --mount type=bind,source=/root/helium/overlay/docker.config,target=/config/sys.config quay.io/team-helium/miner:$version >> /var/dashboard/logs/$name.log

    currentdockerstatus=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}")
    if [[ $currentdockerstatus =~ 'Up' ]]; then
      echo 'stopped' > /var/dashboard/services/$name
      echo $version > /var/dashboard/statuses/current_miner_version
      echo "DISTRIB_RELEASE=$(echo $version | sed -e 's/miner-arm64_//' | sed -e 's/_GA//')" > /etc/lsb_release
      echo 'Update complete.' >> /var/dashboard/logs/$name.log
    else
      echo 'stopped' > /var/dashboard/services/$name
      echo 'Miner docker failed to start.  Check logs to investigate.'
    fi
  else
    echo 'stopped' > /var/dashboard/services/$name
    echo 'Error: Could not stop docker.' >> /var/dashboard/logs/$name.log
  fi
fi

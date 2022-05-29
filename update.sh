#!/bin/bash
sudo apt-get -f install --assume-yes

if test -f /var/dashboard/branch; then
  BRANCH=`cat /var/dashboard/branch`
else
  BRANCH='main'
fi

if id -nG admin | grep -qw "sudo"; then
  rm -rf /tmp/latest.tar.gz
  rm -rf /tmp/PantherDashboard-*
  mkdir -p /var/dashboard/logs/
  echo 'Downloading latest release...' > /var/dashboard/logs/dashboard-update.log
  if test -f /var/dashboard/commit-hash; then
    VER=`cat /var/dashboard/commit-hash`
    wget --no-cache https://codeload.github.com/Panther-X/PantherDashboard/tar.gz/${VER} -O /tmp/latest.tar.gz
  else
    wget https://raw.githubusercontent.com/Panther-X/PantherDashboard/${BRANCH}/version -O /tmp/dashboard_latest_ver
    VER=`cat /tmp/dashboard_latest_ver`
    wget --no-cache https://codeload.github.com/Panther-X/PantherDashboard/tar.gz/refs/tags/${VER} -O /tmp/latest.tar.gz
  fi
  cd /tmp
  if test -f latest.tar.gz; then
    echo 'Extracting contents...' >> /var/dashboard/logs/dashboard-update.log
    tar -xzf latest.tar.gz
    cd PantherDashboard-${VER}
    
    # Add the new services
    for f in dashboard/services/*; do
      if ! test -f /var/$f; then
        cp $f /var/dashboard/services
      fi
    done
    
    # Add the new statuses
    for f in dashboard/statuses/*; do
      if ! test -f /var/$f; then
        cp $f /var/dashboard/statuses
      fi
    done
    
    # Remove useless files
    rm -rf dashboard/services/*
    rm -rf dashboard/statuses/*
    rm nginx/.htpasswd

    if test -f /etc/systemd/system/helium-status-check.timer; then
      systemctl disable helium-status-check.timer
      rm -rf /etc/systemd/system/helium-status-check.timer
    fi

    # Remove /etc/ssl/certs/dhparam.pem if it is empty and regenerate it
    [ -s /etc/ssl/certs/dhparam.pem ] || rm -f /etc/ssl/certs/dhparam.pem
    if ! test -f /etc/ssl/certs/dhparam.pem; then
	    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    fi

    cp monitor-scripts/* /etc/monitor-scripts/   
    cp -r dashboard/* /var/dashboard/
    cp version /var/dashboard/
    cp systemd/* /etc/systemd/system/
    chmod 755 /etc/monitor-scripts/*
    chown root:www-data /var/dashboard/services/*
    chown root:www-data /var/dashboard/statuses/*
    chmod 775 /var/dashboard/services/*
    chmod 775 /var/dashboard/statuses/*
    chown root:www-data /var/dashboard
    chmod 775 /var/dashboard

    bash /etc/monitor-scripts/pantherx-ver-check.sh
    systemctl daemon-reload
    echo 'Starting and enabling services...' >> /var/dashboard/logs/dashboard-update.log
    FILES="systemd/*.timer"
    for f in $FILES;
      do
        name=$(echo $f | sed 's/.timer//' | sed 's/systemd\///')
        systemctl start $name.timer >> /var/dashboard/logs/dashboard-update.log
        systemctl enable $name.timer >> /var/dashboard/logs/dashboard-update.log
        systemctl start $name.service >> /var/dashboard/logs/dashboard-update.log
        systemctl daemon-reload >> /var/dashboard/logs/dashboard-update.log
      done
    systemctl restart nginx
    bash /etc/monitor-scripts/pubkeys.sh
    echo 'Success.' >> /var/dashboard/logs/dashboard-update.log
    echo 'stopped' > /var/dashboard/services/dashboard-update
  else
    echo 'No installation archive found.  No changes made.' >> /var/dashboard/logs/dashboard-update.log
    echo 'stopped' > /var/dashboard/services/dashboard-update
  fi
else
  echo 'Error checking if admin user exists.  No changes made.' >> /var/dashboard/logs/dashboard-update.log
  echo 'stopped' > /var/dashboard/services/dashboard-update
fi

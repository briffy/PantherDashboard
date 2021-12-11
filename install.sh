#!/bin/bash

if id -nG admin | grep -qw "sudo"; then
  wget https://raw.githubusercontent.com/briffy/PantherDashboard/main/latest.tar.gz -O /tmp/latest.tar.gz
  cd /tmp
  if test -f latest.tar.gz; then
    rm -rf /tmp/dashboardinstall
    
    tar -xzf latest.tar.gz
    cd dashboardinstall
    apt-get update
    apt-get --assume-yes install nginx php-fpm php7.3-fpm

    mkdir /var/dashboard
    mkdir /etc/monitor-scripts

    cp -r dashboard/* /var/dashboard/
    cp monitor-scripts/* /etc/monitor-scripts/
       
    cp nginx/snippets/* /etc/nginx/snippets/
    cp nginx/default /etc/nginx/sites-enabled
    
    if ! test -f /var/dashboard/.htpasswd; then
      cp nginx/.htpasswd /var/dashboard/.htpasswd
    fi
    
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
    
    cp systemd/* /etc/systemd/system/

    chmod 755 /etc/monitor-scripts/*
    chown root:www-data /var/dashboard/services/*
    chown root:www-data /var/dashboard/statuses/*
    chmod 775 /var/dashboard/services/*
    chmod 775 /var/dashboard/statuses/*
    chown root:root /etc/ssl/private/nginx-selfsigned.key
    chmod 600 /etc/ssl/private/nginx-selfsigned.key
    chown root:root /etc/ssl/certs/nginx-selfsigned.crt
    chmod 777 /etc/ssl/certs/nginx-selfsigned.crt
    chown root:www-data /var/dashboard/.htpasswd
    chmod 775 /var/dashboard/.htpasswd
    chown root:www-data /var/dashboard
    chmod 775 /var/dashboard

    FILES="systemd/*.timer"
    for f in $FILES;
    do
       name=$(echo $f | sed 's/.timer//' | sed 's/systemd\///')
       systemctl start $name.timer
       systemctl enable $name.timer
       systemctl start $name.service
    done
    
    systemctl enable nginx
    systemctl start nginx

    echo 'Success.'
  else
    echo 'No installation archive found.  No changes made.'
  fi
else
  echo 'Error checking if admin user exists.  No changes made.';
fi

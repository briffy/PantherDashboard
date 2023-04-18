#!/bin/bash

name="server-detection"
service=$(cat /var/dashboard/services/$name | tr -d '\n')

function check_dashboard_server_status() {
    local timeout=5
    local target=$1

    for ((i=0; i<3; i++)); do
        local ret_code=`curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1`
        if [ "x$ret_code" = "x200" ]; then
            echo "$2 can be connected." >> /var/dashboard/logs/$name.log
            return 0
        fi
    done

    echo "$2 can't be connected, please check your local network setting." >> /var/dashboard/logs/$name.log
    return 1
}

function check_miner_server_status(){
    /usr/bin/php /var/dashboard/pages/minerserverstatus.php >> /var/dashboard/logs/$name.log
}

# Fix invalid status when boot finish
if [[ $service == 'running' ]]; then
    if [[ ! -f /tmp/dashboard-$name-flag ]]; then
        echo 'stopped' > /var/dashboard/services/$name
    fi
fi

if [[ $service == 'start' ]]; then
    touch /tmp/dashboard-$name-flag
    echo 'running' > /var/dashboard/services/$name
    echo 'Running Server Detection' > /var/dashboard/logs/$name.log
    check_dashboard_server_status https://raw.githubusercontent.com/Panther-X/PantherDashboard/main/install.sh Dashboard-Server
    check_miner_server_status
    echo 'stopped' > /var/dashboard/services/$name
    echo 'Server Detection complete.' >> /var/dashboard/logs/$name.log
fi

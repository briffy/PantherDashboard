#!/bin/bash
if [ -s /var/dashboard/logs/helium-miner.log ]; then
    beacon_count=`cat /var/dashboard/logs/helium-miner.log | grep "beacon transmitted" | wc -l`;
    echo $beacon_count;
    if [ $beacon_count -gt 0 ]; then
        echo "online" > /var/dashboard/statuses/online_status
    else
        echo 'unknown' > /var/dashboard/statuses/online_status
    fi
else
    echo 'unknown' > /var/dashboard/statuses/online_status
fi
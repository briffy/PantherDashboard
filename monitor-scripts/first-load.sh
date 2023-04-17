#!/bin/bash

## Check pubkey
[ ! -s /var/dashboard/statuses/pubkey ] && /etc/monitor-scripts/pubkeys.sh

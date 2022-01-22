#!/bin/bash

if test -f /opt/miner_data; then
  echo "X1" > /var/dashboard/statuses/pantherx_ver
fi

if test -f /opt/panther-x2/miner_data; then
  echo "X2" > /var/dashboard/statuses/pantherx_ver
fi

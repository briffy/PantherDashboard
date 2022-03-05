#!/bin/bash

if test -d /opt/miner_data; then
  echo -n "X1" > /var/dashboard/statuses/pantherx_ver
fi

if test -d /opt/panther-x2/miner_data; then
  echo -n "X2" > /var/dashboard/statuses/pantherx_ver
fi

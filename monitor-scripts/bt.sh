#!/bin/bash

pantherx_ver=$(cat /var/dashboard/statuses/pantherx_ver)

if [[ "$pantherx_ver" = "X1" ]]; then
    gateway_config_path="/opt/gateway_config"
fi

if [[ "$pantherx_ver" = "X2" ]]; then
    gateway_config_path="/opt/panther-x2/gateway_config"
fi

data=$(sudo ${gateway_config_path}/bin/gateway_config advertise status)

echo $data > /var/dashboard/statuses/bt

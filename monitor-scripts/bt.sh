#!/bin/bash

data=$(sudo /opt/gateway_config/bin/gateway_config advertise status)

echo $data > /var/dashboard/statuses/bt

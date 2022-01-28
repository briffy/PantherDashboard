#!/bin/bash

raw=`awk -v var1=$(</sys/class/thermal/thermal_zone0/temp) -v var2=1000 'BEGIN { print ( var1 / var2 ) }'
{ print ( var1 / var2 ) }'`
data=`printf %0.2f $raw`

echo ${data}\'C > /var/dashboard/statuses/temp

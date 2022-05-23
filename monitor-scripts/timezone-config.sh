#!/bin/bash
file=/var/dashboard/timezone_config

if [ -f "$file" ]; then
  timezone=`cat $file`
  timedatectl set-timezone $timezone
  rm -f $file
fi

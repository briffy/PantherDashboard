#!/bin/bash
pubkey=$(cat /var/dashboard/statuses/pubkey | tr -d "\n")
root_uri='https://api.helium.io/v1/hotspots/'
uri="$root_uri$pubkey"

if data=$(wget -U "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36" $uri -qO-); then
  online_status=$(echo $data | grep -Po '"online":".*?[^\\]"' | sed -e 's/^"online"://' | tr -d '"')
else
  online_status="Not Onboarded"
fi

height=$(wget -U "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36" 'https://api.helium.io/v1/blocks/height' -qO- | grep -Po '"height":[^}]+' | sed -e 's/^"height"://')

if [[ $pubkey ]]; then
  echo $online_status > /var/dashboard/statuses/online_status
else
  echo 'unknown' > /var/dashboard/statuses/online_status
fi

echo $height > /var/dashboard/statuses/current_blockheight
bash /etc/monitor-scripts/info-height.sh

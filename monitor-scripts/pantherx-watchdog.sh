#!/bin/bash

pantherx_ver=$(cat /var/dashboard/statuses/pantherx_ver)

# Patches for Panther X1
if [[ "$pantherx_ver" = "X1" ]]; then
## Add gateway-config monitor
echo "3e7743997670abb75ccedafbb3899d29  /etc/cron.hourly/gateway-config-monitor" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
touch /tmp/pantherx_watchdog.log
echo "fix gateway-config-monitor for Panther X1" > /tmp/pantherx_watchdog.log
cat <<EOF>/etc/cron.hourly/gateway-config-monitor
#!/bin/sh
ret=\`ps -ef | grep "gateway_config/bin/gateway_config" | grep -vc grep\`
if [ "\$ret" != "0" ]; then
    gw_conf=\`/opt/gateway_config/bin/gateway_config status\`
    if [ "\$gw_conf" != "" ]; then
        systemctl restart gateway-config.service
    fi
fi
EOF
fi

## Disable connmon DNS proxy
echo "eae373c7ca2825c93d9408327d78eecf  /lib/systemd/system/connman.service" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    sed -i 's/ExecStart=.*$/ExecStart=\/usr\/sbin\/connmand -n -r/g' /lib/systemd/system/connman.service
    systemctl daemon-reload
    systemctl restart connman
fi

## Fix missing data folder for miner
grep "/opt/miner_data/log" /etc/cron.hourly/helium-miner-status
retval=$?
if [ $retval -ne 0 ]; then
sed -i 's/rm -rf \/opt\/miner_data\/\*$/rm -rf \/opt\/miner_data\/*;mkdir -p \/opt\/miner_data\/log/g' /etc/cron.hourly/helium-miner-status
fi
fi

# Patches for Panther X2
if [[ "$pantherx_ver" = "X2" ]]; then
## Fix typo in /usr/local/sbin/init_wifi.sh
touch /tmp/pantherx_watchdog.log
echo "fix typo in /usr/local/sbin/init_wifi.sh for Panther X2" > /tmp/pantherx_watchdog.log
grep "cconnmanctl" /usr/local/sbin/init_wifi.sh
retval=$?
if [ $retval -eq 0 ]; then
    sed -i 's/\/usr\/bin\/cconnmanctl/\/usr\/bin\/connmanctl/g' /usr/local/sbin/init_wifi.sh
    systemctl restart wifi_init.service
fi

## Add gateway-config monitor
echo "d32cfa7bd2e6ac482cf387b837a4f347  /etc/cron.hourly/gateway-config-monitor" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
touch /tmp/pantherx_watchdog.log
echo "fix gateway-config-monitor for Panther X2" > /tmp/pantherx_watchdog.log
cat <<EOF>/etc/cron.hourly/gateway-config-monitor
#!/bin/sh
ret=\`ps -ef | grep "gateway_config/bin/gateway_config" | grep -vc grep\`
if [ "\$ret" != "0" ]; then
    gw_conf=\`/opt/panther-x2/gateway_config/bin/gateway_config status\`
    if [ "\$gw_conf" != "" ]; then
        systemctl restart gateway-config.service
    fi
fi
EOF
fi

## Disable connmon DNS proxy
echo "a8e57c6d177f10600fcbc68fedcc8f8a  /lib/systemd/system/connman.service" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    sed -i 's/ExecStart=.*$/ExecStart=\/usr\/sbin\/connmand -n -r/g' /lib/systemd/system/connman.service
    systemctl daemon-reload
    systemctl restart connman
fi

## Fix missing data folder for miner
grep "/opt/panther-x2/miner_data/log" /etc/cron.hourly/helium-miner-status
retval=$?
if [ $retval -ne 0 ]; then
sed -i 's/rm -rf \/opt\/panther-x2\/miner_data\/\*$/rm -rf \/opt\/panther-x2\/miner_data\/*;mkdir -p \/opt\/panther-x2\/miner_data\/log/g' /etc/cron.hourly/helium-miner-status
fi

## Update and detected LoRa AS923_1B
echo "94b7cfc3665d3b6f1842c9845ca5b1d1  /etc/global_conf.json.sx1250.AS923_1B.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AS923_1B.template -O /etc/global_conf.json.sx1250.AS923_1B.template
fi

echo "94a5d0c0ef2cc8c0c42bbf7d08758782  /etc/global_conf.json.sx1257.AS923_1B.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AS923_1B.template -O /etc/global_conf.json.sx1257.AS923_1B.template
fi
fi

## Clean /var/log/auth.log
: > /var/log/auth.log

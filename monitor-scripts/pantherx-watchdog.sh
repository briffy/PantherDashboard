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
fi

# Patches for Panther X2
if [[ "$pantherx_ver" = "X2" ]]; then
## Fix typo in /usr/local/sbin/init_wifi.sh
touch /tmp/pantherx_watchdog.log
echo "fix typo in /usr/local/sbin/init_wifi.sh for Panther X2" > /tmp/pantherx_watchdog.log
echo "1b887ffc3a792d93399d5cccd6242d67 /usr/local/sbin/init_wifi.sh" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
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
fi

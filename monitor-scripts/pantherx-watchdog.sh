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

# Check helium-miner-status
[ -f /etc/cron.hourly/helium-miner-status ] && rm -f /etc/cron.hourly/helium-miner-status

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

## Detected and update LoRa AS923_1
echo "94abda56828084b5596a8361366b81e4  /etc/global_conf.json.sx1250.AS923_1.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AS923_1.template -O /etc/global_conf.json.sx1250.AS923_1.template
fi

echo "7accef69baebbcf89eb85d620fb9ce9a  /etc/global_conf.json.sx1257.AS923_1.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AS923_1.template -O /etc/global_conf.json.sx1257.AS923_1.template
fi

## Detected and update LoRa AS923_2
echo "0c1c63411b7b2f70bc6b49f0b205b067  /etc/global_conf.json.sx1250.AS923_2.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AS923_2.template -O /etc/global_conf.json.sx1250.AS923_2.template
fi

echo "747d46380e3063db368346438c9c425e  /etc/global_conf.json.sx1257.AS923_2.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AS923_2.template -O /etc/global_conf.json.sx1257.AS923_2.template
fi

## Detected and update LoRa AS923_3
echo "54510a04ed2bbb19fca896bade0164ae  /etc/global_conf.json.sx1250.AS923_3.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AS923_3.template -O /etc/global_conf.json.sx1250.AS923_3.template
fi

echo "a806ec9c59ec7a1291b0190ab110d3a6  /etc/global_conf.json.sx1257.AS923_3.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AS923_3.template -O /etc/global_conf.json.sx1257.AS923_3.template
fi

## Detected and update LoRa AS923_4
echo "8779558279e3900280bd73e7f20aa868  /etc/global_conf.json.sx1250.AS923_4.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AS923_4.template -O /etc/global_conf.json.sx1250.AS923_4.template
fi

echo "036739073297d322f47b2713e24b41ca  /etc/global_conf.json.sx1257.AS923_4.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AS923_4.template -O /etc/global_conf.json.sx1257.AS923_4.template
fi

## Detected and update LoRa AS923_1C
echo "859eb7d2064e631aa0105ee5ae23014f  /etc/global_conf.json.sx1250.AS923_1C.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AS923_1C.template -O /etc/global_conf.json.sx1250.AS923_1C.template
fi

echo "c82bb5d9adef567555f58c95a5785bc8  /etc/global_conf.json.sx1257.AS923_1C.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AS923_1C.template -O /etc/global_conf.json.sx1257.AS923_1C.template
fi

## Detected and update LoRa AU915
echo "15d69e0a08704c9641f64ad44d45255b  /etc/global_conf.json.sx1250.AU915.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AU915.template -O /etc/global_conf.json.sx1250.AU915.template
fi

echo "fef8a82b5d043df36c782a988b4f40ef  /etc/global_conf.json.sx1257.AU915.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AU915.template -O /etc/global_conf.json.sx1257.AU915.template
fi

## Detected and update LoRa AU915_SB
echo "221e3a197f6314ee1f222fbb421e5a21  /etc/global_conf.json.sx1250.AU915_SB1.template" |  md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AU915_SB1.template -O /etc/global_conf.json.sx1250.AU915_SB1.template
fi

echo "15d69e0a08704c9641f64ad44d45255b  /etc/global_conf.json.sx1250.AU915_SB2.template" |  md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.AU915_SB2.template -O /etc/global_conf.json.sx1250.AU915_SB2.template
fi

echo "5277c3ec564515047b21208f6ea70fb2  /etc/global_conf.json.sx1257.AU915_SB1.template" |  md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AU915_SB1.template -O /etc/global_conf.json.sx1257.AU915_SB1.template
fi

echo "fef8a82b5d043df36c782a988b4f40ef  /etc/global_conf.json.sx1257.AU915_SB2.template" |  md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.AU915_SB2.template -O /etc/global_conf.json.sx1257.AU915_SB2.template
fi

## Detected and update LoRa EU868
echo "1bbc785bdfed48b6a6ff208a42c68670  /etc/global_conf.json.sx1250.EU868.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.EU868.template -O /etc/global_conf.json.sx1250.EU868.template
fi

echo "43999259b016d29954f715d82ad4ec42  /etc/global_conf.json.sx1257.EU868.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.EU868.template -O /etc/global_conf.json.sx1257.EU868.template
fi

## Detected and update LoRa IN865
echo "e54c42c116b9752ea5582d6ddf197707  /etc/global_conf.json.sx1250.IN865.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.IN865.template -O /etc/global_conf.json.sx1250.IN865.template
fi

echo "f52720877671c007b7c94b9560186991  /etc/global_conf.json.sx1257.IN865.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.IN865.template -O /etc/global_conf.json.sx1257.IN865.template
fi

## Detected and update LoRa KR920
echo "41619194a7df001868eeadf21622df8e  /etc/global_conf.json.sx1250.KR920.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.KR920.template -O /etc/global_conf.json.sx1250.KR920.template
fi

echo "0632f122c1d037233c09fd272cefca22  /etc/global_conf.json.sx1257.KR920.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.KR920.template -O /etc/global_conf.json.sx1257.KR920.template
fi

## Detected and update LoRa RU864
echo "5ad237d59a9f331bf276cf330e63edda  /etc/global_conf.json.sx1250.RU864.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.RU864.template -O /etc/global_conf.json.sx1250.RU864.template
fi

echo "e95bb2752bf17e4335961a36819e87db  /etc/global_conf.json.sx1257.RU864.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.RU864.template -O /etc/global_conf.json.sx1257.RU864.template
fi

## Detected and update LoRa US915
echo "3c76acab27b550869be89b03e467307e  /etc/global_conf.json.sx1250.US915.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/sx1302_hal/master/packet_forwarder/global_conf.json.sx1250.US915.template -O /etc/global_conf.json.sx1250.US915.template
fi

echo "8826d6b14102ebf54c3dbeea24a1dfee  /etc/global_conf.json.sx1257.US915.template" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/packet_forwarder/master/lora_pkt_fwd/global_conf.json.sx1257.US915.template -O /etc/global_conf.json.sx1257.US915.template
fi

## Update gateway-config to adapt to the gateway-rs release
echo "f5209cec8a5eae914ff424884edd2d0e  /opt/panther-x2/gateway_config/bin/gateway_config" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    systemctl stop gateway-config.service
    rm -fr /opt/panther-x2/gateway_config
    wget https://raw.githubusercontent.com/Panther-X/panther_x2_release/master/2023-04-10/gateway-config.tar.gz -O /tmp/gateway-config.tar.gz
    tar -zxvf /tmp/gateway-config.tar.gz -C /opt/panther-x2/
    systemctl start gateway-config.service
fi

## Detected region change
echo "8834b9f6b8c2e1a1735f19b78821bb25  /usr/bin/lora_pkt_fwd_start.sh" | md5sum -c
retval=$?
if [ $retval -ne 0 ]; then
    wget https://raw.githubusercontent.com/Panther-X/panther_x2_release/master/2022-11-10/usr/bin/lora_pkt_fwd_start.sh -O /usr/bin/lora_pkt_fwd_start.sh
    chmod +x /usr/bin/lora_pkt_fwd_start.sh
fi

new_region=`docker exec helium-miner helium_gateway info region | jq '.region' | sed 's/"//g' | tr -d '\r\n'`
if [ ! -z $new_region ] && [ "$new_region" != "UNDEFINED" ]; then
    if [ ! -f "/opt/panther-x2/data/region_onchain" ]; then
        echo -n $new_region > /opt/panther-x2/data/region_onchain
        local_region=`/usr/bin/region_uptd`
        if [ "$new_region" != "$local_region" ]; then
            systemctl restart lora-pkt-fwd.service
        fi
    fi

    regulatory_region=`cat /opt/panther-x2/data/region_onchain`
    if [ "$new_region" != "$regulatory_region" ]; then
        echo -n $new_region > /opt/panther-x2/data/region_onchain
        systemctl restart lora-pkt-fwd.service
    fi
fi
fi

## Clean /var/log/auth.log
: > /var/log/auth.log

#!/bin/bash
sudo docker exec helium-miner miner info height | grep -Po '[ \t]+[0-9]*' | sed 's/\t\t//' > /var/dashboard/statuses/infoheight

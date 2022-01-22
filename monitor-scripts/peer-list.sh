#!/bin/bash
docker exec helium-miner miner peer book -s > /var/dashboard/statuses/peerlist

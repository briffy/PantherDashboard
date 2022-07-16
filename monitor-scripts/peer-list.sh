#!/bin/bash
docker exec helium-miner miner peer session > /var/dashboard/statuses/peerlist

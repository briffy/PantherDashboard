#!/bin/bash
sudo docker inspect --format "{{.State.Running}}" helium-miner > /var/dashboard/statuses/miner

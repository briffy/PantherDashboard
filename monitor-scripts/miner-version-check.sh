#!/bin/bash
# https://docs.projectquay.io/api_quay.html#_tag, Max 100/page

function find_tags() {
  curl -s "https://quay.io/api/v1/repository/team-helium/miner/tag/?limit=$1&page=1&onlyActiveTags=true" \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.88 Safari/537.36' \
    -H 'x-requested-with: XMLHttpRequest' | grep -Po 'miner-arm64_[0-9]+\.[0-9]+\.[0-9]+\.[^"]+_GA' | sort -n | tail -1
}

latest=$(find_tags 25)
if [[ ! $latest ]]; then
  echo "try to find the release in last 50"
  latest=$(find_tags 50)
fi
if [[ ! $latest ]]; then
  echo "try to find the release in last 100"
  latest=$(find_tags 100)
fi
echo -n $latest > /var/dashboard/statuses/latest_miner_version
docker ps --format "{{.Image}}" --filter "name=helium-miner" | grep -Po "miner-arm64_.*" > /var/dashboard/statuses/current_miner_version

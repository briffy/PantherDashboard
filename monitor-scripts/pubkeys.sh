#!/bin/bash

data=$(sudo docker exec helium-miner helium_gateway key info)

if [[ $data =~ name([^\"]*) ]]; then
  match=`echo $data | jq '.name' | sed 's/"//g'`
fi

echo "${match//-/ }" > /var/dashboard/statuses/animal_name

if [[ $data =~ key([^\"]*) ]]; then
  match=`echo $data | jq '.key' | sed 's/"//g'`
fi

echo $match > /var/dashboard/statuses/pubkey
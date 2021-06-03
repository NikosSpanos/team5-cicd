#!/bin/bash

if [ -f ./mykey ]; then
    rm -rf ./mykey
fi

if ! command -v jq then
    echo "jq command was not found. Installing it..."
    sudo apt-get install jq
else
    echo "jq command is installed in your system."
fi

file_key_v2=$(terraform output -json | jq -r '.output_private_key.value' > ./mykey)
file_ip_v2=$(terraform output -json | jq -r '.output_public_ip.value')

chmod 600 ./mykey

ssh -i ./mykey codehubTeam5@$file_ip_v2

rm -rf ./mykey

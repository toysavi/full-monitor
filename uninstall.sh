#!/bin/bash

read -p "Are you sure you want to uninstall Docker? (yes/no): " confirm

if [[ "$confirm" == "yes" ]]; then
    echo "Uninstalling Docker..."
    ./resources/docker/docker_uninstall.sh
else
    echo "Operation canceled."
    exit 0
fi

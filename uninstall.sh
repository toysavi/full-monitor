#!/bin/bash

read -p "Are you sure you want to uninstall Docker? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Aborting uninstallation."
    exit 0
fi

echo -e "\n⚠️ WARNING: This action will permanently remove Docker, including all containers, images, volumes, and networks."
echo -e "❗ If you proceed, all your Docker data will be lost."
read -p "Type 'continue' to proceed or anything else to cancel: " final_confirm

if [[ "$final_confirm" != "continue" ]]; then
    echo "Uninstallation aborted."
    exit 0
fi

echo "Proceeding with Docker uninstallation..."
./resources/docker/docker_uninstall.sh

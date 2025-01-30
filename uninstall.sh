#!/bin/bash

### Confirmation for Docker uninstallation ###
read -p "Do you want to delete or drop docker stack? (yes/no): " stack_delete_confirm

if [[ "$stack_delete_confirm" == "yes" ]]; then
    echo "Proceeding with Docker stack deletion..."
    ./resources/zabbix/drop_docker-stack.sh
else
    echo "Skipping Docker stack deletion."
fi

read -p "Are you sure you want to uninstall Zabbix and Docker? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Aborting uninstallation."
    exit 0
fi

echo -e "\n⚠️ WARNING: This action will permanently remove Zabbix, including all containers, images, volumes, and networks."
echo -e "❗ If you proceed, all your Zabbix data will be lost."
read -p "Type 'continue' to proceed or anything else to cancel: " final_confirm

if [[ "$final_confirm" != "continue" ]]; then
    echo "Uninstallation aborted."
    exit 0
fi

echo "Proceeding with Zabbix uninstallation..."

# Run the Zabbix uninstallation script
./resources/zabbix/uninstall_zabbix.sh

### Confirmation for Docker uninstallation ###
read -p "Are you sure you want to uninstall Docker? (yes/no): " docker_confirm

if [[ "$docker_confirm" != "yes" ]]; then
    echo "Aborting Docker uninstallation."
    exit 0
fi

echo -e "\n⚠️ WARNING: This action will permanently remove Docker, including all containers, images, volumes, and networks."
echo -e "❗ If you proceed, all your Docker data will be lost."
read -p "Type 'continue' to proceed or anything else to cancel: " docker_final_confirm

if [[ "$docker_final_confirm" != "continue" ]]; then
    echo "Docker uninstallation aborted."
    exit 0
fi

echo "Proceeding with Docker uninstallation..."
./resources/docker/docker_uninstall.sh

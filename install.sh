#!/bin/bash

echo "Do you want to install Docker for a single node or multi-node setup?"
echo "1) Single Node"
echo "2) Multi Node"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo "Installing Docker for a single node..."
        ./resources/docker/docker_install_single_node.sh
        ;;
    2)
        echo "Installing Docker for a multi-node setup..."
        ./resources/docker/docker_install_multi_node.sh
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Do you want to install Zabbix server?"
read -p "Enter your choice (yes/no): " install_zabbix

if [[ "$install_zabbix" == "yes" ]]; then
    echo "Installing Zabbix server..."
    ./resources/zabbix/zabbix_install.sh
else
    echo "Skipping Zabbix server installation."
fi

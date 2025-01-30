#!/bin/bash

# Asking to install Docker Server for standalone node or multi nodes as swarm mode
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

# Asking to continue to the next step
read -p "Do you want to continue to the next step? (yes/no): " continue_next

if [[ "$continue_next" != "yes" ]]; then
    echo "Skipping next step."
    exit 0
fi

# Asking to install Zabbix Server
echo "Do you want to install Zabbix server?"
read -p "Enter your choice (yes/no): " install_zabbix

if [[ "$install_zabbix" == "yes" ]]; then
    echo "Installing Zabbix server..."
    ./resources/zabbix/zabbix_install.sh
else
    echo "Skipping Zabbix server installation."
fi

# Asking to continue to the next step
read -p "Do you want to continue to the next step? (yes/no): " continue_next

if [[ "$continue_next" != "yes" ]]; then
    echo "Skipping next step."
    exit 0
fi

# Asking to install Grafana Monitor
echo "Do you want to install Grafana Monitor?"
read -p "Enter your choice (yes/no): " install_grafana

if [[ "$install_grafana" == "yes" ]]; then
    echo "Installing Grafana Monitor..."
    ./resources/grafana/install_grafana.sh
else
    echo "Skipping Grafana Monitor installation."
fi

# Asking to continue to the next step
read -p "Do you want to continue to the next step? (yes/no): " continue_next

if [[ "$continue_next" != "yes" ]]; then
    echo "Skipping next step."
    exit 0
fi

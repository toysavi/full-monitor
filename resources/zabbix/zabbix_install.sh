#!/bin/bash

# Function to install Docker Compose
install_docker_compose() {
    if ! command -v docker-compose &>/dev/null; then
        echo "Docker Compose not found. Installing..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        echo "Docker Compose installed successfully."
    else
        echo "Docker Compose is already installed."
    fi
}

# Function to deploy based on user choice
deploy_docker() {
    case $1 in
        1)
            echo "Deploying Docker in single-node mode..."
            docker-compose -f ./resources/zabbix/task/single-node/docker-compose-single-node.yaml up -d
            docker-compose -f ./resources/zabbix/task/single-node/docker-compose.nginx.yml up -d
            ;;
        2)
            echo "Deploying Docker in swarm mode..."
            docker swarm init  # Ensure Swarm is initialized
            docker stack deploy -c ./resources/zabbix/docker-compose-multi-node.yaml stack_zabbix
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
}

# Ask the user for deployment type
echo "Do you want to install Docker on:"
echo "1) Single Node"
echo "2) Swarm Node"
read -p "Enter your choice (1 or 2): " choice

# Confirm before proceeding
read -p "Are you sure? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Installation aborted."
    exit 0
fi

# Ensure Docker Compose is installed
install_docker_compose

# Deploy based on user selection
deploy_docker "$choice"

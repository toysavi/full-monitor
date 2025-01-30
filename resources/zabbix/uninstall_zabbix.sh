#!/bin/bash

echo "Checking for running Docker containers..."

# Check if any containers are running
if [ "$(docker ps -q)" ]; then
    echo "Error: There are running containers. Please stop them before proceeding."
    exit 1
fi

echo "Navigating to the Zabbix resources directory..."
cd ./resources/zabbix

echo "Stopping and removing Zabbix Docker Compose services..."
docker-compose down

# Remove Docker volumes
echo "Removing all Docker volumes..."
docker volume ls -q | xargs -r docker volume rm

# Optionally, remove Docker images (uncomment if you want to remove images as well)
# echo "Removing Zabbix Docker images..."
# docker rmi zabbix/zabbix-server-pgsql:alpine-6.4-latest nginx:latest zabbix/zabbix-web-nginx-pgsql:alpine-6.4-latest postgres:15-alpine zabbix/zabbix-agent:alpine-6.4-latest

# Optionally, remove Docker networks (uncomment if you want to remove networks as well)
# echo "Removing Zabbix Docker networks..."
# docker network rm zbx_net_backend zbx_net_frontend

echo "Zabbix uninstalled successfully."

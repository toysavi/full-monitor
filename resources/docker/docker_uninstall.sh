#!/bin/bash

echo "Checking for running Docker containers..."

# Check if any containers are running
if [ "$(docker ps -q)" ]; then
    echo "Error: There are running containers. Please stop them before proceeding."
    exit 1
fi

echo "Uninstalling Docker..."

# Remove all Docker containers
echo "Removing all Docker containers..."
docker ps -aq | xargs -r docker rm

# Remove all Docker volumes
echo "Removing all Docker volumes..."
docker volume ls -q | xargs -r docker volume rm

# Remove all Docker networks except predefined ones
echo "Removing all Docker networks..."
docker network ls --format '{{.Name}}' | grep -vE 'bridge|host|none' | xargs -r docker network rm

# Leave Docker Swarm mode if active
if docker info | grep -q "Swarm: active"; then
    echo "Leaving Docker Swarm mode..."
    docker swarm leave --force
else
    echo "Not in swarm mode."
fi

# Remove Docker Compose if installed
if command -v docker-compose &> /dev/null; then
    echo "Removing Docker Compose..."
    sudo rm -f $(which docker-compose)
fi

# Uninstall Docker
echo "Uninstalling Docker..."
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get remove -y docker-ce docker-ce-cli containerd.io
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
elif [ -x "$(command -v yum)" ]; then
    sudo yum remove -y docker-ce docker-ce-cli containerd.io
fi

# Clean up residual Docker data
echo "Removing Docker directories..."
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker
sudo rm -rf ~/.docker

echo "Docker has been uninstalled successfully."

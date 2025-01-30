#!/bin/bash

echo "Stopping and removing all Docker containers..."
sudo docker ps -aq | xargs -r sudo docker stop
sudo docker ps -aq | xargs -r sudo docker rm

echo "Removing all Docker volumes..."
sudo docker volume ls -q | xargs -r sudo docker volume rm

echo "Removing all Docker networks..."
sudo docker network ls -q | xargs -r sudo docker network rm

echo "Leaving Docker Swarm (if in swarm mode)..."
sudo docker swarm leave --force 2>/dev/null || echo "Not in swarm mode."

echo "Removing Docker Compose (if installed)..."
sudo rm -f /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "Uninstalling Docker..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            sudo apt-get remove -y docker-ce docker-ce-cli containerd.io
            sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
            sudo apt-get autoremove -y
            ;;
        centos|rhel|ol)
            sudo yum remove -y docker-ce docker-ce-cli containerd.io
            sudo yum autoremove -y
            ;;
        *)
            echo "Unsupported OS: $ID"
            exit 1
            ;;
    esac
else
    echo "Cannot detect the operating system."
    exit 1
fi

echo "Removing Docker directories..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

echo "Docker and Docker Compose have been completely removed."

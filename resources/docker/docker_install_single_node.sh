#!/bin/bash

# Function to install Docker on Debian-based distributions (Ubuntu, Debian)
install_docker_debian() {
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$ID \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    sudo systemctl enable --now docker

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    # Verify installation
    docker-compose --version
}

# Function to install Docker on RHEL-based distributions (CentOS, RHEL, Oracle Linux)
install_docker_rhel() {
    sudo yum update -y
    sudo yum install -y yum-utils

    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    sudo yum install -y docker-ce docker-ce-cli containerd.io

    sudo systemctl enable --now docker

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    # Verify installation
    docker-compose --version
}

# Detect OS and install Docker accordingly
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            install_docker_debian
            ;;
        centos|rhel|ol)
            install_docker_rhel
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

# Ask the user if they want to initialize Docker Swarm mode
read -p "Do you want to initialize Docker Swarm on this node? (yes/no): " init_swarm

if [ "$init_swarm" == "yes" ]; then
    sudo docker swarm init
    MANAGER_TOKEN=$(sudo docker swarm join-token manager -q)
    WORKER_TOKEN=$(sudo docker swarm join-token worker -q)
    MANAGER_IP=$(hostname -I | awk '{print $1}')
    echo $MANAGER_TOKEN > /tmp/manager_token
    echo $WORKER_TOKEN > /tmp/worker_token
    echo "Docker Swarm initialized successfully."
    echo "Manager token stored in /tmp/manager_token"
    echo "Worker token stored in /tmp/worker_token"
    echo "Manager IP: $MANAGER_IP"
else
    echo "Skipping Docker Swarm initialization."
fi

# Ask the user if they want to join an existing Docker Swarm
read -p "Do you want to join an existing Docker Swarm on this node? (yes/no): " join_swarm

if [ "$join_swarm" == "yes" ]; then
    read -p "Enter the Manager IP: " MANAGER_IP
    read -p "Enter the Swarm token: " SWARM_TOKEN
    sudo docker swarm join --token $SWARM_TOKEN $MANAGER_IP:2377
    echo "Node joined to Docker Swarm successfully."
else
    echo "Skipping Docker Swarm join."
fi

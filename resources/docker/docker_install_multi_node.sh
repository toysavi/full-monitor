#!/bin/bash

# Detect the first manager node's IP dynamically
MANAGER_IP=$(hostname -I | awk '{print $1}')

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
}

# Function to install Docker on RHEL-based distributions (CentOS, RHEL, Oracle Linux)
install_docker_rhel() {
    sudo yum update -y
    sudo yum install -y yum-utils
    
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    
    sudo systemctl enable --now docker
}

# Function to initialize Docker Swarm (Manager Node)
initialize_swarm() {
    sudo docker swarm init --advertise-addr $MANAGER_IP
    sudo docker swarm join-token worker -q > /tmp/worker_token
    sudo docker swarm join-token manager -q > /tmp/manager_token
    echo "Swarm manager initialized. Tokens saved to /tmp/worker_token and /tmp/manager_token"
    
    # Loop until user chooses 'no' to adding more nodes
    while true; do
        add_nodes_prompt worker
        add_nodes_prompt manager

        read -p "Do you want to add more nodes? (yes/no): " add_more
        if [[ "$add_more" != "yes" ]]; then
            break
        fi
    done
}

# Function to join Docker Swarm as Worker Node
join_swarm_worker() {
    WORKER_TOKEN=$(cat /tmp/worker_token)
    sudo docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377
    echo "Worker node joined to swarm."
}

# Function to join Docker Swarm as Manager Node
join_swarm_manager() {
    MANAGER_TOKEN=$(cat /tmp/manager_token)
    sudo docker swarm join --token $MANAGER_TOKEN $MANAGER_IP:2377
    echo "Manager node joined to swarm."
}

# Function to check and install Docker if missing
install_docker_if_missing() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Installing now..."
        if [[ -f /etc/os-release ]]; then
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
    else
        echo "Docker is already installed."
    fi
}

# Function to add worker or manager nodes via SSH
add_swarm_nodes() {
    NODE_TYPE=$1
    TOKEN_FILE="/tmp/${NODE_TYPE}_token"
    TOKEN=$(cat $TOKEN_FILE)
    
    while true; do
        read -p "Enter the SSH IP address of the $NODE_TYPE node (or 'done' to finish): " NODE_IP
        if [[ "$NODE_IP" == "done" ]]; then
            break
        fi
        read -p "Enter SSH username: " SSH_USER
        read -s -p "Enter SSH password: " SSH_PASS
        echo ""
        
        sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$NODE_IP "$(declare -f install_docker_if_missing); install_docker_if_missing; sudo docker swarm join --token $TOKEN $MANAGER_IP:2377"
        echo "$NODE_TYPE node added: $NODE_IP"
    done
}

# Function to prompt user to add more nodes
add_nodes_prompt() {
    NODE_TYPE=$1
    while true; do
        read -p "Do you want to add a $NODE_TYPE node? (yes/no): " add_more
        if [[ "$add_more" == "yes" ]]; then
            add_swarm_nodes $NODE_TYPE
        else
            break
        fi
    done
}

# Detect OS and install Docker accordingly
install_docker_if_missing

# Ask user for node type
read -p "Is this node a manager? (yes/no): " response
if [[ "$response" == "yes" ]]; then
    read -p "Is this a new manager or joining an existing swarm? (new/join): " type
    if [[ "$type" == "new" ]]; then
        initialize_swarm
    elif [[ "$type" == "join" ]]; then
        join_swarm_manager
    else
        echo "Invalid selection. Exiting."
        exit 1
    fi
    exit 0
fi

read -p "Is this node a worker? (yes/no): " response
if [[ "$response" == "yes" ]]; then
    join_swarm_worker
    exit 0
fi

echo "No valid selection made. Exiting."
exit 1

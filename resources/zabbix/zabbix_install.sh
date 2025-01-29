#!/bin/bash

# Function to check if Docker is running in swarm mode
is_swarm_mode() {
    docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "active"
}

# Function to execute the appropriate Docker Compose file
execute_docker_compose() {
    if is_swarm_mode; then
        echo "Docker is running in multi-node (swarm) mode."
        docker-compose -f docker-compose-multi-node.yml up -d
    else
        echo "Docker is running in single-node mode."
        docker-compose -f docker-compose-single-node.yml up -d
    fi
}

# Main script execution
execute_docker_compose
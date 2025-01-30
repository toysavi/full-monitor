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

# Function to configure Postgres database connection
configure_database() {
    echo "Select the Postgres database you want to use:"
    echo "1) Remote Database"
    echo "2) Internal (Local) Database"
    echo "3) Database in Docker"
    read -p "Enter your choice (1, 2, or 3): " db_choice

    case $db_choice in
        1)
            read -p "Enter remote database host: " DB_HOST
            read -p "Enter remote database port [5432]: " DB_PORT
            DB_PORT=${DB_PORT:-5432}
            read -p "Enter database username: " DB_USER
            read -sp "Enter database password: " DB_PASSWORD
            echo
            ;;
        2)
            DB_HOST="localhost"
            DB_PORT="5432"
            read -p "Enter database username: " DB_USER
            read -sp "Enter database password: " DB_PASSWORD
            echo
            ;;
        3)
            echo "Deploying PostgreSQL database using Docker Compose..."
            docker swarm init 2>/dev/null || true  # Initialize Swarm if not already
            docker stack deploy -c ./resources/zabbix/task/dbs/docker-compose.postgres.yaml stack_postgres
            DB_HOST="postgres_db"  # Ensure this matches the service name in your compose file
            DB_PORT="5432"
            DB_USER="postgres"
            DB_PASSWORD="postgres"
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac

    # Export database connection parameters
    export DB_HOST
    export DB_PORT
    export DB_USER
    export DB_PASSWORD
}

# Function to create .env file with database parameters
create_env_file() {
    cat <<EOF > .env
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
EOF
}

# Function to ensure network exists
ensure_network() {
    network_name=$1
    if ! docker network ls --filter name=^${network_name}$ --format "{{ .Name }}" | grep -w "${network_name}" &> /dev/null ; then
        echo "Creating network ${network_name}..."
        docker network create --driver overlay --attachable ${network_name}
    else
        echo "Network ${network_name} already exists."
    fi
}

# Function to deploy based on user choice
deploy_docker() {
    case $1 in
        1)
            echo "Deploying Docker in single-node mode..."
            docker stack deploy -c ./resources/zabbix/task/single-node/docker-compose-single-node.yaml stack_zabbix-server
            docker stack deploy -c ./resources/zabbix/task/single-node/docker-compose.nginx.yml stack_nginx
            ;;
        2)
            echo "Deploying Docker in Swarm mode..."
            docker stack deploy -c ./resources/zabbix/docker-compose-multi-node.yaml stack_zabbix
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
}

# Ask the user for deployment type
echo "Do you want to deploy Docker on:"
echo "1) Single Node"
echo "2) Swarm Mode"
read -p "Enter your choice (1 or 2): " choice

# Confirm before proceeding
read -p "Are you sure? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Installation aborted."
    exit 0
fi

# Ensure Docker Compose is installed
install_docker_compose

# Initialize Docker Swarm if not already initialized
docker swarm init 2>/dev/null || true

# Configure the database
configure_database

# Create the .env file
create_env_file

# Ensure the required Docker network exists
ensure_network "zbx_net_frontend"

# Deploy based on user selection
deploy_docker "$choice"

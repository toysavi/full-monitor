#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to delete or drop Docker stacks
delete_docker_stacks() {
    echo
    read -p "Do you want to delete or drop the Docker stacks? (yes/no): " stack_delete_confirm

    if [[ "$stack_delete_confirm" == "yes" ]]; then
        echo "Proceeding with Docker stack deletion..."
        if [[ -f "${SCRIPT_DIR}/resources/zabbix/drop_docker-stack.sh" ]]; then
            bash "${SCRIPT_DIR}/resources/zabbix/drop_docker-stack.sh"
        else
            echo "Error: Docker stack deletion script not found."
            exit 1
        fi
    else
        echo "Skipping Docker stack deletion."
    fi
}

# Function to uninstall Zabbix
uninstall_zabbix() {
    echo
    read -p "Do you want to uninstall Zabbix? (yes/no): " zabbix_confirm

    if [[ "$zabbix_confirm" == "yes" ]]; then
        echo -e "\n⚠️  WARNING: This action will permanently remove Zabbix, including all containers, images, volumes, and networks."
        echo -e "❗ If you proceed, all your Zabbix data will be lost."
        echo -e "📁 It's recommended to back up your data before proceeding.\n"
        read -p "Type 'continue' to proceed or anything else to cancel: " zabbix_final_confirm

        if [[ "$zabbix_final_confirm" == "continue" ]]; then
            echo "Proceeding with Zabbix uninstallation..."
            if [[ -f "${SCRIPT_DIR}/resources/zabbix/uninstall_zabbix.sh" ]]; then
                bash "${SCRIPT_DIR}/resources/zabbix/uninstall_zabbix.sh"
            else
                echo "Error: Zabbix uninstallation script not found."
                exit 1
            fi
        else
            echo "Zabbix uninstallation aborted."
        fi
    else
        echo "Skipping Zabbix uninstallation."
    fi
}

# Function to uninstall Docker
uninstall_docker() {
    echo
    read -p "Do you want to uninstall Docker? (yes/no): " docker_confirm

    if [[ "$docker_confirm" == "yes" ]]; then
        echo -e "\n⚠️  WARNING: This action will permanently remove Docker, including all containers, images, volumes, and networks."
        echo -e "❗ If you proceed, all your Docker data will be lost."
        echo -e "📁 It's recommended to back up your data before proceeding.\n"
        read -p "Type 'continue' to proceed or anything else to cancel: " docker_final_confirm

        if [[ "$docker_final_confirm" == "continue" ]]; then
            echo "Proceeding with Docker uninstallation..."
            if [[ -f "${SCRIPT_DIR}/resources/docker/docker_uninstall.sh" ]]; then
                bash "${SCRIPT_DIR}/resources/docker/docker_uninstall.sh"
            else
                echo "Error: Docker uninstallation script not found."
                exit 1
            fi
        else
            echo "Docker uninstallation aborted."
        fi
    else
        echo "Skipping Docker uninstallation."
    fi
}

# Main script execution
echo "--------------------------------------------"
echo "        Docker and Zabbix Uninstaller       "
echo "--------------------------------------------"

# Step 1: Delete or drop Docker stacks
delete_docker_stacks

# Option to exit after stack deletion
echo
read -p "Do you want to proceed to uninstall Zabbix? (yes/no): " proceed_zabbix
if [[ "$proceed_zabbix" != "yes" ]]; then
    echo "Exiting script. Goodbye!"
    exit 0
fi

# Step 2: Uninstall Zabbix
uninstall_zabbix

# Option to exit before Docker uninstallation
echo
read -p "Do you want to proceed to uninstall Docker? (yes/no): " proceed_docker
if [[ "$proceed_docker" != "yes" ]]; then
    echo "Exiting script. Goodbye!"
    exit 0
fi

# Step 3: Uninstall Docker
uninstall_docker

echo
echo "✅ Uninstallation process completed."

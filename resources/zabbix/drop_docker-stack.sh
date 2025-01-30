#!/bin/bash

# List all Docker stacks
echo "Current Docker stacks:"
docker stack ls

# Get the names of all Docker stacks
STACK_NAMES=$(docker stack ls --format "{{.Name}}")

# Check if there are any stacks
if [ -z "$STACK_NAMES" ]; then
    echo "No Docker stacks found."
    exit 0
fi

# Loop through each stack and ask for confirmation to delete
for STACK_NAME in $STACK_NAMES; do
    read -p "Do you want to delete the stack $STACK_NAME? (yes/no): " CONFIRM
    if [[ "$CONFIRM" == "yes" ]]; then
        echo "Deleting stack $STACK_NAME..."
        docker stack rm "$STACK_NAME"

        # Wait for the stack to be removed
        echo "Waiting for stack $STACK_NAME to be removed..."
        while docker stack ls | grep -q "$STACK_NAME"; do
            sleep 1
        done

        echo "Stack $STACK_NAME has been removed."
    else
        echo "Skipping stack $STACK_NAME."
    fi
done

# List remaining Docker stacks
echo "Remaining Docker stacks:"
docker stack ls

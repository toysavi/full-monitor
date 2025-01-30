#!/bin/bash

# Check if stack name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <stack_name>"
    exit 1
fi

STACK_NAME=$1

# Ask for confirmation to delete the stack
read -p "Are you sure you want to delete the stack $STACK_NAME? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborting."
    exit 1
fi

# Remove the Docker stack
docker stack rm "$STACK_NAME"

# Wait for the stack to be removed
echo "Waiting for stack $STACK_NAME to be removed..."
while docker stack ls | grep -q "$STACK_NAME"; do
    sleep 1
done

echo "Stack $STACK_NAME has been removed."

# List current Docker stacks
echo "Current Docker stacks:"
docker stack ls

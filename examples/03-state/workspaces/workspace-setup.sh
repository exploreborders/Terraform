#!/bin/bash

# Workspace setup script for Terraform workspaces example

set -e

echo "Setting up Terraform workspaces..."
echo

# Initialize terraform if not already done
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
    echo
fi

# Create workspaces
echo "Creating workspaces..."

WORKSPACES=("dev" "staging" "prod")

for ws in "${WORKSPACES[@]}"; do
    if terraform workspace list | grep -q "^[[:space:]]*$ws$"; then
        echo "Workspace '$ws' already exists"
    else
        echo "Creating workspace '$ws'..."
        terraform workspace new "$ws"
    fi
done

echo
echo "Available workspaces:"
terraform workspace list
echo

# Show workspace configurations
echo "Workspace configurations:"
echo "dev:     t2.micro,  1 instance"
echo "staging: t2.small,  2 instances"
echo "prod:    t2.medium, 3 instances"
echo

echo "✅ Workspace setup complete!"
echo
echo "To use workspaces:"
echo "terraform workspace select dev"
echo "terraform plan"
echo "terraform apply"
echo
echo "Switch between workspaces to see different configurations."
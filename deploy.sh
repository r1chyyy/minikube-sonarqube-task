#!/bin/bash
set -e

echo "Checking and installing dependencies if needed..."
# Call install_dependencies script
if [ -f "./install_dependencies.sh" ]; then
    chmod +x ./install_dependencies.sh
    ./install_dependencies.sh
else
    echo "Error: install_dependencies.sh not found"
    exit 1
fi


# Quick dependency check
for cmd in docker kubectl minikube helm terraform; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please run ./install_dependencies.sh first"
        exit 1
    fi
done

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for pod readiness
wait_for_pod() {
    namespace=$1
    label=$2
    echo "Waiting for pod with label $label in namespace $namespace to be ready..."
    kubectl wait --for=condition=ready pod -l $label -n $namespace --timeout=600s || true
    
    # Show pod status even if wait fails
    echo "Pod status:"
    kubectl get pods -l $label -n $namespace
}

# Check for required commands
for cmd in minikube kubectl terraform helm; do
    if ! command_exists $cmd; then
        echo "Error: $cmd is not installed"
        exit 1
    fi
done

# Ensure current directory and terraform directory have correct ownership
current_user=$(whoami)
sudo chown -R $current_user:$current_user .

# Start Minikube if not running
if ! minikube status | grep -q "Running"; then
    echo "Starting Minikube..."
    minikube start --driver=docker --memory=6144 --cpus=2
fi

# Enable ingress addon if not already enabled
if ! minikube addons list | grep "ingress" | grep -q "enabled"; then
    echo "Enabling ingress addon..."
    minikube addons enable ingress
fi

# Initialize and apply Terraform
echo "Initializing Terraform..."
terraform init

echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Wait for PostgreSQL
wait_for_pod "sonarqube" "app.kubernetes.io/name=postgresql"

# Wait for Sonarqube
wait_for_pod "sonarqube" "app=sonarqube"

# Show deployment status
echo "Checking deployment status:"
kubectl get pods -n sonarqube
kubectl get ingress -n sonarqube

echo "Deployment complete!"
echo "Sonarqube URL: http://$(minikube ip)"
echo "Default credentials:"
echo "Username: admin"
echo "Password: admin"

# Show resource usage
echo -e "\nCluster resource usage:"
kubectl top pods -n sonarqube || true

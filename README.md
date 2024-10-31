# Sonarqube Deployment on Minikube

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Requirements Implementation](#requirements-implementation)
- [Technical Details](#technical-details)
- [Usage](#usage)
- [Design Decisions](#design-decisions)
- [Future Improvements](#future-improvements)

## Overview

This repository contains a solution for deploying Sonarqube on a Minikube cluster using Terraform and Helm charts. The implementation fulfills all the specified requirements while following infrastructure-as-code best practices.

## Project Structure

```text
.
├── README.md          		# This file
├── install_dependencies.sh	# For easier dependancy management
├── deploy.sh          		# Main deployment script
├── main.tf           		# Terraform configuration
└── .gitignore       		# Git ignore file
```

## Requirements Implementation
1. Helm Configuration

- Implemented using Helm 3 (no Tiller required)
- Helm provider configured in Terraform with proper kubernetes context
- Helm repositories automatically added during deployment

2. Nginx Ingress Controller

- Implemented using Minikube's built-in ingress addon
- Enabled automatically during deployment
- Configured to handle Sonarqube ingress traffic
- Ingress class properly set in Sonarqube helm chart

3. PostgreSQL Installation

- Deployed using official Bitnami PostgreSQL Helm chart
- Runs in separate pod within the same namespace
- Configured with persistent storage
- Credentials managed via Terraform variables

4. Sonarqube Database Configuration

- External database configuration pointing to PostgreSQL instance
- Database credentials passed through Helm values
- Connection validated during deployment

5. Sonarqube Installation

- Deployed using official Sonarqube Helm chart
- Persistent volume enabled for data storage
- Resource limits configured appropriately
- Health checks implemented

## Technical Details
Recommended Prerequisites:

- Ubuntu 22.04
- 4GB RAM
- 2 CPU cores
- 10GB free disk space
- Internet connection

Required Software:

- Docker
- Minikube
- Kubectl
- Helm 3
- Terraform

##  Usage
Deployment

```text
# Clone the repository:
git clone https://github.com/r1chyyy/minikube-sonarqube-task.git
cd minikube-sonarqube-task

# Set proper permissions:
sudo chmod +x deploy.sh
sudo chmod +x install_dependencies.sh

# Run dependacny installation and deployment:
./install_dependencies.sh
./deploy.sh
```

Verification

```text
Check pod status:
kubectl get pods -n sonarqube

Access Sonarqube:
echo "http://$(minikube ip)"
```

Default credentials:

- Username: admin
- Password: admin

Cleanup

```text
# To remove all resources:
terraform destroy -auto-approve
minikube delete
```

## Design Decisions
1. Why Minikube?

- Suitable for development and testing
- Built-in ingress support
- Easy to set up and tear down
- Minimal resource requirements

2. Why Terraform?

- Infrastructure as Code best practices
- Reproducible deployments
- State management
- Dependency handling

3. Why Separate PostgreSQL Chart?

- Better resource isolation
- Independent scaling
- Separate backup and restore processes
- Follows microservices best practices

## Future Improvements

1. Security Enhancements

- Implement HTTPS
- Configure network policies
- Implement secret management

2. High Availability

- Configure pod disruption budgets
- Implement proper backup strategies

3. Monitoring

- Add Prometheus metrics
- Configure logging
- Implement alerting

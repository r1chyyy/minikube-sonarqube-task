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
├── README.md          # This file
├── deploy.sh          # Main deployment script
├── main.tf           # Terraform configuration
└── .gitignore        # Git ignore file

## Requirements Implementation
1. Helm Configuration

Implemented using Helm 3 (no Tiller required)
Helm provider configured in Terraform with proper kubernetes context
Helm repositories automatically added during deployment

2. Nginx Ingress Controller

Implemented using Minikube's built-in ingress addon
Enabled automatically during deployment
Configured to handle Sonarqube ingress traffic
Ingress class properly set in Sonarqube helm chart

3. PostgreSQL Installation

Deployed using official Bitnami PostgreSQL Helm chart
Runs in separate pod within the same namespace
Configured with persistent storage
Credentials managed via Terraform variables

4. Sonarqube Database Configuration

External database configuration pointing to PostgreSQL instance
Database credentials passed through Helm values
Connection validated during deployment

5. Sonarqube Installation

Deployed using official Sonarqube Helm chart
Persistent volume enabled for data storage
Resource limits configured appropriately
Health checks implemented

## Technical Details
Prerequisites

Ubuntu 22.04 (recommended)
Minimum 4GB RAM
2 CPU cores
10GB free disk space
Internet connection

Required Software
The deployment script will check for and use:

Docker
Minikube
kubectl
Helm 3
Terraform

##  Usage
Deployment

Clone the repository:
git clone <repository-url>
cd <repository-name>

Set proper permissions:
sudo chmod +x deploy.sh

Run deployment:
./deploy.sh

Verification

Check pod status:
kubectl get pods -n sonarqube

Access Sonarqube:
echo "http://$(minikube ip)"

Default credentials:

Username: admin
Password: admin

Cleanup
To remove all resources:
terraform destroy -auto-approve
minikube delete

## Design Decisions
Why Minikube?

Suitable for development and testing
Built-in ingress support
Easy to set up and tear down
Minimal resource requirements
(Also a requirement)

Why Terraform?

Infrastructure as Code best practices
Reproducible deployments
State management
Dependency handling
(Also a requirement)

Why Separate PostgreSQL Chart?

Better resource isolation
Independent scaling
Separate backup and restore processes
Follows microservices best practices
(Also a requirement)


## Future Improvements

1. Security Enhancements

Implement HTTPS
Configure network policies
Implement secret management

2. High Availability

Configure pod disruption budgets
Implement proper backup strategies

3. Monitoring

Add Prometheus metrics
Configure logging
Implement alerting

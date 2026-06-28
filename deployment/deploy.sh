#!/bin/bash

###############################################################################
# EmployeeHub Deployment Script
#
# Author      : Santhosh Kumar
# Project     : EmployeeHub
# Environment : Production
###############################################################################

set -eo pipefail

echo "========================================================"
echo "        EmployeeHub Deployment Started"
echo "========================================================"

echo ""
echo "Build Number : ${BUILD_NUMBER}"
echo "Git Commit   : ${GIT_COMMIT}"
echo "AWS Region   : ${AWS_REGION}"
echo ""

###############################################################################
# Validate Environment Variables
###############################################################################

required_vars=(
AWS_REGION
AWS_ACCOUNT_ID
BACKEND_ECR
FRONTEND_ECR
ECS_CLUSTER
BACKEND_SERVICE
FRONTEND_SERVICE
BACKEND_TASK_FAMILY
FRONTEND_TASK_FAMILY
EXECUTION_ROLE_ARN
TASK_ROLE_ARN
RDS_ENDPOINT
DB_USERNAME
DB_PASSWORD
)

echo "Validating environment..."

for var in "${required_vars[@]}"
do
    if [ -z "${!var}" ]; then
        echo "ERROR : $var is not defined."
        exit 1
    fi
done

echo "Environment validation completed."

###############################################################################
# Build Images
###############################################################################

echo ""
echo "========== Building Docker Images =========="

chmod +x deployment/scripts/build_images.sh

deployment/scripts/build_images.sh

###############################################################################
# Push Images
###############################################################################

echo ""
echo "========== Pushing Images to Amazon ECR =========="

chmod +x deployment/scripts/push_images.sh

deployment/scripts/push_images.sh

###############################################################################
# Register Task Definitions
###############################################################################

echo ""
echo "========== Registering ECS Task Definitions =========="

chmod +x deployment/scripts/register_tasks.sh

deployment/scripts/register_tasks.sh

###############################################################################
# Update ECS Services
###############################################################################

echo ""
echo "========== Updating ECS Services =========="

chmod +x deployment/scripts/update_services.sh

deployment/scripts/update_services.sh

###############################################################################
# Verify Deployment
###############################################################################

echo ""
echo "========== Verifying Deployment =========="

chmod +x deployment/scripts/verify_deployment.sh

deployment/scripts/verify_deployment.sh

###############################################################################
# Cleanup
###############################################################################

echo ""
echo "========== Cleaning Docker =========="

chmod +x deployment/cleanup.sh

deployment/cleanup.sh

echo ""
echo "========================================================"
echo " EmployeeHub Deployment Completed Successfully"
echo "========================================================"
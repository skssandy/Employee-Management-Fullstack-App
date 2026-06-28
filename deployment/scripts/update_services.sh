#!/bin/bash

###############################################################################
# Update ECS Services
#
# Project : EmployeeHub
# Author  : Santhosh Kumar
###############################################################################

set -e

echo "========================================================"
echo "          Updating ECS Services"
echo "========================================================"

###############################################################################
# Read Task Definition ARNs
###############################################################################

BACKEND_TASK_ARN=$(cat deployment/.backend_task_arn)
FRONTEND_TASK_ARN=$(cat deployment/.frontend_task_arn)

echo ""
echo "Backend Task Definition"
echo "${BACKEND_TASK_ARN}"

echo ""
echo "Frontend Task Definition"
echo "${FRONTEND_TASK_ARN}"

###############################################################################
# Update Backend ECS Service
###############################################################################

echo ""
echo "Updating Backend ECS Service..."

aws ecs update-service \
    --cluster ${ECS_CLUSTER} \
    --service ${BACKEND_SERVICE} \
    --task-definition ${BACKEND_TASK_ARN} \
    --force-new-deployment \
    --region ${AWS_REGION}

echo "Backend Service Updated."

###############################################################################
# Update Frontend ECS Service
###############################################################################

echo ""
echo "Updating Frontend ECS Service..."

aws ecs update-service \
    --cluster ${ECS_CLUSTER} \
    --service ${FRONTEND_SERVICE} \
    --task-definition ${FRONTEND_TASK_ARN} \
    --force-new-deployment \
    --region ${AWS_REGION}

echo "Frontend Service Updated."

###############################################################################
# Wait for Backend Deployment
###############################################################################

echo ""
echo "Waiting for Backend Deployment..."

aws ecs wait services-stable \
    --cluster ${ECS_CLUSTER} \
    --services ${BACKEND_SERVICE} \
    --region ${AWS_REGION}

echo "Backend Deployment Completed."

###############################################################################
# Wait for Frontend Deployment
###############################################################################

echo ""
echo "Waiting for Frontend Deployment..."

aws ecs wait services-stable \
    --cluster ${ECS_CLUSTER} \
    --services ${FRONTEND_SERVICE} \
    --region ${AWS_REGION}

echo "Frontend Deployment Completed."

###############################################################################
# Deployment Summary
###############################################################################

echo ""
echo "========================================================"
echo " Deployment Summary"
echo "========================================================"

echo "Cluster           : ${ECS_CLUSTER}"
echo "Backend Service   : ${BACKEND_SERVICE}"
echo "Frontend Service  : ${FRONTEND_SERVICE}"

echo ""
echo "Backend Revision"
echo "${BACKEND_TASK_ARN}"

echo ""
echo "Frontend Revision"
echo "${FRONTEND_TASK_ARN}"

echo ""
echo "========================================================"
echo " ECS Deployment Completed Successfully"
echo "========================================================"
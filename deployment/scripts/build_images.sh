#!/bin/bash

###############################################################################
# Build Docker Images
#
# Project : EmployeeHub
# Author  : Santhosh Kumar
###############################################################################

set -e

echo "========================================================"
echo "         Building Docker Images"
echo "========================================================"

###############################################################################
# Git Commit SHA
###############################################################################

GIT_SHA=$(git rev-parse --short HEAD)

export IMAGE_TAG=${GIT_SHA}

echo "Git Commit : ${GIT_SHA}"
echo "Image Tag  : ${IMAGE_TAG}"

###############################################################################
# Build Backend Image
###############################################################################

echo ""
echo "Building Backend Docker Image..."

docker build \
    -t ${BACKEND_REPOSITORY}:${IMAGE_TAG} \
    -t ${BACKEND_REPOSITORY}:latest \
    ./backend

echo "Backend image built successfully."

###############################################################################
# Build Frontend Image
###############################################################################

echo ""
echo "Building Frontend Docker Image..."

docker build \
    -t ${FRONTEND_REPOSITORY}:${IMAGE_TAG} \
    -t ${FRONTEND_REPOSITORY}:latest \
    ./frontend

echo "Frontend image built successfully."

###############################################################################
# Verify Images
###############################################################################

echo ""
echo "Verifying Docker Images..."

docker images | grep ${BACKEND_ECR}
docker images | grep ${FRONTEND_ECR}

echo ""
echo "Docker Images Successfully Created."

###############################################################################
# Export Image Tag
###############################################################################

echo ${IMAGE_TAG} > deployment/.image_tag

echo ""
echo "Image Tag Saved."

echo "========================================================"
echo " Docker Build Completed"
echo "========================================================"
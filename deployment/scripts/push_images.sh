#!/bin/bash

###############################################################################
# Push Docker Images to Amazon ECR
#
# Project : EmployeeHub
# Author  : Santhosh Kumar
###############################################################################

set -e

echo "========================================================"
echo "         Push Docker Images to Amazon ECR"
echo "========================================================"

###############################################################################
# Read Image Tag
###############################################################################

IMAGE_TAG=$(cat deployment/.image_tag)

echo "Image Tag : ${IMAGE_TAG}"

###############################################################################
# Repository URLs
###############################################################################

BACKEND_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${BACKEND_ECR}"

FRONTEND_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${FRONTEND_ECR}"

###############################################################################
# Login to Amazon ECR
###############################################################################

echo ""
echo "Logging in to Amazon ECR..."

aws ecr get-login-password \
    --region ${AWS_REGION} | \
docker login \
    --username AWS \
    --password-stdin \
    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "Amazon ECR Login Successful."

###############################################################################
# Push Backend Image
###############################################################################

echo ""
echo "Pushing Backend Image..."

docker push ${BACKEND_REPOSITORY}:${IMAGE_TAG}
docker push ${BACKEND_REPOSITORY}:latest

echo "Backend Image Uploaded."

###############################################################################
# Push Frontend Image
###############################################################################

echo ""
echo "Pushing Frontend Image..."

docker push ${FRONTEND_REPOSITORY}:${IMAGE_TAG}
docker push ${FRONTEND_REPOSITORY}:latest

echo "Frontend Image Uploaded."

###############################################################################
# Verify Backend Image
###############################################################################

echo ""
echo "Verifying Backend Image..."

aws ecr describe-images \
    --repository-name ${BACKEND_ECR} \
    --image-ids imageTag=${IMAGE_TAG} \
    --region ${AWS_REGION}

###############################################################################
# Verify Frontend Image
###############################################################################

echo ""
echo "Verifying Frontend Image..."

aws ecr describe-images \
    --repository-name ${FRONTEND_ECR} \
    --image-ids imageTag=${IMAGE_TAG} \
    --region ${AWS_REGION}

echo ""
echo "========================================================"
echo " Images Successfully Uploaded to Amazon ECR"
echo "========================================================"
#!/bin/bash

###############################################################################
# Cleanup Script
#
# Project : EmployeeHub
# Author  : Santhosh Kumar
###############################################################################

set -e

echo "========================================================"
echo "            Cleaning Deployment Environment"
echo "========================================================"

###############################################################################
# Remove Temporary Files
###############################################################################

echo ""
echo "Removing temporary files..."

rm -f deployment/.image_tag
rm -f /tmp/.backend_task_arn
rm -f /tmp/.frontend_task_arn
rm -f /tmp/backend-task-definition-final.json
rm -f /tmp/frontend-task-definition-final.json

echo "Temporary files removed."

###############################################################################
# Clean Docker
###############################################################################

echo ""
echo "Cleaning Docker..."

docker image prune -af || true
docker container prune -f || true
docker builder prune -af || true

echo "Docker cleanup completed."

###############################################################################
# Clean npm Cache
###############################################################################

echo ""
echo "Cleaning npm cache..."

npm cache clean --force || true

###############################################################################
# Remove Maven Cache (Optional)
###############################################################################

echo ""
echo "Cleaning Maven temporary files..."

find ~/.m2 -name "*.lastUpdated" -delete 2>/dev/null || true

###############################################################################
# Cleanup Finished
###############################################################################

echo ""
echo "========================================================"
echo " Cleanup Completed Successfully"
echo "========================================================"
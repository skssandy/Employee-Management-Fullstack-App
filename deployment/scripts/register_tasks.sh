#!/bin/bash

###############################################################################
# Register ECS Task Definitions
#
# Project : EmployeeHub
# Author  : Santhosh Kumar
###############################################################################

set -e

echo "========================================================"
echo "     Registering ECS Task Definitions"
echo "========================================================"

###############################################################################
# Read Image Tag
###############################################################################

IMAGE_TAG=$(cat deployment/.image_tag)

echo "Image Tag : ${IMAGE_TAG}"

###############################################################################
# Repository URIs
###############################################################################

BACKEND_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${BACKEND_ECR}:${IMAGE_TAG}"

FRONTEND_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${FRONTEND_ECR}:${IMAGE_TAG}"

###############################################################################
# Generate Backend Task Definition
###############################################################################

echo ""
echo "Generating Backend Task Definition..."

jq \
--arg IMAGE "$BACKEND_IMAGE" \
--arg EXEC_ROLE "$EXECUTION_ROLE_ARN" \
--arg TASK_ROLE "$TASK_ROLE_ARN" \
--arg RDS "$RDS_ENDPOINT" \
--arg USER "$DB_USERNAME" \
--arg PASS "$DB_PASSWORD" \
'
.executionRoleArn = $EXEC_ROLE |
.taskRoleArn      = $TASK_ROLE |

.containerDefinitions[0].image = $IMAGE |

.containerDefinitions[0].environment |=
map(
    if .name=="SPRING_DATASOURCE_URL"
        then .value="jdbc:mysql://\($RDS)/employeehub"
    elif .name=="SPRING_DATASOURCE_USERNAME"
        then .value=$USER
    elif .name=="SPRING_DATASOURCE_PASSWORD"
        then .value=$PASS
    else .
    end
)
' \
/tmp/backend-task-definition.json \
> /tmp/backend-task-definition-final.json

###############################################################################
# Generate Frontend Task Definition
###############################################################################

echo ""
echo "Generating Frontend Task Definition..."

jq \
--arg IMAGE "$FRONTEND_IMAGE" \
--arg EXEC_ROLE "$EXECUTION_ROLE_ARN" \
--arg TASK_ROLE "$TASK_ROLE_ARN" \
'
.executionRoleArn = $EXEC_ROLE |
.taskRoleArn      = $TASK_ROLE |
.containerDefinitions[0].image = $IMAGE
' \
/tmp/frontend-task-definition.json \
> /tmp/frontend-task-definition-final.json

###############################################################################
# Register Backend Task
###############################################################################

echo ""
echo "Registering Backend Task..."

BACKEND_TASK_ARN=$(
aws ecs register-task-definition \
    --cli-input-json file://tmp/backend-task-definition-final.json \
    --query 'taskDefinition.taskDefinitionArn' \
    --output text
)

echo "$BACKEND_TASK_ARN" > deployment/.backend_task_arn

echo "Backend Task Registered"

###############################################################################
# Register Frontend Task
###############################################################################

echo ""
echo "Registering Frontend Task..."

FRONTEND_TASK_ARN=$(
aws ecs register-task-definition \
    --cli-input-json file://tmp/frontend-task-definition-final.json \
    --query 'taskDefinition.taskDefinitionArn' \
    --output text
)

echo "$FRONTEND_TASK_ARN" > deployment/.frontend_task_arn

echo "Frontend Task Registered"

###############################################################################
# Summary
###############################################################################

echo ""
echo "Backend Task ARN"
echo "$BACKEND_TASK_ARN"

echo ""
echo "Frontend Task ARN"
echo "$FRONTEND_TASK_ARN"

echo ""
echo "========================================================"
echo " ECS Task Definitions Registered Successfully"
echo "========================================================"
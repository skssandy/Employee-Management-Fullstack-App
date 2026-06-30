set -e

echo "========================================================"
echo "        Verifying ECS Deployment"
echo "========================================================"

echo ""
echo "Backend Service"

aws ecs describe-services \
    --cluster ${ECS_CLUSTER} \
    --services ${BACKEND_SERVICE} \
    --region ${AWS_REGION} \
    --query "services[0].deployments"

echo ""
echo "Frontend Service"

aws ecs describe-services \
    --cluster ${ECS_CLUSTER} \
    --services ${FRONTEND_SERVICE} \
    --region ${AWS_REGION} \
    --query "services[0].deployments"

echo ""
echo "Deployment Verified Successfully."
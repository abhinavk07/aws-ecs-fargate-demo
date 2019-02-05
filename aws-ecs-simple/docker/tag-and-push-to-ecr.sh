#!/bin/bash

# TODO: The openjdk10 image is really much too big. I really hope we are going to have Alpine openjdk10 in some near future.
# TODO: Maybe in real-world projects we should be using Java8 at least as long until we have newer openjdks for Alpine.

if [ $# -ne 3 ]
then
    echo "Usage: AWS_PROFILE=<YOUR-AWS-PROFILE> ./tag-and-push-to-ecr.sh <region> <aws-account-id> <version>"
    echo "Example: AWS_PROFILE=<YOUR-AWS-PROFILE> ./tag-and-push-to-ecr.sh eu-west-1 11111111111 0.1"
    exit 1
fi

MY_REGION=$1
MY_AWS_ACCOUNT_ID=$2
MY_VERSION=$3

MY_LOCAL_DOCKER_IMAGE_NAME=tieto-pc/java-crm-demo
MY_AWS_ECR_IMAGE_NAME=aws-ecs-demo-dev-ecr-java-crm-demo

echo "Using region: $MY_REGION"

echo "Current images:"
docker images

echo "Logging to ECR..."
LOGIN_CMD=$(aws ecr get-login --no-include-email --region $MY_REGION)
$LOGIN_CMD

echo "Tagging image for ECR..."
# We could automate version tag and other stuff in real CI pipeline.
docker tag $MY_LOCAL_DOCKER_IMAGE_NAME:$MY_VERSION $MY_AWS_ACCOUNT_ID.dkr.ecr.$MY_REGION.amazonaws.com/$MY_AWS_ECR_IMAGE_NAME:$MY_VERSION

echo "Tagging done:"
docker images

echo "Pushing image to ECR..."
docker push $MY_AWS_ACCOUNT_ID.dkr.ecr.$MY_REGION.amazonaws.com/$MY_AWS_ECR_IMAGE_NAME:$MY_VERSION

echo "Pushing done:"
aws ecr describe-images --repository-name $MY_AWS_ECR_IMAGE_NAME

echo "All done."



# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values
# to this env-def module which defines the actual environment and creates that environment
# by injecting the environment related values to modules.


# NOTE: In demonstration you might want to follow this procedure since there is some dependency
# for the ECR.
# 1. Comment all other modules except ECR.
# 2. Run terraform init and apply. This creates only the ECR.
# 3. Use script TODO to deploy the application Docker image to ECR.
# 3. Uncomment all modules.
# 4. Run terraform init and apply. This creates other resources and also deploys the ECS using the image in ECR.

# We store the Docker images of the application in this ECR registry.
module "ecr" {
  source        = "../ecr"
  prefix        = "${var.prefix}"
  env           = "${var.env}"
  region        = "${var.region}"
  name          = "aws-ecs-simple"
}


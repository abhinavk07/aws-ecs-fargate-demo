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

# NOTE: In real world development we wouldn't need that procedure, of course, since the ECR registry would be created
# at the beginning of the project and the ECR registry would then persist for the development period for that
# environment.

module "vpc" {
  source           = "../vpc"
  prefix           = "${var.prefix}"
  env              = "${var.env}"
  region           = "${var.region}"
  vpc_cidr_block   = "${var.vpc_cidr_block}"
  private_subnets  = "${var.private_subnets}"
}



# We store the Docker images of the application in this ECR registry.
module "ecr" {
  source        = "../ecr"
  prefix        = "${var.prefix}"
  env           = "${var.env}"
  region        = "${var.region}"
}


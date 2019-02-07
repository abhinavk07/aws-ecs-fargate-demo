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

# Resource group is not actually needed in this demo.
# Just wanted to see how it could be used.
module "resource-group" {
  source           = "../resource-group"
  prefix           = "${var.prefix}"
  env              = "${var.env}"
}

# We could run the demo in default vpc but it is a good idea to isolate
# even small demos to a dedicated vpc.
module "vpc" {
  source           = "../vpc"
  prefix           = "${var.prefix}"
  env              = "${var.env}"
  region           = "${var.region}"
  vpc_cidr_block   = "${var.vpc_cidr_block}"
  private_subnets  = "${var.private_subnets}"
  app_port         = "${var.app_port}"
}

# We store the Docker images of the application in this ECR registry.
module "ecr" {
  source        = "../ecr"
  prefix        = "${var.prefix}"
  env           = "${var.env}"
  region        = "${var.region}"
}

module "ecs" {
  source                    = "../ecs"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  region                    = "${var.region}"
  ecs_service_desired_count = "${var.ecs_service_desired_count}"
  ecs_subnet_az_names       = "${module.vpc.ecs_subnet_availability_zones}"
  ecr_image_url             = "${module.ecr.ecr_url}"
  ecr_crm_image_version     = "${var.ecr_crm_image_version}"
  fargate_container_memory  = "${var.fargate_container_memory}"
  fargate_container_cpu     = "${var.fargate_container_cpu}"
  ecs_subnet_ids            = "${module.vpc.subnet_ids}"
  app_port                  = "${var.app_port}"
  vpc_id                    = "${module.vpc.vpc_id}"
}

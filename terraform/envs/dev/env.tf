# Dev environment.
# NOTE: If environment copied, change environment related values (e.g. "dev" -> "perf").

##### Terraform configuration #####

# Usage:
# AWS_PROFILE=pc-demo terraform init
# AWS_PROFILE=pc-demo terraform get
# AWS_PROFILE=pc-demo terraform plan
# AWS_PROFILE=pc-demo terraform apply

# NOTE: If you want to create a separate version of this demo, use a unique prefix, e.g. "petri-ecs-demo".
# This way all entities have a different name and also you create a dedicate terraform state file
# (remember to call 'terraform destroy' once you are done with your experimentation).
# So, you have to change the prefix in both local below and terraform configuration section in key.

locals {
  # Ireland
  my_region                 = "eu-west-1"
  # Use unique environment names, e.g. dev, custqa, qa, test, perf, ci, prod...
  my_env                    = "dev"
  # Use consisten prefix, e.g. <cloud-provider>-<demo-target/purpose>-demo, e.g. aws-ecs-demo
  my_prefix = "aws-ecs-demo"
  all_demos_terraform_info  = "tieto-pc-demos-terraform-backends"
  # Reserve 10.20.*.* address space for this demonstration.
  vpc_cidr_block            = "10.20.0.0/16"
  # TODO: Change to "private_subnets_count" to make name more explicit.
  private_subnets           = "2"
  ecs_service_desired_count = 2
  ecr_crm_image_version     = "0.1"
  # See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  fargate_container_memory  = "4096"
  fargate_container_cpu     = "1024"
  # TODO: debugging
  app_port                  = "80"
  #app_port                  = "5055"
}

# NOTE: You cannot use locals in the terraform configuration since terraform
# configuration does not allow interpolation in the configuration section.
terraform {
  required_version = ">=0.11.11"
  backend "s3" {
    # NOTE: We use the same bucket for storing terraform statefiles for all PC demos (but different key).
    bucket     = "tieto-pc-demos-terraform-backends"
    # NOTE: This must be unique for each Tieto PC demo!!!
    # Use the same prefix and dev as in local!
    # I.e. key = "<prefix>/<dev>/terraform.tfstate".
    key        = "aws-ecs-fargate-demo/dev/terraform.tfstate"
    region     = "eu-west-1"
    # NOTE: We use the same DynamoDB table for locking all state files of all demos. Do not change name.
    dynamodb_table = "tieto-pc-demos-terraform-backends"
    # NOTE: This is AWS account profile, not env! You probably have two accounts: one dev (or test) and one prod.
    profile    = "pc-demo"
  }
}

provider "aws" {
  region     = "${local.my_region}"
}

# Here we inject our values to the environment definition module which creates all actual resources.
module "env-def" {
  source                    = "../../modules/env-def"
  prefix                    = "${local.my_prefix}"
  env                       = "${local.my_env}"
  region                    = "${local.my_region}"
  vpc_cidr_block            = "${local.vpc_cidr_block}"
  private_subnets           = "${local.private_subnets}"
  ecs_service_desired_count = "${local.ecs_service_desired_count}"
  ecr_crm_image_version     = "${local.ecr_crm_image_version}"
  fargate_container_memory  = "${local.fargate_container_memory}"
  fargate_container_cpu     = "${local.fargate_container_cpu}"
  app_port                  = "${local.app_port}"
}

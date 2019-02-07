variable "prefix" {}
variable "env" {}
variable "region" {}
variable "ecs_service_desired_count" {}
variable "ecs_subnet_az_names" {}
variable "ecs_subnet_ids" {
  type = "list"
}
variable "ecr_image_url" {}
variable "ecr_crm_image_version" {}
variable "fargate_container_memory" {}
variable "fargate_container_cpu" {}
variable "app_port" {}
variable "vpc_id" {}

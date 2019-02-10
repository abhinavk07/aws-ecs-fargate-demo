variable "prefix" {}
variable "env" {}
variable "region" {}
variable "ecs_private_subnet_ids" {
  type = "list"
}
variable "alb_public_subnet_ids" {
  type = "list"
}
variable "nat-public_subnet_id" {}

variable "ecs_private_subnet_sg_id" {}
variable "alb-public-subnet-sg_id" {}
variable "nat-public_subnet_sg_id" {}



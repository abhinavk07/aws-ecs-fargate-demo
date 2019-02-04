locals {
  my_name  = "${var.prefix}-${var.env}-ecr-repo"
  my_env   = "${var.prefix}-${var.env}"
}

resource "aws_ecr_repository" "aws-ecs-simple-repository" {
  name = "${local.my_name}"
  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


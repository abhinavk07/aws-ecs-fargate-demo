locals {
  my_name  = "${var.prefix}-${var.env}-test-ec2"
  my_env   = "${var.prefix}-${var.env}"
  my_key_name = "Kari-testing"
}

# NOTE: These ec2 instances are used just for debugging purposes regarding
# connections between entities in different subnets.
# NOTE: This module assumes that there is an existing "Kari-testing" key-pair.
# TODO: Create new keypair and rename it as "ecs-fargate-demo-keypair"
# and change the name in local.
# Or create the key-pair dynamically.

resource "aws_eip" "nat-ec2-eip" {
  instance = "${aws_instance.nat-ec2.id}"
  vpc      = true
}

resource "aws_instance" "nat-ec2" {
  ami                    = "ami-08935252a36e25f85"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${var.nat-public_subnet_sg_id}"]
  subnet_id              = "${var.nat-public_subnet_id}"
  key_name               = "${local.my_key_name}"


  tags {
    Name        = "${local.my_name}-nat"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_eip" "alb-ec2-eip" {
  instance = "${aws_instance.alb-ec2.id}"
  vpc      = true
}

resource "aws_instance" "alb-ec2" {
  ami                    = "ami-08935252a36e25f85"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${var.alb-public-subnet-sg_id}"]
  subnet_id              = "${var.alb_public_subnet_ids[0]}"
  key_name               = "${local.my_key_name}"

  tags {
    Name        = "${local.my_name}-alb"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_eip" "ecs-ec2-eip" {
  instance = "${aws_instance.ecs-ec2.id}"
  vpc      = true
}

resource "aws_instance" "ecs-ec2" {
  ami                    = "ami-08935252a36e25f85"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${var.ecs_private_subnet_sg_id}"]
  subnet_id              = "${var.ecs_private_subnet_ids[0]}"
  key_name               = "${local.my_key_name}"

  tags {
    Name        = "${local.my_name}-ecs"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}
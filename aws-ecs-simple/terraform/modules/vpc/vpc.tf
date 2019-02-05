locals {
  my_name  = "${var.prefix}-${var.env}-vpc"
  my_env   = "${var.prefix}-${var.env}"
}


# Using example provided in
# https://github.com/terraform-providers/terraform-provider-aws/blob/master/examples/eks-getting-started/vpc.tf
# With some of my own conventions.

data "aws_availability_zones" "available" {}


resource "aws_vpc" "ecs-vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_subnet" "ecs-subnet" {
  count = "${var.private_subnets}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  # Assumes that vpc cidr block is format "xx.yy.0.0/16", i.e. we are creating /24 for the last to numbers.
  # TODO: Maybe create a more generic solution here later.
  cidr_block        = "${replace("${var.vpc_cidr_block}", ".0.0/16", ".${count.index}.0/24")}"
  vpc_id            = "${aws_vpc.ecs-vpc.id}"

  tags {
    Name        = "${local.my_name}-${count.index}-subnet"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}
//
//resource "aws_internet_gateway" "ecs-internet-gateway" {
//  vpc_id = "${aws_vpc.ecs-vpc.id}"
//
//  tags {
//    Name        = "${local.my_name}-ig"
//    Environment = "${local.my_env}"
//    Prefix      = "${var.prefix}"
//    Env         = "${var.env}"
//    Region      = "${var.region}"
//    Terraform   = "true"
//  }
//}
//
//
//resource "aws_route_table" "ecs-route-table" {
//  vpc_id = "${aws_vpc.ecs-vpc.id}"
//
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = "${aws_internet_gateway.ecs-internet-gateway.id}"
//  }
//
//  tags {
//    Name        = "${local.my_name}-route-table"
//    Environment = "${local.my_env}"
//    Prefix      = "${var.prefix}"
//    Env         = "${var.env}"
//    Region      = "${var.region}"
//    Terraform   = "true"
//  }
//}
//
//resource "aws_route_table_association" "eks-route-table-association" {
//  count = 2
//
//  subnet_id      = "${aws_subnet.eks-subnet.*.id[count.index]}"
//  route_table_id = "${aws_route_table.eks-route-table.id}"
//}
locals {
  my_name  = "${var.prefix}-${var.env}-vpc"
  my_env   = "${var.prefix}-${var.env}"
}

# Examples, see: https://github.com/terraform-aws-modules/terraform-aws-vpc

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

# See: https://aws.amazon.com/blogs/compute/task-networking-in-aws-fargate/
# Chapter "Private subnets
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.ecs-vpc.id}"

  tags {
    Name        = "${local.my_name}-ig"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


resource "aws_subnet" "nat-public-subnet" {
  # Assumes that vpc cidr block is format "xx.yy.0.0/16", i.e. we are creating /24 for the last to numbers. A bit of a hack. TODO: Maybe create a more generic solution here later.
  cidr_block        = "${replace("${var.vpc_cidr_block}", ".0.0/16", ".5.0/24")}"
  vpc_id            = "${aws_vpc.ecs-vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name        = "${local.my_name}-nat-public-subnet"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

# AWS ECS/Fargate needs EIP/NAT to pull the images.
resource "aws_eip" "nat-gw-eip" {
  vpc = true
  tags {
    Name        = "${local.my_name}-nat-gw-eip"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

# AWS ECS/Fargate needs EIP/NAT to pull the images.
# See: https://aws.amazon.com/blogs/compute/task-networking-in-aws-fargate/
# Chapter "Private subnets
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat-gw-eip.id}"
  subnet_id     = "${aws_subnet.nat-public-subnet.id}"

  tags {
    Name        = "${local.my_name}-nat-gw"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


resource "aws_route_table" "nat-public-subnet-route-table" {
  vpc_id = "${aws_vpc.ecs-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet-gateway.id}"
  }

  tags {
    Name        = "${local.my_name}-nat-public-subnet-route-table"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

# From our public NAT to Internet gateway.
resource "aws_route_table_association" "public-nat-subnet-route-table-association" {
  subnet_id      = "${aws_subnet.nat-public-subnet.id}"
  route_table_id = "${aws_route_table.nat-public-subnet-route-table.id}"
}


resource "aws_subnet" "ecs-private-subnet" {
  count = "${var.private_subnets}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  # Assumes that vpc cidr block is format "xx.yy.0.0/16", i.e. we are creating /24 for the last to numbers. A bit of a hack.
  # TODO: Maybe create a more generic solution here later.
  cidr_block        = "${replace("${var.vpc_cidr_block}", ".0.0/16", ".${count.index}.0/24")}"
  vpc_id            = "${aws_vpc.ecs-vpc.id}"

  tags {
    Name        = "${local.my_name}-${count.index}-ecs-private-subnet"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_subnet" "ecs-alb-public-subnet" {
  count = "${var.private_subnets}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  # Assumes that vpc cidr block is format "xx.yy.0.0/16", i.e. we are creating /24 for the last to numbers. A bit of a hack.
  # TODO: Maybe create a more generic solution here later.
  cidr_block        = "${replace("${var.vpc_cidr_block}", ".0.0/16", ".${count.index+10}.0/24")}"
  vpc_id            = "${aws_vpc.ecs-vpc.id}"

  tags {
    Name        = "${local.my_name}-${count.index+10}-ecs-alb-public-subnet"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


# From ECS private subnet forward to NAT gateway.
# We need this for ECS to pull images from the private subnet.
resource "aws_route_table" "ecs-private-subnet-route-table" {
  vpc_id = "${aws_vpc.ecs-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }


  tags {
    Name        = "${local.my_name}-ecs-private-subnet-route-table"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

# From our ECS private subnet to NAT.
resource "aws_route_table_association" "ecs-private-subnet-route-table-association" {
  count = "${var.private_subnets}"
  subnet_id      = "${aws_subnet.ecs-private-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.ecs-private-subnet-route-table.id}"
}



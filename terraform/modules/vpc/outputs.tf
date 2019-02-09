
output "vpc_id" {
  value = "${aws_vpc.ecs-vpc.id}"
}

# ECS network configuration needs these.
output "ecs_private_subnet_ids" {
  value = ["${aws_subnet.ecs-private-subnet.*.id}"]
}

output "alb_public_subnet_ids" {
  value = ["${aws_subnet.ecs-alb-public-subnet.*.id}"]
}


output "internet_gateway_id" {
  value = ["${aws_internet_gateway.internet-gateway.id}"]
}

# TODO: Terraform apply fails the first time when creating vpc module from scratch.
# Most probably some dependency is not ready.
# Just run the terraform apply again.
data "aws_subnet_ids" "output-ecs-private-subnet-ids" {
  vpc_id = "${aws_vpc.ecs-vpc.id}"
}

data "aws_subnet" "output-ecs-private-subnet" {
  count = "${var.private_subnets}"
  id    = "${data.aws_subnet_ids.output-ecs-private-subnet-ids.ids[count.index]}"
}

output "ecs_subnet_cidr_blocks" {
  value = ["${data.aws_subnet.output-ecs-private-subnet.*.cidr_block}"]
}

# ECS needs to know the availability zone names used for ECS cluster.
output "ecs_subnet_availability_zones" {
  value = ["${data.aws_subnet.output-ecs-private-subnet.*.availability_zone}"]
}


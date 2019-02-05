
output "vpc_id" {
  value = "${aws_vpc.ecs-vpc.id}"
}

output "subnet_ids" {
  value = "${aws_subnet.ecs-subnet.*.id}"
}

data "aws_subnet_ids" "output-ecs-subnet-ids" {
  vpc_id = "${aws_vpc.ecs-vpc.id}"
}

data "aws_subnet" "output-ecs-subnet" {
  count = "${length(data.aws_subnet_ids.output-ecs-subnet-ids.ids)}"
  id    = "${data.aws_subnet_ids.output-ecs-subnet-ids.ids[count.index]}"
}

output "ecs_subnet_cidr_blocks" {
  value = ["${data.aws_subnet.output-ecs-subnet.*.cidr_block}"]
}

# ECS needs to know the availability zone names used for ECS cluster.
output "ecs_subnet_availability_zones" {
  value = ["${data.aws_subnet.output-ecs-subnet.*.availability_zone}"]
}



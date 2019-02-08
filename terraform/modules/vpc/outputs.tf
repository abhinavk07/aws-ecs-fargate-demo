
output "vpc_id" {
  value = "${aws_vpc.ecs-vpc.id}"
}

# ECS network configuration needs these.
output "subnet_ids" {
  value = ["${aws_subnet.ecs-private-subnet.*.id}"]
}
//
//data "aws_subnet_ids" "output-ecs-subnet-ids" {
//  vpc_id = "${aws_vpc.ecs-vpc.id}"
//}
//
//data "aws_subnet" "output-ecs-public-subnet" {
//  count = "${length(data.aws_subnet_ids.output-ecs-subnet-ids.ids)}"
//  id    = "${data.aws_subnet_ids.output-ecs-subnet-ids.ids[count.index]}"
//}
//
//output "ecs_subnet_cidr_blocks" {
//  value = ["${data.aws_subnet.output-ecs-public-subnet.*.cidr_block}"]
//}
//
//# ECS needs to know the availability zone names used for ECS cluster.
//output "ecs_subnet_availability_zones" {
//  value = ["${data.aws_subnet.output-ecs-public-subnet.*.availability_zone}"]
//}

output "internet_gateway_id" {
  value = ["${aws_internet_gateway.internet-gateway.id}"]
}

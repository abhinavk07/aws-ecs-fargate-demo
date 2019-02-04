
output "vpc_id" {
  value = "${aws_vpc.ecs-vpc.id}"
}

output "subnet_ids" {
  value = "${aws_subnet.ecs-subnet.*.id}"
}


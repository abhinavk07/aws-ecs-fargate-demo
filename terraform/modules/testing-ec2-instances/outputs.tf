
output "nat_public_ip" {
  value = "${aws_instance.nat-ec2.public_ip}"
}

output "alb_public_ip" {
  value = "${aws_instance.alb-ec2.public_ip}"
}

output "ecs_public_ip" {
  value = "${aws_instance.ecs-ec2.public_ip}"
}
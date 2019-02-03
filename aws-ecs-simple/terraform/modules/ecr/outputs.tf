
output "ecr_name" {
  value = "${aws_ecr_repository.aws-ecs-simple-repository.name}"
}

output "ecr_id" {
  value = "${aws_ecr_repository.aws-ecs-simple-repository.id}"
}

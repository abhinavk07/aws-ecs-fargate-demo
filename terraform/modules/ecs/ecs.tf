locals {
  my_name  = "${var.prefix}-${var.env}-ecs"
  my_env   = "${var.prefix}-${var.env}"
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${local.my_name}-cluster"
}

# We create the task definition file from template so that we inject the image url
# dynamically and we do not expose our AWS account id in json code
# (the image url comprises the AWS account id).
data "template_file" "ecs_crm_task_def_template" {
  template = "${file("../../task-definitions/java-crm.json.template")}"
  vars {
    crm_image_url            = "${var.ecr_image_url}:${var.ecr_crm_image_version}"
    fargate_container_memory = "${var.fargate_container_memory}"
    fargate_container_cpu    = "${var.fargate_container_cpu}"
  }
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${local.my_name}-java-crm-task-definition"
  memory                   = "${var.fargate_container_memory}"
  cpu                      = "${var.fargate_container_cpu}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = "${data.template_file.ecs_crm_task_def_template.rendered}"
}

resource "aws_ecs_service" "ecs-service" {
  name            = "${local.my_name}-ecs-service"
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  launch_type     = "FARGATE"
  desired_count   = "${var.ecs_service_desired_count}"
  task_definition = "${aws_ecs_task_definition.ecs-task-definition.arn}"
}
locals {
  my_name  = "${var.prefix}-${var.env}-ecs"
  my_env   = "${var.prefix}-${var.env}"
}

# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "ecs-task-execution-role" {
  name = "${local.my_name}-ecs-task-execution-role"

  assume_role_policy = <<ROLEPOLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
ROLEPOLICY

  tags {
    Name        = "${local.my_name}-ecs-task-execution-role"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


# See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = "${aws_iam_role.ecs-task-execution-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${local.my_name}-cluster"

  tags {
    Name        = "${local.my_name}-cluster"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }

}

# We could create the task definition file from template so that we inject the image url
# dynamically and we do not expose our AWS account id in json code
# (the image url comprises the AWS account id). But let's put all code explicitely here using inline container definition.
# So, NOTE: Not used in this demo, kept for historical reasons.
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
  execution_role_arn       = "${aws_iam_role.ecs-task-execution-role.arn}"

  # Just keeping the template model as a reminder that you can easily template the container definition...
  # container_definitions    = "${data.template_file.ecs_crm_task_def_template.rendered}"
  # But let's do the container definition inline here to make it more explicit.

  # NOTE: You cannot quote int64 in inline section!!! (I.e., do not close
  # ${var.fargate_container_memory} inside double quotes (").
  container_definitions = <<CONTAINERDEFINITION
[
  {
    "name": "${local.my_name}-crm-container",
    "memory": ${var.fargate_container_memory},
    "cpu": ${var.fargate_container_cpu},
    "image": "${var.ecr_image_url}:${var.ecr_crm_image_version}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
CONTAINERDEFINITION

  tags {
    Name        = "${local.my_name}-java-crm-task-definition"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }

}

resource "aws_ecs_service" "ecs-service" {
  name            = "${local.my_name}-ecs-service"
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  launch_type     = "FARGATE"
  desired_count   = "${var.ecs_service_desired_count}"
  task_definition = "${aws_ecs_task_definition.ecs-task-definition.arn}"

  tags {
    Name        = "${local.my_name}-ecs-service"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }

}
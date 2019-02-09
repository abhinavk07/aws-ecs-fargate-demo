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
data "template_file" "ecs-crm-task-def-template" {
  template = "${file("../../task-definitions/java-crm.json.template")}"
  vars {
    crm_image_url            = "${var.ecr_image_url}:${var.ecr_crm_image_version}"
    fargate_container_memory = "${var.fargate_container_memory}"
    fargate_container_cpu    = "${var.fargate_container_cpu}"
    app_port                 = "${var.app_port}"
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
//  container_definitions = <<CONTAINERDEFINITION
//[
//  {
//    "name": "${local.my_name}-crm-container",
//    "memory": ${var.fargate_container_memory},
//    "cpu": ${var.fargate_container_cpu},
//    "image": "${var.ecr_image_url}:${var.ecr_crm_image_version}",
//    "networkMode": "awsvpc",
//    "portMappings": [
//      {
//        "containerPort": ${var.app_port},
//        "hostPort": ${var.app_port}
//      }
//    ]
//  }
//]
//CONTAINERDEFINITION


  # TESTING:
  container_definitions = <<CONTAINERDEFINITION
[
  {
    "name": "${local.my_name}-crm-container",
    "memory": ${var.fargate_container_memory},
    "cpu": ${var.fargate_container_cpu},
    "image": "nginx:1.13.9-alpine",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": ${var.app_port}
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

# See: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
resource "aws_s3_bucket" "ecs-alb-s3-log-bucket" {
  bucket = "${local.my_name}-ecs-alb-s3-log-bucket"
  policy = <<BUCKETPOLICY
{
  "Id": "Policy1549706693168",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1549706688933",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::aws-ecs-demo-dev-ecs-ecs-alb-s3-log-bucket/alb-log/AWSLogs/${var.aws_account_id}/*",
      "Principal": {
        "AWS": [
          "156460612806"
        ]
      }
    }
  ]
}
BUCKETPOLICY

  tags {
    Name        = "${local.my_name}-ecs-alb-s3-log-bucket"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


resource "aws_security_group" "ecs-alb-sg" {
  name = "${local.my_name}-ecs-alb-sg"
  description = "${local.my_name} ECS alb security group"
  vpc_id = "${var.vpc_id}"

  # TODO: Check later that accepts only from ELB.
  ingress {
    from_port   = 0
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "ecs-alb" {
  name               = "${local.my_name}-ecsl-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.ecs-alb-sg.id}"]
  subnets            = ["${var.alb_public_subnet_ids}"]

  //enable_deletion_protection = true

  access_logs {
    bucket  = "${aws_s3_bucket.ecs-alb-s3-log-bucket.bucket}"
    prefix  = "alb-log"
    enabled = true
  }

  tags {
    Name        = "${local.my_name}-ecs-alb"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.ecs-alb.arn}"
  port              = "${var.app_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-alb-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "ecs-alb-target-group" {
  name        = "${local.my_name}-ecs-alb-tg"
  port        = "${var.app_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"
}

resource "aws_security_group" "ecs-task-sg" {
  name     = "${local.my_name}-ecs-task-sg"
  description = "Allow inbound access from the ALB only"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    security_groups = ["${aws_security_group.ecs-alb-sg.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "ecs-service" {
  name            = "${local.my_name}-ecs-service"
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  launch_type     = "FARGATE"
  desired_count   = "${var.ecs_service_desired_count}"
  task_definition = "${aws_ecs_task_definition.ecs-task-definition.arn}"

  network_configuration {
    subnets = ["${var.ecs_private_subnet_ids}"]
    security_groups = ["${aws_security_group.ecs-task-sg.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-alb-target-group.arn}"
    container_name   = "${local.my_name}-crm-container",
    // TODO: testing
    container_port   = "80"
    //container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_alb_listener.alb_listener"
  ]

  // NOTE: Does not support tagging. Maybe migrate later.
  // The new ARN and resource ID format must be enabled to add tags to the service.
  // Opt in to the new format and try again.
//  tags {
//    Name        = "${local.my_name}-ecs-service"
//    Environment = "${local.my_env}"
//    Prefix      = "${var.prefix}"
//    Env         = "${var.env}"
//    Region      = "${var.region}"
//    Terraform   = "true"
//  }

}



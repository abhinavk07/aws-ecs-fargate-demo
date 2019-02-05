locals {
  my_env   = "${var.prefix}-${var.env}"
}

resource "aws_resourcegroups_group" "ecs-prefix-rg" {
  # Group name cannot start with "aws".
  name        = "prefix-${local.my_env}-rg"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::ECS::Cluster",
    "AWS::ECS::Service",
    "AWS::ECS::TaskDefinition"
  ],
  "TagFilters": [
    {
      "Key": "Environment",
      "Values": ["${local.my_env}"]
    }
  ]
}
JSON
  }
}
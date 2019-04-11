# AWS ECS Fargate Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [AWS Solution](#aws-solution)
- [Deployment Instructions](#deployment-instructions)
- [Terraform Code](#terraform-code)
- [Demo Application](#demo-application)
- [Terraform Modules](#terraform-modules)
  - [VPC module](#vpc-module)
  - [ECR module](#ecr-module)
  - [ECS module](#ecs-module)
  - [Resource Groups module](#resource-groups-module)
- [Testing the Application Running in ECS](#testing-the-application-running-in-ecs)
- [Demo Manuscript](#demo-manuscript)



# Introduction

This infra code demonstrates how to create a simple AWS [ECS](https://aws.amazon.com/ecs/) container service using [Fargate](https://aws.amazon.com/fargate/). The demonstration also creates an [ECR](https://aws.amazon.com/ecr/) container registry for storing the application Docker image. The demonstration uses the [Java Simple Rest Demo CRM Application ](https://github.com/tieto-pc/java-simple-rest-demo-app) as a demo application.

# AWS Solution

The AWS solution is depicted in the diagram below.

![AWS ECS Fargate Demo Topology](docs/aws-ecs-fargate-demo-diagram.png?raw=true "AWS ECS Fargate Demo Topology")

All AWS resources are documented in more detail in the Terraform Code chapter.

The demonstration uses a dedicated VPC. There are two public subnets for the Application load balancer (ALB) and two private subnets for the ECS infrastructure (in the diagram ECS and Fargate are depicted in the bigger AZ just for diagram clarity) in two availability zones. There is also a public subnet for the NAT infrastructure for ECS to pull public images. All subnets have a dedicated security group which allows only inbound/outbound traffic that is needed for the resources in that subnet. 

There is also an internet gateway for NAT, a S3 Bucket for ALB logs, an ECR for storing Docker images used by ECS and an IAM role for running the ECS tasks.

# Deployment Instructions

Install Terraform. Clone this project. Open console in [dev](terraform/envs/dev) folder. Configure the terraform backend (S3 Bucket and DynamoDB table as instructed in the dev.tf file). Then usual terraform init, get, plan and apply commands.

# Terraform Code

I am using [Terraform](https://www.terraform.io/) as a [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code) (IaC) tool. Terraform is very much used both in AWS and Azure side and one of its strenghts compared to cloud native tools (AWS / [CloudFormation](https://aws.amazon.com/cloudformation) and Azure / [ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates)) is that you can use Terraform with many cloud providers, you have to learn just one infra language and syntax, and Terraform language (hcl) is pretty powerful and clear.

If you are new to infrastructure as code (IaC) and terraform specifically let's explain the high level structure of the terraform code first. Project's terraform code is hosted in [terraform](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/terraform) folder.

It is a cloud best practice that you should modularize your infra code and also modularize it so that you can create many different (exact) copies of your infra as you like re-using the infra modules. I use a common practice to organize terraform code in three levels:

1. **Environment parameters**. In [envs](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/terraform/envs) folder we host the various environments. In this demo we have only the dev environment, but this folder could have similar environment parameterizations for qa, perf, prod environments etc. 
2. **Environment definition**. In [env-def](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/terraform/modules/env-def) folder we define the modules that will be used in every environment. The environments inject the environment specific parameters to the env-def module which then creates the actual infra using those parameters by calling various infra modules and forwarding environment parameters to the infra modules.
3. **Modules**. In [modules](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/terraform/modules) folder we have the modules that are used by environment definition (env-def, a terraform module itself also). There are modules for the main services used in this demonstration: [VPC](https://aws.amazon.com/vpc/), [ECR](https://aws.amazon.com/ecr/) and [ECS](https://aws.amazon.com/ecs/).


# Demo Application

The demo application used in this demonstration is a simple Java REST application that simulates a CRM system. The application is hosted in a different Git repository since we are using the demo app in many cloud demonstrations: [java-simple-rest-demo-app](https://github.com/tieto-pc/java-simple-rest-demo-app). 

The demo application is dockerized since the Docker image is used in ECS. The actual docker image is hosted in the ECR registry. See [docker](docker) folder for scripts how to build and tag/push the image to ECR.


# Terraform Modules

## VPC module

The [vpc](terraform/modules/vpc) module turned out to be much bigger than I originally thought I need. The reason mainly was that I wanted to make the demonstration a bit more real-like, e.g. putting ECS to private subnet, providing [application load balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) and other security / redundancy features. Those decisions rippled to the VPC in that sense that I needed to add some extra infra boilerplate, e.g. needed to add a nat public subnet since ECS cannot pull images from public repositories unless it has a route table to a nat in a public subnet which directs traffic to internet gateway etc.

NOTE: I could have create a [AWS PrivateLink endpoint](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html) for ECR so that instances in ECS could have pulled images from ECR using the endpoint. But I wanted to test pulling images from Dockerhub so I needed the NAT / Gateway setup anyway.

I did cut some corners, though. E.g. there is just one nat gateway in one availability zone serving all private subnets in different availability zones. This would not be that much of a problem in a real-world production since the nat is just needed in the initialization of the ECS / task definition (booting Docker containers) to pull the Docker image from ECR. But it would be easy to add a dedicated nat to each availability zone (adding expenses - one of the reasons I added just one nat in this exercise).


## ECR module

The [ecr](terraform/modules/ecr) module is pretty simple: it defines the only repository we need in this demonstration, the "java-crm-demo" repository.


## ECS module

The [ecs](terraform/modules/ecs) module also turned out to be more challenging than I thought it would be before starting this exercise. There is quite a lot of stuff in the ecs module:

- IAM role for ECS task execution ( + role policy)
- ECS cluster
- ECS task definition
- S3 bucket for access logs
- Application load balancer (+ listener and target group)
- ECS service

The ECS even with using Fargate is a bit complex to configure.


## Resource Groups module

The [resource-groups](terraform/modules/resource-groups) module defines a dedicated resource group for each tag key I use in all AWS resources that support tagging. The tag keys are:

- Name: <prefix>-<env>-<name-of-the-resource>, e.g. "aws-ecs-demo-dev-vpc" (not used in resource groups, of course)
- Environment: <env>, e.g. "dev"
- Deployment: <prefix>-<env>, e.g. "aws-ecs-demo-dev"
- Prefix: <prefix>, e.g. "aws-ecs-demo"
- Region: <region>, e.g. "eu-west-1
- Terraform: "true" (fixed)

This way you can pretty easily search the resources. Examples:

- Environment = "dev" => All resources in all projects which have deployed as "dev"
- Prefix = "aws-ecs-demo" => All AWS ECS demo resources in all envs (dev, perf, qa, prod...)
- Deployment = "aws-ecs-demo-dev" => The resources of a specific terraform deployment (since each demo has dedicated deployments for all envs)

In AWS Console go to "Resource Groups" view => Saved Resource Groups => You see the 5 resource groups => Click one and you see all resources regarding that tag key and value (that support tagging in AWS).

# Testing the Application Running in ECS

Run command 'AWS_PROFILE=YOUR-PROFILE terraform output -module=env-def.ecs' => you get the application load balancer DNS. Use it to curl the ALB:

```bash
curl http://ALB-DNS-HERE:5055/customer/1
# => Should return: {"ret":"ok","customer":{"id":1,"email":"kari.karttinen@foo.com","firstName":"Kari","lastName":"Karttinen"}}
```

# Demo Manuscript

E.g. for cloud training related presentations we give here detailed instructions how to use this demonstration to build everything from scratch.

1. Git clone the project.
2. In your version change the prefix and env as you like.
3. Configure terraform backend (example in [dev.tf](terraform/envs/dev/dev.tf)).
4. AWS_PROFILE=YOUR_PROFILE terraform init
5. In [env-def.tf](terraform/modules/env-def) comment all other modules except ECR.
6. AWS_PROFILE=YOUR_PROFILE terraform get / apply. Now you should have ECR registry.
7. Go to [docker](docker) directory.
8. Build the docker image using script [build-docker-image.sh](docker/build-docker-image.sh). Test image locally.
9. Use script [tag-and-push-to-ecr.sh](docker/tag-and-push-to-ecr.sh) to tag the image and push it to ECR registry.
10. In [env-def.tf](terraform/modules/env-def) uncomment all modules (except 'testing-ec2-instances' - needed only when debugging connections, security groups, route tables...).
11. AWS_PROFILE=YOUR_PROFILE terraform init / get / apply. Now you should have all resources created.
12. It takes some time for ECS to pull the demo image from ECR and configure everything, boot EC2 instances in Fargate, deploy image etc. You can browse entities in AWS Console => Resource groups in the mean time.
13. Finally check in AWS Console / ECS view that tasks are running.
14. AWS_PROFILE=pc-demo terraform output -module=env-def.ecs  => you should get the ALB DNS. Use it to curl the application: 'curl http://ALB-DNS:5055/customer/1' => You should get reply: '{"ret":"ok","customer":{"id":1,"email":"kari.karttinen@foo.com","firstName":"Kari","lastName":"Karttinen"}}'.
15. AWS_PROFILE=YOUR_PROFILE terraform destroy => Destroy all resources.



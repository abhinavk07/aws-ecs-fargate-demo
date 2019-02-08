# AWS ECS Fargate Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [Terraform Code](#terraform-code)
- [Demo Application](#demo-application)
- [Demo Manuscript](#demo-manuscript)


# *********** NOTE: WORK IN PROGRESS!!! ***************

**Work in progress**. I'll remove this chapter when this demonstration is ready.

# Introduction

This infra code demonstrates how to create a simple AWS [ECS](https://aws.amazon.com/ecs/) container service using [Fargate](https://aws.amazon.com/fargate/). The demonstration also creates an [ECR](https://aws.amazon.com/ecr/) container registry for storing the application Docker image.


# Terraform Code

We are using [Terraform](https://www.terraform.io/) as a [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code) (IaC) tool. Terraform is very much used both in AWS and Azure side and one of its strenghts compared to cloud native tools (AWS / [CloudFormation](https://aws.amazon.com/cloudformation) and Azure / [ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates)) is that you can use Terraform with many cloud providers, you have to learn just one infra language and syntax and Terraform language (hcl) is pretty powerfull and clear.

If you are new to infrastructure as code (IaC) and terraform specifically let's explain the high level structure of the terraform code first. Project terraform code is hosted in [terraform](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/terraform) folder.

It is a cloud best practice that you should modularize your infra code and also modularize it so that you can create many different (exact) copies of your infra as you like re-using the infra modules. I use a common practice to organize terraform code in three levels:

1. **Environment parameters**. In [envs](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/terraform/envs) folder we host the various environments. In this demo we have only the dev environment, but this folder could have similar environment parameterizations for qa, perf, prod environments etc.
2. **Environment definition**. In [env-def](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/terraform/modules/env-def) folder we define the modules that will be used in every environment. The environments inject the environment specific parameters to env-def module which then creates the actual infra using those parameters by calling various infra modules and forwarding environment parameters to infra modules.
3. **Modules**. In [modules](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/terraform/modules) folder we have the modules that are used by environment definition (env-def, a terraform module itself also). There are modules for the main services used in this demonstration: [VPC](https://aws.amazon.com/vpc/), [ECR](https://aws.amazon.com/ecr/) and [ECS](https://aws.amazon.com/ecs/).



# Demo Application

The demo application used in this demonstration is a simple Java REST application that simulates a CRM system. The application is hosted in a different Git repository since we are using the demo app in many cloud demonstrations: [java-simple-rest-demo-app](https://github.com/tieto-pc/java-simple-rest-demo-app). 

The demo application is dockerized since the Docker image is used in ECS. The actual docker image is hosted in the ECR registry. See [docker](https://github.com/tieto-pc/aws-small-demos/tree/master/aws-ecs-simple/docker) folder for scripts how to build and tag/push the image to ECR.


# Demo Manuscript

E.g. for cloud training related presentations we give here detailed instructions how to use this demonstration to build everything from scratch.

TODO.



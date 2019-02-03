# AWS ECR Simple Demonstrations  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)


# Introduction

This infra code demonstrates how to set a simple ECR container registry in AWS and how to use its terraform state as read-only to get reference in other AWS infra projects. The purpose of separate the terraform state of this ECR project from the other infra projects is that in e.g. in [aws-ecs-simple](TODO) we can't build the whole infra if we already do not have the ECR registry ready (the aws-ecs-simple builds the container and pushes the Docker image to the ECR registry which must be ready at this point).


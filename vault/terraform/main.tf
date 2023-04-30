# # launch the vault docker image into a ecs cluster

# provider "aws" {
#   region = "us-west-2" # Use the appropriate AWS region
# }

# locals {
#   cluster_name = "minimal-cost-ecs-cluster"
#   app_name     = "vault"
# }

# resource "aws_ecs_cluster" "this" {
#   name = local.cluster_name
# }

# resource "aws_ecs_task_definition" "this" {
#   family                   = local.app_name
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = "512"
#   memory                   = "1024"
#   execution_role_arn       = aws_iam_role.execution_role.arn
#   task_role_arn            = aws_iam_role.task_role.arn

#   container_definitions = jsonencode([
#     {
#       name  = "vault"
#       image = "public.ecr.aws/hashicorp/vault:latest"

#       essential = true
#       cpu       = 256
#       memory    = 512

#       portMappings = [
#         {
#           containerPort = 8200
#           hostPort      = 8200
#         }
#       ]

#       environment = [
#         {
#           name  = "VAULT_ADDR"
#           value = "http://127.0.0.1:8200"
#         }
#       ]
#     },
#     {
#       name  = "tailscale"
#       image = "tailscale/tailscale:latest"

#       essential = true
#       cpu       = 256
#       memory    = 512

#       # Add environment variables required for Tailscale
#       environment = [
#         {
#           name  = "TS_AUTHKEY"
#           value = var.tailscale_key
#         }
#       ]
#     }
#   ])
# }

# resource "aws_vpc" "this" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = local.cluster_name
#   }
# }

# resource "aws_subnet" "this" {
#   vpc_id     = aws_vpc.this.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = local.cluster_name
#   }
# }

# resource "aws_security_group" "allow_vault" {
#   name        = "${local.cluster_name}-allow-vault"
#   description = "Allow vault traffic"
#   vpc_id      = aws_vpc.this.id

#   ingress {
#     from_port   = 8200
#     to_port     = 8200
#     protocol    = "tcp"
#     cidr_blocks = [aws_subnet.this.cidr_block]
#   }
# }

# resource "aws_ecs_service" "this" {
#   name            = local.app_name
#   cluster         = aws_ecs_cluster.this.id
#   task_definition = aws_ecs_task_definition.this.arn
#   launch_type     = "FARGATE"

#   desired_count = 1

#   network_configuration {
#     subnets          = [aws_subnet.this.id]
#     security_groups  = [aws_security_group.allow_vault.id]
#     assign_public_ip = "ENABLED"
#   }
# }

# resource "aws_iam_role" "execution_role" {
#   name = "ecs_task_execution_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
#   role       = aws_iam_role.execution_role.name
# }

# resource "aws_iam_role" "task_role" {
#   name = "ecs_task_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "task_role_policy" {
#   name = "ecs_task_role_policy"
#   role = aws_iam_role.task_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "ecr:GetAuthorizationToken",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       }
#     ]
#   })
# }

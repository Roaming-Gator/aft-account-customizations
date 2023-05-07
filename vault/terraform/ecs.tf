resource "aws_ecs_cluster" "this" {
  name = local.cluster_name
}

resource "aws_ecs_task_definition" "vault" {
  family                   = local.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name  = "vault"
      image = "public.ecr.aws/hashicorp/vault:latest"

      essential = true
      cpu       = 256
      memory    = 512

      portMappings = [
        {
          containerPort = 8200
          hostPort      = 8200
        }
      ]

      environment = [
        {
          name  = "VAULT_ADDR"
          value = "http://127.0.0.1:8200"
        }
      ]
    },
    # {
    #   name  = "tailscale"
    #   image = "tailscale/tailscale:latest"

    #   essential = true
    #   cpu       = 256
    #   memory    = 512

    #   # Add environment variables required for Tailscale
    #   environment = [
    #     {
    #       name  = "TS_AUTHKEY"
    #       value = var.tailscale_key
    #     }
    #   ]
    # }
  ])
}

resource "aws_security_group" "allow_vault" {
  name        = "${local.cluster_name}-allow-vault"
  description = "Allow vault traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = aws_subnet.deployment_targets[*].cidr_block
  }
}

resource "aws_ecs_service" "this" {
  name            = local.app_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.vault.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets          = aws_subnet.deployment_targets[*].cidr_block
    security_groups  = [aws_security_group.allow_vault.id]
    assign_public_ip = "ENABLED"
  }
}

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#####FAKE_Services

######modules ---
#example: https://developer.hashicorp.com/consul/docs/ecs/terraform/secure-configuration#acl-controller
module "acl_controller3" {
  source  = "hashicorp/consul-ecs/aws//modules/acl-controller"
  version = "0.6.0"

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-acl-controller-fakeservice"
    }
  }
  consul_server_http_addr           = var.consul_url
  consul_bootstrap_token_secret_arn = aws_secretsmanager_secret.bootstrap_token.arn
  #consul_server_ca_cert_arn         = aws_secretsmanager_secret.ca_cert.arn #Do not configure for HCP
  ecs_cluster_arn                   = aws_ecs_cluster.clients3.arn
  region                            = var.region
  subnets                           = var.private_subnet_ids_az1
  security_groups = var.security_group_id
  name_prefix = "${local.secret_prefix}-3"
  consul_partitions_enabled = true 
  consul_partition = "default"
}

module "acl_controller4" {
  source  = "hashicorp/consul-ecs/aws//modules/acl-controller"
  version = "0.6.0"

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-acl-controller-fakeservice2"
    }
  }
  consul_server_http_addr           = var.consul_url
  consul_bootstrap_token_secret_arn = aws_secretsmanager_secret.bootstrap_token.arn
  #consul_server_ca_cert_arn         = aws_secretsmanager_secret.ca_cert.arn #Do not configure for HCP
  ecs_cluster_arn                   = aws_ecs_cluster.clients4.arn
  region                            = var.region
  subnets                           = var.private_subnet_ids_az2
  security_groups = var.security_group_id
  name_prefix = "${local.secret_prefix}-4"
  consul_partitions_enabled = true 
  consul_partition = "default"
}


module "example_client_app" {
  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version = "0.6.0"

  family            = "example-client-app"
  port              = "9090"
  #log_configuration = local.example_client_app_log_config
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-client"
    }
  }
  container_definitions = [{
    name             = "example-client-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
    #logConfiguration = local.example_client_app_log_config
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-client"
    }
  }
    environment = [
      {
        name  = "NAME"
        value = "example-client-app"
      },
      {
        name  = "UPSTREAM_URIS"
        value = "http://localhost:1234"
      }
    ]
    portMappings = [
      {
        containerPort = 9090
        hostPort      = 9090
        protocol      = "tcp"
      }
    ]
    cpu         = 0
    mountPoints = []
    volumesFrom = []
  }]
  upstreams = [
    {
      destinationName = "example-server-app"
      #destinationNamespace = "az2"
      localBindPort  = 1234
    }
  ]
  
  retry_join        = var.client_retry_join
  consul_datacenter = var.datacenter
  consul_image      = "public.ecr.aws/hashicorp/consul-enterprise:${var.consul_version}-ent"
  consul_partition               = "default"
  consul_namespace               = "az1"
  tls                       = true
  consul_server_ca_cert_arn = aws_secretsmanager_secret.ca_cert.arn
  gossip_key_secret_arn     = aws_secretsmanager_secret.gossip_key.arn
  consul_http_addr               = var.consul_url
  #consul_https_ca_cert_arn       = aws_secretsmanager_secret.ca_cert.arn #Do not configure for HCP
  acls                           = true
  additional_task_role_policies  = [aws_iam_policy.hashicups.arn]
  additional_execution_role_policies = [aws_iam_policy.hashicups.arn]
}

module "example_server_app" {
  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version = "0.6.0"

  family            = "example-server-app"
  port              = "9090"
  #log_configuration = local.example_server_app_log_config
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-server"
    }
  }
  container_definitions = [{
    name             = "example-server-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
   #logConfiguration = local.example_server_app_log_config
    log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-server"
    }
  }
    environment = [
      {
        name  = "NAME"
        value = "example-server-app"
      }
    ]
  }]
  retry_join        = var.client_retry_join
  consul_datacenter = var.datacenter
  consul_image      = "public.ecr.aws/hashicorp/consul-enterprise:${var.consul_version}-ent"
  consul_partition               = "default"
  consul_namespace               = "az1"
  tls                       = true
  consul_server_ca_cert_arn = aws_secretsmanager_secret.ca_cert.arn
  gossip_key_secret_arn     = aws_secretsmanager_secret.gossip_key.arn
  consul_http_addr               = var.consul_url
  #consul_https_ca_cert_arn       = aws_secretsmanager_secret.ca_cert.arn #Do not configure for HCP
  acls                           = true
  additional_task_role_policies  = [aws_iam_policy.hashicups.arn]
  additional_execution_role_policies = [aws_iam_policy.hashicups.arn]
}


module "example_server_app2" {
  source  = "hashicorp/consul-ecs/aws//modules/mesh-task"
  version = "0.6.0"

  family            = "example-server-app2"
  port              = "9090"
  #log_configuration = local.example_server_app_log_config
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-server2"
    }
  }
  container_definitions = [{
    name             = "example-server-app"
    image            = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential        = true
   #logConfiguration = local.example_server_app_log_config
    log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "consul-server2"
    }
  }
    environment = [
      {
        name  = "NAME"
        value = "example-server-app"
      }
    ]
  }]
  retry_join        = var.client_retry_join
  consul_datacenter = var.datacenter
  consul_image      = "public.ecr.aws/hashicorp/consul-enterprise:${var.consul_version}-ent"
  consul_partition               = "default"
  consul_namespace               = "az2"
  consul_service_name = "example-server-app"
  tls                       = true
  consul_server_ca_cert_arn = aws_secretsmanager_secret.ca_cert.arn
  gossip_key_secret_arn     = aws_secretsmanager_secret.gossip_key.arn
  consul_http_addr               = var.consul_url
  #consul_https_ca_cert_arn       = aws_secretsmanager_secret.ca_cert.arn #Do not configure for HCP
  acls                           = true
  additional_task_role_policies  = [aws_iam_policy.hashicups.arn]
  additional_execution_role_policies = [aws_iam_policy.hashicups.arn]
}


resource "aws_ecs_service" "example_client_app" {
  name            = "example-client-app"
  cluster         = aws_ecs_cluster.clients3.arn
  task_definition = module.example_client_app.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets         = var.private_subnet_ids_az1
    security_groups = var.security_group_id
  }
  launch_type    = "FARGATE"
  propagate_tags = "TASK_DEFINITION"
  load_balancer {
    target_group_arn = aws_lb_target_group.example_client_app.arn
    container_name   = "example-client-app"
    container_port   = 9090
  }
  enable_execute_command = true
}

# The server app is part of the service mesh. It's called
# by the client app.
resource "aws_ecs_service" "example_server_app" {
  name            = "example-server-app"
  cluster         = aws_ecs_cluster.clients3.arn
  task_definition = module.example_server_app.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets         = var.private_subnet_ids_az1
    security_groups = var.security_group_id
  }
  launch_type            = "FARGATE"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true 
}

# The server app is part of the service mesh. It's called
# by the client app.
resource "aws_ecs_service" "example_server_app2" {
  name            = "example-server-app"
  cluster         = aws_ecs_cluster.clients4.arn
  task_definition = module.example_server_app2.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets         = var.private_subnet_ids_az2
    security_groups = var.security_group_id
  }
  launch_type            = "FARGATE"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true
}



# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {
  secret_prefix = random_id.id.dec
}

resource "aws_security_group_rule" "allow_http_inbound" {
  count       = length(var.allowed_http_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = 9090
  to_port     = 9090
  protocol    = "tcp"
  cidr_blocks = var.allowed_http_cidr_blocks

  security_group_id = var.security_group_id
}

#adding two ECS Clusters to test fake services - NOT NEEDED IF REUSING YOUR OWN in SERVICES.TF

#adding a second cluster for failover
resource "aws_ecs_cluster" "clients3" {
  name               = "hcp-ecs-cluster-${random_id.id.dec}-3"
  capacity_providers = ["FARGATE"]

  depends_on = [var.nat_public_ips]
}

#adding a second cluster for failover
resource "aws_ecs_cluster" "clients4" {
  name               = "hcp-ecs-cluster-${random_id.id.dec}-4"
  capacity_providers = ["FARGATE"]

  depends_on = [var.nat_public_ips]
}


resource "random_id" "id" {
  byte_length = 2
}

#AWS Secret manager resources required 

resource "aws_secretsmanager_secret" "bootstrap_token" {
  name                    = "${local.secret_prefix}-bootstrap-token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bootstrap_token" {
  secret_id     = aws_secretsmanager_secret.bootstrap_token.id
  secret_string = var.root_token
}

resource "aws_secretsmanager_secret" "ca_cert" {
  name                    = "${local.secret_prefix}-client-ca-cert"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ca_cert" {
  secret_id     = aws_secretsmanager_secret.ca_cert.id
  secret_string = base64decode(var.client_ca_file)
}

resource "aws_secretsmanager_secret" "gossip_key" {
  name                    = "${local.secret_prefix}-gossip-encryption-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "gossip_key" {
  secret_id     = aws_secretsmanager_secret.gossip_key.id
  secret_string = var.client_gossip_key
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${local.secret_prefix}-ecs-client"
}

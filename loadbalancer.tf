# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
###LB for fake service

####LB config 

resource "aws_lb" "example_client_app" {
  name               = "example-client-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_id
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "example_client_app" {
  name                 = "example-client-app"
  port                 = 9090
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 10
  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
  }
}

resource "aws_lb_listener" "example_client_app" {
  load_balancer_arn = aws_lb.example_client_app.arn
  port              = "9090"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_client_app.arn
  }
} 




# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


output "fakeservice_url" {
  value = aws_lb.example_client_app.dns_name
}
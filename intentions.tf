# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
resource "consul_intention" "all" {
  source_name      = "*"
  source_namespace = "az1"
  destination_name = "*"
  destination_namespace = "az1"
  action           = "allow"
}

#adding second intention for AZ2/namespace
resource "consul_intention" "all2" {
  source_name      = "*"
  source_namespace = "az1"
  destination_name = "*"
  destination_namespace = "az2"
  action           = "allow"
}

#adding second intention for AZ2/namespace
resource "consul_intention" "all3" {
  source_name      = "*"
  source_namespace = "az2"
  destination_name = "*"
  destination_namespace = "az2"
  action           = "allow"
}


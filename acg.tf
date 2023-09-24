
################################################################################
# Network Interface
################################################################################

# WEB Server NIC
resource "ncloud_network_interface" "test-web-svr-nic-01" {
  name                  = "test-web-svr-nic-01"
  description           = "WEB Server NIC 01"
  subnet_no             = ncloud_subnet.test-sbn-pub-01.id
  access_control_groups = [ncloud_access_control_group.test-web-svr-acg.id]
}

# WAS Server NIC
resource "ncloud_network_interface" "test-was-svr-nic-01" {
  name                  = "test-was-svr-nic-01"
  description           = "WAS Server NIC 01"
  subnet_no             = ncloud_subnet.test-sbn-pri-01.id
  access_control_groups = [ncloud_access_control_group.test-was-svr-acg.id]
}

# DB Server NIC
resource "ncloud_network_interface" "test-db-svr-nic-01" {
  name                  = "test-db-svr-nic-01"
  description           = "DB Server NIC 01"
  subnet_no             = ncloud_subnet.test-sbn-pri-02.id
  access_control_groups = [ncloud_access_control_group.test-db-svr-acg.id]
}

################################################################################
# ACG
################################################################################

# WEB Server ACG
resource "ncloud_access_control_group" "test-web-svr-acg" {
  name        = "test-web-svr-acg"
  vpc_no      = ncloud_vpc.test-vpc-01.id
  description = "WEB Server ACG"
}

# WAS Server ACG
resource "ncloud_access_control_group" "test-was-svr-acg" {
  name        = "test-was-svr-acg"
  vpc_no      = ncloud_vpc.test-vpc-01.id
  description = "WAS Server ACG"
}

# DB Server ACG
resource "ncloud_access_control_group" "test-db-svr-acg" {
  name        = "test-db-svr-acg"
  vpc_no      = ncloud_vpc.test-vpc-01.id
  description = "DB Server ACG"
}

################################################################################
# ACG Rules
################################################################################
variable "inbound_rules" {
  type = map(object({
    protocol    = string
    ip_block    = string
    port_range  = string
    description = string
  }))
  default = {
    ssh = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "22"
      description = "Accept 22 Port"
    },
    http = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "80"
      description = "Accept 80 Port"
    }
  }
}

variable "outbound_rules" {
  type = map(object({
    protocol    = string
    ip_block    = string
    port_range  = string
    description = string
  }))
  default = {
    all = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "1-65535"
      description = "Accept All Port"
    }
  }
}

# WEB Server ACG Rules
resource "ncloud_access_control_group_rule" "test-web-svr-acg-rule" {
  access_control_group_no = ncloud_access_control_group.test-web-svr-acg.id

  dynamic "inbound" {
    for_each = var.inbound_rules

    content {
      protocol    = inbound.value.protocol
      ip_block    = inbound.value.ip_block
      port_range  = inbound.value.port_range
      description = inbound.value.description
    }
  }

  dynamic "outbound" {
    for_each = var.outbound_rules

    content {
      protocol    = outbound.value.protocol
      ip_block    = outbound.value.ip_block
      port_range  = outbound.value.port_range
      description = outbound.value.description
    }
  }
}

# WAS Server ACG Rules
resource "ncloud_access_control_group_rule" "test-was-svr-acg-rule" {
  access_control_group_no = ncloud_access_control_group.test-was-svr-acg.id

  dynamic "inbound" {
    for_each = var.inbound_rules

    content {
      protocol    = inbound.value.protocol
      ip_block    = inbound.value.ip_block
      port_range  = inbound.value.port_range
      description = inbound.value.description
    }
  }

  dynamic "outbound" {
    for_each = var.outbound_rules

    content {
      protocol    = outbound.value.protocol
      ip_block    = outbound.value.ip_block
      port_range  = outbound.value.port_range
      description = outbound.value.description
    }
  }
}

# DB Server ACG Rules
resource "ncloud_access_control_group_rule" "test-db-svr-acg-rule" {
  access_control_group_no = ncloud_access_control_group.test-db-svr-acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = "${ncloud_server.test-was-svr-01.network_interface.0.private_ip}/32"
    port_range  = "3306"
    description = "Accept 3306 Port"
  }

}

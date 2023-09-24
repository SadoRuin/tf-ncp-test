################################################################################
# VPC
################################################################################
resource "ncloud_vpc" "test-vpc-01" {
  name            = "test-vpc-01"
  ipv4_cidr_block = "10.0.0.0/16"
}


################################################################################
# Subnet
################################################################################
resource "ncloud_subnet" "test-sbn-pub-01" {
  vpc_no         = ncloud_vpc.test-vpc-01.id
  subnet         = "10.0.0.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.test-vpc-01.default_network_acl_no
  subnet_type    = "PUBLIC"
  name           = "test-sbn-pub-01"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "test-sbn-pri-01" {
  vpc_no         = ncloud_vpc.test-vpc-01.id
  subnet         = "10.0.1.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.test-vpc-01.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "test-sbn-pri-01"
  usage_type     = "GEN"
}

resource "ncloud_subnet" "test-sbn-pri-02" {
  vpc_no         = ncloud_vpc.test-vpc-01.id
  subnet         = "10.0.2.0/24"
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.test-vpc-01.default_network_acl_no
  subnet_type    = "PRIVATE"
  name           = "test-sbn-pri-02"
  usage_type     = "GEN"
}


################################################################################
# Public IP
################################################################################
resource "ncloud_public_ip" "web-svr-pub-ip-01" {
  server_instance_no = ncloud_server.test-web-svr-01.id
  description        = "WEB Server Public IP 01"
}

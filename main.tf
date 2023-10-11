################################################################################
# VPC
################################################################################

module "tf_test_vpc" {
  source = "github.com/sadoruin/terraform-ncloud-vpc.git"

  name            = "tf-test-vpc"
  ipv4_cidr_block = "10.0.0.0/16"

  subnets = [
    {
      subnet      = "10.0.0.0/24"
      zone        = "KR-1"
      subnet_type = "PUBLIC"
      name        = "tf-test-web-sbn"
      usage_type  = "GEN"
    },
    {
      subnet      = "10.0.1.0/24"
      zone        = "KR-1"
      subnet_type = "PRIVATE"
      name        = "tf-test-was-sbn"
      usage_type  = "GEN"
    },
    {
      subnet      = "10.0.2.0/24"
      zone        = "KR-1"
      subnet_type = "PRIVATE"
      name        = "tf-test-db-sbn"
      usage_type  = "GEN"
    }
  ]

  inbound_acl_rules = {
    tf-test-web-sbn = [
      {
        priority    = "1"
        protocol    = "TCP"
        rule_action = "ALLOW"
        ip_block    = "0.0.0.0/0"
        port_range  = "443"
      },
      {
        priority    = "2"
        protocol    = "TCP"
        rule_action = "ALLOW"
        ip_block    = "0.0.0.0/0"
        port_range  = "80"
      }
    ],
    tf-test-was-sbn = [],
    tf-test-db-sbn  = []
  }

  outbound_acl_rules = {
    tf-test-web-sbn = [
      {
        priority    = "1"
        protocol    = "TCP"
        rule_action = "ALLOW"
        ip_block    = "0.0.0.0/0"
        port_range  = "1-65535"
      }
    ],
    tf-test-was-sbn = [],
    tf-test-db-sbn  = []
  }
}


################################################################################
# ACG
################################################################################

module "access_control_group" {
  source = "github.com/sadoruin/terraform-ncloud-acg.git"

  acgs = [
    {
      name        = "tf-test-web-svr-acg"
      vpc_id      = module.tf_test_vpc.vpc_id
      description = "WEB Server ACG"
    },
    {
      name        = "tf-test-was-svr-acg"
      vpc_id      = module.tf_test_vpc.vpc_id
      description = "WAS Server ACG"
    },
    {
      name        = "tf-test-db-svr-acg"
      vpc_id      = module.tf_test_vpc.vpc_id
      description = "DB Server ACG"
    }
  ]

  inbound_rules = {
    tf-test-web-svr-acg = [var.acg_rules["ssh"], var.acg_rules["http"], var.acg_rules["https"]],
    tf-test-was-svr-acg = [var.acg_rules["tomcat"]],
    tf-test-db-svr-acg  = [var.acg_rules["mysql"]]
  }

  outbound_rules = {
    tf-test-web-svr-acg = [var.acg_rules["all"]],
    tf-test-was-svr-acg = [],
    tf-test-db-svr-acg  = []
  }

}


################################################################################
# Server
################################################################################

module "tf_test_web_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 0

  name                      = "tf-test-web-svr-${count.index}"
  subnet_no                 = module.tf_test_vpc.subnet_ids["tf-test-web-sbn"]
  server_image_product_code = data.ncloud_server_image.rocky_8_8.id
  server_product_code       = data.ncloud_server_product.c2_g2_h50.id
  login_key_name            = "yh-test-svr-key"

  nics = [
    {
      name                  = "tf-test-web-svr-nic-${count.index}"
      description           = "WEB Server NIC"
      subnet_no             = module.tf_test_vpc.subnet_ids["tf-test-web-sbn"]
      access_control_groups = [module.access_control_group.acg_ids["tf-test-web-svr-acg"]]
      order                 = 0
    }
  ]
}

module "tf_test_was_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 0

  name                      = "tf-test-was-svr-${count.index}"
  subnet_no                 = module.tf_test_vpc.subnet_ids["tf-test-was-sbn"]
  server_image_product_code = data.ncloud_server_image.rocky_8_8.id
  server_product_code       = data.ncloud_server_product.c2_g2_h50.id
  login_key_name            = "yh-test-svr-key"

  nics = [
    {
      name                  = "tf-test-was-svr-nic-${count.index}"
      description           = "WAS Server NIC"
      subnet_no             = module.tf_test_vpc.subnet_ids["tf-test-was-sbn"]
      access_control_groups = [module.access_control_group.acg_ids["tf-test-was-svr-acg"]]
      order                 = 0
    }
  ]
}

module "tf_test_db_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 0

  name                      = "tf-test-db-svr-${count.index}"
  subnet_no                 = module.tf_test_vpc.subnet_ids["tf-test-db-sbn"]
  server_image_product_code = data.ncloud_server_image.centos7_mariadb_10_2.id
  server_product_code       = data.ncloud_server_product.c2_g2_h50.id
  login_key_name            = "yh-test-svr-key"

  nics = [
    {
      name                  = "tf-test-db-svr-nic-${count.index}"
      description           = "DB Server NIC"
      subnet_no             = module.tf_test_vpc.subnet_ids["tf-test-db-sbn"]
      access_control_groups = [module.access_control_group.acg_ids["tf-test-db-svr-acg"]]
      order                 = 0
    }
  ]
}


################################################################################
# Server Image
################################################################################

data "ncloud_server_image" "rocky_8_8" {
  filter {
    name   = "product_name"
    values = ["Rocky Linux 8.8"]
  }
}

data "ncloud_server_image" "centos7_mariadb_10_2" {
  filter {
    name   = "product_name"
    values = ["mariadb(10.2)-centos-7.8-64"]
  }
}


################################################################################
# Server Product
################################################################################

data "ncloud_server_product" "c2_g2_h50" {
  server_image_product_code = data.ncloud_server_image.rocky_8_8.id

  dynamic "filter" {
    for_each = {
      "product_code" = "HDD"
      "product_type" = "HICPU"
      "cpu_count"    = "2"
      "memory_size"  = "4GB"
    }

    content {
      name   = filter.key
      values = [filter.value]
      regex  = filter.key == "product_code" ? true : false
    }
  }
}

################################################################################
# VPC
################################################################################

module "tf_test_vpc" {
  source = "github.com/sadoruin/terraform-ncloud-vpc.git"

  name            = "tf-test-vpc"
  ipv4_cidr_block = "10.0.0.0/16"

  subnets = [
    {
      subnet             = "10.0.0.0/24"
      zone               = "KR-1"
      subnet_type        = "PUBLIC"
      name               = "tf-test-web-sbn"
      usage_type         = "GEN"
      inbound_acl_rules  = []
      outbound_acl_rules = []
    },
    {
      subnet             = "10.0.1.0/24"
      zone               = "KR-1"
      subnet_type        = "PRIVATE"
      name               = "tf-test-was-sbn"
      usage_type         = "GEN"
      inbound_acl_rules  = []
      outbound_acl_rules = []
    },
    {
      subnet             = "10.0.2.0/24"
      zone               = "KR-1"
      subnet_type        = "PRIVATE"
      name               = "tf-test-db-sbn"
      usage_type         = "GEN"
      inbound_acl_rules  = []
      outbound_acl_rules = []
    },
    {
      subnet             = "10.0.3.0/24"
      zone               = "KR-1"
      subnet_type        = "PRIVATE"
      name               = "tf-test-alb-sbn"
      usage_type         = "LOADB"
      inbound_acl_rules  = []
      outbound_acl_rules = []
    },
    {
      subnet             = "10.0.4.0/24"
      zone               = "KR-1"
      subnet_type        = "PRIVATE"
      name               = "tf-test-nlb-sbn"
      usage_type         = "LOADB"
      inbound_acl_rules  = []
      outbound_acl_rules = []
    }
  ]
}


################################################################################
# ACG
################################################################################

module "access_control_group" {
  source = "github.com/sadoruin/terraform-ncloud-acg.git"

  acgs = [
    {
      name           = "tf-test-web-svr-acg"
      vpc_id         = module.tf_test_vpc.vpc_id
      description    = "WEB Server ACG"
      inbound_rules  = [var.acg_rules["ssh"], var.acg_rules["http"], var.acg_rules["https"]]
      outbound_rules = [var.acg_rules["all"]]
    },
    {
      name           = "tf-test-was-svr-acg"
      vpc_id         = module.tf_test_vpc.vpc_id
      description    = "WAS Server ACG"
      inbound_rules  = [var.acg_rules["tomcat"]]
      outbound_rules = []
    },
    {
      name           = "tf-test-db-svr-acg"
      vpc_id         = module.tf_test_vpc.vpc_id
      description    = "DB Server ACG"
      inbound_rules  = [var.acg_rules["mysql"]]
      outbound_rules = []
    }
  ]
}


################################################################################
# Server
################################################################################

module "tf_test_web_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 2

  name                      = "tf-test-web-svr-${count.index}"
  subnet_id                 = module.tf_test_vpc.subnet_ids["tf-test-web-sbn"]
  server_image_product_code = data.ncloud_server_image.rocky_8_8.id
  server_product_code       = data.ncloud_server_product.c2_g2_h50.id
  login_key_name            = "yh-test-svr-key"

  nics = [
    {
      name                  = "tf-test-web-svr-nic-${count.index}"
      description           = "WEB Server NIC"
      subnet_id             = module.tf_test_vpc.subnet_ids["tf-test-web-sbn"]
      access_control_groups = [module.access_control_group.acg_ids["tf-test-web-svr-acg"]]
      order                 = 0
    }
  ]
}

module "tf_test_was_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 2

  name                      = "tf-test-was-svr-${count.index}"
  subnet_id                 = module.tf_test_vpc.subnet_ids["tf-test-was-sbn"]
  server_image_product_code = data.ncloud_server_image.rocky_8_8.id
  server_product_code       = data.ncloud_server_product.c2_g2_h50.id
  login_key_name            = "yh-test-svr-key"

  nics = [
    {
      name                  = "tf-test-was-svr-nic-${count.index}"
      description           = "WAS Server NIC"
      subnet_id             = module.tf_test_vpc.subnet_ids["tf-test-was-sbn"]
      access_control_groups = [module.access_control_group.acg_ids["tf-test-was-svr-acg"]]
      order                 = 0
    }
  ]
}

module "tf_test_db_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 1

  name                      = "tf-test-db-svr-${count.index}"
  subnet_id                 = module.tf_test_vpc.subnet_ids["tf-test-db-sbn"]
  server_image_product_code = data.ncloud_server_image.centos7_mariadb_10_2.id
  server_product_code       = data.ncloud_server_product.c2_g2_h50.id
  login_key_name            = "yh-test-svr-key"

  nics = [
    {
      name                  = "tf-test-db-svr-nic-${count.index}"
      description           = "DB Server NIC"
      subnet_id             = module.tf_test_vpc.subnet_ids["tf-test-db-sbn"]
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


################################################################################
# Load Balancer
################################################################################

module "web_alb" {
  source = "github.com/sadoruin/terraform-ncloud-lb"

  name            = "tf-test-web-alb"
  network_type    = "PUBLIC"
  idle_timeout    = 60
  type            = "APPLICATION"
  throughput_type = "SMALL"
  subnet_no_list  = [module.tf_test_vpc.subnet_ids["tf-test-alb-sbn"]]
  vpc_id          = module.tf_test_vpc.vpc_id

  lb_listeners = [
    {
      protocol = "HTTP"
      port     = 80
      target_group = {
        name               = "tf-test-web-alb-tg"
        protocol           = "HTTP"
        port               = 80
        description        = "WEB Server Target Group"
        use_sticky_session = false
        use_proxy_protocol = false
        algorithm_type     = "RR"
        health_check = {
          protocol       = "HTTP"
          http_method    = "GET"
          port           = 80
          url_path       = "/"
          cycle          = 30
          up_threshold   = 2
          down_threshold = 2
        }

        target_no_list = [
          for x in module.tf_test_web_svr : x.server_id
        ]
      }
    }
  ]
}

module "was_nlb" {
  source = "github.com/sadoruin/terraform-ncloud-lb"

  name            = "tf-test-was-nlb"
  network_type    = "PRIVATE"
  idle_timeout    = 60
  type            = "NETWORK"
  throughput_type = "SMALL"
  subnet_no_list  = [module.tf_test_vpc.subnet_ids["tf-test-nlb-sbn"]]
  vpc_id          = module.tf_test_vpc.vpc_id

  lb_listeners = [
    {
      protocol = "TCP"
      port     = 8080
      target_group = {
        name               = "tf-test-web-nlb-tg"
        protocol           = "TCP"
        port               = 8080
        description        = "WAS Server Target Group"
        use_sticky_session = true
        use_proxy_protocol = false
        algorithm_type     = "MH"
        health_check = {
          protocol       = "TCP"
          port           = 8080
          cycle          = 30
          up_threshold   = 2
          down_threshold = 2
        }

        target_no_list = [
          for x in module.tf_test_was_svr : x.server_id
        ]
      }
    }
  ]
}

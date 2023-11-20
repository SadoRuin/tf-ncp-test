################################################################################
# VPC
################################################################################

module "tf_test_vpc" {
  source = "github.com/sadoruin/terraform-ncloud-vpc.git"

  name            = "tf-test-vpc"
  ipv4_cidr_block = "10.0.0.0/16"


  ##############################################################################
  # Subnet
  ##############################################################################
  subnets = [
    {
      subnet      = "10.0.0.0/24"
      zone        = "KR-1"
      subnet_type = "PUBLIC"
      name        = "tf-test-web-sbn"
      usage_type  = "GEN"
      network_acl = "default"
    },
    {
      subnet      = "10.0.1.0/24"
      zone        = "KR-1"
      subnet_type = "PRIVATE"
      name        = "tf-test-was-sbn"
      usage_type  = "GEN"
      network_acl = "default"
    },
    {
      subnet      = "10.0.2.0/24"
      zone        = "KR-1"
      subnet_type = "PRIVATE"
      name        = "tf-test-db-sbn"
      usage_type  = "GEN"
      network_acl = "default"
    },
    {
      subnet      = "10.0.3.0/24"
      zone        = "KR-1"
      subnet_type = "PRIVATE"
      name        = "tf-test-alb-sbn"
      usage_type  = "LOADB"
      network_acl = "default"
    },
    {
      subnet      = "10.0.4.0/24"
      zone        = "KR-1"
      subnet_type = "PRIVATE"
      name        = "tf-test-nlb-sbn"
      usage_type  = "LOADB"
      network_acl = "default"
    }
  ]

  network_acls = [
    {
      name               = "default"
      description        = "Default Network ACL"
      inbound_acl_rules  = []
      outbound_acl_rules = []
    }
  ]

  ##############################################################################
  # ACG
  ##############################################################################
  acgs = [
    {
      name        = "tf-test-web-svr-acg"
      description = "WEB Server ACG"
      inbound_rules = [
        {
          protocol    = "TCP"
          ip_block    = "0.0.0.0/0"
          port_range  = "22"
          description = "SSH 접속 허용"
        },
        {
          protocol    = "TCP"
          ip_block    = "0.0.0.0/0"
          port_range  = "80"
          description = "HTTP 통신 허용"
        },
        {
          protocol    = "TCP"
          ip_block    = "0.0.0.0/0"
          port_range  = "443"
          description = "HTTPS 통신 허용"
        }
      ]
      outbound_rules = [
        {
          protocol    = "TCP"
          ip_block    = "0.0.0.0/0"
          port_range  = "1-65535"
          description = "모든 포트 허용"
        }
      ]
    },
    {
      name        = "tf-test-was-svr-acg"
      description = "WAS Server ACG"
      inbound_rules = [
        {
          protocol    = "TCP"
          ip_block    = "0.0.0.0/0"
          port_range  = "8080"
          description = "Tomcat 포트 허용"
        }
      ]
      outbound_rules = []
    },
    {
      name        = "tf-test-db-svr-acg"
      description = "DB Server ACG"
      inbound_rules = [
        {
          protocol    = "TCP"
          ip_block    = "0.0.0.0/0"
          port_range  = "3306"
          description = "MySQL 포트 허용"
        }
      ]
      outbound_rules = []
    }
  ]
}


################################################################################
# Server
################################################################################


# resource "terraform_data" "create_svr_image" {
#   depends_on = [module.image_server]

#   triggers_replace = [timestamp()]

#   provisioner "local-exec" {
#     working_dir = "/home/yhpark/cli_linux"
#     command     = <<EOF
#       export INSTANCE_NO=${module.image_server.server.id}
#       ./ncloud vserver createMemberServerImageInstance --regionCode KR --serverInstanceNo $INSTANCE_NO --memberServerImageName tf-test-web-svr
#     EOF
#   }
# }


module "tf_test_web_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 2

  name              = "tf-test-web-svr-${format("%02d", count.index + 1)}"
  subnet_id         = module.tf_test_vpc.subnets["tf-test-web-sbn"].id
  server_image_name = "CentOS 7.8 (64-bit)"
  # member_server_image_name = "test-web"
  product_generation = "G2"
  product_type       = "High CPU"
  product_name       = "vCPU 2EA, Memory 4GB, Disk 50GB"
  login_key_name     = "yh-test-svr-key"

  network_interfaces = [
    {
      subnet_id             = module.tf_test_vpc.subnets["tf-test-web-sbn"].id
      access_control_groups = [module.tf_test_vpc.acgs["tf-test-web-svr-acg"].id]
      order                 = 0
    }
  ]

  is_associate_public_ip = true

  additional_block_storages = []
}

module "tf_test_was_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 2

  name              = "tf-test-was-svr-${format("%02d", count.index + 1)}"
  subnet_id         = module.tf_test_vpc.subnets["tf-test-was-sbn"].id
  server_image_name = "Rocky Linux 8.8"
  # member_server_image_name = "packer-20231106012335"
  product_generation = "G2"
  product_type       = "High CPU"
  product_name       = "vCPU 2EA, Memory 4GB, Disk 50GB"
  login_key_name     = "yh-test-svr-key"

  network_interfaces = [
    {
      subnet_id             = module.tf_test_vpc.subnets["tf-test-was-sbn"].id
      access_control_groups = [module.tf_test_vpc.acgs["tf-test-was-svr-acg"].id]
      order                 = 0
    }
  ]
}

module "tf_test_db_svr" {
  source = "github.com/sadoruin/terraform-ncloud-server.git"

  count = 1

  name               = "tf-test-db-svr-${format("%02d", count.index + 1)}"
  subnet_id          = module.tf_test_vpc.subnets["tf-test-db-sbn"].id
  server_image_name  = "mariadb(10.2)-centos-7.8-64"
  product_generation = "G2"
  product_type       = "High CPU"
  product_name       = "vCPU 2EA, Memory 4GB, Disk 50GB"
  login_key_name     = "yh-test-svr-key"

  network_interfaces = [
    {
      subnet_id             = module.tf_test_vpc.subnets["tf-test-db-sbn"].id
      access_control_groups = [module.tf_test_vpc.acgs["tf-test-db-svr-acg"].id]
      order                 = 0
    }
  ]
}


################################################################################
# Ansible
################################################################################


# resource "ncloud_login_key" "ansible_test" {
#   lifecycle {
#     prevent_destroy = true
#   }
#   key_name = "ansible-test"
# }

# data "ncloud_root_password" "root_pwd" {
#   count              = length(module.tf_test_web_svr)
#   server_instance_no = module.tf_test_web_svr[count.index].server_id
#   private_key        = ncloud_login_key.ansible_test.private_key
# }

# resource "terraform_data" "ssh_config" {
#   depends_on = [module.tf_test_web_svr[0]]
#   provisioner "local-exec" {
#     command = <<EOF
#       echo "[ncloud]" > ~/ansible/inventory
#       ${join("\n", [for i in range(length(module.tf_test_web_svr)) : "echo '${module.tf_test_web_svr[i].server_name} ansible_host=${module.tf_test_web_svr[i].public_ip} ansible_port=22 ansible_ssh_user=root ansible_ssh_pass=${data.ncloud_root_password.root_pwd[i].root_password}' >> ~/ansible/inventory"])}
#     EOF
#   }

#   provisioner "local-exec" {
#     command = <<EOF
#       ANSIBLE_HOST_KEY_CHECKING=False
#       ansible-playbook -i ~/ansible/inventory ~/ansible/exclude-kernel.yml
#     EOF
#   }
# }



################################################################################
# Load Balancer
################################################################################

module "web_alb" {
  source = "github.com/sadoruin/terraform-ncloud-load-balancer.git"

  name            = "tf-test-web-alb"
  network_type    = "PUBLIC"
  idle_timeout    = 60
  type            = "APPLICATION"
  throughput_type = "SMALL"
  subnet_no_list  = [module.tf_test_vpc.subnets["tf-test-alb-sbn"].id]

  lb_listeners = [
    {
      protocol        = "HTTP"
      port            = 80
      target_group_no = module.target_groups.target_groups["tf-test-web-tg"].id
    }
  ]
}

module "was_nlb" {
  source = "github.com/sadoruin/terraform-ncloud-load-balancer.git"

  name            = "tf-test-was-nlb"
  network_type    = "PRIVATE"
  idle_timeout    = 60
  type            = "NETWORK"
  throughput_type = "SMALL"
  subnet_no_list  = [module.tf_test_vpc.subnets["tf-test-nlb-sbn"].id]

  lb_listeners = [
    {
      protocol        = "TCP"
      port            = 8080
      target_group_no = module.target_groups.target_groups["tf-test-was-tg"].id
    }
  ]
}


################################################################################
# Target Groups
################################################################################

module "target_groups" {
  source = "github.com/sadoruin/terraform-ncloud-target-group.git"

  target_groups = [
    {
      vpc_id      = module.tf_test_vpc.vpc.id
      name        = "tf-test-web-tg"
      protocol    = "HTTP"
      target_type = "VSVR"
      port        = 80
      description = "WEB Server Target Group"
      health_check = {
        protocol    = "HTTP"
        http_method = "GET"
        port        = 80
        url_path    = "/"
      }

      target_no_list = [
        for x in module.tf_test_web_svr : x.server.id
      ]
    },
    {
      vpc_id      = module.tf_test_vpc.vpc.id
      name        = "tf-test-was-tg"
      protocol    = "TCP"
      target_type = "VSVR"
      port        = 8080
      description = "WAS Server Target Group"
      health_check = {
        protocol = "TCP"
        port     = 8080
      }

      target_no_list = [
        for x in module.tf_test_was_svr : x.server.id
      ]
    }
  ]
}


################################################################################
# Launch Configuration
################################################################################

module "lc" {
  source = "github.com/sadoruin/terraform-ncloud-launch-configuration.git"

  name                     = "tf-test-lc"
  server_image_name        = "Rocky Linux 8.8"
  member_server_image_name = null
  product_generation       = "G2"
  product_type             = "High CPU"
  product_name             = "vCPU 2EA, Memory 4GB, Disk 50GB"
  is_encrypted_volume      = false
  init_script_no           = null
  login_key_name           = "yh-test-svr-key"
}


################################################################################
# Auto Scaling
################################################################################

module "asg" {
  source = "github.com/sadoruin/terraform-ncloud-auto-scaling-group.git"

  launch_configuration_no = module.lc.launch_configuration.id

  name                    = "tf-test-asg"
  subnet_no               = module.tf_test_vpc.subnets["tf-test-web-sbn"].id
  server_name_prefix      = "web"
  min_size                = 0
  max_size                = 0
  desired_capacity        = 0
  ignore_capacity_changes = false

  default_cooldown          = 300
  health_check_grace_period = 300
  health_check_type_code    = "LOADB"

  access_control_group_no_list = [
    module.tf_test_vpc.acgs["tf-test-web-svr-acg"].id
  ]

  target_group_list = [
    module.target_groups.target_groups["tf-test-web-tg"].id
  ]

}



################################################################################
# NAS Volume
################################################################################

module "nas_volumes" {
  source = "github.com/sadoruin/terraform-ncloud-nas.git"

  nas_volumes = [
    {
      volume_name_postfix            = "testnas"
      volume_size                    = 500
      volume_allotment_protocol_type = "NFS"
      server_instance_no_list        = [for x in module.tf_test_web_svr : x.server.id]
      zone                           = "KR-1"
      is_return_protection           = false
      is_encrypted_volume            = false
    }
  ]
}



################################################################################
# NKS
################################################################################

module "nks" {
  source = "github.com/sadoruin/terraform-ncloud-nks.git"

  name              = "test-cluster"
  k8s_version       = "1.24.10"
  vpc_id            = module.tf_test_vpc.vpc.id
  zone              = "KR-1"
  is_public_network = false
  subnet_id_list = [
    module.tf_test_vpc.subnets["tf-test-was-sbn"].id
  ]
  lb_private_subnet_id = module.tf_test_vpc.subnets["tf-test-nlb-sbn"].id
  maximum_node_count   = 10
  audit_log            = false
  login_key_name       = "yh-test-svr-key"

  node_pools = [
    {
      node_pool_name = "test-node-pool"
      # k8s_version    = "1.24.10"
      node_count     = 1
      ubuntu_version = "18.04"
      product_type   = "High CPU"
      product_name   = "vCPU 2EA, Memory 4GB, [SSD]Disk 50GB"
      subnet_id_list = [
        module.tf_test_vpc.subnets["tf-test-was-sbn"].id
      ]
    }
  ]
}


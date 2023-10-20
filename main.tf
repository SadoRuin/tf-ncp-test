################################################################################
# VPC
################################################################################

locals {
  vpcs = var.vpcs
}

module "vpcs" {
  source = "terraform-ncloud-modules/vpc/ncloud"

  for_each = { for vpc in local.vpcs : vpc.name => vpc }

  name                  = each.value.name
  ipv4_cidr_block       = each.value.ipv4_cidr_block
  subnets               = each.value.subnets
  network_acls          = each.value.network_acls
  deny_allow_groups     = each.value.deny_allow_groups
  access_control_groups = each.value.access_control_groups
  public_route_tables   = each.value.public_route_tables
  private_route_tables  = each.value.private_route_tables
  nat_gateways          = each.value.nat_gateways
}


################################################################################
# Server
################################################################################

locals {
  servers = var.servers

  flatten_servers = flatten([for server in local.servers :
    [
      for index in range(server.count) : merge(
        { name = join("", [server.name_prefix, server.create_multiple ? format("-%02d", index + server.start_index) : ""]) },
        { for attr_key, attr_val in server : attr_key => attr_val if(attr_key != "default_network_interface" && attr_key != "additional_block_storages") },
        { default_network_interface = merge(server.default_network_interface, { name = join("", [
          server.default_network_interface.name_prefix, server.create_multiple ? format("-%03d", index + server.start_index) : "", "-${server.default_network_interface.name_postfix}"]) })
        },
        { additional_block_storages = [for vol in server.additional_block_storages : merge(vol, { name = join("", [
          vol.name_prefix, server.create_multiple ? format("-%03d", index + server.start_index) : "", "-${vol.name_postfix}"]) })]
        }
      )
    ]
  ])
}

module "servers" {
  source = "terraform-ncloud-modules/server/ncloud"

  depends_on = [module.vpcs]

  for_each = { for server in local.flatten_servers : server.name => server }

  name        = each.value.name
  description = each.value.description

  // you can use "vpc_name" & "subnet_name". Then module will find "subnet_id" from "DataSource: ncloud_subnet".
  vpc_name    = each.value.vpc_name
  subnet_name = each.value.subnet_name
  // or use only "subnet_id" instead for inter-module reference structure.
  # subnet_id            = module.vpcs[each.value.vpc_name].subnets[each.value.subnet_name].id

  login_key_name       = each.value.login_key_name
  init_script_id       = each.value.init_script_id
  fee_system_type_code = each.value.fee_system_type_code

  server_image_name  = each.value.server_image_name
  product_generation = each.value.product_generation
  product_type       = each.value.product_type
  product_name       = each.value.product_name

  is_associate_public_ip                 = each.value.is_associate_public_ip
  is_protect_server_termination          = each.value.is_protect_server_termination
  is_encrypted_base_block_storage_volume = each.value.is_encrypted_base_block_storage_volume

  default_network_interface = merge(each.value.default_network_interface, {
    access_control_group_ids = [for acg_name in each.value.default_network_interface.access_control_groups : module.vpcs[each.value.vpc_name].access_control_groups[acg_name].id]
  })

  additional_block_storages = each.value.additional_block_storages
}

/*
resource "ncloud_login_key" "ansible_test" {
  lifecycle {
    prevent_destroy = true
  }
  key_name = "ansible-test"
}

data "ncloud_root_password" "root_pwd" {
  server_instance_no = module.tf_test_web_svr[0].server_id
  private_key        = ncloud_login_key.ansible_test.private_key
}

resource "terraform_data" "ssh_config" {
  depends_on = [module.tf_test_web_svr[0]]
  provisioner "local-exec" {
    command = <<EOF
      echo "[ncloud]" > ~/ansible/inventory
      echo '${module.tf_test_web_svr[0].server_name} ansible_host=${module.tf_test_web_svr[0].public_ip} ansible_port=22 ansible_ssh_user=root ansible_ssh_pass=${data.ncloud_root_password.root_pwd.root_password}' >> ~/ansible/inventory
    EOF
  }

  provisioner "local-exec" {
    command = <<EOF
      docker exec ansible /bin/sh -c ANSIBLE_HOST_KEY_CHECKING=False
      docker exec ansible /bin/sh -c 'ansible-playbook -i /root/ansible/inventory /root/ansible/playbook-test.yml'
    EOF
  }
}
*/


################################################################################
# Load Balancer
################################################################################

locals {
  load_balancers = var.load_balancers
}

module "load_balancers" {
  source = "terraform-ncloud-modules/load-balancer/ncloud"

  depends_on = [module.target_groups]

  for_each = { for lb in local.load_balancers : lb.name => lb }

  name         = each.value.name
  description  = each.value.description
  type         = each.value.type
  network_type = each.value.network_type

  // you can use "vpc_name" & "subnet_name". Then module will find "subnet_id" from "DataSource: ncloud_subnet".
  vpc_name     = each.value.vpc_name
  subnet_names = each.value.subnet_names
  // or "subnet_id" instead
  # subnet_ids      = [ for subnet_name in each.value.subnet_names : module.vpcs[each.value.vpc_name].subnets[subnet_name].id ] 

  throughput_type = each.value.throughput_type
  idle_timeout    = each.value.idle_timeout

  // you can use "listeners" with "target_group_name" as object attribute.
  listeners = each.value.listeners
  // or "listeners" with "target_group_id" instead.
  # listeners       = [for listener in each.value.listeners : merge(
  #   { for k, v in listener : k => v if k != "target_group_name" },
  #   { target_group_id = module.target_groups[listener.target_group_name].target_group.id }
  # )]
}


################################################################################
# Target Group
################################################################################

locals {
  target_groups = var.target_groups
}

module "target_groups" {
  source = "terraform-ncloud-modules/target-group/ncloud"

  depends_on = [module.vpcs]

  for_each = { for tg in local.target_groups : tg.name => tg }

  name               = each.value.name
  description        = each.value.description
  vpc_name           = each.value.vpc_name
  protocol           = each.value.protocol
  port               = each.value.port
  algorithm_type     = each.value.algorithm_type
  use_sticky_session = each.value.use_sticky_session
  use_proxy_protocol = each.value.use_proxy_protocol
  target_type        = each.value.target_type

  // you can use "target_instance_names". Then module will find "server_instance_no" from "DataSource: ncloud_server"
  target_instance_names = [for x in module.servers : x.server.name if startswith(x.server.name, each.value.target_instance_names[0])]
  // or "target_instance_ids" instead
  # target_instance_ids   = [for instance_name in each.value.target_instance_names : module.servers[instance_name].server.id]

  health_check = each.value.health_check
}

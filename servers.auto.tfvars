servers = [
  ##############################################################################
  # WEB Server
  ##############################################################################
  {
    create_multiple = true
    count           = 2
    start_index     = 1

    name_prefix          = "tf-test-web-svr"
    description          = "WEB Server"
    vpc_name             = "tf-test-vpc"
    subnet_name          = "tf-test-web-sbn"
    login_key_name       = "yh-test-svr-key"
    init_script_id       = null
    fee_system_type_code = "MTRAT"

    server_image_name  = "CentOS 7.8 (64-bit)"
    product_generation = "G2"
    product_type       = "High CPU"
    product_name       = "vCPU 2EA, Memory 4GB, Disk 50GB"

    is_associate_public_ip                 = true
    is_protect_server_termination          = false
    is_encrypted_base_block_storage_volume = false

    default_network_interface = {
      name_prefix           = "tf-test-web-svr"
      name_postfix          = "nic"
      description           = "WEB Server NIC"
      private_ip            = null
      access_control_groups = ["tf-test-web-svr-acg"]
    }

    additional_block_storages = []
  },
  ##############################################################################
  # WAS Server
  ##############################################################################
  {
    create_multiple = true
    count           = 2
    start_index     = 1

    name_prefix          = "tf-test-was-svr"
    description          = "WAS Server"
    vpc_name             = "tf-test-vpc"
    subnet_name          = "tf-test-was-sbn"
    login_key_name       = "yh-test-svr-key"
    init_script_id       = null
    fee_system_type_code = "MTRAT"

    server_image_name  = "CentOS 7.8 (64-bit)"
    product_generation = "G2"
    product_type       = "High CPU"
    product_name       = "vCPU 2EA, Memory 4GB, Disk 50GB"

    is_associate_public_ip                 = false
    is_protect_server_termination          = false
    is_encrypted_base_block_storage_volume = false

    default_network_interface = {
      name_prefix           = "tf-test-was-svr"
      name_postfix          = "nic"
      description           = "WAS Server NIC"
      private_ip            = null
      access_control_groups = ["tf-test-was-svr-acg"]
    }

    additional_block_storages = []
  },
  ##############################################################################
  # DB Server
  ##############################################################################
  {
    create_multiple = true
    count           = 1
    start_index     = 1

    name_prefix          = "tf-test-db-svr"
    description          = "DB Server"
    vpc_name             = "tf-test-vpc"
    subnet_name          = "tf-test-db-sbn"
    login_key_name       = "yh-test-svr-key"
    init_script_id       = null
    fee_system_type_code = "MTRAT"

    server_image_name  = "mariadb(10.2)-centos-7.8-64"
    product_generation = "G2"
    product_type       = "High CPU"
    product_name       = "vCPU 2EA, Memory 4GB, Disk 50GB"

    is_associate_public_ip                 = false
    is_protect_server_termination          = false
    is_encrypted_base_block_storage_volume = false

    default_network_interface = {
      name_prefix           = "tf-test-db-svr"
      name_postfix          = "nic"
      description           = "DB Server NIC"
      private_ip            = null
      access_control_groups = ["tf-test-db-svr-acg"]
    }

    additional_block_storages = []
  }
]

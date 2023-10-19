variable "access_key" {
  default   = "NCP API Access Key"
  type      = string
  sensitive = true
}

variable "secret_key" {
  description = "NCP API Secret Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "NCP 리전"
  type        = string
}

variable "site" {
  description = "NCP 사이트(public | gov | fin)"
  type        = string
}

variable "support_vpc" {
  description = "VPC 사용 여부"
  type        = string
}

variable "vpcs" {
  type = list(object({
    name            = string
    ipv4_cidr_block = string // cidr block

    subnets = optional(list(object({
      name        = string
      usage_type  = optional(string, "GEN")     // GEN (default) | LOADB
      subnet_type = string                      // PUBLIC | PRIVATE, If usage_type is LOADB in the KR region, only PRIVATE is allowed. 
      zone        = string                      // (PUB) KR-1 | KR-2 // (FIN) FKR-1 | FKR-2 // (GOV) KR | KRS
      subnet      = string                      // cidr block
      network_acl = optional(string, "default") // default (default) | NetworkAclName, If set "default", then "default Network ACL" will be set. 
    })), [])

    network_acls = optional(list(object({
      name        = string               // if set "default", then "default Network ACL rule" will be created
      description = optional(string, "") // if name is "default", then description is ignored

      // The order of writing inbound_rules & outbound_rules is as follows.
      // [
      //   priority(number),                                      // 1-199
      //   protocol(string),                                      // TCP | UDP | ICMP
      //   cidr_block(string) | deny_allow_group_name(string),      
      //   port_number(number) | port_range(string),              // need to enter "" if protocol is ICMP
      //   rule_action(string),                                   // ALLOW | DROP
      //   description(string)
      // ]
      inbound_rules  = optional(list(list(any)), [])
      outbound_rules = optional(list(list(any)), [])
    })), [])

    deny_allow_groups = optional(list(object({
      name        = string
      description = optional(string, "")
      ip_list     = optional(list(string), []) // IP address (not CIDR)
    })), [])

    access_control_groups = optional(list(object({
      name        = string               // if set "default", then "default ACG rule" will be created
      description = optional(string, "") // if name is "default", then description is ignored

      // The order of writing inbound_rules & outbound_rules is as follows.
      // [
      //   protocol(string),                                      // TCP | UDP | ICMP
      //   cidr_block(string) | access_control_group_name(string),      
      //   port_number(number) | port_range(string),              // need to enter "" if protocol is ICMP
      //   description(string)
      // ]
      inbound_rules  = optional(list(list(any)), [])
      outbound_rules = optional(list(list(any)), [])
    })), [])

    public_route_tables = optional(list(object({
      name         = string
      description  = optional(string, "")
      subnet_names = optional(list(string), []) // All subnets not specified in the separately created route table are automatically associated to the "default route table".
    })), [])

    private_route_tables = optional(list(object({
      name         = string
      description  = optional(string, "")
      subnet_names = optional(list(string), []) // All subnets not specified in the separately created route table are automatically associated to the "default route table".
    })), [])

    nat_gateways = optional(list(object({
      name        = string
      zone        = string                      // KR-1 | KR-2
      route_table = optional(string, "default") // default (default) | RouteTableName, If set "default", then "default Route Table for private Subnet" will be set.
    })), [])
  }))
  default = []
}

variable "servers" {
  type = list(object({
    create_multiple = optional(bool, false) // If true, create multiple servers with postfixes "-001", "-002"
    count           = optional(number, 1)   // Required when create_multiple = true
    start_index     = optional(number, 1)   // Required when create_multiple = true

    name_prefix          = string // Same as "name" if create_multiple = false
    description          = optional(string, "")
    vpc_name             = string
    subnet_name          = string
    login_key_name       = string
    init_script_id       = optional(string, null)
    fee_system_type_code = optional(string, "MTRAT") // MTRAT (default) | FXSUM

    server_image_name  = string // "Image Name" on "terraform-ncloud-docs"
    product_generation = string // "Gen" on "Server product" page on "terraform-ncloud-docs"
    product_type       = string // "Type" on "Server product" page on "terraform-ncloud-docs"
    product_name       = string // "Product Name" on "Server product" page on "terraform-ncloud-docs"

    is_associate_public_ip                 = optional(bool, false) // Can only be true if the subnet is a public subnet.
    is_protect_server_termination          = optional(bool, false)
    is_encrypted_base_block_storage_volume = optional(bool, false)

    default_network_interface = object({
      name_prefix           = string // "name" will be "${name_prefix}-${name_postfix}" if create_multiple = false
      name_postfix          = string
      description           = optional(string, "")
      private_ip            = optional(string, null)              // IP address (not CIDR)
      access_control_groups = optional(list(string), ["default"]) // default value is ["default"], "default" is the "default access control group".
    })

    additional_block_storages = optional(list(object({
      name_prefix  = string // "name" will be "${name_prefix}-${name_postfix}" if create_multiple = false
      name_postfix = string
      description  = optional(string, "")
      size         = number                  // Unit = GB
      disk_type    = optional(string, "SSD") // SSD (default) | HDD
    })), [])
  }))
  default = []
}

variable "load_balancers" {
  type = list(object({
    name         = string
    description  = optional(string, "")
    type         = string                     // NETWORK | NETWORK_PROXY | APPLICATION
    network_type = optional(string, "PUBLIC") // PUBLIC (default) | PRIVATE

    vpc_name     = string
    subnet_names = list(string)

    throughput_type = optional(string, "SMALL") // SMALL (default) | MEDUIM | LARGE
    // Only SMALL can be selected when type is NETWORK and network_type is PRIVATE
    idle_timeout = optional(number, 60) // 60 (default)

    listeners = optional(list(object({
      protocol          = string // TCP (when type is NETWORK), TCP/TLS (when type is NETWORK_PROXY), HTTP/HTTPS (when type is APPLICATION)
      port              = number
      target_group_name = string

      // The properties below are valid only when the listener protocol is HTTPS or TLS.
      ssl_certificate_no   = optional(string, null)
      tls_min_version_type = optional(string, "TLSV10") // TLSV10 (default) | TLSV11 | TLSV12

      // The property below are valid only when the listener protocol is HTTPS
      use_http2 = optional(bool, false) // false (default)
    })), [])
  }))
  default = []
}

variable "target_groups" {
  type = list(object({
    name        = string
    description = string
    vpc_name    = string

    protocol = string // TCP | PROXY_TCP | HTTP | HTTPS
    port     = number

    algorithm_type = optional(string, "RR") // RR(Round Robin) (default) | SIPHS(Source IP Hash) | LC(Least Connection) | MH(Maglev Hash). 
    // RR | SIPHS | LC (when protocol = PROXY_TCP/HTTP/HTTPS). 
    // RR | MM (when protocol = TCP)
    use_sticky_session = optional(bool, false) // false (default)
    use_proxy_protocol = optional(bool, false) // false (default)

    target_type           = optional(string, "VSVR") // VSVR (default)
    target_instance_names = optional(list(string), [])

    health_check = object({
      protocol = string // TCP (when protocol = TCP/PROXY_TCP) | HTTP (when protocol = HTTP/HTTPS) | HTTPS (when protocol = HTTP/HTTPS)
      port     = number

      http_method    = optional(string, "GET") // GET (default) | HEAD 
      url_path       = optional(string, "/")   // "/" (default)
      cycle          = optional(number, "30")  // 30 (default)
      up_threshold   = optional(number, "2")   // 2 (default)
      down_threshold = optional(number, "2")   // 2 (default)
    })
  }))
  default = []
}

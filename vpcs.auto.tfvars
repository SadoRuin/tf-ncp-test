vpcs = [
  {
    name            = "tf-test-vpc"
    ipv4_cidr_block = "10.0.0.0/16"

    ##############################################################################
    # Subnets
    ##############################################################################
    subnets = [
      {
        name        = "tf-test-web-sbn"
        usage_type  = "GEN"
        subnet_type = "PUBLIC"
        zone        = "KR-1"
        subnet      = "10.0.0.0/24"
        network_acl = "default"
      },
      {
        name        = "tf-test-was-sbn"
        usage_type  = "GEN"
        subnet_type = "PRIVATE"
        zone        = "KR-1"
        subnet      = "10.0.1.0/24"
        network_acl = "default"
      },
      {
        name        = "tf-test-db-sbn"
        usage_type  = "GEN"
        subnet_type = "PRIVATE"
        zone        = "KR-1"
        subnet      = "10.0.2.0/24"
        network_acl = "default"
      },
      {
        name        = "tf-test-alb-sbn"
        usage_type  = "LOADB"
        subnet_type = "PRIVATE"
        zone        = "KR-1"
        subnet      = "10.0.3.0/24"
        network_acl = "default"
      },
      {
        name        = "tf-test-nlb-sbn"
        usage_type  = "LOADB"
        subnet_type = "PRIVATE"
        zone        = "KR-1"
        subnet      = "10.0.4.0/24"
        network_acl = "default"
      }
    ]

    network_acls = [
      {
        name           = "default"
        description    = "Default Network ACL for this VPC"
        inbound_rules  = []
        outbound_rules = []
      }
    ]

    deny_allow_groups = []

    ##############################################################################
    # ACG
    ##############################################################################
    access_control_groups = [
      {
        name        = "default"
        description = "Default ACG for this VPC"
        inbound_rules = [
          ["TCP", "0.0.0.0/0", 3389, ""],
          ["TCP", "0.0.0.0/0", 22, ""]
        ]
        outbound_rules = [
          ["ICMP", "0.0.0.0/0", "", ""],
          ["UDP", "0.0.0.0/0", "1-65535", ""],
          ["TCP", "0.0.0.0/0", "1-65535", ""]
        ]
      },
      {
        name        = "tf-test-web-svr-acg"
        description = "WEB Server ACG"
        inbound_rules = [
          ["TCP", "0.0.0.0/0", 22, "SSH 접속 허용"],
          ["TCP", "0.0.0.0/0", 80, "HTTP 통신 허용"],
          ["TCP", "0.0.0.0/0", 443, "HTTPS 통신 허용"]
        ]
        outbound_rules = [
          ["TCP", "0.0.0.0/0", "1-65535", "모든 포트 허용"]
        ]
      },
      {
        name        = "tf-test-was-svr-acg"
        description = "WAS Server ACG"
        inbound_rules = [
          ["TCP", "0.0.0.0/0", 8080, "Tomcat 포트 허용"]
        ]
        outbound_rules = []
      },
      {
        name        = "tf-test-db-svr-acg"
        description = "DB Server ACG"
        inbound_rules = [
          ["TCP", "0.0.0.0/0", 3306, "MySQL 포트 허용"]
        ]
        outbound_rules = []
      }
    ]

    public_route_tables  = []
    private_route_tables = []

    nat_gateways = []
  }
]

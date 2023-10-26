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

variable "acg_rules" {
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
      description = "SSH 접속 허용"
    },

    http = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "80"
      description = "HTTP 통신 허용"
    },

    https = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "443"
      description = "HTTPS 통신 허용"
    },

    tomcat = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "8080"
      description = "Tomcat 포트 허용"
    },

    mysql = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "3306"
      description = "MySQL 포트 허용"
    },

    all = {
      protocol    = "TCP"
      ip_block    = "0.0.0.0/0"
      port_range  = "1-65535"
      description = "모든 포트 허용"
    }
  }
}

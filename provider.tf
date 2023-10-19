terraform {
  required_version = ">= 1.0"

  cloud {
    organization = "TF-TEST-ORG-123"
    hostname     = "app.terraform.io"
    workspaces {
      name = "ncp-test"
    }
  }

  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = ">= 2.3.18"
    }
  }
}

// Configure the ncloud provider
provider "ncloud" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  region      = var.region
  site        = var.site
  support_vpc = var.support_vpc
}

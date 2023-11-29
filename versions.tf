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

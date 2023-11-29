terraform {
  required_version = ">= 1.0"

  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = ">= 2.3.18"
    }
  }
}

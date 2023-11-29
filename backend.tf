terraform {
  cloud {
    organization = "TF-TEST-ORG-123"
    hostname     = "app.terraform.io"
    workspaces {
      name = "ncp-test"
    }
  }
}

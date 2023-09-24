################################################################################
# Server
################################################################################

# WEB Server
resource "ncloud_server" "test-web-svr-01" {
  subnet_no                 = ncloud_subnet.test-sbn-pub-01.id
  name                      = "test-web-svr-01"
  server_image_product_code = data.ncloud_server_image.rocky-8_8.id
  server_product_code       = data.ncloud_server_product.c2-g2-h50.id
  login_key_name            = var.loginkey
  network_interface {
    network_interface_no = ncloud_network_interface.test-web-svr-nic-01.id
    order                = 0
  }
}

# WAS Server
resource "ncloud_server" "test-was-svr-01" {
  subnet_no                 = ncloud_subnet.test-sbn-pri-01.id
  name                      = "test-was-svr-01"
  server_image_product_code = data.ncloud_server_image.rocky-8_8.id
  server_product_code       = data.ncloud_server_product.c2-g2-h50.id
  login_key_name            = var.loginkey
  network_interface {
    network_interface_no = ncloud_network_interface.test-was-svr-nic-01.id
    order                = 0
  }
}

# DB Server
resource "ncloud_server" "test-db-svr-01" {
  subnet_no                 = ncloud_subnet.test-sbn-pri-02.id
  name                      = "test-db-svr-01"
  server_image_product_code = data.ncloud_server_image.centos7-mariadb-10_2.id
  server_product_code       = data.ncloud_server_product.c2-g2-h50.id
  login_key_name            = var.loginkey
  network_interface {
    network_interface_no = ncloud_network_interface.test-db-svr-nic-01.id
    order                = 0
  }
}

################################################################################
# Login Key
################################################################################
variable "loginkey" {
  default = "yh-test-svr-key"
}


################################################################################
# Server Image
################################################################################
data "ncloud_server_image" "rocky-8_8" {
  filter {
    name   = "product_name"
    values = ["Rocky Linux 8.8"]
  }
}

data "ncloud_server_image" "centos7-mariadb-10_2" {
  filter {
    name   = "product_name"
    values = ["mariadb(10.2)-centos-7.8-64"]
  }
}

################################################################################
# Server Product
################################################################################
data "ncloud_server_product" "c2-g2-h50" {
  server_image_product_code = data.ncloud_server_image.rocky-8_8.id

  dynamic "filter" {
    for_each = {
      "product_code" = "HDD"
      "product_type" = "HICPU"
      "cpu_count"    = "2"
      "memory_size"  = "4GB"
    }

    content {
      name   = filter.key
      values = [filter.value]
      regex  = filter.key == "product_code" ? true : false
    }
  }
}


/*
################################################################################
# 이미지 목록 조회
################################################################################
data "ncloud_server_images" "images" {
  filter {
    name   = "platform_type"
    values = ["LNX64"]
  }

  output_file = "images.json"
}

output "list_image" {
  value = {
    for image in data.ncloud_server_images.images.server_images :
    image.product_name => image.os_information
  }
}
*/

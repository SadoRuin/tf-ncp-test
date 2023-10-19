load_balancers = [
  {
    name         = "tf-test-web-alb"
    description  = "WEB Server Application Load Balancer"
    type         = "APPLICATION"
    network_type = "PUBLIC"

    vpc_name     = "tf-test-vpc"
    subnet_names = ["tf-test-alb-sbn"]

    throughput_type = "SMALL"
    idle_timeout    = 60

    listeners = [
      {
        protocol          = "HTTP"
        port              = 80
        target_group_name = "tf-test-web-alb-tg"
      }
    ]
  },
  {
    name         = "tf-test-was-nlb"
    description  = "WAS Server Network Load Balancer"
    type         = "NETWORK"
    network_type = "PRIVATE"

    vpc_name     = "tf-test-vpc"
    subnet_names = ["tf-test-nlb-sbn"]

    throughput_type = "SMALL"
    idle_timeout    = 60

    listeners = [
      {
        protocol          = "TCP"
        port              = 8080
        target_group_name = "tf-test-was-nlb-tg"
      }
    ]
  }
]

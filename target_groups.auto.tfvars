target_groups = [
  {
    name        = "tf-test-web-alb-tg"
    description = "WEB Server Target Group"
    vpc_name    = "tf-test-vpc"

    protocol = "HTTP"
    port     = 80

    algorithm_type     = "RR"
    use_sticky_session = false
    use_proxy_protocol = false

    target_type           = "VSVR"
    target_instance_names = ["tf-test-web-svr"]

    health_check = {
      protocol = "HTTP"
      port     = 80

      http_method    = "GET"
      url_path       = "/"
      cycle          = 30
      up_threshold   = 2
      down_threshold = 2
    }
  },
  {
    name        = "tf-test-was-nlb-tg"
    description = "WAS Server Target Group"
    vpc_name    = "tf-test-vpc"

    protocol = "TCP"
    port     = 8080

    algorithm_type     = "MH"
    use_sticky_session = false
    use_proxy_protocol = false

    target_type           = "VSVR"
    target_instance_names = ["tf-test-was-svr"]

    health_check = {
      protocol = "TCP"
      port     = 8080

      cycle          = 30
      up_threshold   = 2
      down_threshold = 2
    }
  }
]

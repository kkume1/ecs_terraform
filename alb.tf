# ALBのログ用のS3バケットの取得

data "aws_s3_bucket" "bucket" {
  bucket = "mecgogo-backet1"
}

# ロードバランサーの定義
resource "aws_lb" "alb" {
  name = "${var.ProjectName}-ALB"
  load_balancer_type = "application"
  internal = false
  idle_timeout = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.public0.id,
    aws_subnet.public1.id,
  ]

  access_logs {
    bucket = data.aws_s3_bucket.bucket.id
    prefix = "nginx-CF-ALB-Logs"
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
  ]
  tags = {
    Name = "${var.ProjectName}-ALB"
  }
}

# リスナーの定義
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"

  # defaultはプライオリティーが一番低い
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

# ターゲットグループの定義(ECSと紐づける)
resource "aws_lb_target_group" "nginx" {
  name = "${var.ProjectName}-TG"
  vpc_id = aws_vpc.vpc.id
  target_type = "ip"
  port = 80
  protocol = "HTTP"

  deregistration_delay = 300

  health_check {
    path = "/"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    matcher = 200
    port = "traffic-port" # 「port = 80」 の値が使用される
    protocol = "HTTP"
  }

  depends_on = [aws_lb.alb]
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

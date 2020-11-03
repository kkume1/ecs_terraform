# セキュリティグループの定義

# 外部からの80番ポートの通信を許可（ALB向け）
module "http_sg" {
  source = "./security_group"
  name = "${var.ProjectName}-http-sg"
  vpc_id = aws_vpc.vpc.id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}

# 内部からの80番ポートへの通信を許可（コンテナ向け）
module "nginx_sg" {
  source = "./security_group"
  name = "${var.ProjectName}-nginx-sg"
  vpc_id = aws_vpc.vpc.id
  port = 80
  cidr_blocks = [aws_vpc.vpc.cidr_block]
}

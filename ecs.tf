# クラスターの定義
resource "aws_ecs_cluster" "nginx" {
  name = "${var.ProjectName}-Cluster"
}

# タスク定義の定義
resource "aws_ecs_task_definition" "nginx" {
  family = "${var.ProjectName}-Task"
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = file("./container.json")
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

# サービスの定義
resource "aws_ecs_service" "nginx" {
  name = "nginx-sample-Service"
  # 使用するクラスタ
  cluster = aws_ecs_cluster.nginx.arn
  # 使用するタスク定義
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count = 2
  launch_type = "FARGATE"
  platform_version = "1.3.0"
  health_check_grace_period_seconds = 60
  deployment_minimum_healthy_percent = 50
  #deployment_maximum_percent = 200

  network_configuration {
    # ECSがECRからイメージを取得するときはインターネットを経由する。
    # パブリックサブネットにコンテナを配置する場合は「assign_public_ip = true」でイメージを取得できる。、
    # 今回はプライベートサブネットにコンテナを配置し、NatGW経由でイメージを取得するためfalseでも取得できる。
    assign_public_ip = false
    security_groups = [module.nginx_sg.security_group_id]

    subnets = [
      # プライベートサブネットに配置する
      aws_subnet.private0.id,
      aws_subnet.private1.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name = var.ProjectName
    container_port = 80
  }

  lifecycle {
    ignore_changes = [task_definition] # デプロイのたびにタスク定義が変更されるので、無視する
  }
}

# cloudwatch log の定義
resource "aws_cloudwatch_log_group" "nginx" {
  name = "/nginx-CF/ECS-logs"
  retention_in_days = 180
}



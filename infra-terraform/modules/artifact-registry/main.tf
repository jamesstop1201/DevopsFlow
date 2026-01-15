resource "aws_ecr_repository" "finance_app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # 推送時掃描映像檔
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}


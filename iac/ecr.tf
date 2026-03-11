resource "aws_ecr_repository" "ecr-ci-api" {
  name = "ecr-ci-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    IAC = "true"
  }
}
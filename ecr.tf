resource "aws_ecr_repository" "todolamp" {
  name                 = "todolamp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.todolamp.repository_url
}

output "ecr_repository_name" {
  value = aws_ecr_repository.todolamp.name
  
}
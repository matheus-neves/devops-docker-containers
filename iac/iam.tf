resource "aws_iam_openid_connect_provider" "open_id_connect_git" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["cf23df2207d99a74fbe169e3eba035e633b65d94"]

  tags = {
    IAC = "true"
  }
}

resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"

  assume_role_policy = jsonencode({
    "Version"   = "2012-10-17"
    "Statement" = [
      {
        "Effect"    = "Allow"
        "Principal" = { "Service" = "build.apprunner.amazonaws.com" }
        "Action"    = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  tags = {
    IAC = "true"
  }
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" = "sts:AssumeRoleWithWebIdentity"
        "Condition" = {
          "StringEquals" = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:matheus-neves/devops-docker-containers:ref:refs/heads/main"
          }
        }
        "Effect" = "Allow"
        "Principal" = {
          "Federated" = "arn:aws:iam::296348348274:oidc-provider/token.actions.githubusercontent.com"
        }
      }
    ]
  })

  inline_policy {
    name = "ecr-app-permission"

    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "Statement1",
          "Effect": "Allow",
          "Action": "apprunner:*",
          "Resource": "*"
        },
        {
          "Sid": "Statement2",
          "Effect": "Allow",
          "Action": [
            "iam:PassRole",
            "iam:CreateServiceLinkedRole",
          ],
          "Resource": "*"
        },
        {
          "Sid": "Statement3",
          "Action": [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
          ]
          "Effect": "Allow",
          "Resource": "*"
        },
      ]
    })
  }

  tags = {
    IAC = "true"
  }
}
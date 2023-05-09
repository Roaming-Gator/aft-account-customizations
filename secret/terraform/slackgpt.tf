# enable terraform cloud to assume a role in the slackgpt accounts and perform administrative actions

# get current account id
data "aws_caller_identity" "current" {}

# allow the specified terraform cloud project to assume the role
resource "aws_iam_role" "slackgpt" {
  name = "slackgpt"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/app.terraform.io"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "app.terraform.io:aud" : "aws.workload.identity"
          },
          "StringLike" : {
            "app.terraform.io:sub" : "organization:roaminggator:project:slackgpt:workspace:*:run_phase:*",
          }
        }
      }
    ]
  })
}

# allow the assumed role to perform the needed actions 
resource "aws_iam_policy" "slackgpt" {
  name        = "SlackGPTReadSecrets"
  description = "Allow read access to AWS Secrets Manager secrets under services/slackgpt/*"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:*:*:secret:services/slackgpt/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "slackgpt" {
  policy_arn = aws_iam_policy.slackgpt.arn
  role       = aws_iam_role.slackgpt.name
}

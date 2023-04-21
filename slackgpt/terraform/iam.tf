# enable terraform cloud to assume a role in the slackgpt accounts and perform administrative actions

# get current account id
data "aws_caller_identity" "current" {}

# allow the specified terraform cloud project to assume the role
resource "aws_iam_role" "terraform_cloud" {
  name = "terraform-cloud"
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

resource "aws_iam_role_policy_attachment" "lambda-full-access" {
  role       = aws_iam_role.terraform_cloud.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# dynamodb holds the chat state
resource "aws_iam_role_policy_attachment" "dynamodb-full-access" {
  role       = aws_iam_role.terraform_cloud.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# secrets manager holds the keys, etc
resource "aws_iam_role_policy_attachment" "secretsmanager-read-write" {
  role       = aws_iam_role.terraform_cloud.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# need to be able to set up iam roles
resource "aws_iam_role_policy_attachment" "iam-full-access" {
  role       = aws_iam_role.terraform_cloud.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# api gateway is the endpoint that slack sends events to
resource "aws_iam_role_policy_attachment" "apigw-full-access" {
  role       = aws_iam_role.terraform_cloud.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}

# sqs is the queue that lambda uses to send jobs to the background
resource "aws_iam_role_policy_attachment" "sqs-full-access" {
  role       = aws_iam_role.terraform_cloud.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

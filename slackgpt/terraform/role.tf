# # create an iam role for github actions to assume

# # get current account id
# data "aws_caller_identity" "current" {}

# # allow the specified github repo to assume the role
# resource "aws_iam_role" "github_actions" {
#   name = "github-actions"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         "Version" : "2012-10-17",
#         "Statement" : [
#           {
#             "Effect" : "Allow",
#             "Principal" : {
#               "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
#             },
#             "Action" : "sts:AssumeRoleWithWebIdentity",
#             "Condition" : {
#               "StringEquals" : {
#                 "token.actions.githubusercontent.com:sub" : "repo:Roaming-Gator/slackgpt:ref:refs/heads/*",
#                 "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
#               }
#             }
#           }
#         ]
#       }
#     ]
#   })
# }

# # associate the needed policies with the github actions role 

# resource "aws_iam_role_policy_attachment" "lambda-full-access" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
# }

# resource "aws_iam_role_policy_attachment" "dynamodb-full-access" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "secretsmanager-read-write" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
# }

# resource "aws_iam_role_policy_attachment" "iam-full-access" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
# }

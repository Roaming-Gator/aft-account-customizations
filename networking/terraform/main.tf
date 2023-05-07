module "basic" {
  source = "github.com/aws-ia/terraform-aws-ipam"

  top_cidr        = ["10.0.0.0/8"]
  top_name        = "Internal IP Space"
  ipam_scope_type = "private"
  pool_configurations = {
    us-east-1 = {
      cidr   = ["10.1.0.0/16"]
      locale = "us-east-1"
      ram_share_principals = [
        data.aws_organizations_organization.org.arn
      ]
    }
  }
}

data "aws_organizations_organization" "org" {}

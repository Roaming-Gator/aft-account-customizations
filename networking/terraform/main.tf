module "basic" {
  source = "github.com/aws-ia/terraform-aws-ipam"

  top_cidr        = ["10.0.0.0/8"]
  top_name        = "Internal IP Space"
  ipam_scope_type = "private"
  ram_share_principals = [
    data.aws_organizations_organization.org.id
  ]
}

data "aws_organizations_organization" "org" {}

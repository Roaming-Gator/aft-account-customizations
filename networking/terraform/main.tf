module "basic" {
  source = "github.com/aws-ia/terraform-aws-ipam"

  top_cidr = ["10.0.0.0/8"]
  top_name = "basic ipam"
}

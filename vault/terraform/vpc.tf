
# look up ipam pool us-east-1
data "aws_vpc_ipam_pool" "this" {
  filter {
    name   = "name"
    values = ["us-east-1"]
  }

  filter {
    name   = "address-family"
    values = ["ipv4"]
  }
}

data "aws_region" "current" {}

# create a vpc
resource "aws_vpc" "this" {
  ipv4_ipam_pool_id   = data.aws_vpc_ipam_pool.this.id
  ipv4_netmask_length = 28
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "deployment_targets" {
  for_each          = toset(slice(data.aws_availability_zones.available.names, 0, local.subnet_count))
  availability_zone = each.key
}

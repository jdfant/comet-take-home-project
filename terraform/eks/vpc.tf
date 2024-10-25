provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

################################################################################
# VPC
################################################################################
# Let's go ahead and create one just for this project.
# Since I have no existing VPC details, it's very possible the cidr below could overlap with other cidrs.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  # We're just going to match the VPC name with EKS Cluster Name for this project
  name            = local.eks_cluster_name
  enable_flow_log = local.enable_vpc_flow_logs

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for k, v in module.vpc.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in module.vpc.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_tags  = local.cluster_tags
  private_subnet_tags = local.cluster_tags

  tags = merge(
    local.tags,
    local.cluster_tags
  )
}
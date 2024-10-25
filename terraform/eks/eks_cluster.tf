module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.eks_cluster_name
  cluster_version = local.cluster_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  enable_irsa                    = local.enable_irsa
  cluster_endpoint_public_access = true
  cluster_encryption_config      = local.cluster_encryption_config

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  eks_managed_node_groups = {
    defaults = {
      ami_type              = local.ami_type
      ami_release_version   = local.ami_release_version
      instance_types        = local.instance_types
      platform              = local.platform
      block_device_mappings = local.block_device_mappings

      max_size = local.max_size
      min_size = local.min_size
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = local.desired_size

      cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id

      vpc_security_group_ids = [
        module.eks.cluster_primary_security_group_id,
        module.eks.cluster_security_group_id,
      ]

      # k8s labels 
      labels = local.labels

      # Additional Policies
      iam_role_additional_policies = local.iam_role_additional_policies

      # Not sure if this enry is even necessary after module version 20.0? :/
      # Keeping it here for posterity.
      create_iam_instance_profile = true
    }
  }

  tags = merge(
    local.tags,
    local.cluster_tags
  )
}

# Why am I using the aws-ia blueprints addons module?
#  I find their modules to be more 'robust' than the 
#  one's provided from terraform-aws-modules/eks/aws 
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  eks_addons            = local.eks_addons
  cluster_name          = module.eks.cluster_name
  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_version       = module.eks.cluster_version
  oidc_provider_arn     = module.eks.oidc_provider_arn
  enable_metrics_server = local.enable_metrics_server
}

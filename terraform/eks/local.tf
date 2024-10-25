locals {
  region  = "us-west-2"
  account = "387699453544"
  #  region  = "REPLACE WITH CORRECT AWS REGION"
  #account = "REPLACE WITH CORRECT AWS ACCOUNT"

  # VPC details
  # Since I have no existing VPC details, it's very possible the cidr below could overlap with other cidrs.
  vpc_cidr             = "10.0.0.0/16"
  enable_vpc_flow_logs = true

  eks_cluster_name = "jd-fant-comet-project" # Name of the EKS cluster.
  cluster_version  = "1.31"                  # Specifies the Kubernetes version. See https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
  enable_irsa      = true                    # Enables IAM Roles for Service Accounts (IRSA) that allows for fine-grained access control.

  # EC2
  instance_types      = ["t3.medium"]         # Example: c6i.large (https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html)
  ami_type            = "BOTTLEROCKET_x86_64" # Valid values are 'AL2_x86_64', 'AL2_x86_64_GPU, 'AL2_ARM_64', 'CUSTOM', 'BOTTLEROCKET_ARM_64', 'BOTTLEROCKET_x86_64'.
  ami_release_version = "1.25.0-388e1050"     # Example: 1.18.0-7452c37e - Use version number-first 8 chars of commit id (https://github.com/bottlerocket-os/bottlerocket/releases)
  platform            = "bottlerocket"        # 'bottlerocket' or 'linux'

  # Managed node group scaling_config
  # For this project, we're not addressing any scaling
  # If scaling is desired, just set your instance size counts and enable the 'metrics server', below
  desired_size = 1
  max_size     = 1
  min_size     = 1

  # EC2 Disks
  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 4
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
    xvdb = {
      device_name = "/dev/xvdb"
      ebs = {
        volume_size           = 100
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
  }

  labels = {
    lifecycle           = "Ec2OnDemand",
    "strict-scheduling" = "ondemand",
    owner               = local.account
  }

  tags = {
    Account     = local.account
    ClusterName = local.eks_cluster_name
    Terraformed = "True"
  }

  cluster_tags = {
    ClusterName                                           = local.eks_cluster_name
    Terraformed                                           = "True"
    "kubernetes.io/cluster/${local.eks_cluster_name}"     = "owned"
    "k8s.io/cluster-autoscaler/enabled"                   = "true"
    "k8s.io/cluster-autoscaler/${local.eks_cluster_name}" = "owned"
    "kubernetes.io/role/elb"                              = 1
  }

  # This is called on by the eks_blueprints_addons module
  # Enable this for scaling actions and/or for sending metrics to logging/monitoring applications.
  enable_metrics_server = false

  eks_addons = {
    # Updating VPC-CNI can only go up or down 1 minor version at a time.
    # Leaving 'most_recent' to true is fine on a fresh install or if you know a version has not been skipped.
    # If you receive version errors, you will need to specify the version.
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
    vpc-cni = {
      addon_name                  = "vpc-cni"
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      addon_name                  = "kube-proxy"
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      addon_name  = "coredns"
      most_recent = true
      configuration_values = jsonencode({
        computeType = "ec2"
      })
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      addon_name                  = "aws-ebs-csi-driver"
      service_account_role_arn    = module.eks.cluster_iam_role_arn
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  cluster_encryption_config = {
    resources = ["secrets"]
  }

  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonEKSServicePolicy             = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    AmazonEC2RoleforSSM                = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  }
}

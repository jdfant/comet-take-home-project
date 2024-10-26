terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 remote backend w/Dynamodb locking:
  backend "s3" {
    encrypt        = "true"
    bucket         = "remote-backend-jd-comet-tf-project"
    key            = "jd-comet-project/eks-cluster.tfstate"
    dynamodb_table = "jd-comet-tf-project"
    region         = "us-west-2"
  }
}
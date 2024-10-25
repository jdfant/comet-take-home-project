locals {
  dynamodb_table_name        = "jd-comet-tf-project"
  region                     = "us-west-2"
  bucket_remote_backend_name = "remote-backend-jd-comet-tf-project"

  tags = {
    Name        = "remote-backend-jd-comet-tf-project"
    Terraformed = formatdate("MM-DD-YYYY", timestamp())
  }
}
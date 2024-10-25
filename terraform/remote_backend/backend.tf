module "s3_remote_backend_bucket" {
  source = "./modules/remote_backend/s3-remote-backend"

  bucket_remote_backend_name = local.bucket_remote_backend_name
  tags                       = local.tags
}

module "dynamo_locking_table" {
  source = "./modules/remote_backend/dynamo-locking"

  dynamodb_table_name = local.dynamodb_table_name
  tags                = local.tags
}
### This module will create the terraform remote backend S3 bucket along with the DynamoDB (locking) table.
***The "statefile" for this module will be retained in the current local directory.***  
***Ideally, the 'statefile' should be uploaded to an S3 Bucket with a unique S3 'prefix'***
<br />
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamo_locking_table"></a> [dynamo\_locking\_table](#module\_dynamo\_locking\_table) | ./modules/remote_backend/dynamo-locking | n/a |
| <a name="module_s3_remote_backend_bucket"></a> [s3\_remote\_backend\_bucket](#module\_s3\_remote\_backend\_bucket) | ./modules/remote_backend/s3-remote-backend | n/a |
<!-- END_TF_DOCS -->


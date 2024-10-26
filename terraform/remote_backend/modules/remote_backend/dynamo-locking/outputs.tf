output "dynamodb_table" {
  description = "Name of the DynamoDB table to store Terraform state file."
  value       = aws_dynamodb_table.dynamodb_terraform_state_lock.id
}
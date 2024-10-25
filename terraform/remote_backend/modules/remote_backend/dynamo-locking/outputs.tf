output "dynamodb_table" {
  description = "Name of the DynamaDB table to store Terraform state file."
  value       = aws_dynamodb_table.dynamodb_terraform_state_lock.id
}
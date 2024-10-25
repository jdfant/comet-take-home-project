variable "dynamodb_table_name" {
  description = "dynamodb table name"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
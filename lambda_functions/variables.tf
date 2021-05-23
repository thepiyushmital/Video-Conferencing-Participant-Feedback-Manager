variable "access_key" {
        description = "Access key of AWS IAM user"
}

variable "secret_key" {
        description = "Secret key of AWS IAM user"
}

variable "connection_table_name" {
  description = "Dynamodb table name (space is not allowed)"
  default = "webSocketDb"
}

variable "feedback_table_name" {
  description = "Dynamodb table name (space is not allowed)"
  default = "clientFeedbackDb"
}

variable "environment" {
  description = "Name of environment"
  default = "dev"
}

variable "account_id" {
  default = "249733502015"
}

variable "lambda_environment"{
  default = "dev"
}
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

# ----------------------------Invoke ARNS------------------------------------

variable "connect_lambda_invoke_arn"{
  type = string
  description = "INVOKE ARN of connect lambda function"
}

variable "disconnect_lambda_invoke_arn"{
  type = string
  description = "INVOKE ARN of disconnect lambda function"
}
variable "collectfeedback_lambda_invoke_arn"{
  type = string
  description = "INVOKE ARN of message lambda function"
}

#---------------------function name --------------------------

variable "connect_lambda_function_name" {
  type = string 
  description = "connect Lambda function name"
}

variable "disconnect_lambda_function_name" {
  type = string 
  description = "disconnect Lambda function name"
}

variable "collectfeedback_lambda_function_name" {
  type = string 
  description = "disconnect Lambda function name"
}
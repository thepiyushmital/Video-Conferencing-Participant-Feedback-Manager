variable "access_key" {
        description = "Access key of AWS IAM user"
}

variable "secret_key" {
        description = "Secret key of AWS IAM user"
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

variable "generatefeedback_lambda_arn"{
  type = string
  description = "ARN for invokation of generate feedback lambda function from step functions"
}

variable "step_function_name"{
  default = "websocket_step_function"
}
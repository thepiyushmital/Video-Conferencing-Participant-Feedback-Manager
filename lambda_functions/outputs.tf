#------------- invoke arn ---------------------------------------

output "connect_lambda_invoke_arn" {
  value = "${aws_lambda_function.websockets_connect_lambda.invoke_arn}"
}

output "disconnect_lambda_invoke_arn" {
  value = "${aws_lambda_function.websockets_disconnect_lambda.invoke_arn}"
}

output "collectfeedback_lambda_invoke_arn" {
  value = "${aws_lambda_function.websockets_collectfeedback_lambda.invoke_arn}"
}

#---------------------function name --------------------------

output "connect_lambda_function_name" {
  value = "${aws_lambda_function.websockets_connect_lambda.function_name}"
}

output "disconnect_lambda_function_name" {
  value = "${aws_lambda_function.websockets_disconnect_lambda.function_name}"
}

output "collectfeedback_lambda_function_name" {
  value = "${aws_lambda_function.websockets_collectfeedback_lambda.function_name}"
}

#------------------ LAMBDA ARN-------------------------------------

output "generatefeedback_lambda_arn" {
  value = "${aws_lambda_function.websockets_generatefeedback_lambda.arn}"
}
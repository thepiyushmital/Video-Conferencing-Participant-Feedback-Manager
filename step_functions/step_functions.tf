resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = var.step_function_name
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
  {
  "Comment": "Step function for waiting 30s after execution of first onMessage lambda function, and then executing sendMEssage lambda function",
  "StartAt": "Wait",
  "States": {
    "Wait": {
      "Type": "Wait",
      "Seconds": 30,
      "Next": "Invoke Lambda function"
    },

    "Invoke Lambda function": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${var.generatefeedback_lambda_arn}",
        "Payload": {
          "Input.$": "$"
        }
      },
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role" "step_function_role" {
  name               = "${var.step_function_name}-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "StepFunctionAssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "step_function_policy" {
  name    = "${var.step_function_name}-policy"
  role    = aws_iam_role.step_function_role.id

  policy  = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "${var.generatefeedback_lambda_arn}"
      }
    ]
  }
  EOF
}
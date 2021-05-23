# ------------------------------ ROLES AND POLICIES-------------------------------------------------------

# Role created for feedback system lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role_${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Policiy to be attached to aws role created for feedback system
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy_${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        },
         {
            "Effect": "Allow",
            "Action": "states:*",
            "Resource": "*"
        },
        {
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "arn:aws:lambda:us-east-1:${var.account_id}:function:*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "cognito-idp:AdminCreateUser",
                "cognito-idp:AdminDisableUser",
                "cognito-idp:AdminGetUser",
                "cognito-idp:AdminUpdateUserAttributes",
                "cognito-idp:ListUserPoolClients"
            ],
            "Resource": [
                "arn:aws:cognito-idp:us-east-1:${var.account_id}:userpool/*"
            ],
            "Effect": "Allow"
        },        
        {
            "Action": [
                "execute-api:Invoke",
                "execute-api:ManageConnections"
            ],
            "Resource": [
                "arn:aws:execute-api:us-east-1:${var.account_id}:*"
            ],
            "Effect": "Allow"
        },
         {
            "Action": [
                "dynamodb:*"
            ],
            "Resource": [
               "*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

# ------------------------------ Data ------------------------------------------------------------

data "archive_file" "lambda_on_connect" {
  type        = "zip"
  source_file = "api_gateways/python_handlers/onConnect.py"
  output_path = "api_gateways/python_handlers/onConnect.py.zip"
}

data "archive_file" "lambda_disconnect" {
  type        = "zip"
  source_file = "api_gateways/python_handlers/onConnect.py"
  output_path = "api_gateways/python_handlers/onConnect.py.zip"
}

data "archive_file" "lambda_collectfeedback" {
  type        = "zip"
  source_file = "api_gateways/python_handlers/collectfeedback.py"
  output_path = "api_gateways/python_handlers/collectfeedback.py.zip"
}

data "archive_file" "lambda_generatefeedback" {
  type        = "zip"
  source_file = "api_gateways/python_handlers/generatefeedback.py"
  output_path = "api_gateways/python_handlers/generatefeedback.py.zip"
}


# ------------------------------ LAMBDA FUNCTIONS---------------------------------------------------

resource "aws_lambda_function" "websockets_connect_lambda" {
#   depends_on       = [var.websockets_object]
  function_name = "websockets_connect_${var.environment}"
  handler       = "onConnect.lambda_handler"
  filename      = data.archive_file.lambda_on_connect.output_path
  runtime       = "python3.8"
  timeout       = 30
  memory_size   = 128
  role           = aws_iam_role.lambda_role.arn
#   environment {
#     variables = var.lambda_environment
#   }
}

resource "aws_lambda_function" "websockets_generatefeedback_lambda" {
#   depends_on       = [var.websockets_object]
  function_name = "websockets_generatefeedback_${var.environment}"
  handler       = "generateFeedback.lambda_handler"
  filename      = data.archive_file.lambda_generatefeedback.output_path
  runtime       = "python3.8"
  timeout       = 30
  memory_size   = 128
  role           = aws_iam_role.lambda_role.arn
#   environment {
#     variables = var.lambda_environment
#   }
}


resource "aws_lambda_function" "websockets_collectfeedback_lambda" {
#   depends_on       = [var.websockets_object]
  function_name = "websockets_collectfeedback_${var.environment}"
  handler       = "collectFeedback.lambda_handler"
  filename      = data.archive_file.lambda_collectfeedback.output_path
  runtime       = "python3.8"
  timeout       = 30
  memory_size   = 128
  role           = aws_iam_role.lambda_role.arn
#   environment {
#     variables = var.lambda_environment
#   }
}

resource "aws_lambda_function" "websockets_disconnect_lambda" {
#   depends_on       = [var.websockets_object]
  function_name    = "websockets_disconnect_${var.environment}"
  handler       = "onConnect.lambda_handler"
  filename      = data.archive_file.lambda_disconnect.output_path
  runtime       = "python3.8"
  timeout       = 30
  memory_size   = 128
  role           = aws_iam_role.lambda_role.arn
#   environment {
#     variables = var.lambda_environment
#   }
}





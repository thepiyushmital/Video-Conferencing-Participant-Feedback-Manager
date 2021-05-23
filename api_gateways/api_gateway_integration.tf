# ------------------------------ WEBSOCKET API ----------------------------------------------------------

resource "aws_apigatewayv2_api" "websocket_api" {
  name                       = "websocket_api_${var.environment}"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}


# ------------------------------ ROUTES------------------------------------------------------------------

resource "aws_apigatewayv2_route" "connect" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "onconnect"
  #   authorization_type = "CUSTOM"
  #   authorizer_id      = aws_apigatewayv2_authorizer.websocket_authorizer.id
  target = "integrations/${aws_apigatewayv2_integration.websockets_connect_integration.id}"
}

resource "aws_apigatewayv2_route" "collectfeedback" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "collectfeedback"
  target = "integrations/${aws_apigatewayv2_integration.websockets_collectfeedback_integration.id}"
}

# Route for disconnection
resource "aws_apigatewayv2_route" "disconnect" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.websockets_disconnect_integration.id}"
}

# ------------------------------ ROLES AND POLICIES-------------------------------------------------------

# API Gateway Invocation role for invoking Websocket APIs
resource "aws_iam_role" "api_gateway_invocation_role" {
  name = "api_gateway_invocation_role_${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#Policy associated with the API gateway invocation role
resource "aws_iam_role_policy" "api_gateway_invocation_policy" {
  name = "api_gateway_invocation_policy_${var.environment}"
  role = aws_iam_role.api_gateway_invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#------------------------------LAMBDA INTEGRATIONS-------------------------------------------------

resource "aws_apigatewayv2_integration" "websockets_connect_integration" {
  api_id             = aws_apigatewayv2_api.websocket_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri           = "${var.connect_lambda_invoke_arn}"
  passthrough_behavior      = "WHEN_NO_MATCH"
  credentials_arn           = "arn:aws:iam::${var.account_id}:role/api_gateway_invocation_role_${var.environment}"
  content_handling_strategy = "CONVERT_TO_TEXT"
}


resource "aws_apigatewayv2_integration" "websockets_disconnect_integration" {
  api_id             = aws_apigatewayv2_api.websocket_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri           = "${var.disconnect_lambda_invoke_arn}"
  passthrough_behavior      = "WHEN_NO_MATCH"
  credentials_arn           = "arn:aws:iam::${var.account_id}:role/api_gateway_invocation_role_${var.environment}"
  content_handling_strategy = "CONVERT_TO_TEXT"
}

resource "aws_apigatewayv2_integration" "websockets_collectfeedback_integration" {
  api_id             = aws_apigatewayv2_api.websocket_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri           = "${var.collectfeedback_lambda_invoke_arn}"
  passthrough_behavior      = "WHEN_NO_MATCH"
  credentials_arn           = "arn:aws:iam::${var.account_id}:role/api_gateway_invocation_role_${var.environment}"
  content_handling_strategy = "CONVERT_TO_TEXT"
}


#------------------------------- API GW EXECUTION ROLE FOR LAMBDA -------------------------------------

resource "aws_lambda_permission" "apigw_connect_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.connect_lambda_function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_collectfeedback_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.disconnect_lambda_function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*/*"
}


resource "aws_lambda_permission" "apigw_disconnect_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.collectfeedback_lambda_function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*/*"
}

#---------------------------STAGE----------------------------------------------------------------

resource "aws_apigatewayv2_stage" "stage" {
  api_id        = aws_apigatewayv2_api.websocket_api.id
  name          = var.environment
  deployment_id = aws_apigatewayv2_deployment.websocket_deploy.id
}

#--------------------------DEPLOYMENT-------------------------------------------------------------

resource "aws_apigatewayv2_deployment" "websocket_deploy" {
  api_id = aws_apigatewayv2_api.websocket_api.id

  depends_on = [
    aws_apigatewayv2_route.connect,
    aws_apigatewayv2_route.disconnect,
  ]

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    deployed_at = "Deployed at ${timestamp()}"
  }
}


# resource "aws_acm_certificate" "websockets" {
#   domain_name       = "ws-${var.current_color}.${var.dns_domain}"
#   validation_method = "DNS"

#   tags = {
#     Name          = "ws-${var.current_color}.${var.dns_domain}"
#     ProductDomain = "EFCMS websockets"
#     Environment   = var.environment
#     Description   = "Certificate for ws.${var.dns_domain}"
#     ManagedBy     = "terraform"
#   }
# }

# resource "aws_acm_certificate_validation" "validate_websockets" {
#   certificate_arn         = aws_acm_certificate.websockets.arn
#   validation_record_fqdns = [for record in aws_route53_record.websockets_route53 : record.fqdn]
#   count                   = var.validate
# }

# resource "aws_route53_record" "websockets_route53" {
#   for_each = {
#     for dvo in aws_acm_certificate.websockets.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#   name            = each.value.name
#   records         = [each.value.record]
#   type            = each.value.type
#   zone_id         = var.zone_id
#   ttl             = 60
#   allow_overwrite = true
# }

# resource "aws_apigatewayv2_domain_name" "websockets_domain" {
#   domain_name = "ws-${var.current_color}.${var.dns_domain}"

#   domain_name_configuration {
#     certificate_arn = aws_acm_certificate.websockets.arn
#     endpoint_type   = "REGIONAL"
#     security_policy = "TLS_1_2"
#   }
# }

# resource "aws_apigatewayv2_api_mapping" "websocket_mapping" {
#   api_id      = aws_apigatewayv2_api.websocket_api.id
#   domain_name = aws_apigatewayv2_domain_name.websockets_domain.id
#   stage       = aws_apigatewayv2_stage.stage.id
# }

# resource "aws_route53_record" "websocket_regional_record" {
#   name           = aws_apigatewayv2_domain_name.websockets_domain.domain_name
#   type           = "A"
#   zone_id        = var.zone_id
#   set_identifier = "ws_${var.region}_${var.current_color}"

#   alias {
#     name                   = aws_apigatewayv2_domain_name.websockets_domain.domain_name_configuration.0.target_domain_name
#     zone_id                = aws_apigatewayv2_domain_name.websockets_domain.domain_name_configuration.0.hosted_zone_id
#     evaluate_target_health = false
#   }

#   latency_routing_policy {
#     region = var.region
#   }
# }

# resource "aws_apigatewayv2_authorizer" "websocket_authorizer" {
#   api_id                     = aws_apigatewayv2_api.websocket_api.id
#   authorizer_type            = "REQUEST"
#   authorizer_credentials_arn = "arn:aws:iam::${var.account_id}:role/api_gateway_invocation_role_${var.environment}"
#   authorizer_uri             = var.authorizer_uri
#   identity_sources           = ["route.request.querystring.token"]
#   name                       = "websocket_authorizer_${var.environment}"
# }

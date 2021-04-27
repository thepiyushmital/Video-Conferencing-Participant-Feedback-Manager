resource "aws_dynamodb_table" "connection_table_name" {
  name = var.connection_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key = "connectionId"
  attribute {
    name = "connectionId"
    type = "S"
  }

  # attribute {
  #   name = "meetingId"
  #   type = "S"
  # }

  # attribute {
  #   name = "username"
  #   type = "S"
  # }

  # attribute {
  #   name = "imgURL"
  #   type = "S"
  # }
      
   tags = {
    environment = var.environment
  }
}

resource "aws_dynamodb_table" "feedback_table_name" {
  name = var.feedback_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key = "meetingId"
  range_key = "roundId"
  attribute {
    name = "meetingId"
    type = "S"
  }

  attribute {
    name = "roundId"
    type = "S"
  }

  # attribute {
  #   name = "speakerName"
  #   type = "S"
  # }

  # attribute {
  #   name = "remarkType"
  #   type = "S"
  # }

  # attribute {
  #   name = "feedbackStatus"
  #   type = "S"
  # }
  
  # attribute {
  #   name = "feedbackData"
  #   type = "L"
  # }

  #  attribute {
  #   name = "transcriptionData"
  #   type = "L"
  # }
      
   tags = {
    environment = var.environment
  }
}

output "clientFeedbackDb_name" {
  value = "${aws_dynamodb_table.feedback_table_name.name}"
}

output "webSocketDb_name" {
  value = "${aws_dynamodb_table.connection_table_name.name}"
}


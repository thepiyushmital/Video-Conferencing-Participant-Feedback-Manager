resource "aws_dynamodb_table" "connection_table_name" {
  name = var.connection_table_name
  # With provisioned throughput, you pay based on having the capacity to handle a given amount
  # of read and write throughput. You pay for read and write capacity units. 
  # Each read capacity unit allows you to handle one read request per second 
  # and each write capacity unit allows you to handle one write request per second.
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  # HashKey and Range Key together make up the primary key of the row
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
  # HashKey and Range Key together make up the primary key of the row
  hash_key = "meetingId"
  # Each meeting has a unique Id and can have multiple rounds of feedback being held simultaneously
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
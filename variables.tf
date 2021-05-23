# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file
# except in compliance with the License. A copy of the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under the License.
variable "access_key" {
        description = "Access key of AWS IAM user"
}

variable "secret_key" {
        description = "Secret key of AWS IAM user"
}

variable "table_name" {
  description = "Dynamodb table name (space is not allowed)"
  default = "my-first-test-table"
}

variable "table_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  default = "PAY_PER_REQUEST"
}


variable "environment" {
  description = "Name of environment"
  default = "test"
}


variable "region" {
  default = "us-east-1"
}

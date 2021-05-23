provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "dynamo_tables" {
  source = "./dynamodb_tables"
  access_key = var.access_key
  secret_key = var.secret_key
  # key_name = var.key_name
  # ip_range = var.ip_range
}

module "lambda_functions" {
  access_key = var.access_key
  secret_key = var.secret_key
  source = "./lambda_functions"
  # key_name = var.key_name
  # ip_range = var.ip_range
}

module "api_gateways" { 
  access_key = var.access_key
  secret_key = var.secret_key
  source = "./api_gateways"
  connect_lambda_invoke_arn = "${module.lambda_functions.connect_lambda_invoke_arn}"
  disconnect_lambda_invoke_arn = "${module.lambda_functions.disconnect_lambda_invoke_arn}"
  collectfeedback_lambda_invoke_arn = "${module.lambda_functions.collectfeedback_lambda_invoke_arn}"
  connect_lambda_function_name = "${module.lambda_functions.connect_lambda_function_name}"
  disconnect_lambda_function_name = "${module.lambda_functions.disconnect_lambda_function_name}"
  collectfeedback_lambda_function_name = "${module.lambda_functions.collectfeedback_lambda_function_name}"
}

module "step_functions" {
  access_key = var.access_key
  secret_key = var.secret_key
  source = "./step_functions"
  generatefeedback_lambda_arn = "${module.lambda_functions.generatefeedback_lambda_arn}"

  # key_name = var.key_name
  # ip_range = var.ip_range
}
# module "launch_configurations" {
#   source = "./launch_configurations"
#   webapp_http_inbound_sg_id = module.site.webapp_http_inbound_sg_id
#   webapp_ssh_inbound_sg_id = module.site.webapp_ssh_inbound_sg_id
#   webapp_outbound_sg_id = module.site.webapp_outbound_sg_id
#   key_name = var.key_name
# }
# module "load_balancers" {
#   source = "./load_balancers"
#   public_subnet_id = module.site.public_subnet_id
#   webapp_http_inbound_sg_id = module.site.webapp_http_inbound_sg_id
# }
# module "autoscaling_groups" {
#   source = "./autoscaling_groups"
#   public_subnet_id = module.site.public_subnet_id
#   webapp_lc_id = module.launch_configurations.webapp_lc_id
#   webapp_lc_name = module.launch_configurations.webapp_lc_name
#   webapp_elb_name = module.load_balancers.webapp_elb_name
# }
# module "instances" {
#   source = "./instances"
#   public_subnet_id = module.site.public_subnet_id
#   bastion_ssh_sg_id = module.site.bastion_ssh_sg_id
#   private_subnet_id = module.site.private_subnet_id
#   ssh_from_bastion_sg_id = module.site.ssh_from_bastion_sg_id
#   web_access_from_nat_sg_id = module.site.web_access_from_nat_sg_id
#   key_name = var.key_name
# }

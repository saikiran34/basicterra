variable "region" {
  default = "ca-central-1"
}
variable "main_vpc_cidr" {}
variable "public_subnet1" {}
variable "public_subnet2" {}
variable "private_subnet1" {}
variable "private_subnet2" {}
variable "private_subnet3" {}
variable "project_name" {
  default     = "FxLink-2.0-test"
  type        = string
  description = "Project name"
}

#SQS

variable "aws_security_group_SQS" {
  description = "aws_security_group_SQS"
  type        = string
  default     = "Fxlink-SQS-security_group"
}

variable "aws_api_gateway_rest_api_title" {
  description = "aws_security_group_SQS"
  type        = string
  default     = "Fxlink-2.0-api_gateway"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
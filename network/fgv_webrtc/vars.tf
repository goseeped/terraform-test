variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
}

variable "name" {
  description = "The name for the ASG. This name is also used to namespace all the other resources created by this module."
}

variable "server_port" {
  description = "The port number the web server on each EC2 Instance should listen on for HTTP requests"
}

variable "elb_port" {
  description = "The port number the ELB should listen on for HTTP requests"
}

# ---------------------------------------------------------------------------------------------------------------------
# A SIMPLE EXAMPLE OF HOW DEPLOY AN ASG WITH AN ELB IN FRONT OF IT
# This is an example of how to use Terraform to deploy an Auto Scaling Group (ASG) with an Elastic Load
# Balancer (ELB) in front of it. To keep the example simple, we deploy a vanilla Ubuntu AMI across the ASG and run a
# dirt simple "web server" on top of it as a User Data script. The "web server" always returns "Hello, World".
#
# Note: This code is meant solely as a simple demonstration of how to lay out your files and folders with Terragrunt
# in a way that keeps your Terraform code DRY. This is not production-ready code, so use at your own risk.
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "webserver_example" {
  launch_configuration = "${aws_launch_configuration.webserver_example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  load_balancers    = ["${aws_elb.webserver_example.name}"]
  health_check_type = "ELB"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }
}

data "aws_availability_zones" "all" {}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAUNCH CONFIGURATION
# This defines what runs on each EC2 Instance in the ASG. To keep the example simple, we run a plain Ubuntu AMI and
# configure a User Data scripts that runs a dirt-simple "Hello, World" web server. In real-world usage, you'd want to
# package the web server code into a custom AMI (rather than shoving it into User Data) and pass in the ID of that AMI
# as a variable.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "webserver_example" {
  image_id        = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.asg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Load the network module for fgv_webrtc
# This defines elb and security groups
# ---------------------------------------------------------------------------------------------------------------------


module "network_fgv_webrtc" {
  source = "https://github.com/goseeped/terraform-test.git?ref=v0.0.1//network/fgv_webrtc"

  aws_region   = "${var.aws_region}"
  name         = "${var.name}"

  server_port = "${var.server_port}"
  elb_port = "${var.elb_port}"

}

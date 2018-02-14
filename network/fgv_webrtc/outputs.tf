
output "elb_name_new" {
  value = "${aws_elb.webserver_example.name}"
}

output "asg_id" {
  value = "${aws_security_group.asg.id}"
}


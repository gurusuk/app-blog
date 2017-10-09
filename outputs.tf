# Resource Values are displayed after creation
output "security_group_ssh" {
  value = "${aws_security_group.blog_ssh.id}"
}

output "security_group_http" {
  value = "${aws_security_group.blog_http.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.blog-lc.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.blog-asg.id}"
}

output "elb_name" {
  value = "${aws_elb.blog-elb.dns_name}"
}

output "ec2_instances" {
  value = "${aws_launch_configuration.blog-lc.id}"
}
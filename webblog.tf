# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_elb" "blog-elb" {
  name = "myblog"

  # The same availability zone as our instances
  availability_zones = ["${split(",", var.availability_zones)}"]
  security_groups = ["${aws_security_group.blog_http.id}"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

#Auto scaling group resources
resource "aws_autoscaling_group" "blog-asg" {
  availability_zones   = ["${split(",", var.availability_zones)}"]
  name                 = "Publishing-blog-ASG"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_required}"
  launch_configuration = "${aws_launch_configuration.blog-lc.name}"
  load_balancers       = ["${aws_elb.blog-elb.name}"]
  
  tag {
    key                 = "Name"
    value               = "Publishing blog"
    propagate_at_launch = "true"
  }
}

#EC2 resources
resource "aws_launch_configuration" "blog-lc" {
  name          = "Publishing-blog"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.BlogDeployer.id}"
  security_groups = ["${aws_security_group.blog_ssh.id}","${aws_security_group.blog_http.id}"]
  user_data       = "${data.template_file.user_data_cs.rendered}"
  key_name        = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }
}

#Substitute the bucket name defined in variables in the shell script
data "template_file" "user_data_cs" {
  template = "${file("userdata.sh")}"
  vars {
    bucket_name = "${var.blog_bucket_name}"
  }
}

# Create security group to access the instances over SSH
resource "aws_security_group" "blog_ssh" {
  name        = "Publishing blog ssh access"
  description = "Access the Publishing blog instances over SSH"

  # SSH access from specific cidr variable
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_inbound_cidr}"]
  }

  # outbound internet access for all protocols and all IPs
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group to access the instances over HTTP
resource "aws_security_group" "blog_http" {
  name        = "Publishing blog Web access"
  description = "Access the Publishing blog application over HTTP"

  # HTTP access from specific cidr variable defined
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.http_inbound_cidr}"]
  }

  # outbound internet access for all protocols and all IPs
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create IAM Role and allow assume role
resource "aws_iam_role" "BlogDeployer" {
  name = "BlogDeployer"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#Create new IAM custom policy
resource "aws_iam_policy" "AllowBlogFilesRead" {
  name        = "AllowBlogFilesRead"
  path        = "/"
  description = "List and read S3 bucket with blog files"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1507493124000",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.webblog-bucket.arn}",
                "${aws_s3_bucket.webblog-bucket.arn}/*"
            ]
        }
    ]
}
EOF
}

#Attach IAM policy to the role
resource "aws_iam_role_policy_attachment" "BlogDeployerAttach" {
    role       = "${aws_iam_role.BlogDeployer.name}"
    policy_arn = "${aws_iam_policy.AllowBlogFilesRead.arn}"
}

resource "aws_iam_instance_profile" "BlogDeployer" {
  name = "BlogApp"
  role = "${aws_iam_role.BlogDeployer.name}"
}

#Create S3 bucket 
resource "aws_s3_bucket" "webblog-bucket" {
  bucket = "${var.blog_bucket_name}"
  acl    = "private" 
}

#Put objects to the bucket
resource "aws_s3_bucket_object" "index" {
  bucket = "${aws_s3_bucket.webblog-bucket.id}"
  key = "index.html"
  source = "conf/index.html"
  storage_class = "REDUCED_REDUNDANCY"
}
resource "aws_s3_bucket_object" "image" {
  bucket = "${aws_s3_bucket.webblog-bucket.id}"
  key = "cs.png"
  source = "conf/cs.png"
  storage_class = "REDUCED_REDUNDANCY"  
}
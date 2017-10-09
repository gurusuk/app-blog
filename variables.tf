#User Credentials for accessing AWS account
variable "aws_access_key" {
  description = "IAM user's access key"
  default     = ""
}

variable "aws_secret_key" {
  description = "IAM user's secret key"
  default     = ""
}

# Default AWS region
variable "aws_region" {
  description = "The AWS region where resources will be created"
  default     = "eu-west-1"
}

# Amazon Linux AMI 2017.09.0 (HVM)
variable "aws_amis" {
  default = {
    "eu-west-1" = "ami-acd005d5"
    #"eu-west-2" = "ami-1a7f6d7e"
  }
}

variable "availability_zones" {
  default     = "eu-west-1a,eu-west-1b,eu-west-1c"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "key_name" {
  description = "Name of AWS key pair"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of instances to launch in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of instances to launch in ASG"
  default     = "2"
}

variable "asg_required" {
  description = "Number of instances required to be launched in ASG"
  default     = "1"
}

variable "ssh_inbound_cidr" {
  description = "CIDR for allowing ssh to the Unix host"
  default     = "0.0.0.0/0"
}

variable "http_inbound_cidr" {
  description = "CIDR for allowing http to the Unix host"
  default     = "0.0.0.0/0"
}

variable "blog_bucket_name" {
	default	 = "webblog-bucket"
	description = "S3 bucket name where web blog application files are kept"
}
Introduction
============

Application infrastructure is coded using Terraform. Terraform scripts launches a blog application in Amazon Linux EC2 instance(s). Application is hosted on nginx server.

AWS Resources created:
- load balancer
- auto scaling group
- Security groups for SSH and HTTP
- Custom IAM Policy
- IAM Role
- IAM instance profile
- S3 bucket
- EC2 instance

After successful script execution, AWS EC2 instance will be launched behind a ELB in a auto scale configuration/group as per the values defined in variables.tf file.
The IAM role is attached to the instance. The user data for launch configuration installs nginx listening on port 80 and pulling files from S3 bucket.

You should be able to launch the web site using the DNS name of the ELB

Application Setup
=================
Components:
README.txt 		- This readme file
variables.tf 	- Variables used by the script
webblog.tf		- Main TF 
outputs.tf		- AWS resources created are displayed
userdata.sh		- Shell commands that are executed during EC2 launch
conf			- Conf folder contains application files that are copied into S3. These files are copied into nginx web server as part of userdata

Make sure you edit variables.tf file and change following values as applicable to your account / setup

- aws_region for your AWS Region
- availability_zones for Specific AZs within the region
- aws_amis for AMI ids 
- asg_min, asg_max, asg_required for Auto scaling configuration
- ssh_inbound_cidr to include specific CIDR or All (0.0.0.0/0) for SSH
- blog_bucket_name for S3 bucket name where application files should be stored.

-
Installation & Execution
========================
1) Install terraform if not installed already

Follow the instructions in the page for finding and installing appropriate binaries - https://www.terraform.io/intro/getting-started/install.html

2)
After installation, ensure terraform binary available in the path and it can be executed. 
Open a new command promt (or ssh session) and execute the command "terraform -v". This should give current terraform version installed.

3)
Pull scripts from git repository https://github.com/gurusuk/app-blog.git
For example: git clone https://github.com/gurusuk/app-blog.git . for copying files into local folder of choice

4)
Open a command prompt window or shell and change directory to the local git repository location 

5)
Execute init command to initialise all required plugins

terraform init

6)
Execute following command to check the plan of resources. Replace <xxx> with appropriate values for your account

terraform plan -var "aws_access_key=<access key>" -var "aws_secret_key=<your secret key>" -var "key_name=<your AWS key pair name>"

7)
terraform apply -var "aws_access_key=<access key>" -var "aws_secret_key=<your secret key>" -var "key_name=<your AWS key pair name>"

The scripts would create various AWS resources. From the output copy the elb_name. It would look like "myblog-nnnnnnnnnnnn.<region>.elb.amazonaws.com"

8)
Paste the DNS name of the ELB copied in the previous step in the browser tab and press enter

You should see the home page of the blog

9)
Enter the following the command to destroy all resources that were created in step 7

terraform destroy -var "aws_access_key=<access key>" -var "aws_secret_key=<your secret key>" -var "key_name=<your AWS key pair name>"

10)
To scale up/down EC2 instances, change values of the variables asg_min, asg_max, asg_required for Auto scaling configuration
For example: To increase number of instances running from 1 to 2 :

asg_min - 1
asg_max - 2
asg_required from 1 to 2 

execute terraform apply command. It will change desired_capacity: "1" => "2"

11)
If a running instance goes down, new instance will be automatically launched as per configuration defined in ASG
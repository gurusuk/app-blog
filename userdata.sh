#!/bin/bash
#Update existing packages
sudo sh -c 'yum update -y >/tmp/yum_update.log'
#install nginx web server and capture output
sudo sh -c 'yum install -y nginx >/tmp/nginx.log'
#Start nginx service
sudo sh -c 'service nginx start >/tmp/nginx.log'
#Add to startup enable to start nginx when instance restarted
sudo chkconfig nginx on
#Give access to ec2-user for writing to web folders
sudo usermod -a -G nginx ec2-user
sudo chown -R root:nginx /usr/share/nginx
sudo chmod 2775 /usr/share/nginx
#Deploy files from S3 bucket
aws s3 cp s3://${bucket_name} /usr/share/nginx/html/ --recursive
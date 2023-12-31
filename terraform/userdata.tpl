#!/bin/bash -xe

# Redirect all output to a log file
exec > >(tee -a /var/log/userdata.log) 2>&1

# Log the script start time
echo "Script started: $(date)"

yum update -y
yum install -y amazon-linux-extras
yum install -y awslogs httpd mysql gcc-c++ nfs-utils
amazon-linux-extras enable php7.4
yum clean metadata
sudo setenforce 0 # disable SELinux
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel,opcache}
systemctl enable nfs-server.service
systemctl start nfs-server.service
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${dns}:/ /var/www/html

chkconfig httpd on
service httpd start

# Log the script end time
echo "Script completed: $(date)"

#!/bin/bash -xe

              # Redirect all output to a log file
              exec > >(tee -a /var/log/userdata.log) 2>&1

              # Log the script start time
              echo "Script started: $(date)"

              yum update -y
              yum install -y amazon-linux-extras
              yum install -y awslogs httpd mysql gcc-c++
              amazon-linux-extras enable php7.4
              yum clean metadata
              yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel,opcache}
              systemctl enable nfs-server.service
              systemctl start nfs-server.service
              mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.myefs.dns_name}:/ /var/www/html

              # Log the script end time
              echo "Script completed: $(date)"

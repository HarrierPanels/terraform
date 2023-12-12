[![EPAM](https://img.shields.io/badge/Cloud&DevOps%20UA%20Lab%202nd%20Path-Terraform%20%2F%20Ansible%20Task%20(AWS)-orange)](./)
[![HitCount](https://hits.dwyl.com/HarrierPanels/terraform.svg?style=flat&show=unique)](http://hits.dwyl.com/HarrierPanels/terraform)
<br>
## Deploy https://github.com/FaztWeb/php-mysql-crud using Terraform / Ansible Toolchain for an AWS multi-tier architecture as follows:
<img src="./Architecture.PNG" width="350" height="446">

**Note:** You have to precreate an SSH-key in your AWS account with name "Test_key" or change the name of key in the **key_name** parameter of 'resource "aws_launch_configuration" "my_conf"'.  
  
  After the creation of all resources, you can manually delete EC2 instance with name **Delete_me**, because it needs only for creation of special AMI with preinstalled Apache and PHP.

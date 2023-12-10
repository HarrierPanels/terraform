provider "aws" {
}

data "http" "myip" {
  url = "https://ifconfig.me/ip"
}

data "aws_ami" "AL2_latest" {
  owners = ["137112412989"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "avail" {
  state = "available"
}

resource "aws_vpc" "crud_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "crud_vpc"
  }
}

resource "aws_subnet" "subnet_az_1" {
  vpc_id            = aws_vpc.crud_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.avail.names[0]

  tags = {
    Name = "${data.aws_availability_zones.avail.names[0]}"
  }
}

resource "aws_subnet" "subnet_az_2" {
  vpc_id            = aws_vpc.crud_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.avail.names[1]

  tags = {
    Name = "${data.aws_availability_zones.avail.names[1]}"
  }
}

resource "aws_internet_gateway" "mygw" {
  vpc_id = aws_vpc.crud_vpc.id

  tags = {
    Name = "MyIG"
  }
  depends_on = [aws_vpc.crud_vpc]
}

resource "aws_route" "route_to_ig" {
  route_table_id         = aws_vpc.crud_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mygw.id
  depends_on             = [aws_internet_gateway.mygw, aws_vpc.crud_vpc]
}

resource "aws_route_table_association" "crud_rt_az_1" {
  subnet_id      = aws_subnet.subnet_az_1.id
  route_table_id = aws_vpc.crud_vpc.main_route_table_id
}

resource "aws_route_table_association" "crud_rt_az_2" {
  subnet_id      = aws_subnet.subnet_az_2.id
  route_table_id = aws_vpc.crud_vpc.main_route_table_id
}

resource "aws_efs_file_system" "myefs" {
  encrypted = true
  tags = {
    Name = "MyEFS"
  }
}

resource "aws_efs_mount_target" "crud_mt_az_1" {
  file_system_id  = aws_efs_file_system.myefs.id
  subnet_id       = aws_subnet.subnet_az_1.id
  security_groups = [aws_security_group.SG_for_EFS.id]
  depends_on      = [aws_efs_file_system.myefs, aws_security_group.SG_for_EFS]
}

resource "aws_efs_mount_target" "crud_mt_az_2" {
  file_system_id  = aws_efs_file_system.myefs.id
  subnet_id       = aws_subnet.subnet_az_2.id
  security_groups = [aws_security_group.SG_for_EFS.id]
  depends_on      = [aws_efs_file_system.myefs, aws_security_group.SG_for_EFS]
}

resource "aws_security_group" "SG_for_EC2" {
  name        = "SG_for_EC2"
  description = "Allow 80, 443, 22 port inbound traffic"
  vpc_id      = aws_vpc.crud_vpc.id

  ingress {
    description = "TLS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.myip.response_body}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG_for_RDS" {
  name        = "SG_for_RDS"
  description = "Allow MySQL inbound traffic"
  vpc_id      = aws_vpc.crud_vpc.id

  ingress {
    description     = "RDS from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_for_EC2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.SG_for_EC2]
}

resource "aws_security_group" "SG_for_EFS" {
  name        = "SG_for_EFS"
  description = "Allow NFS inbound traffic"
  vpc_id      = aws_vpc.crud_vpc.id

  ingress {
    description     = "NFS from EC2"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_for_EC2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.SG_for_EC2]
}

resource "aws_security_group" "SG_for_ELB" {
  name        = "SG_for_ELB"
  description = "Allow traffic for ELB"
  vpc_id      = aws_vpc.crud_vpc.id

  ingress {
    description = "Allow all inbound traffic on the 80 port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_for_EC2.id]
  }
  depends_on = [aws_security_group.SG_for_EC2]
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.subnet_az_1.id, aws_subnet.subnet_az_2.id]
}

resource "aws_db_instance" "mysql" {
  identifier = "mysql"
  engine     = "mysql"
  engine_version                  = "8.0.28"
  instance_class                  = "db.t3.medium"
  db_subnet_group_name            = aws_db_subnet_group.default.name
  enabled_cloudwatch_logs_exports = ["general", "error"]
  db_name                         = var.rds_credentials.dbname
  username                        = var.rds_credentials.username
  password                        = var.rds_credentials.password
  allocated_storage               = 20
  max_allocated_storage           = 0
  backup_retention_period         = 7
  backup_window                   = "00:00-00:30"
  maintenance_window              = "Sun:21:00-Sun:21:30"
  storage_type                    = "gp2"
  vpc_security_group_ids          = [aws_security_group.SG_for_RDS.id]
  skip_final_snapshot             = true
  depends_on                      = [aws_security_group.SG_for_RDS, aws_db_subnet_group.default]
}

resource "local_file" "userdata_init" {
  filename = "./userdata.sh"
  content = templatefile("./userdata.tpl", {
    dns = aws_efs_file_system.myefs.dns_name
  })
  depends_on = [aws_efs_file_system.myefs]
}

resource "aws_launch_configuration" "my_conf" {
  name_prefix                 = "My Launch Config with WP"
  image_id                    = data.aws_ami.AL2_latest.id
  instance_type               = "t3.medium"
  key_name                    = "j2"
  user_data                   = file("userdata.sh")
  security_groups             = [aws_security_group.SG_for_EC2.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    encrypted   = false
  }
  depends_on = [aws_security_group.SG_for_EC2]
}

resource "aws_autoscaling_group" "my_asg" {
  name_prefix               = "my_asg"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  launch_configuration      = aws_launch_configuration.my_conf.name
  vpc_zone_identifier       = [aws_subnet.subnet_az_1.id, aws_subnet.subnet_az_2.id]
  load_balancers            = [aws_elb.my_elb.name]
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_elb.my_elb, aws_launch_configuration.my_conf, aws_efs_mount_target.crud_mt_az_1, aws_efs_mount_target.crud_mt_az_2]
}

resource "aws_elb" "my_elb" {
  name            = "My-ELB"
  security_groups = [aws_security_group.SG_for_ELB.id]
  subnets         = [aws_subnet.subnet_az_1.id, aws_subnet.subnet_az_2.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:80"
    interval            = 20
  }

  cross_zone_load_balancing = true
  idle_timeout              = 60
  depends_on                = [aws_security_group.SG_for_ELB]
}

resource "local_file" "wp_config" {
  filename = "../ansible/roles/crud/files/wp-config.php"
  content = templatefile("./wp-config.tmpl", {
    database_name = var.rds_credentials.dbname
    username      = var.rds_credentials.username
    password      = var.rds_credentials.password
    db_host       = aws_db_instance.mysql.endpoint
  })
  depends_on = [aws_db_instance.mysql, aws_autoscaling_group.my_asg]
}

data "aws_instances" "my_inst" {

  filter {
    name   = "image-id"
    values = [data.aws_ami.AL2_latest.id]
  }
  depends_on = [aws_autoscaling_group.my_asg]
}

resource "local_file" "servers" {
  filename = "../ansible/hosts"
  content = templatefile("./servers.tmpl", {
    ip = data.aws_instances.my_inst.public_ips[0]
  })
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "ansible-playbook -i hosts crud.yaml --ssh-common-args='-o StrictHostKeyChecking=no' -b -vvv"
  }
  depends_on = [local_file.servers]
}

resource "aws_cloudwatch_metric_alarm" "cpuover60" {
  alarm_name                = "cpuover60"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "60"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions     = [aws_autoscaling_policy.scale_out_one.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpuunder20" {
  alarm_name                = "cpuunder20"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "20"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions     = [aws_autoscaling_policy.scale_in_one.arn]
}

resource "aws_autoscaling_policy" "scale_out_one" {
  name                   = "add_one_unit_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
}

resource "aws_autoscaling_policy" "scale_in_one" {
  name                   = "delete_one_unit_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
}

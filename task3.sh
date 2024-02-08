#!/bin/bash -xe

# Variables
profile_name="task3"
terraform_folder="task3"
terraform_file="$terraform_folder/main.tf"
log_file="task3_log"

# Function to check if a utility is installed
check_util() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install utility using yum or apt-get
install_util() {
    if check_util yum; then
        sudo yum install yum-utils -y
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
        sudo yum install "$1" -y
        return
    elif check_util apt-get; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update
        sudo apt-get install "$1" -y
        return
    else
        echo "Error: no supported package manager found"
        return 1
    fi
}

# Function to check if Terraform is installed
check_terraform() {
    if ! check_util terraform; then
        echo "Terraform not found."
        install_util "terraform"
    fi
}

# Function to create Terraform folder and main.tf file
create_terraform_files() {
    mkdir -p "$terraform_folder"
    cat <<EOF > "$terraform_file"
provider "aws" {
  profile = "$profile_name"
}

data "aws_ami" "AL2_latest" {
  owners     = ["137112412989"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2_instance" {
  count         = 2
  ami           = data.aws_ami.AL2_latest.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ec2_security_group.name]
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "Allow inbound traffic on port 80"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
EOF
}

# Function to check execution plan
terraform_check_plan() {
    terraform -chdir="$terraform_folder" init
    terraform -chdir="$terraform_folder" plan
}

# Function to apply changes
terraform_apply_changes() {
    terraform -chdir="$terraform_folder" apply -auto-approve
}

# Redirect all output to a log file
exec > >(tee -a "${log_file}") 2>&1

# Log the script start time
echo "Script started: $(date)"

# Main execution
check_terraform
create_terraform_files
terraform_check_plan
terraform_apply_changes

# Log the script end time
echo "Script completed: $(date)"

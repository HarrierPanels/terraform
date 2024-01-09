#!/bin/bash -xe

# Variables
profile_name="task1"
terraform_folder="task1"
terraform_file="$terraform_folder/main.tf"
log_file="task1_log"

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

# Function to list AWS credentials for a specific profile
list_aws_credentials() {
    aws configure list --profile "$profile_name"
}

# Function to create Terraform folder and main.tf file
create_terraform_files() {
    mkdir -p "$terraform_folder"
    cat <<EOF > "$terraform_file"
provider "aws" {
  profile = "$profile_name"
}
EOF
}

# Function to initialize and apply the Terraform project
terraform_init_apply() {
    terraform -chdir="$terraform_folder" init
    terraform -chdir="$terraform_folder" apply -input=false
}

# Function to delete all created files and folders
delete_created_files() {
    rm -rf "$terraform_folder"
}

# Redirect all output to a log file
exec > >(tee -a "${log_file}") 2>&1

# Log the script start time
echo "Script started: $(date)"

# Main execution
check_terraform
list_aws_credentials
create_terraform_files
terraform_init_apply
delete_created_files

# Log the script end time
echo "Script completed: $(date)"

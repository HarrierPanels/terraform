#!/bin/bash -xe

# Variables
profile_name="task2"
region=$(aws configure list --profile "$task2" | grep region | awk '{print $2}')
terraform_folder="task2"
terraform_file="$terraform_folder/main.tf"
module_name="vpc"
module_source="https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-${module_name}/master/README.md"
log_file="task2_log"

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
EOF
}

# Function to retrieve and include Terraform module code
retrieve_module() {

    # Fetch the content from the URL
    content=$(curl -s "$module_source")

    # Extract the HCL code between "```hcl" and "```"
    hcl_code=$(echo "$content" | awk '/module "vpc" {/,/}/ {print} /}/ {exit}' |
    sed "s/\"eu-west-1a\"/\""$region"a\"/g; s/\"eu-west-1b\"/\""$region"b\"/g; s/\"eu-west-1c\"/\""$region"c\"/g")

    # Append the HCL code to the main.tf file
    echo "$hcl_code" >> "$terraform_file"
    # Append the closing brace } to the file
    echo "}" >> "$terraform_file"
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

# Function to destroy infrastructure
terraform_destroy_infrastructure() {
    terraform -chdir="$terraform_folder" destroy -auto-approve
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
create_terraform_files
retrieve_module
terraform_check_plan
terraform_apply_changes
terraform_destroy_infrastructure
delete_created_files

# Log the script end time
echo "Script completed: $(date)"

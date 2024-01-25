[![EPAM](https://img.shields.io/badge/Cloud&DevOps%20UA%20Lab%202nd%20Path-Terraform-orange)](./)
[![EPAM](https://img.shields.io/badge/Infrastructure%20as%20Code-Practical%20Tasks-blue)](./)
[![HitCount](https://hits.dwyl.com/HarrierPanels/terraform.svg?style=flat&show=unique)](http://hits.dwyl.com/HarrierPanels/terraform)
# Terraform Tasks
The purpose of the tasks is to apply theoretical knowledge in practice and acquire hands-on experience using the tools and technologies presented in the submodule *Infrastructure as code*.
## Environment Requirements
To complete the practical tasks for the Terraform lessons, you need to build a working environment on a local machine using virtualization (e.g., Vagrant) or install Terraform on your laptop/computer.

The architecture of the project you build should include:

- VPC (Virtual Private Cloud)
- 2 x EC2 Instances
- 1 x Load Balancer
## Task 1
For this task, you will install Terraform, create a Terraform minimal viable product (MVP), and execute Terraform commands.

**Goals:**
- Install Terraform to your control machine (your laptop).
- Create a folder for your Terraform project and put the main.ts file in it.
- Add information to the **main.tf** file about your cloud provider, Amazon AWS.
- Generate an AWS_ACCESS_KEY and an AWS_SECRET_KEY in your Amazon AWS account.
- Add Amazon AWS credentials to the **main.tf** file or environment variables.
- Initialize and apply the current version of your Terraform project.
## Task implementation
To achieve the task goals, the script **[task1.sh](./task1.sh)** automates the installation of Terraform on the control machine, lists AWS credentials for a specified profile (*task1*), creates a folder named '*task1*' with a Terraform configuration file (*main.tf*) specifying the *AWS* provider, initializes and applies the Terraform project within the *task1* folder, and logs the entire script execution to a file named **[task1_log](./task1_log)**. The script also includes functions to check for utility installation, install utilities using `yum` or `apt-get`, and delete all files and folders created during the process.
## Task 2
For this task, you will provision a VPC in AWS using a VPC modu;e from the Terraform Registry.

**Goals:**

- Find an appropriate Terraform module in the Terraform Registry.
- Add a block of code into the main.tf file that configures VPC based on the module from the Terraform Registry.
- Check the execution plan.
- Apply the changes.
## Task implementation
The Bash script **[task2.sh](./task2.sh)** automates the deployment and destruction of AWS infrastructure using Terraform. It checks for utility installations, installs Terraform if needed, creates configuration files, applies changes, and cleans up. All output is logged to a specified log file **[task2_log](./task2_log)** for reference. The script ensures proper tooling and facilitates AWS infrastructure management through Terraform, with detailed logging for each step.
## Task 3
## Task 4
# To be continued! Check back often!

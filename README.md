[![EPAM](https://img.shields.io/badge/Cloud&DevOps%20UA%20Lab%202nd%20Path-Terraform%20%2F%20Ansible%20Task%20(AWS)-orange)](./)
[![HitCount](https://hits.dwyl.com/HarrierPanels/terraform.svg?style=flat&show=unique)](http://hits.dwyl.com/HarrierPanels/terraform)
<br>
## Deploy https://github.com/FaztWeb/php-mysql-crud using Terraform / Ansible Toolchain for an AWS multi-tier architecture as follows:
[![MULTI-TIER](./CRUD-multi-tier.png)](./CRUD-multi-tier.png)
#### Terraform Task
<sub>Must be implemented in the form of two modules: one module - everything related to the network; the second is different
Input parameters of the module: the name of the service (start from it when creating resources). For example, vasya-app-load-balancer, vasya-auto-scaling-group and so on. Input parameters for the program module are instance types; IPs from which there will be access. Outputs: instant sides.State must be a locked remote. Bucket and DB table can be created manually.
It will be a plus: Using terraform cloud.</sub>
#### Ansible Task
<sub>Create your inventory file, in which the host groups: app, db
For all groups - access by ssh key. The configuration of the general ssh parameters and the location of the Inventory - take out in ansible.cfg. Create a playbook that does the following: 1. Installs apache and php on app hosts. 2. Put mysql on the db host. 3. Create a user and a database, which must then be used i db.php. 4. Deploy the project code. For configuration of apache and mysql connection of PHP code, use jinja-templates. Avoid using shell, command and similar modules.</sub>
#### Integrating Terraform and Ansible Tasks: A Unified Execution Strategy
Combining Terraform and Ansible in a single toolchain for deploying a multi-tier architecture on AWS is a common and reasonable approach. Both tools serve different purposes in the infrastructure deployment process:

**Terraform:** Used for infrastructure provisioning. It defines the architecture of your infrastructure, including networks, security groups, instances, databases, etc.

**Ansible:** Used for configuration management and application deployment. It ensures that the software running on your infrastructure is properly configured.

**The benefits of using both tools together include:**<br>
Separation of Concerns: Terraform focuses on infrastructure provisioning, while Ansible focuses on configuration management. This separation makes it easier to manage and understand the different aspects of your infrastructure.

**Idempotency:** Terraform is idempotent by design, meaning it brings the infrastructure to the desired state regardless of its current state. Ansible follows a similar philosophy, making it safe to apply configurations multiple times.

**Scalability:** Terraform excels at defining infrastructure as code, and Ansible excels at configuration management. As your infrastructure grows, you can continue to use Terraform to scale your infrastructure and use Ansible to configure new instances.

**Flexibility:** The combination allows you to leverage the strengths of each tool. Terraform can handle complex infrastructure changes, while Ansible provides flexibility in configuring software components.

**Reusability:** With separate Terraform modules and Ansible roles, you can reuse code for similar setups in different environments, making it easier to maintain and update.

Using only Terraform or only Ansible for a multi-tier architecture can have certain drawbacks, and using a toolchain that combines both can address these limitations. Let's explore the cons of using only Terraform or only Ansible for such an architecture:
#### Using Only Terraform:
**Configuration Management Limitations:**
- Terraform is primarily designed for infrastructure provisioning and may lack the robustness and features required for detailed configuration management.
- Managing software configurations, application deployments, and dynamic changes on instances might be challenging.

**Limited Idempotency:**
- While Terraform is idempotent at the infrastructure level, it may not be as effective at managing configurations on instances.
- Making changes to configuration files or installing software may not be as reliable or idempotent as Ansible.

**Complexity for Application Deployment:**
- As the complexity of application deployments increases, handling it solely through Terraform may result in complex and less maintainable code.
#### Using Only Ansible:
**Infrastructure Provisioning:**
- While Ansible is excellent for configuration management, it lacks Terraform's ability to manage the complete lifecycle of infrastructure.
- Defining network architecture, security groups, and other infrastructure elements might be less intuitive in Ansible.

**Limited State Management:**
- Ansible does not inherently manage state, making it less suitable for tracking the state of the infrastructure and handling drift.
- Keeping track of resource dependencies and managing changes in a complex infrastructure might be challenging.

**Less Declarative:**
- Ansible is more procedural and imperative, which may result in less declarative and more step-by-step scripting for infrastructure setup.
#### Using a Toolchain (Terraform + Ansible):
**Leveraging Strengths:**
- Combining Terraform for infrastructure provisioning and Ansible for configuration management leverages the strengths of each tool.
- Terraform provides a declarative approach to define infrastructure, while Ansible handles configuration and application deployment more flexibly.

**Scalability and Reusability:**
- The toolchain approach allows for scalable infrastructure changes using Terraform and reusable, modular Ansible roles for consistent configuration across instances.

**Better Collaboration:**
- Teams with expertise in different areas (infrastructure vs. configuration management) can collaborate more effectively, each focusing on their strengths.

**Clear Separation of Concerns:**
- Separating infrastructure provisioning and configuration management provides clarity in responsibilities and makes codebases more manageable.
#### Prerequisites
- AWS S3 Bucket
- DynamoDB Database
- EC2 key pair
#### Terraform / Ansible Toolchain structure:
```
terraform/
└── ansible/
    ├── crud.yaml [*]
    ├── hosts [*]
    └── roles/
        └── crud/
            └── tasks/
                └── main.yml
terraform/
├── crud.tmpl
├── main.tf
├── outputs.tf
├── servers.tmpl
├── userdata.tpl
├── userdata.sh [*]
└── variables.tf
```
<sub>[*] created by Terraform from a template</sub>

The provided Terraform configuration sets up a multi-tier architecture on AWS, including a VPC, subnets, internet gateway, route tables, EFS (Elastic File System), security groups, RDS (Relational Database Service), EC2 instances, and an ELB (Elastic Load Balancer) with Autoscaling Group. After the infrastructure is provisioned using Terraform, Ansible is used to configure the instances and deploy a PHP-MySQL CRUD application.

Here's the high-level workflow:
#### Terraform:
- **Infrastructure Provisioning:**
  - AWS resources are defined in the Terraform configuration (**[main.tf](terraform/main.tf)**), including VPC, subnets, internet gateway, route tables, EFS, security groups, RDS, EC2 instances, ELB, Autoscaling group, and CloudWatch Alarms.
  - Dependencies between resources are specified using the **depends_on** attribute to ensure proper provisioning order.

- **UserData Script:**
  - A crucial part of the Terraform configuration is the UserData script, defined in the (**[userdata.tpl](terraform/userdata.tpl)**) template. This script is crafted to be executed on EC2 instances during launch.
  - The UserData script, generated by Terraform from the specified template, plays a pivotal role in the AWS Launch Configuration. Specifically designed for use within an AWS Auto Scaling Group, this script automates the instance initialization process.
  - The script performs the following tasks:
    - Installs required packages to ensure a consistent and functional environment.
    - Updates the system to the latest patches and security updates.
    - Installs essential software components, including Apache, PHP, and MySQL, to set up the necessary runtime for the application.
    - Mounts the Amazon Elastic File System (EFS) file system, providing shared storage for application files.
    - Initiates and starts relevant services, ensuring a fully operational state for the EC2 instance.
  - Importantly, the UserData script is dynamically generated by Terraform using the userdata.tpl template. This template allows for the insertion of dynamic values and configuration parameters, adapting to the specific needs of the environment. The script is then seamlessly integrated into the AWS Launch Configuration, facilitating the deployment and scaling processes within the AWS Auto Scaling Group. See **[userdata.log](terraform/userdata.log)**.

- **EFS Shared File System:**
  - The Terraform configuration includes the setup of an Amazon Elastic File System (EFS). This EFS file system is used to share files among multiple EC2 instances.
  - The Ansible playbook is designed to be executed on one of the EC2 instances within the Auto Scaling Group. Once executed, the shared EFS becomes a central location for storing application files, ensuring consistency across all instances.
  - This design simplifies the deployment process since updates to the application or its configuration can be done on a single instance, and the changes are immediately reflected across all instances sharing the same EFS. It promotes a more efficient and scalable approach, especially in dynamic and auto-scaling environments.

- **Dynamic Inventory:**
  - To facilitate dynamic discovery and management of AWS EC2 instances, a dynamic inventory is employed. In this setup, the data "aws_instances" block in Terraform is utilized.
  - The Ansible inventory file, an essential component for orchestrating tasks across the infrastructure, is dynamically generated from the **[servers.tmpl](terraform/servers.tmpl)** template. This template includes the necessary configuration to organize and specify hosts within Ansible.
  - The dynamic inventory process dynamically identifies AWS EC2 instances, retrieving information such as public IP addresses. These instances are then seamlessly integrated into the Ansible inventory, ensuring that the playbook tasks are executed on the correct hosts.
  - It's noteworthy that the inventory file generation is an integral part of the overall automation process, enhancing flexibility and scalability in managing the infrastructure.

- **Terraform Remote Backend:**
  - The Terraform configuration benefits from a Remote Backend, specifically an AWS S3 bucket configured as the backend for storing the Terraform state file (terraform.tfstate).
  - The backend "s3" block in the Terraform configuration defines the settings for this remote backend. The S3 bucket (**terraform-ansible-task**), key (*environments/production/terraform.tfstate*), and DynamoDB table (**terraform-lock-table**) collectively serve as a robust infrastructure state management solution.
  - This remote backend configuration enhances collaboration and state management, allowing multiple team members to work on the infrastructure concurrently. It provides a centralized location for storing and versioning the Terraform state, promoting consistency and avoiding conflicts in a collaborative environment. The use of DynamoDB for state locking ensures the integrity of the state file during concurrent operations.

- **[Output Values:](terraform/outputs.tf)**
  - Outputs like EFS DNS name and RDS endpoint are defined to be used in Ansible.
 
- **Terraform Variables:**
  - The **[variables.tf](terraform/variables.tf)** file plays a crucial role in managing dynamic values and parameters in the Terraform configuration.
  - This file defines variables, such as the **rds_credentials** variable, which encapsulates sensitive information like the master DB username, password, and database name.
  - The **rds_credentials** variable is of type **object** and is set to default values in this configuration. However, it's designed to be easily customized by users, allowing for a secure and flexible approach to managing database credentials.
  - By externalizing these variable values, the Terraform configuration becomes more modular and adaptable. Users can customize these variables based on their specific requirements, promoting reusability and ensuring that sensitive information remains confidential.
  - When deploying the infrastructure, users can provide values for these variables interactively or through various methods, such as input files, environment variables, or command-line flags.
  - In summary, **[variables.tf](terraform/variables.tf)** enhances the configurability and security of the Terraform setup by centralizing variable definitions and allowing users to customize values according to their specific needs.

 #### Ansible
 - **Playbook:**
   - An Ansible playbook (**[crud.yaml](terraform/crud.yaml)**) is dynamically generated by Terraform using a template (crud.tmpl). This playbook orchestrates various tasks on EC2 instances within the deployed infrastructure.
   - Tasks encompass a range of activities such as installing necessary packages, downloading and extracting the CRUD application, modifying SQL scripts, updating PHP files with dynamic values obtained from the deployed infrastructure, and configuring Apache.
   - The template used to generate the playbook incorporates variables derived from the deployed infrastructure, ensuring that the playbook aligns with the specifics of the actual environment. This seamless integration between Terraform and Ansible enhances automation, consistency, and the overall manageability of the infrastructure.

- **Inventory File:**
  - An inventory file (**hosts**) is generated dynamically with the public IP of the EC2 instance.

 - **Execution:**
   - Ansible is executed using the **null_resource** and **local-exec** provisioner in Terraform.
   - Ansible playbook is run on EC2 instances to configure the software and deploy the PHP-MySQL CRUD application.

#### Terraform apply process:
The **[logs](terraform/logs)** show the Terraform apply process, including resource creation, progress updates, and Ansible playbook execution. Key steps include acquiring a state lock, generating a plan, creating AWS resources (VPC, subnets, security groups, RDS, EFS), and executing an Ansible playbook. Outputs include the DNS name for the EFS file system and the RDS endpoint.

# Infrastructure Automation with Terraform and Ansible 🚀

This project demonstrates how to provision and configure a simple cloud infrastructure using **Terraform** and **Ansible**.  
Terraform creates the AWS resources (network, security groups, and two EC2 instances), while Ansible automatically installs and configures the required software — a **PHP web application (Bookstore)** on one instance and a **MySQL database** on the other.

---

## 🧰 Technologies Used
- **Terraform** – Infrastructure as Code (IaC)  
- **Ansible** – Configuration management and automation  
- **AWS** – Cloud provider (EC2, VPC, Security Groups)  
- **Ubuntu 22.04** – Operating system for both instances

---

## ⚙️ How It Works
1. Terraform provisions:
   - VPC, subnet, and security groups  
   - Two EC2 instances (one for the web app, one for the database)
2. Terraform outputs the database instance IP address and passes it to Ansible.
3. Ansible playbooks:
   - Install Apache, PHP, and required packages on the app server  
   - Install and configure MySQL on the database server  
   - Clone the PHP Bookstore app from GitHub  
   - Import the database and dynamically update the `connectDB.php` file

---

## ⚙️ Setup Instructions

1. **Clone the repository**
   ``bash
   git clone https://github.com/<your-username>/<repo-name>.git
   cd <repo-name>
3. **Define all required variables**

Create a file named terraform.tfvars in the project root directory.
This file is not included in the repository for security reasons.

Example:
my_ip             = "your_public_ip/32"
aws_region        = "eu-central-1"
aws_instance_type = "t2.micro"
public_key_path   = "~/.ssh/id_rsa.pub"
private_key_path  = "~/.ssh/id_rsa"
Update the my_ip variable with your current public IP address.
This allows SSH access to the EC2 instances from your machine.
If your IP changes, you must update this variable and re-apply Terraform.

3. **Initialize Terraform**
``bash
terraform init

4. **Apply the Terraform configuration**
``bash
terraform apply
Confirm with yes when prompted. Terraform will create the infrastructure on AWS.

**Notes**

The file terraform.tfvars is intentionally not uploaded to GitHub to protect sensitive data such as IP addresses, keys, and credentials.

You must define all variables in your local terraform.tfvars file before running Terraform.

The variable my_ip must match your current public IP address, otherwise SSH will be blocked by the security group rules.

Make sure you have valid AWS credentials configured locally (e.g. using aws configure).

Terraform automatically outputs the IP addresses of the created EC2 instances, which are then used by Ansible for configuration.

Before running Ansible, ensure that your private key file has the correct permissions:

chmod 400 ~/.ssh/id_rsa

This setup is intended for learning and demonstration purposes — for production use, additional security hardening and best practices should be applied.


provider "aws" {
  region = "eu-central-1"
}
resource "aws_vpc" "myapp-vpc"{
    cidr_block=var.vpc_cidr_block

    tags = {
       Name : "${var.env_prefix}-vpc"
    }
}
module "myapp-subnet"{
  source = "./modules/subnet"
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
}
module "myapp-servers"{
  source = "./modules/webserver-app"
  vpc_id = aws_vpc.myapp-vpc.id
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  image_name = var.image_name
  my_ip = var.my_ip
  aws_instance_type = var.aws_instance_type
  aws_instance_count = var.aws_instance_count
  public_key_location = var.public_key_location 
  subnet_id = module.myapp-subnet.subnet.id
}

resource "null_resource" "delay" {
  depends_on = [module.myapp-servers.instances]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
resource "null_resource" "ansible_provisioning" {

  depends_on = [null_resource.delay]

  provisioner "local-exec" {
    command = "ansible-playbook -i ${module.myapp-servers.instances[0].public_ip}, --private-key $(echo ${var.private_key_location}) --extra-vars \"mysql_host=$(terraform output -no-color -raw second_instance_ip)\"  install_apache_and_php.yml"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${module.myapp-servers.instances[1].public_ip}, --private-key $(echo ${var.private_key_location}) mysql.yml"

  }
}

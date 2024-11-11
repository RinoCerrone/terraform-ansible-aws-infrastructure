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
data "aws_ami" "latest-ubuntu-22_04-LTS"{
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  } 
 }

resource "aws_instance" "apache" {
  ami                         = data.aws_ami.latest-ubuntu-22_04-LTS.id
  count                       = var.aws_instance_count
  instance_type               = var.aws_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  subnet_id                   = module.myapp-subnet.subnet.id
  key_name                    = aws_key_pair.ssh-key.key_name
  availability_zone           = var.avail_zone

  tags = {
      Name: "${var.env_prefix}-servers"
     }
}
resource "aws_key_pair" "ssh-key"{
  key_name = "server-key"
  public_key = file(var.public_key_location)
}


resource "null_resource" "delay" {
  depends_on = [aws_instance.apache]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
resource "null_resource" "ansible_provisioning" {

  depends_on = [null_resource.delay]

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.apache[0].public_ip}, --private-key $(echo ${var.private_key_location}) --extra-vars \"mysql_host=$(terraform output -no-color -raw second_instance_ip)\"  install_apache_and_php.yml"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.apache[1].public_ip}, --private-key $(echo ${var.private_key_location}) mysql.yml"

  }
}

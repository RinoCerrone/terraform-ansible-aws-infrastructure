resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
       Name: "${var.env_prefix}-default-sg"
    }
}
data "aws_ami" "latest-ubuntu-22_04-LTS"{
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = [var.image_name]
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
  subnet_id                   = var.subnet_id
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

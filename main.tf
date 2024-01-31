provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "apache" {

  ami                         = "ami-073ff6027d02b1312"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.apache.id]
  key_name                    = "web_server_key"


  provisioner "remote-exec" {

    inline = ["echo 'Wait until SSH is ready!'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/tkoma/AWS_keys/web_server_key.pem")
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.apache.public_ip}, --private-key ${"/home/tkoma/AWS_keys/web_server_key.pem"} install_apache.yml"
  }
}



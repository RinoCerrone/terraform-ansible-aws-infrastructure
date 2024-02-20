provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "apache" {
  ami                         = "ami-073ff6027d02b1312"
  count                       = 2
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.apache.id]
  key_name                    = "web_server_key"
}

resource "null_resource" "wait_for_ssh" {
  count = 2

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready!'"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/tkoma/AWS_keys/web_server_key.pem")
      host        = aws_instance.apache[count.index].public_ip
    }
  }
}



output "second_instance_ip" {
  value = aws_instance.apache[1].public_ip
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
    command = "echo $(terraform output -no-color -raw second_instance_ip)"
  }


  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.apache[0].public_ip}, --private-key ${"/home/tkoma/AWS_keys/web_server_key.pem"} --extra-vars \"mysql_host=$(terraform output -no-color -raw second_instance_ip)\"  install_apache_and_php.yml"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.apache[1].public_ip}, --private-key ${"/home/tkoma/AWS_keys/web_server_key.pem"} mysql.yml"

  }
}

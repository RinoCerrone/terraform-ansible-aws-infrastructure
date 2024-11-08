output "second_instance_ip" {
  value = aws_instance.apache[1].public_ip
}
output "aws_ami_id"{
    value = data.aws_ami.latest-ubuntu-22_04-LTS.id
}
output "instances" {
  value = aws_instance.apache[*]
}
output "ami" {
    value = data.aws_ami.latest-ubuntu-22_04-LTS.id
}

output "second_instance_ip" {
  value = module.myapp-servers.instances[1].public_ip
}
output "aws_ami_id"{
    value = module.myapp-servers.ami
}
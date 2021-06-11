output "instance_id" {
  description = "Id of the EC2 instance"
  value = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "EC public ip"
  value = aws_instance.app_server.public_ip
}
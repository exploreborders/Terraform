# Instance outputs
output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.example.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.example.private_ip
}

output "instance_state" {
  description = "Current state of the EC2 instance"
  value       = aws_instance.example.instance_state
}

# Security group outputs
output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_instance.example.vpc_security_group_ids[0]
}

output "security_group_name" {
  description = "Name of the created security group"
  value       = aws_security_group.instance_sg.name
}

# AMI information
output "ami_id" {
  description = "ID of the AMI used for the instance"
  value       = aws_instance.example.ami
}

output "ami_name" {
  description = "Name of the AMI used for the instance"
  value       = data.aws_ami.amazon_linux_2.name
}

# Connection information
output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = var.key_pair_name != null ? "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.example.public_ip}" : "SSH key pair not configured"
}

output "http_url" {
  description = "HTTP URL to access the web server"
  value       = "http://${aws_instance.example.public_ip}"
}
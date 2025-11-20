output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.genai_agent.id
}

output "instance_public_ip" {
  description = "Public IP address"
  value       = aws_eip.genai_agent_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS"
  value       = aws_instance.genai_agent.public_dns
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_eip.genai_agent_eip.public_ip}:8080"
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_eip.genai_agent_eip.public_ip}:5000"
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i your-key.pem ubuntu@${aws_eip.genai_agent_eip.public_ip}"
}
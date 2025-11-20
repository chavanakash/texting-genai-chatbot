terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group for EC2
resource "aws_security_group" "genai_agent_sg" {
  name        = "genai-agent-sg"
  description = "Security group for GenAI Agent EC2"
  vpc_id = "vpc-0489ee7865a147dba"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask App"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "genai-agent-sg"
  }
}

# EC2 Instance (Free Tier)
resource "aws_instance" "genai_agent" {
  ami           = var.ami_id  # Ubuntu 22.04 LTS
  instance_type = "t2.micro"  # Free tier eligible
  subnet_id = "subnet-0d5e89b388ea4b3c3"
  vpc_security_group_ids = [aws_security_group.genai_agent_sg.id]
  key_name              = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              sudo apt-get update -y
              
              # Install Docker
              sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              
              # Install Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              
              # Add ubuntu user to docker group
              sudo usermod -aG docker ubuntu
              
              # Install Git
              sudo apt-get install -y git
              
              # Create Jenkins home directory
              sudo mkdir -p /var/jenkins_home
              sudo chown -R 1000:1000 /var/jenkins_home
              
              # Start Jenkins container
              sudo docker run -d \
                --name jenkins \
                -p 8080:8080 \
                -p 50000:50000 \
                -v /var/jenkins_home:/var/jenkins_home \
                -v /var/run/docker.sock:/var/run/docker.sock \
                --restart unless-stopped \
                jenkins/jenkins:lts
              
              # Wait for Jenkins to start and get initial password
              sleep 60
              sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword > /home/ubuntu/jenkins_initial_password.txt
              sudo chown ubuntu:ubuntu /home/ubuntu/jenkins_initial_password.txt
              EOF

  tags = {
    Name = "genai-agent-ec2"
  }

  root_block_device {
    volume_size = 20  # Free tier allows up to 30 GB
    volume_type = "gp2"
  }
}

resource "aws_internet_gateway" "genai_igw" {
  vpc_id = "vpc-0489ee7865a147dba"

  tags = {
    Name = "genai-igw"
  }
}
resource "aws_route_table" "genai_route_table" {
  vpc_id = "vpc-0489ee7865a147dba"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.genai_igw.id
  }

  tags = {
    Name = "genai-route-table"
  }
}

resource "aws_route_table_association" "genai_rta" {
  subnet_id      = "subnet-0d5e89b388ea4b3c3"  
  route_table_id = aws_route_table.genai_route_table.id
}

# Elastic IP (optional, for static IP)
resource "aws_eip" "genai_agent_eip" {
  instance = aws_instance.genai_agent.id
  domain   = "vpc"

  tags = {
    Name = "genai-agent-eip"
  }
}
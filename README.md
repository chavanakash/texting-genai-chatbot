cat > README.md <<EOF
# GenAI Agent - DevOps Practice Project

A simple GenAI chatbot application for practicing DevOps deployment with AWS, Terraform, Docker, and Jenkins.

## Features

- Flask backend API with Anthropic Claude AI
- React frontend with beautiful UI
- Dockerized application
- Terraform infrastructure as code
- Jenkins CI/CD pipeline
- AWS EC2 deployment (free tier)

## Quick Start

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for complete instructions.

## Local Development

\`\`\`bash
# Set API key
export ANTHROPIC_API_KEY=your_key_here

# Run with Docker Compose
docker-compose up

# Access at http://localhost:5000
\`\`\`

## Tech Stack

- **Backend:** Python, Flask, Anthropic API
- **Frontend:** React, TailwindCSS
- **Container:** Docker
- **CI/CD:** Jenkins
- **Infrastructure:** Terraform, AWS EC2
- **Version Control:** Git, GitHub
EOF
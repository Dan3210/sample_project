variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "todo-app"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "backend_ami" {
  description = "AMI ID for backend instance"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2023 in us-east-1
}

variable "frontend_ami" {
  description = "AMI ID for frontend instance"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2023 in us-east-1
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend"
  type        = string
  default     = "t3.micro"
}

variable "frontend_instance_type" {
  description = "EC2 instance type for frontend"
  type        = string
  default     = "t3.micro"
}

# Todo App - Terraform Infrastructure

This Terraform configuration deploys a full-stack todo application on AWS with separate backend and frontend instances.

## Architecture

- **Backend**: Node.js/Express API with SQLite database running on EC2
- **Frontend**: React application served by nginx on EC2
- **Networking**: VPC with public subnet, internet gateway, and security groups
- **Security**: SSH key-based access and security groups for port management

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform** installed (version >= 1.0)
3. **SSH key pair** for EC2 instance access
4. **AWS account** with appropriate permissions

## Quick Start

1. **Clone or copy the Terraform files** to your project directory

2. **Configure your variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Access your application**:
   - Frontend: `http://<frontend_public_ip>`
   - Backend API: `http://<backend_public_ip>:4000`

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `project_name` | Project name for resource tagging | `todo-app` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `public_subnet_cidr` | Public subnet CIDR | `10.0.1.0/24` |
| `ssh_public_key_path` | Path to SSH public key | `~/.ssh/id_rsa.pub` |
| `backend_ami` | AMI for backend instance | Amazon Linux 2023 |
| `frontend_ami` | AMI for frontend instance | Amazon Linux 2023 |
| `backend_instance_type` | EC2 instance type for backend | `t3.micro` |
| `frontend_instance_type` | EC2 instance type for frontend | `t3.micro` |

### Customizing AMI IDs

The default AMI IDs are for Amazon Linux 2023 in `us-east-1`. If you're using a different region, you'll need to update the AMI IDs. You can find the correct AMI ID for your region using:

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" \
  --query 'Images[0].ImageId' \
  --output text
```

## Infrastructure Components

### Networking
- **VPC**: Custom VPC with DNS support
- **Subnet**: Public subnet with auto-assign public IPs
- **Internet Gateway**: For internet connectivity
- **Route Table**: Routes traffic to internet gateway

### Security
- **Security Groups**: Separate groups for backend and frontend
- **Backend SG**: Allows SSH (22) and API (4000)
- **Frontend SG**: Allows SSH (22), HTTP (80), and HTTPS (443)

### Compute
- **Backend Instance**: Runs Node.js API with PM2 process manager
- **Frontend Instance**: Runs React app with nginx web server
- **IAM Role**: Basic EC2 instance profile

## Application Deployment

### Backend
- Node.js 18.x installed via NodeSource repository
- Express.js API with SQLite database
- PM2 for process management
- CORS enabled for frontend communication

### Frontend
- Node.js 18.x with build tools
- React application built with webpack
- nginx web server with proxy configuration
- Automatic build and deployment via user data

## Management

### View Outputs
```bash
terraform output
```

### SSH Access
```bash
# Backend
ssh -i ~/.ssh/id_rsa ec2-user@<backend_public_ip>

# Frontend
ssh -i ~/.ssh/id_rsa ec2-user@<frontend_public_ip>
```

### Destroy Infrastructure
```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **AMI not found**: Update AMI IDs in `terraform.tfvars` for your region
2. **SSH connection failed**: Verify your SSH key path and permissions
3. **Application not accessible**: Check security group rules and instance status
4. **Build failures**: Check user data logs in EC2 console

### Logs and Monitoring

- **Backend logs**: `pm2 logs` on backend instance
- **Frontend logs**: `sudo journalctl -u nginx` on frontend instance
- **User data logs**: Check `/var/log/cloud-init-output.log` on both instances

## Security Considerations

- This configuration is for development/demo purposes
- For production, consider:
  - Private subnets for backend instances
  - Application Load Balancer
  - RDS instead of SQLite
  - HTTPS with SSL certificates
  - More restrictive security groups
  - CloudWatch monitoring and logging

## Cost Optimization

- Use `t3.micro` instances for development (free tier eligible)
- Consider using Spot instances for cost savings
- Monitor usage and clean up unused resources
- Use AWS Cost Explorer to track expenses

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review AWS CloudTrail logs
3. Check Terraform state with `terraform show`
4. Verify AWS console for resource status

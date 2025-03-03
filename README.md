# Terraform Infrastructure for ECS + RDS

## Overview
This Terraform project provisions a complete AWS infrastructure for TODO App using LAMP stack with the following components:
This Project follows the Well Architected FrameWork. Check the Attached Architectural Diagram

- **VPC**: A Virtual Private Cloud with two availability zones.
- **Subnets**:
  - Public subnets for the ECS Fargate cluster.
  - Private subnets for the RDS database.
- **ECS (Fargate)**:
  - Runs a containerized application.
  - Hosted in the public subnets.
- **RDS (Relational Database Service)**:
  - A managed database hosted in private subnets.
- **ALB (Application Load Balancer)**:
  - Distributes traffic to the ECS service.
- **CloudWatch**:
  - Monitors the ECS service and RDS database.
- **Security Groups**:
  - Controls traffic flow between ECS, RDS, and the Load Balancer.

## Project Structure
```
.
├── alb.tf              # Defines the Application Load Balancer
├── cloudwatch.tf       # CloudWatch configuration for monitoring
├── ecr.tf              # Elastic Container Registry setup
├── ecs.tf              # ECS Fargate Cluster and Service definition
├── provider.tf         # Defines the AWS provider
├── rds.tf              # RDS database configuration
├── terraform.tfstate   # Terraform state file (DO NOT PUSH TO GIT!)
├── terraform.tfstate.backup  # Terraform state backup file
├── terraform.tfvars    # Terraform variables (DO NOT PUSH SENSITIVE DATA!)
├── variables.tf        # Variable definitions for the project
├── vpc.tf              # VPC, subnets, and networking configurations
```

## Prerequisites
- Terraform installed
- AWS CLI configured with proper credentials

## Deployment Steps
1. Initialize Terraform:
   ```sh
   terraform init
   ```
2. Preview the changes:
   ```sh
   terraform plan
   ```
3. Apply the configuration:
   ```sh
   terraform apply -auto-approve
   ```

## Cleanup
To destroy all resources:
```sh
terraform destroy -auto-approve
```

## Notes
- Ensure secrets like database credentials are managed securely.
- Create a terraform.tfvars file and add all your configurations for database and vpc etc (you will find the stuffs you need to add by going through the variables.tf)

## Author
**Ignatus Anim** - [GitHub Profile](https://github.com/ignatus-anim)


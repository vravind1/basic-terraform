# Basic Terraform to get started (just use main.tf)
Sample Terraform Code to create few resources in AWS Cloud environment
- Uses hashicorp/aws provider (v4.18)
- Requires two variables
    - Public Key (for remote access)
    - Instance type (check EC2 instance types)
    
# For checking out Sentinel policy
You can copy/download .hcl and .sentinel files
- This basic policy restricts Terraform to deploy few EC2 instance types

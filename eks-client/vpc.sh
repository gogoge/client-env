#!/bin/bash

# Define variables
CIDR_BLOCK="10.0.0.0/20"
PUBLIC_SUBNET_1_CIDR="10.0.0.0/24"
PUBLIC_SUBNET_2_CIDR="10.0.1.0/24"
PRIVATE_SUBNET_1_CIDR="10.0.2.0/24"
PRIVATE_SUBNET_2_CIDR="10.0.3.0/24"
AZ1="us-east-1a" # Change to your preferred AZ
AZ2="us-east-1b" # Change to your preferred AZ

# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $CIDR_BLOCK --query 'Vpc.VpcId' --output text)
echo "Created VPC: $VPC_ID"

# Create Subnets
PUBLIC_SUBNET_1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_SUBNET_1_CIDR --availability-zone $AZ1 --query 'Subnet.SubnetId' --output text)
echo "Created Public Subnet 1: $PUBLIC_SUBNET_1_ID"

PUBLIC_SUBNET_2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_SUBNET_2_CIDR --availability-zone $AZ2 --query 'Subnet.SubnetId' --output text)
echo "Created Public Subnet 2: $PUBLIC_SUBNET_2_ID"

# public subnet must auto assign IP
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_1_ID --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_2_ID --map-public-ip-on-launch


PRIVATE_SUBNET_1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_SUBNET_1_CIDR --availability-zone $AZ1 --query 'Subnet.SubnetId' --output text)
echo "Created Private Subnet 1: $PRIVATE_SUBNET_1_ID"

PRIVATE_SUBNET_2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_SUBNET_2_CIDR --availability-zone $AZ2 --query 'Subnet.SubnetId' --output text)
echo "Created Private Subnet 2: $PRIVATE_SUBNET_2_ID"

# for alb auto discover subnet
aws ec2 create-tags --resources $PUBLIC_SUBNET_1_ID $PUBLIC_SUBNET_2_ID --tags Key=kubernetes.io/role/elb,Value=1
aws ec2 create-tags --resources $PRIVATE_SUBNET_1_ID $PRIVATE_SUBNET_2_ID  --tags Key=kubernetes.io/role/internal-elb,Value=1

# Create and Attach Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
echo "Created Internet Gateway: $IGW_ID"

aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
echo "Attached Internet Gateway: $IGW_ID to VPC: $VPC_ID"

# Create Route Tables
PUBLIC_RTB_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
echo "Created Public Route Table: $PUBLIC_RTB_ID"

PRIVATE_RTB_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
echo "Created Private Route Table: $PRIVATE_RTB_ID"

# Create Routes for Public Subnet
aws ec2 create-route --route-table-id $PUBLIC_RTB_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
echo "Created route to IGW in Public Route Table: $PUBLIC_RTB_ID"

# Associate Subnets with Route Tables
aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_1_ID --route-table-id $PUBLIC_RTB_ID
echo "Associated Public Subnet 1 with Public Route Table"

aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_2_ID --route-table-id $PUBLIC_RTB_ID
echo "Associated Public Subnet 2 with Public Route Table"

aws ec2 associate-route-table --subnet-id $PRIVATE_SUBNET_1_ID --route-table-id $PRIVATE_RTB_ID
echo "Associated Private Subnet 1 with Private Route Table"

aws ec2 associate-route-table --subnet-id $PRIVATE_SUBNET_2_ID --route-table-id $PRIVATE_RTB_ID
echo "Associated Private Subnet 2 with Private Route Table"

# Create NAT Gateway
EIP_ALLOC_ID=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
echo "Allocated Elastic IP: $EIP_ALLOC_ID"

NAT_GW_ID=$(aws ec2 create-nat-gateway --subnet-id $PUBLIC_SUBNET_1_ID --allocation-id $EIP_ALLOC_ID --query 'NatGateway.NatGatewayId' --output text)
echo "Created NAT Gateway: $NAT_GW_ID in Public Subnet 1: $PUBLIC_SUBNET_1_ID"

# Wait for NAT Gateway to become available
echo "Waiting for NAT Gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID
echo "NAT Gateway is now available."

# Create Routes for Private Subnet
aws ec2 create-route --route-table-id $PRIVATE_RTB_ID --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW_ID
echo "Created route to NAT Gateway in Private Route Table: $PRIVATE_RTB_ID"

echo "AWS VPC and subnets setup complete."


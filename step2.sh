# Create VPC
export VPC_ID=$(aws ec2 create-vpc \
	--cidr-block $VPC_CIDR \
	--tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-vpc}]" \
	--query Vpc.VpcId --output text)
echo "Created VPC: $VPC_ID"

# Enable DNS support for the VPC
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames

# Create public subnets (for NAT Gateway)
export PUBLIC_SUBNET_1_ID=$(aws ec2 create-subnet \
	--vpc-id $VPC_ID \
	--cidr-block 10.0.0.0/24 \
	--availability-zone $AZ_1 \
	--tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-public-subnet-1}]" \
	--query Subnet.SubnetId --output text)
echo "Created Public Subnet 1: $PUBLIC_SUBNET_1_ID"

export PUBLIC_SUBNET_2_ID=$(aws ec2 create-subnet \
	--vpc-id $VPC_ID \
	--cidr-block 10.0.1.0/24 \
	--availability-zone $AZ_2 \
	--tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-public-subnet-2}]" \
	--query Subnet.SubnetId --output text)
echo "Created Public Subnet 2: $PUBLIC_SUBNET_2_ID"

# Create private subnets (for Fargate pods)
export PRIVATE_SUBNET_1_ID=$(aws ec2 create-subnet \
	--vpc-id $VPC_ID \
	--cidr-block 10.0.2.0/24 \
	--availability-zone $AZ_1 \
	--tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-private-subnet-1}]" \
	--query Subnet.SubnetId --output text)
echo "Created Private Subnet 1: $PRIVATE_SUBNET_1_ID"

export PRIVATE_SUBNET_2_ID=$(aws ec2 create-subnet \
	--vpc-id $VPC_ID \
	--cidr-block 10.0.3.0/24 \
	--availability-zone $AZ_2 \
	--tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-private-subnet-2}]" \
	--query Subnet.SubnetId --output text)
echo "Created Private Subnet 2: $PRIVATE_SUBNET_2_ID"

# Tag all subnets for Kubernetes
aws ec2 create-tags \
	--resources $PUBLIC_SUBNET_1_ID $PUBLIC_SUBNET_2_ID $PRIVATE_SUBNET_1_ID $PRIVATE_SUBNET_2_ID \
	--tags "Key=kubernetes.io/cluster/${EKS_CLUSTER_NAME},Value=shared"

# Tag public subnets for public load balancers
aws ec2 create-tags \
	--resources $PUBLIC_SUBNET_1_ID $PUBLIC_SUBNET_2_ID \
	--tags "Key=kubernetes.io/role/elb,Value=1"

# Tag private subnets for internal load balancers
aws ec2 create-tags \
	--resources $PRIVATE_SUBNET_1_ID $PRIVATE_SUBNET_2_ID \
	--tags "Key=kubernetes.io/role/internal-elb,Value=1"

# Create and attach internet gateway (for public subnets)
export IGW_ID=$(aws ec2 create-internet-gateway \
	--tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-igw}]" \
	--query InternetGateway.InternetGatewayId --output text)
echo "Created Internet Gateway: $IGW_ID"

aws ec2 attach-internet-gateway \
	--internet-gateway-id $IGW_ID \
	--vpc-id $VPC_ID

# Create public route table and associate with public subnets
export PUBLIC_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
	--vpc-id $VPC_ID \
	--tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-public-rtb}]" \
	--query RouteTable.RouteTableId --output text)
echo "Created Public Route Table: $PUBLIC_ROUTE_TABLE_ID"

aws ec2 create-route \
	--route-table-id $PUBLIC_ROUTE_TABLE_ID \
	--destination-cidr-block 0.0.0.0/0 \
	--gateway-id $IGW_ID

aws ec2 associate-route-table \
	--route-table-id $PUBLIC_ROUTE_TABLE_ID \
	--subnet-id $PUBLIC_SUBNET_1_ID

aws ec2 associate-route-table \
	--route-table-id $PUBLIC_ROUTE_TABLE_ID \
	--subnet-id $PUBLIC_SUBNET_2_ID

# Create an Elastic IP for NAT Gateway
export EIP_ALLOCATION_ID=$(aws ec2 allocate-address \
	--domain vpc \
	--tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-eip}]" \
	--query AllocationId --output text)
echo "Created Elastic IP: $EIP_ALLOCATION_ID"

# Create NAT Gateway in the public subnet
export NAT_GATEWAY_ID=$(aws ec2 create-nat-gateway \
	--subnet-id $PUBLIC_SUBNET_1_ID \
	--allocation-id $EIP_ALLOCATION_ID \
	--tag-specifications "ResourceType=natgateway,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-natgw}]" \
	--query NatGateway.NatGatewayId --output text)
echo "Created NAT Gateway: $NAT_GATEWAY_ID"

# Wait for NAT Gateway to become available
echo "Waiting for NAT Gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GATEWAY_ID
echo "NAT Gateway is now available."

# Create private route table and associate with private subnets
export PRIVATE_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
	--vpc-id $VPC_ID \
	--tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-private-rtb}]" \
	--query RouteTable.RouteTableId --output text)
echo "Created Private Route Table: $PRIVATE_ROUTE_TABLE_ID"

aws ec2 create-route \
	--route-table-id $PRIVATE_ROUTE_TABLE_ID \
	--destination-cidr-block 0.0.0.0/0 \
	--nat-gateway-id $NAT_GATEWAY_ID

aws ec2 associate-route-table \
	--route-table-id $PRIVATE_ROUTE_TABLE_ID \
	--subnet-id $PRIVATE_SUBNET_1_ID

aws ec2 associate-route-table \
	--route-table-id $PRIVATE_ROUTE_TABLE_ID \
	--subnet-id $PRIVATE_SUBNET_2_ID

# Create VPC
export VPC_ID=$(aws ec2 create-vpc \
	--cidr-block $VPC_CIDR \
	--tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-vpc}]" \
	--query Vpc.VpcId --output text)
echo "Created VPC: $VPC_ID"

# Create Subnets
export SUBNET_1_ID=$(aws ec2 create-subnet \
	--vpc-id $VPC_ID \
	--cidr-block $SUBNET_1_CIDR \
	--availability-zone $AZ_1 \
	--tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-subnet-1}]" \
	--query Subnet.SubnetId --output text)
echo "Created Subnet 1: $SUBNET_1_ID"

export SUBNET_2_ID=$(aws ec2 create-subnet \
	--vpc-id $VPC_ID \
	--cidr-block $SUBNET_2_CIDR \
	--availability-zone $AZ_2 \
	--tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-subnet-2}]" \
	--query Subnet.SubnetId --output text)
echo "Created Subnet 2: $SUBNET_2_ID"

# Tag subnets for Kubernetes (required for AWS load balancer integration)
aws ec2 create-tags \
	--resources $SUBNET_1_ID $SUBNET_2_ID \
	--tags "Key=kubernetes.io/cluster/${EKS_CLUSTER_NAME},Value=shared"

# Create and attach internet gateway (for outbound internet access)
export IGW_ID=$(aws ec2 create-internet-gateway \
	--tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-igw}]" \
	--query InternetGateway.InternetGatewayId --output text)
echo "Created Internet Gateway: $IGW_ID"

aws ec2 attach-internet-gateway \
	--internet-gateway-id $IGW_ID \
	--vpc-id $VPC_ID

# Create route table and associate with subnets
export ROUTE_TABLE_ID=$(aws ec2 create-route-table \
	--vpc-id $VPC_ID \
	--tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${EKS_CLUSTER_NAME}-rtb}]" \
	--query RouteTable.RouteTableId --output text)
echo "Created Route Table: $ROUTE_TABLE_ID"

aws ec2 create-route \
	--route-table-id $ROUTE_TABLE_ID \
	--destination-cidr-block 0.0.0.0/0 \
	--gateway-id $IGW_ID

aws ec2 associate-route-table \
	--route-table-id $ROUTE_TABLE_ID \
	--subnet-id $SUBNET_1_ID

aws ec2 associate-route-table \
	--route-table-id $ROUTE_TABLE_ID \
	--subnet-id $SUBNET_2_ID

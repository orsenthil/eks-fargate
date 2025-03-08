# Set these values according to your requirements

```
export AWS_REGION=us-east-1
export VPC_CIDR=10.0.0.0/16
export SUBNET_1_CIDR=10.0.1.0/24
export SUBNET_2_CIDR=10.0.2.0/24
export AZ_1=us-east-1a
export AZ_2=us-east-1b
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

# Resource naming

```
export EKS_CLUSTER_NAME=my-eks-fargate-cluster
export EKS_CLUSTER_ROLE=eks-cluster-role
export EKS_FARGATE_POD_EXECUTION_ROLE=eks-fargate-pod-execution-role
export EKS_FARGATE_COREDNS_PROFILE=coredns-profile
export EKS_FARGATE_DEFAULT_PROFILE=default-profile
```

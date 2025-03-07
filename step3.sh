# Create EKS cluster role
aws iam create-role \
	--role-name $EKS_CLUSTER_ROLE \
	--assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Attach required policies to the EKS cluster role
aws iam attach-role-policy \
	--role-name $EKS_CLUSTER_ROLE \
	--policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Create Fargate pod execution role
aws iam create-role \
	--role-name $EKS_FARGATE_POD_EXECUTION_ROLE \
	--assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks-fargate-pods.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Attach required policies to the Fargate pod execution role
aws iam attach-role-policy \
	--role-name $EKS_FARGATE_POD_EXECUTION_ROLE \
	--policy-arn arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy

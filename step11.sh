# To delete the cluster and resources when you're done
# Uncomment and run these commands

# Delete the test deployment
# kubectl delete deployment nginx-test

# Delete Fargate profiles
# aws eks delete-fargate-profile --fargate-profile-name $EKS_FARGATE_DEFAULT_PROFILE --cluster-name $EKS_CLUSTER_NAME
# aws eks delete-fargate-profile --fargate-profile-name $EKS_FARGATE_COREDNS_PROFILE --cluster-name $EKS_CLUSTER_NAME

# Delete EKS cluster
# aws eks delete-cluster --name $EKS_CLUSTER_NAME

# Delete IAM roles (first detach policies)
# aws iam detach-role-policy --role-name $EKS_FARGATE_POD_EXECUTION_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy
# aws iam delete-role --role-name $EKS_FARGATE_POD_EXECUTION_ROLE
# aws iam detach-role-policy --role-name $EKS_CLUSTER_ROLE --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
# aws iam delete-role --role-name $EKS_CLUSTER_ROLE

# Delete VPC resources (route table association, routes, internet gateway, subnets, VPC)
# aws ec2 delete-vpc --vpc-id $VPC_ID

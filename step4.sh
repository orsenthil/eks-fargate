aws eks create-cluster \
  --name $EKS_CLUSTER_NAME \
  --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EKS_CLUSTER_ROLE} \
  --resources-vpc-config subnetIds=${PUBLIC_SUBNET_1_ID},${PUBLIC_SUBNET_2_ID},${PRIVATE_SUBNET_1_ID},${PRIVATE_SUBNET_2_ID} \
  --kubernetes-version 1.29

echo "EKS cluster creation initiated. This will take 10-15 minutes."

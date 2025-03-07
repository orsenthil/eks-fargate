aws eks update-kubeconfig \
  --name $EKS_CLUSTER_NAME \
  --region $AWS_REGION

echo "kubectl configured to use the new EKS cluster."

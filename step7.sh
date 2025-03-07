# Create Fargate profile for CoreDNS
aws eks create-fargate-profile \
	--fargate-profile-name $EKS_FARGATE_COREDNS_PROFILE \
	--cluster-name $EKS_CLUSTER_NAME \
	--pod-execution-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EKS_FARGATE_POD_EXECUTION_ROLE} \
	--subnets $SUBNET_1_ID $SUBNET_2_ID \
	--selectors namespace=kube-system,labels={k8s-app=kube-dns}

echo "CoreDNS Fargate profile creation initiated. This will take 2-5 minutes."

# Wait for CoreDNS profile to become active
echo "Waiting for CoreDNS Fargate profile to become active..."
while true; do
	STATUS=$(aws eks describe-fargate-profile \
		--fargate-profile-name $EKS_FARGATE_COREDNS_PROFILE \
		--cluster-name $EKS_CLUSTER_NAME \
		--query fargateProfile.status --output text)
	echo "Current CoreDNS profile status: $STATUS"
	if [ "$STATUS" = "ACTIVE" ]; then
		break
	fi
	sleep 30
done

# Create default Fargate profile for workloads
aws eks create-fargate-profile \
	--fargate-profile-name $EKS_FARGATE_DEFAULT_PROFILE \
	--cluster-name $EKS_CLUSTER_NAME \
	--pod-execution-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EKS_FARGATE_POD_EXECUTION_ROLE} \
	--subnets $SUBNET_1_ID $SUBNET_2_ID \
	--selectors namespace=default

echo "Default Fargate profile creation initiated. This will take 2-5 minutes."

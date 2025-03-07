echo "Waiting for EKS cluster to become active..."
while true; do
	STATUS=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query cluster.status --output text)
	echo "Current cluster status: $STATUS"
	if [ "$STATUS" = "ACTIVE" ]; then
		break
	fi
	sleep 60
done

echo "EKS cluster is now active."

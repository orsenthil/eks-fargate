# Wait a moment for the profiles to be fully ready
sleep 30

# Remove EC2 node selector from CoreDNS
kubectl patch deployment coredns \
	-n kube-system \
	--type=json \
	-p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'

echo "CoreDNS patched to run on Fargate."

# Wait a moment for the profiles to be fully ready
sleep 30

kubectl patch deployment coredns \
  -n kube-system \
  --type=json \
  -p='[{"op": "add", "path": "/spec/template/metadata/annotations", "value": {"eks.amazonaws.com/compute-type": "fargate"}}]'

echo "CoreDNS patched to run on Fargate."

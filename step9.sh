# Wait for CoreDNS pods to reschedule
echo "Waiting for CoreDNS pods to start on Fargate..."
sleep 60

# Check CoreDNS pods
echo "Checking CoreDNS pods:"
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check nodes (should be Fargate virtual nodes)
echo "Checking nodes:"
kubectl get nodes

# Check all system pods
echo "Checking all system pods:"
kubectl get pods --all-namespaces

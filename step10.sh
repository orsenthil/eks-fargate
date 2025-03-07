# Create a test deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-test
  template:
    metadata:
      labels:
        app: nginx-test
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
EOF

# Wait for deployment to be ready
echo "Waiting for test deployment to be ready..."
sleep 60

# Check test deployment
echo "Checking test deployment:"
kubectl get pods -l app=nginx-test

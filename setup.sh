if kind get clusters 2>/dev/null | grep -q "^pe-architecture$"; then
  echo "Kind cluster 'pe-architecture' already exists, skipping creation."
else
  kind create cluster --name pe-architecture
fi 

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install grafana-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values grafana-stack-values.yaml \
  --wait

# Verify installation
kubectl get pods -n monitoring

# Apply Gatekeeper manifests
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

# Wait for Gatekeeper to be ready
kubectl wait --for=condition=Ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=90s

kubectl get pods -n gatekeeper-system

kubectl apply -f simple-constraint-template.yaml

#kubectl apply -f simple-constraint.yaml

#kubectl apply -f simple-ns-with-label.yaml

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Install (--kubelet-insecure-tls required for development/lab environments)
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls}

# Wait for ready
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metrics-server -n kube-system --timeout=90s

kubectl get pods -n kube-system -l app.kubernetes.io/name=metrics-server

kubectl top nodes
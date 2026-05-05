# Verify OPA Gatekeeper is running
kubectl get pods -n gatekeeper-system

# Verify constraint templates exist
kubectl get constrainttemplates

kubectl apply -f workshop/capoc/cve/cve-constraint-template.yaml

kubectl get constrainttemplates

kubectl apply -f workshop/capoc/cve/cve-constraint.yaml

kubectl get constraints

#FAILS
# kubectl apply -f workshop/capoc/cve/deployment.yaml

#WORKING
#kubectl apply -f workshop/capoc/cve/deployment-working.yaml
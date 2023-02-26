
kubectl delete -f gateway.yaml

echo "\n\ncheck:\n"

kubectl get gtw -n istio-system
kubectl get secret -n istio-system
kubectl get httproute -n istio-system

echo "\n\n"


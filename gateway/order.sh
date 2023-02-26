
kubectl apply -f gateway.yaml
kubectl wait --for=condition=ready gtw cluster-gateway -n istio-system
export INGRESS_HOST=$(kubectl get gtw cluster-gateway -n istio-system -o jsonpath='{.status.addresses[*].value}')
export SECURE_INGRESS_PORT=443
echo $INGRESS_HOST:$SECURE_INGRESS_PORT


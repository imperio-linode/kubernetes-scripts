kubectl delete -f bin.yaml
kubectl delete -f gateway.yaml
rm -rf certs*
kubectl delete secret instances-credential -n istio-system
kubectl delete secret gateway-imperio-credential -n istio-system




echo "\n\ncheck:\n"

kubectl get gtw -n istio-system
kubectl get secret -n istio-system
kubectl get httproute -n istio-system
echo "\n\n"

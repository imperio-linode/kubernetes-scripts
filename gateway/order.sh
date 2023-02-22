mkdir certs
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=Better Nerf./CN=imperio' -keyout certs/imperio.key -out certs/imperio.crt
openssl req -out certs/gateway.imperio.csr -newkey rsa:2048 -nodes -keyout certs/gateway.imperio.key -subj "/CN=gateway.imperio/O=gateway organization"
openssl x509 -req -sha256 -days 365 -CA certs/imperio.crt -CAkey certs/imperio.key -set_serial 0 -in certs/gateway.imperio.csr -out certs/gateway.imperio.crt

openssl req -out certs/instances.imperio.csr -newkey rsa:2048 -nodes -keyout certs/instances.imperio.key -subj "/CN=instances.imperio/O=instances organization"
openssl x509 -req -sha256 -days 365 -CA certs/imperio.crt -CAkey certs/imperio.key -set_serial 1 -in certs/instances.imperio.csr -out certs/instances.imperio.crt

openssl req -out certs/client.imperio.csr -newkey rsa:2048 -nodes -keyout certs/client.imperio.key -subj "/CN=client.imperio/O=client organization"
openssl x509 -req -sha256 -days 365 -CA certs/imperio.crt -CAkey certs/imperio.key -set_serial 1 -in certs/client.imperio.csr -out certs/client.imperio.crt

kubectl create -n istio-system secret tls instances-credential \
  --key=certs/instances.imperio.key \
  --cert=certs/instances.imperio.crt

kubectl create -n istio-system secret tls gateway-imperio-credential \
  --key=certs/gateway.imperio.key \
  --cert=certs/gateway.imperio.crt

kubectl apply -f gateway.yaml

kubectl wait --for=condition=ready gtw cluster-gateway -n istio-system
export INGRESS_HOST=$(kubectl get gtw cluster-gateway -n istio-system -o jsonpath='{.status.addresses[*].value}')
export SECURE_INGRESS_PORT=443
echo $INGRESS_HOST:$SECURE_INGRESS_PORT

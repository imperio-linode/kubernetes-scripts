#!/bin/bash


certsdir=$workdir/kubernetes-scripts/tls/certs

. $workdir/kubernetes-scripts/log.sh

#Arguments:
#     $1 = This is export password for p12
exportPass=$1


#Setup CSR that relates to KEY. CA cert + key validates CSR with KEY and signs new CERT
#HTTP request takes CA cert.
inf "Create Certs" "Initializing..."
mkdir $workdir/kubernetes-scripts/tls/certs

inf "Create Certs" "Generating CA..."
#CA domain        key1 + crt1
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=Better Nerf./CN=imperio' -keyout $certsdir/imperio.key -out $certsdir/imperio.crt

inf "Create Certs" "Generating service keypairs..."
#CSR + prv key gateway      key2 + csr1
openssl req -out $certsdir/gateway.imperio.csr -newkey rsa:2048 -nodes -keyout $certsdir/gateway.imperio.key -subj "/CN=gateway.imperio/O=gateway organization"
#CERT gateway     crt2
openssl x509 -req -sha256 -days 365 -CA $certsdir/imperio.crt -CAkey $certsdir/imperio.key -set_serial 0 -in $certsdir/gateway.imperio.csr -out $certsdir/gateway.imperio.crt

#CSR + prv key instances    key3 + csr2
openssl req -out $certsdir/instances.imperio.csr -newkey rsa:2048 -nodes -keyout $certsdir/instances.imperio.key -subj "/CN=instances.imperio/O=instances organization"
#CERT instances   crt3
openssl x509 -req -sha256 -days 365 -CA $certsdir/imperio.crt -CAkey $certsdir/imperio.key -set_serial 1 -in $certsdir/instances.imperio.csr -out $certsdir/instances.imperio.crt

#CSR + prv key client       key4 + csr3
openssl req -out $certsdir/client.imperio.csr -newkey rsa:2048 -nodes -keyout $certsdir/client.imperio.key -subj "/CN=client.imperio/O=client organization"
#CERT client      crt 4
openssl x509 -req -sha256 -days 365 -CA $certsdir/imperio.crt -CAkey $certsdir/imperio.key -set_serial 1 -in $certsdir/client.imperio.csr -out $certsdir/client.imperio.crt

#CSR + prv key linode-services
openssl req -out $certsdir/linode-services.imperio.csr -newkey rsa:2048 -nodes -keyout $certsdir/linode-services.imperio.key -subj "/CN=linodeservices.imperio/O=linodeservices organization"
#CERT linode-services
openssl x509 -req -sha256 -days 365 -CA $certsdir/imperio.crt -CAkey $certsdir/imperio.key -set_serial 1 -in $certsdir/linode-services.imperio.csr -out $certsdir/linode-services.imperio.crt

inf "Create Certs" "Creating kubernetes secrets..."
kubectl create -n istio-system secret tls instances-credential \
  --key=$certsdir/instances.imperio.key \
  --cert=$certsdir/instances.imperio.crt
kubectl create -n istio-system secret tls gateway-imperio-credential \
  --key=$certsdir/gateway.imperio.key \
  --cert=$certsdir/gateway.imperio.crt
kubectl create -n istio-system secret tls linode-services-imperio-credential \
  --key=$certsdir/linode-services.imperio.key \
  --cert=$certsdir/linode-services.imperio.crt

inf "Create Certs" "Generating pkcs12 stores..."
openssl pkcs12 -export -password pass:$exportPass -out $workdir/instances/src/main/resources/keystore.p12 -inkey $certsdir/instances.imperio.key -in $certsdir/instances.imperio.crt
openssl pkcs12 -export -password pass:$exportPass -out $workdir/gateway/src/main/resources/keystore.p12 -inkey $certsdir/gateway.imperio.key -in $certsdir/gateway.imperio.crt
#Looks like only this one is needed, but only because we have mTLS from istio. Otherwise needs to add keystores.
openssl pkcs12 -export -password pass:$exportPass -out $certsdir/ca.p12 -inkey $certsdir/imperio.key -in $certsdir/imperio.crt

inf "Create Certs" "Copying certs..."
cp -r $certsdir/ca.p12 $workdir/instances/src/main/resources/
cp -r $certsdir/ca.p12 $workdir/gateway/src/main/resources/
cp $certsdir/linode-services.* $workdir/linode-services/app/resources/
cp $certsdir/imperio.crt $workdir/linode-services/app/resources/
cp $certsdir/imperio.key $workdir/linode-services/app/resources/

inf "Create Certs" "Done with pki setup."

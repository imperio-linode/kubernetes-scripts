#!/bin/bash


kubectl delete secret gateway-imperio-credential -n istio-system
kubectl delete secret instances-credential -n istio-system
kubectl delete secret linode-services-imperio-credential -n istio-system

pwd

rm $workdir/instances/src/main/resources/*.p12
rm $workdir/instances/src/main/resources/*.crt
rm $workdir/instances/src/main/resources/*.key
rm $workdir/instances/src/main/resources/*.csr
rm $workdir/instances/src/main/resources/*.pem

rm $workdir/gateway/src/main/resources/*.p12
rm $workdir/gateway/src/main/resources/*.crt
rm $workdir/gateway/src/main/resources/*.key
rm $workdir/gateway/src/main/resources/*.csr
rm $workdir/gateway/src/main/resources/*.pem

rm $workdir/linode-services/app/resources/*.crt
rm $workdir/linode-services/app/resources/*.key
rm $workdir/linode-services/app/resources/*.csr
rm $workdir/linode-services/app/resources/*.pem

rm -rf $workdir/kubernetes-scripts/tls/certs/*

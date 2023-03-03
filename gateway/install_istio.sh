#!/bin/bash

. $workdir/kubernetes-scripts/log.sh

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

inf "istio" "Install gateway api"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.5.1/standard-install.yaml

inf "istio" "Create istio namespace"
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system

inf "istio" "Helm ls"
helm ls -n istio-system
#todo: ask if valid
inf "istio" "Installing istiod..."
helm install istiod istio/istiod -n istio-system --wait

#todo: ask if valid
inf "istio" "Helm ls 2"
helm ls -n istio-system

inf "istio" "Helm status"
helm status istiod -n istio-system

inf "istio" "Installing crds..."
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.6.1" | kubectl apply -f -; }

inf "istio" "Creating ingress namespace..."
kubectl create namespace istio-ingress
inf "istio" "Install gateway"
helm install istio-ingress istio/gateway -n istio-ingress --wait


inf "istio" "Apply gateway.yaml"
kubectl delete ns istio-ingress
kubectl apply -f $workdir/kubernetes-scripts/gateway/gateway.yaml
kubectl wait --for=condition=ready gtw cluster-gateway -n istio-system
export INGRESS_HOST=$(kubectl get gtw cluster-gateway -n istio-system -o jsonpath='{.status.addresses[*].value}')
export SECURE_INGRESS_PORT=443
echo $INGRESS_HOST:$SECURE_INGRESS_PORT

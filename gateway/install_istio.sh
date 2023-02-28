#!/bin/bash

. $workdir/kubernetes-scripts/log.sh

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

inf "istio" "Create istio namespace"
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
inf "istio" "Helm ls"
helm ls -n istio-system
#todo: ask if valid
helm install istiod istio/istiod -n istio-system --wait
#todo: ask if valid
inf "istio" "Helm ls 2"
helm ls -n istio-system
inf "istio" "Helm status"
helm status istiod -n istio-system
inf "istio" "Get crd"
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.6.1" | kubectl apply -f -; }

inf "istio" "Create ingress namespace"
kubectl create namespace istio-ingress
helm install istio-ingressgateway istio/gateway -n istio-ingress

inf "istio" "Install gateway api"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.5.1/standard-install.yaml

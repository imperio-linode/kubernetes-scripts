#!/bin/bash

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm ls -n istio-system
#todo: ask if valid
helm install istiod istio/istiod -n istio-system --wait
#todo: ask if valid
helm ls -n istio-system
helm status istiod -n istio-system

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.6.1" | kubectl apply -f -; }

kubectl create namespace istio-ingress
helm install istio-ingressgateway istio/gateway -n istio-ingress

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.5.1/standard-install.yaml

kubectl apply -f gateway.yaml

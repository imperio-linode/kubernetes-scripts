#!/bin/bash

workdir=~/work/imperio

. $workdir/kubernetes-scripts/log.sh

helm repo add istio https://istio-release.storage.googleapis.com/charts &>/dev/null
helm repo update &>/dev/null

inf "istio" "Install gateway api"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.6.1/experimental-install.yaml &>/dev/null


inf "istio" "Create istio namespace"
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system &>/dev/null

#todo: ask if valid
inf "istio" "Installing istiod"
helm install istiod istio/istiod -n istio-system --wait &>/dev/null

#todo: ask if valid
inf "istio" "Helm ls 2"
helm ls -n istio-system

inf "istio" "Helm status"
helm status istiod -n istio-system &>/dev/null

inf "istio" "Installing crds"
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.6.1" | kubectl apply -f -; }
kubectl get crd tcproutes.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.6.1" | sed 's@HTTPRoute@TCPRoute@' | kubectl apply -f -; }

inf "istio" "Creating ingress namespace"
kubectl create namespace istio-ingress
inf "istio" "Install gateway"
helm install istio-ingress istio/gateway -n istio-ingress --wait &>/dev/null


inf "istio" "Apply gateway.yaml"
kubectl delete ns istio-ingress
kubectl apply -f $workdir/kubernetes-scripts/gateway/gateway.yaml

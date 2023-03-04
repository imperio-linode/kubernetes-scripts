#!/bin/bash


helm delete istio-ingress -n istio-ingress
kubectl delete ns istio-ingress
helm delete istiod -n istio-system
helm delete istio-base -n istio-system
kubectl delete namespace istio-system
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.5.1/standard-install.yaml


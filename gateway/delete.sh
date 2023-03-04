#!/bin/bash


kubectl delete -f gateway.yaml
kubectl get gtw -n istio-system
kubectl get secret -n istio-system
kubectl get httproute -n istio-system

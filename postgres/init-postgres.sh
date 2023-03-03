#!/bin/bash

#delete
kubectl delete pvc data-postgres-postgresql-0

helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl apply -f $workdir/kubernetes-scripts/postgres/postgres-pv.yaml
#If using with --namespace need to copy secret after deploy to default ns.
helm install postgres bitnami/postgresql --set persistence.existingClaim=postgresql-pv-claim --set volumePermissions.enabled=true


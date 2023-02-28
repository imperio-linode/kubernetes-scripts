#!/bin/bash


helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl apply -f postgres/postgres-pv.yaml
#If using with --namespace need to copy secret after deploy to default ns.
helm install postgres bitnami/postgresql --set persistence.existingClaim=postgresql-pv-claim --set volumePermissions.enabled=true

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)
echo $POSTGRES_PASSWORD

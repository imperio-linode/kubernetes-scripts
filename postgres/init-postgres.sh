#!/bin/bash


. $workdir/kubernetes-scripts/log.sh

kubectl delete pvc data-data-imperio-postgresql-0  &>/dev/null
kubectl delete pv postgresql-pv --grace-period=0 --force &>/dev/null
kubectl delete pod imperio-postgresql-client 0 &>/dev/null

helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl apply -f $workdir/kubernetes-scripts/postgres/postgres-pv.yaml
#If using with --namespace need to copy secret after deploy to default ns.
inf "postgres" "Installing postgres..."
helm install data-imperio bitnami/postgresql --set persistence.existingClaim=postgresql-pv-claim --set volumePermissions.enabled=true &>/dev/null
inf "postgres" "Exposing postgres..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=postgresql --timeout=50s
export POSTGRES_PASSWORD=$(kubectl get secret data-imperio-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)

inf "postgres" "Creating database imperio..."
kubectl run imperio-postgresql-client --rm -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:15.2.0-debian-11-r5 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
  --command -- sh -c "psql --host data-imperio-postgresql -U postgres -d postgres -p 5432 -c 'CREATE DATABASE imperio;' < /dev/null"

inf "postgres" "Applying postgres IP to services config..."
postgres_ip=$(kubectl get svc data-imperio-postgresql --template"={{.spec.clusterIP}}")
cp $workdir/instances/imperio-instances-template.yaml $workdir/instances/imperio-instances.yaml
sed -i '' "s/POSTGRES_IP_SED/$postgres_ip/g" $workdir/instances/imperio-instances.yaml

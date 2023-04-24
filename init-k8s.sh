#!/bin/bash

export workdir=~/work/imperio

. $workdir/kubernetes-scripts/log.sh


exportPass=$1
linodeToken=$2

external_ip=$(kubectl get svc -n istio-system cluster-gateway-istio --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")

main() {
  inf "Imperio] \n\n\n\t\t\t:[\INSTALLING APP\t" "\n"
  checkClusterConnection
  checkOrInstallHelm
  installPostgress
  initGateway
  rotateCerts
  kubectl create secret generic linode-token --from-literal=linode-token=$linodeToken
  postInstallInfo
}

checkClusterConnection() {
  kubectl get nodes &>/dev/null
  if [ $? -eq 0 ]; then
    inf "Imperio" "Connection to cluster successfull."
  else
    err "Imperio" "Can't connect to kubernetes cluster. Check your kubectl config."
    exit
  fi
}

checkOrInstallHelm() {
  helm version &>/dev/null
  if [ $? -eq 0 ]; then
    inf "Imperio" "Helm already present."
  else
    err "Imperio" "Helm not installed. Installing"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    if [ $? -eq 0 ]; then
      inf "Imperio" "Helm installed."
    else
      err "Imperio" "Failure installing helm."
      exit
    fi
  fi
}

installPostgress() {
  inf "imperio" "Postgres setup"
  sh $workdir/kubernetes-scripts/postgres/init-postgres.sh
}

initGateway() {
  inf "imperio" "Installing Istio"
  sh $workdir/kubernetes-scripts/gateway/install-istio.sh
  if [ $? -eq 0 ]; then
    inf "Imperio" "Istio installed correctly."
  else
    err "Imperio" "Failure installing istio."
    exit
  fi
}

rotateCerts() {
  inf "imperio" "Creating TLS certs"

  kubectl create secret generic imperio-store --from-literal=spring=$exportPass
  sh $workdir/kubernetes-scripts/tls/rotate.sh $exportPass
}

postInstallInfo() {
  external_ip=""
  POSTGRES_PASSWORD=$(kubectl get secret data-imperio-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)

  while [ -z $external_ip ]; do
    echo "Waiting for gateway ip"
    external_ip=$(kubectl get svc -n istio-system cluster-gateway-istio --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
    [ -z "$external_ip" ] && sleep 10
  done

  inf "Imperio] \n\n\n\t\t\t:[\tSETUP COMPLETE\t" "\n"
  inf "postgres pass localhost" $POSTGRES_PASSWORD
  inf "gateway" "Update /etc/hosts with hostnames and $external_ip"
}


main

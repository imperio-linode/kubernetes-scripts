#!/bin/bash


export workdir=~/work/imperio

. $workdir/kubernetes-scripts/log.sh

#Use with 1 parameter which is CA password.

exportPass=$1

main() {
  inf "Imperio] \n\n\n\t\t\t:[\tSTARTING APP\t" "\n"
  checkClusterConnection
  checkOrInstallHelm
#  installPostgress
  initGateway
  rotateCerts
  inf "Imperio] \n\n\n\t\t\t:[\tSETUP COMPLETE\t" "\n"
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
        err "Imperio" "Helm not installed. Installing..."
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
  inf "imperio" "Initialize Postgres... Password will be printed."
  sh postgres/init-postgres.sh
  inf "imperio postgres" "Remember to create database imperio now."
}

initGateway() {
  inf "imperio" "Installing Istio..."
  sh $workdir/kubernetes-scripts/gateway/install_istio.sh
  kubectl apply -f $workdir/kubernetes-scripts/gateway/gateway.yaml
  kubectl wait --for=condition=ready gtw cluster-gateway -n istio-system
  export INGRESS_HOST=$(kubectl get gtw cluster-gateway -n istio-system -o jsonpath='{.status.addresses[*].value}')
  export SECURE_INGRESS_PORT=443
  echo $INGRESS_HOST:$SECURE_INGRESS_PORT
  if [ $? -eq 0 ]; then
      inf "Imperio" "Istio installed correctly."
  else
      err "Imperio" "Failure installing istio."
      exit
  fi
}

rotateCerts() {
  inf "imperio" "Creating TLS certs..."
  sh $workdir/kubernetes-scripts/tls/rotate.sh $exportPass
}

main

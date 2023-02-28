#!/bin/bash

cd $workdir/kubernetes-scripts/tls
sh $workdir/kubernetes-scripts/tls/delete-certs.sh
sh $workdir/kubernetes-scripts/tls/order-certs.sh $1

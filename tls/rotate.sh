#!/bin/bash

sh $workdir/kubernetes-scripts/tls/delete-certs.sh
sh $workdir/kubernetes-scripts/tls/order-certs.sh $1

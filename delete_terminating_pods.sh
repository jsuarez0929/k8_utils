#!/bin/sh

# --------------------------------------------------------
# Delete all pods stuck in Terminating status
#
# Reqs:
# - kubectl
# - Set kubectl context to desired cluster
# --------------------------------------------------------

for namespace in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')
do
  for pod in $(kubectl get pods -n $namespace | grep Terminating | awk '{print $1}')
  do
    kubectl delete pod $pod -n $namespace --force --grace-period=0
  done
done

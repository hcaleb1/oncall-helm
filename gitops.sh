#!/bin/bash

STARTTIME=$(date +%s)

k3d cluster delete

k3d cluster create --k3s-server-arg "--no-deploy=traefik" --port "80:80@loadbalancer" --port "443:443@loadbalancer"

echo "copying config from root to caleb linux user"
cp ~/.kube/config /home/caleb/.kube/config
chmod 777 /home/caleb/.kube/config

echo "copying config from root to CalebHicks windows user"
cp ~/.kube/config /mnt/c/Users/CalebHicks/.kube/config
chmod 777 /mnt/c/Users/CalebHicks/.kube/config

helm upgrade \
  cert-manager ./cert-manager \
  --install \
  --namespace cert-manager \
  --create-namespace \
  --version v1.4.0 \
  --set installCRDs=true \
  --wait

helm upgrade \
  istio-operator ./istio-operator \
  --install \
  --set operatorNamespace=istio-operator \
  --wait

helm upgrade \
  istio-controlplane ./istio-controlplane \
  --install \
  --namespace istio-system \
  --create-namespace \
  --wait

helm upgrade \
  oncall ./oncall \
  --install \
  --wait

helm upgrade --install \
  oncall-postinstall-setup ./oncall-postinstall-setup \
  --wait

ENDTIME=$(date +%s)
echo "It took $(($ENDTIME - $STARTTIME)) seconds to complete this task..."
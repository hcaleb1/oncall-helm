#!/bin/bash

STARTTIME=$(date +%s)

k3d cluster delete

k3d cluster create --k3s-server-arg "--no-deploy=traefik" --port "80:80@loadbalancer" --port "443:443@loadbalancer"

echo "copying config from root to karch linux user"
cp ~/.kube/config /home/karch/.kube/config
chmod 777 /home/karch/.kube/config

echo "copying config from root to karchaf windows user"
cp ~/.kube/config /mnt/c/Users/karch/.kube/config
chmod 777 /home/karch/.kube/config

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
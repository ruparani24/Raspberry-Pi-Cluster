#!/bin/bash
# Deploy Pi-hole on K3s
kubectl create namespace pihole
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm install pihole mojo2600/pihole --namespace pihole -f pihole-values.yaml
echo "Pi-hole deployed! Check service details using:"
echo "kubectl get svc -n pihole"

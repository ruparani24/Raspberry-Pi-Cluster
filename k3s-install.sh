#!/bin/bash
echo "Installing K3s on Master Node..."
curl -sfL https://get.k3s.io | sh - 
echo "Fetching K3s Token..."
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo "K3s Token: $K3S_TOKEN"
echo "Installation Complete. Run the following on worker nodes:"
echo "curl -sfL https://get.k3s.io | K3S_URL='https://192.168.1.43:6443' K3S_TOKEN='$K3S_TOKEN' sh -"

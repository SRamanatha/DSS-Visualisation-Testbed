#!/bin/bash

sudo systemctl stop kubelet
sudo kubeadm reset -f --ignore-preflight-errors all
sudo apt purge kubeadm kubelet kubectl kubernetes-cni kube* docker* containerd* -y
sudo rm -rf /opt/cni/bin /etc/cni/net.d /var/lib/kubelet /etc/kubernetes/manifest 
sudo rm /etc/apt/keyrings/kubernetes-apt-keyring.gpg /etc/apt/keyrings/docker.gpg /etc/apt/sources.list.d/kubernetes.list /etc/apt/sources.list.d/docker.list
sudo apt autoremove -y
sudo rm -rf ~/.kube
sudo apt update 
sudo apt upgrade -y
sudo -i
iptables -F && iptables -X
iptables -t nat -F && iptables -t nat -X
iptables -t raw -F && iptables -t raw -X
iptables -t mangle -F && iptables -t mangle -X
exit

sudo apt update
sudo apt autoremove -y


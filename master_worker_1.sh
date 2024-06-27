#!/bin/bash

# --------------------------------System prerequisites----------------------------------------------------------
# disable ubuntu firewall
sudo ufw disable

# update apt repository and upgrade
sudo apt update
sudo apt -y full-upgrade

# enable time sync with an NTP server
sudo apt install systemd-timesyncd
sudo timedatectl set-ntp true

# turn of swap
sudo swapoff -a
sudo sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

# configure required kernel modules
sudo cat /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter

EOF

sudo modprobe overlay \
modprobe br_netfilter

# configure network parameters
sudo cat /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1

EOF

sudo sysctl --system

# install necessary tools
sudo apt-get install -y apt-transport-https ca-certificates curl \
gpg gnupg2 software-properties-common

# -----------------------------Kubernetes and containerd runtime--------------------------------------------
# install Kubernetes
sudo mkdir -m 755 /etc/apt/keyrings

# change the Kubernetes version in this command by replacing v1.29 with the desired version
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# make sure the Kubernetes versions in this command and the previous command match
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# install containerd runtime
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y containerd.io

# configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default|sudo tee /etc/containerd/config.toml

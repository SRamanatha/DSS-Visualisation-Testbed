#!/bin/bash

sudo systemctl restart containerd
sudo systemctl enable containerd

sudo apt install cri-tools

sudo cat /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: true # <- if you don't want to see debug info you can set this to false
pull-image-on-create: false
EOF

sudo systemctl enable kubelet

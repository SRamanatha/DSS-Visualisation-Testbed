# DSS-Visualisation-Testbed
This repository includes instructions to set up a time-series data visualisation testbed on **Debian/Ubuntu** systems. The testbed is comprised of a proxy/load-balancer and a Kubernetes (K8s) cluster with multiple master nodes and worker nodes.  Telegraf-InfluxDB-Grafana (TIG) stack is implemented on the K8s cluster to support visualisation. Persistent volumes are used to store TIG stack data and configurations.

This testbed was succesfully implemented on a private cloud infrastrcuture with 6 Raspberry Pi-4 devices with Ubuntu 22.04 Desktop OS. K8s cluster was setup with 2 master nodes and 6 worker nodes. 1 Pi was used as proxy/loadbalancer outside the K8s cluster.

**NOTE** - Some values in the configuration files are missing. These values must be created and added during implementation as described in the instructions below.

You will need **sudo** access to implement the testbed.

## Initial clean-up
(*This step is optional*)

Run `clean_up.sh` on Ubuntu terminal. This shell script includes instructions to -
1. Purge any previous installations of Kubernetes, Docker, and containerd
2. Remove all related folders from root
3. Remove all related package indices from sources.list
4. Reset iptables
5. Autoremove any unwanted packages

**Caution** - Running this shell script will remove Docker, and hence might affect any other project you

## Installing HAProxy on loadbalancer
(*This step is optional*)

You can install HAProxy on one of the devices to use it as a proxy/loadbalancer for K8s cluster. 
Loadbalancer can be used to advertise the K8s cluster without adding it to the cluster.

## Installing Kubernetes and Containerd
Run `master_worker_1.sh` on all devices. On all devices, open the toml file using any editor. 

 For example - `sudo nano /etc/containerd/config.toml`

Browse the file to find the sections shown in the picture below - 

![image](https://github.com/SRamanatha/DSS-Visualisation-Testbed/assets/140810477/203305f1-26bd-4035-b79c-3b9ac57bdde9)

![image](https://github.com/SRamanatha/DSS-Visualisation-Testbed/assets/140810477/5d3b5516-ffb4-4a1d-9f46-57eeaae84437)

Check if the sections highlighted in the picture match, make changes to the file if necessary.

Run `master_worker_2.sh`.

## Initialising master nodes and worker nodes


## Deploying TIG stack

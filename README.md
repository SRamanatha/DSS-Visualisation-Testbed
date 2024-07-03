# DSS-Visualisation-Testbed
This repository includes instructions to set up a time-series data visualisation testbed on **Debian/Ubuntu** systems. The testbed is comprised of a proxy/load-balancer and a Kubernetes (K8s) cluster with multiple master nodes and worker nodes.  Telegraf-InfluxDB-Grafana (TIG) stack is implemented on the K8s cluster to support visualisation. Persistent volumes are used to store TIG stack data and configurations. 

This testbed was succesfully implemented on a private cloud infrastrcuture with 6 Raspberry Pi-4 devices with Ubuntu 22.04 Desktop OS. K8s cluster was setup with 2 master nodes and 6 worker nodes. 1 Pi was used as proxy/loadbalancer outside the K8s cluster.

**NOTE** - Some values in the configuration files are missing. These values must be created and added during implementation as described in the instructions below.

You will need **sudo** access to implement the testbed.

## 1. Initial clean-up
(*This step is optional*)

Run `clean_up.sh` on Ubuntu terminal. This shell script includes instructions to -
1. Purge any previous installations of Kubernetes, Docker, and containerd
2. Remove all related folders from root
3. Remove all related package indices from sources.list
4. Reset iptables
5. Autoremove any unwanted packages

**Caution** - Running this shell script will remove Docker, and hence might affect any other project you

## 2. Installing HAProxy on loadbalancer
(*This step is optional*)

You can install HAProxy on one of the devices to use it as a proxy/loadbalancer for K8s cluster. 
Loadbalancer can be used to advertise the K8s cluster without adding it to the cluster.

## 3. Installing Kubernetes and Containerd
Run `master_worker_1.sh` on all devices. On all devices, open the toml file using any editor. 

 For example - `sudo nano /etc/containerd/config.toml`

Browse the file to find the sections shown in the picture below - 

![image](https://github.com/SRamanatha/DSS-Visualisation-Testbed/assets/140810477/203305f1-26bd-4035-b79c-3b9ac57bdde9)

![image](https://github.com/SRamanatha/DSS-Visualisation-Testbed/assets/140810477/5d3b5516-ffb4-4a1d-9f46-57eeaae84437)

Check if the sections highlighted in the picture match, make changes to the file if necessary.

Run `master_worker_2.sh`.

## 4. Initializing K8s cluster
### 4.1 Initializing primary master node
Replace `<ip address of loadbalancer>` with appropriate ip address in the command below and run it in a terminal on the device you wish to use as primary master - 

```
sudo kubeadm init \
--pod-network-cidr=10.244.0.0/16 \
--upload-certs --control-plane-endpoint= <ip address of loadbalancer> \
--cri-socket unix:///var/run/containerd/containerd.sock
```
Once the Kubernetes control-plane is succesfully initialized, make a copy of the `kubeadm join` instructions.
For adding more master nodes, copy the `kubeadm join` command that appears immediately after this message - 

`You can now join any number of the control-plane node running the following command on each as root`

Similarly, for adding worker nodes, copy the `kubeadm join` command that appears immediately after this message -

`Then you can join any number of worker nodes by running the following on each as root`

These instructions are necessary to add more nodes to the initialized K8s cluster.

Run the following commands -

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

You should deploy a pod network at this stage. A list of pod networking add-ons can be found [here](https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy). Note that in the `kubeadm init` command above `pod-network-cidr=10.244.0.0/16`. Therefore, Flannel add-on was used in the testbed. Flannel can be deployed by running the following command - 

```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

**NOTE** - Deploying add-on with address space that matches `pod-network-cidr` is crucial for stability of the K8s cluster.

### 4.2 Initializing secondary master and worker nodes
Run the `kubeadm join` command corresponding to control plane nodes on terminal of each device you wish to add to the K8s cluster as a secondary master.

Run the following commands on each secondary master node if it is recommended in the output of `kubeadm join` command -

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Run the `kubeadm join` command corresponding to worker nodes on terminal of each device you wish to add to the K8s cluster as a secondary master.
There is no need to run any additional commands on the worker nodes.

### 4.3 Checking health of K8s cluster
Health of K8s cluster can be checked at any point after initialization by running the follwoing commands - 

`kubectl get nodes` - This command will list all the nodes in the cluster, their roles and status. If initialized correctly, status of all nodes must be `Ready`.

`kubectl get pod --all-namespaces` -  This command will list all pods deployed in the cluster. You must ideally see `kube-system` and `kube-flannel` under `NAMESPACE` column. If the cluster was initialized properly, status of all pods will be `Running`.


## 5. Deploying TIG stack
InfluxDB must be deployed before Telegraf as Telegraf requires token from InfluxDB. Grafana can be deployed at any point. However, the intention is to use InfluxDB as data source within Grafana. Therefore, the recommended order of deployment is - InfluxDB, Telegraf, Grafana.

### 5.1 Namespaces
Separate namespaces can be created by running the following commands -  

```
kubectl create namespace influxdb
kubectl create namespace my-grafana
kubectl create namespace telegraf
```
This step is optional. If separate namespaces are not created, all deployments will be added to `default` namespace.

### 5.2 Persistent volumes and claims
The next step is to create persistent volumes for InfluxDB and Grafana. This can be done by creating directories on one of the devices in the cluster using `mkdir` command and running the following commands - 

```
kubectl apply -f influxdb-pv.yaml
kubectl apply -f grafana-pv.yaml
```

**NOTE** - the value of `path` variable in `yaml` files must match the path of respective newly created directory. For example, a new directory `/home/master1/graf-data` was created on master1. The same path was added in `grafana-pv.yaml`.

The next step is creating persistent volume claims. This can be done by running the following commands - 

```
kubectl apply -f influxdb-pvc.yaml -n influxdb
kubectl apply -f grafana-pvc.yaml -n my-grafana
```

**NOTE** - the values of multiple fields in pv and pvc yaml files must match for the physical volumes to succesfully bind to the respective claims

The status of persitent volumes can be checked by running the following command - 

```
kubectl get pv
```

If done right, the statust must read `Bound` for both persistent volumes.

### 5.3 InfluxDB
Run the following command to deploy InfluxDB - 

```
kubectl apply -f influxdb-deploy.yaml -n influxdb
```

Note that the pv and pvc fields in this yaml match the previously created pv and pvc. This command creates InfluxDB deployment and a service. The status of these can be viewed by running the following command - 

```
kubectl get all -n influxdb
```

### 5.4 Telegraf
The Telegraf agent in this testbed subscribes to a MQTT server from another project and writes the data to InfluxDB. Telegraf agent is not necessary if you intend to write data into InfluxDB using other methods.


### 5.5 Grafana

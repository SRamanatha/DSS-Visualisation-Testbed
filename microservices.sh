#!/bin/bash

kubectl create namespace influxdb
kubectl create namespace my-grafana
kubectl create namespace telegraf

kubectl apply -f influxdb-pv.yaml
kubectl apply -f grafana-pv.yaml

kubectl apply -f influxdb-pvc.yaml -n influxdb
kubectl apply -f influxdb-deploy.yaml -n influxdb
kubectl apply -f grafana-pvc.yaml -n my-grafana
kubectl apply -f grafana.yaml -n my-grafana

kubectl apply -f telegraf.yaml -n telegraf

#!/bin/bash

terraform apply -auto-approve

cluster="terraform-eks-demo"
region="us-east-1"
terraform output -raw kubeconfig > ~/.kube/config
aws eks --region $region update-kubeconfig --name $cluster

# Nodes start to join cluster
terraform output -raw config-map-aws-auth > config-map-aws-auth.yaml 
kubectl apply -f config-map-aws-auth.yaml

# Create autoscaler Deployment as k8s resource https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
kubectl apply -f cluster-autoscaler-autodiscover.yaml

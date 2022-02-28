#!/bin/bash

cluster="terraform-eks-demo"
region="us-east-1"
terraform output -raw kubeconfig > ~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name terraform-eks-demo

# Nodes start to join cluster
terraform output -raw config-map-aws-auth > config-map-aws-auth.yaml 
kubectl apply -f config-map-aws-auth.yaml

# Create eksctl.sh for configuring autoscaler 
eksctl utils associate-iam-oidc-provider --region=$region --cluster=terraform-eks-demo --approve


# Create autoscaler config as k8s resource https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
kubectl apply -f cluster-autoscaler-autodiscover.yaml

terraform output -raw eksctl > eksctl.sh

# aws_iam_role_policy - terraform does not have a output module for 'arn', therefore the hack
sed -i 's/role/policy/g' eksctl.sh
sed -i 's/terraform-eks-demo-node/autoscaler-policy/g' eksctl.sh 
chmod +x eksctl.sh 
./eksctl.sh


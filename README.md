# EKS clutser automation with Node-Autoscaler
- Typical DevOps take home task! 
- Create a stateful application 
- Deploy it in Kubernetes
- Do you know IaC? Please use your fav IaC tool to automate. (Terraform - I mean just say it now!) 

So here is answer to all those questions!

## Create the file terraform.tfvars 
```
vim terraform.tfvars
```
Add the keys in this format
```
AWS_ACCESS_KEY="xxxx"
AWS_SECRET_KEY="xxxxxxxxxx"
```

## Terraform apply
```
terraform init
terraform apply
```

## Configure kubectl
```
terraform output -raw kubeconfig > ~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name terraform-eks-demo
```

## Configure config-map-auth-aws
```
terraform output -raw config-map-aws-auth > config-map-aws-auth.yaml # save output in
kubectl apply -f config-map-aws-auth.yaml
```

## See nodes coming up
```
kubectl get nodes
```



## Create autoscaler config as k8s resource 
https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

```
kubectl apply -f cluster-autoscaler-autodiscover.yaml

```
## Play around by creating Deployment and scale up to test

``` 
kubectl create -f stressload-deployment.yaml 
kubectl scale deployment application-cpu --replicas=5
kubectl get nodes -w
```

## Destroy
Make sure all the resources created by Kubernetes are removed (LoadBalancers, Security groups), and issue:
```
terraform destroy
```

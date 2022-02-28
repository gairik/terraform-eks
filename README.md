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
## Add autoscalaer configuration

## Create eksctl.sh for configuring autoscaler
``` 
eksctl utils associate-iam-oidc-provider --region=$region --cluster=terraform-eks-demo --approve
```

## Create autoscaler config as k8s resource 
https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

```
kubectl apply -f cluster-autoscaler-autodiscover.yaml

terraform output -raw eksctl > eksctl.sh

# aws_iam_role_policy - terraform does not have a output module for 'arn', therefore the hack
sed -i 's/role/policy/g' eksctl.sh
sed -i 's/terraform-eks-demo-node/autoscaler-policy/g' eksctl.sh 
chmod +x eksctl.sh 
./eksctl.sh
```
## Destroy
Make sure all the resources created by Kubernetes are removed (LoadBalancers, Security groups), and issue:
```
terraform destroy
```

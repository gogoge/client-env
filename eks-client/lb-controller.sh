CLUSTER_NAME=eks-lab
ACCOUNT_ID=515477624492
REGION=us-east-1

curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
	--policy-name AWSLoadBalancerControllerIAMPolicy \
	--policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider \
	--region=${REGION} \
	--cluster=${CLUSTER_NAME} \
	--approve
	
eksctl create iamserviceaccount \
	--cluster=${CLUSTER_NAME} \
	--namespace=kube-system \
	--name=aws-load-balancer-controller \
	--attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
	--approve
	

helm repo add eks https://aws.github.io/eks-charts
	
helm install aws-load-balancer-controller \
	eks/aws-load-balancer-controller \
	-n kube-system \
	--set clusterName=eks-lab \
	--set serviceAccount.create=false \
	--set serviceAccount.name=aws-load-balancer-controller


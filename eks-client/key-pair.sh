aws ec2 create-key-pair --key-name eks-node --query 'KeyMaterial' --output text > eks-node.pem
sudo chmod 400 eks-node.pem


clear
sudo apt update -y
sudo apt remove awscli -y
sudo apt update
sudo apt install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
aws --version
eksctl version
kubectl version --client
aws configure
whoami
eksctl create cluster   --name prod-cluster   --region us-east-1   --version 1.29   --nodegroup-name prod-nodes   --node-type m7i-flex.large \ 
kubectl get nodes
aws eks describe-cluster   --name prod-cluster   --region us-east-1   --query "cluster.resourcesVpcConfig.vpcId"   --output text
aws ec2 describe-subnets   --filters "Name=vpc-id,Values=vpc-019f2cc18c8097d40"   --query "Subnets[*].{SubnetId:SubnetId,MapPublic:MapPublicIpOnLaunch,AZ:AvailabilityZone}"   --output table
aws rds create-db-subnet-group   --db-subnet-group-name prod-rds-subnet-group   --db-subnet-group-description "Prod RDS subnet group for EKS"   --subnet-ids subnet-02c0ed46b46c12a75 subnet-0d22bea907af77ae1
aws ec2 describe-security-groups   --filters Name=group-name,Values="*eks*"   --query "SecurityGroups[*].{ID:GroupId,Name:GroupName}"   --output table
aws ec2 create-security-group   --group-name prod-rds-sg   --description "Allow MySQL from EKS nodes only"   --vpc-id vpc-019f2cc18c8097d40
aws ec2 authorize-security-group-ingress   --group-id sg-044a4398d1a997f6f   --protocol tcp   --port 3306   --source-group sg-06446c7b5f3cf29b6
aws rds create-db-instance   --db-instance-identifier prod-mysql   --engine mysql   --engine-version 8.0   --db-instance-class db.m7i-flex.large   --allocated-storage 20   --storage-type gp3   --master-username admin   --master-user-password StrongPassword123!   --vpc-security-group-ids sg-044a4398d1a997f6f   --db-subnet-group-name prod-rds-subnet-group   --multi-az false   --no-publicly-accessible   --region us-east-1
aws rds create-db-instance   --db-instance-identifier prod-mysql   --engine mysql   --engine-version 8.0   --db-instance-class db.m7i-flex.large   --allocated-storage 20   --storage-type gp3   --master-username admin   --master-user-password StrongPassword123!   --vpc-security-group-ids sg-044a4398d1a997f6f   --db-subnet-group-name prod-rds-subnet-group   --no-multi-az   --no-publicly-accessible   --region us-east-1
aws rds create-db-instance   --db-instance-identifier prod-mysql   --engine mysql   --engine-version 8.0   --db-instance-class db.t3.small \ 
aws rds create-db-instance   --db-instance-identifier prod-mysql   --engine mysql   --engine-version 8.0   --db-instance-class db.t3.small   --allocated-storage 20   --storage-type gp3   --master-username admin   --master-user-password StrongPassword123!   --vpc-security-group-ids sg-044a4398d1a997f6f   --db-subnet-group-name prod-rds-subnet-group   --no-multi-az   --no-publicly-accessible   --region us-east-1
aws rds create-db-instance   --db-instance-identifier prod-mysql   --engine mysql   --engine-version 8.0   --db-instance-class db.t2.micro   --allocated-storage 20   --storage-type gp3   --master-username admin   --master-user-password StrongPassword123!   --vpc-security-group-ids sg-044a4398d1a997f6f   --db-subnet-group-name prod-rds-subnet-group   --no-multi-az   --no-publicly-accessible   --region us-east-1
aws rds describe-db-instances   --db-instance-identifier prod-mysql   --query "DBInstances[0].DBInstanceStatus"
aws rds describe-db-instances   --db-instance-identifier prod-mysql   --query "DBInstances[0].Endpoint.Address"   --output text
aws secretsmanager create-secret   --name prod/mysql   --description "Production MySQL credentials for backend"   --secret-string '{
    "DB_HOST": "prod-mysql.cc7siem6uuf1.us-east-1.rds.amazonaws.com",
    "DB_PORT": "3306",
    "DB_NAME": "appdb",
    "DB_USER": "admin",
    "DB_PASSWORD": "StrongPassword123!"
  }'
helm --version
sudo apyt install helm
sudo apt install helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
aws rds describe-db-instances   --db-instance-identifier prod-mysql   --query "DBInstances[0].Endpoint.Address"   --output text
kubectl create namespace external-secrets
helm install external-secrets external-secrets/external-secrets   -n external-secrets   --set installCRDs=true
kubectl get pods -n external-secrets
aws eks describe-cluster   --name prod-cluster   --query "cluster.identity.oidc.issuer"   --output text
vi trust-policy.json
aws iam create-role   --role-name ExternalSecretsRole   --assume-role-policy-document file://trust-policy.json
vi secrets-policy.json
cat secrets-policy.json
aws iam put-role-policy   --role-name ExternalSecretsRole   --policy-name ExternalSecretsPolicy   --policy-document file://secrets-policy.json
kubectl create namespace prod
kubectl create serviceaccount external-secrets -n prod
kubectl annotate serviceaccount external-secrets   -n prod   eks.amazonaws.com/role-arn=arn:aws:iam::708037417213:role/ExternalSecretsRole
vi secretstore.yaml
kubectl apply -f secretstore.yaml
kubectl get secretstore -n prod
kubectl get sa external-secrets -n external-secrets -o yaml | grep eks.amazonaws.com
kubectl annotate serviceaccount external-secrets   -n external-secrets   eks.amazonaws.com/role-arn=arn:aws:iam::708037417213:role/ExternalSecretsRole   --overwrite
kubectl rollout restart deployment external-secrets -n external-secrets
kubectl get secretstore -n prod
kubectl get sa external-secrets -n external-secrets -o yaml | grep eks.amazonaws.com
kubectl get secretstore -n prod
clear
kubectl get secretstore -n prod
aws iam get-role --role-name ExternalSecretsRole
kubectl get secretstore aws-secretsmanager -n prod -o yaml
ls
vi trust-policy.json
aws iam update-assume-role-policy   --role-name ExternalSecretsRole   --policy-document file://trust-policy.json
kubectl rollout restart deployment external-secrets -n external-secrets
kubectl get secretstore -n prod
cat trust-policy.json
kubectl get secretstore -n prod
aws iam list-open-id-connect-providers
eksctl utils associate-iam-oidc-provider   --region us-east-1   --cluster prod-cluster \ 
eksctl utils associate-iam-oidc-provider   --region us-east-1   --cluster prod-cluster --approve 
aws iam list-open-id-connect-providers
kubectl rollout restart deployment external-secrets -n external-secrets
kubectl get secretstore -n prod
ls
vi secretstore.yaml
kubectl delete secretstore aws-secretsmanager -n prod
kubectl delete sa external-secrets -n prod
kubectl create serviceaccount external-secrets -n prod
kubectl annotate serviceaccount external-secrets   -n prod   eks.amazonaws.com/role-arn=arn:aws:iam::708037417213:role/ExternalSecretsRole
kubectl get sa external-secrets -n prod -o yaml | grep role-arn
ls
vi secretstore.yaml
kubectl apply -f secretstore.yaml
kubectl get secretstore -n prod
kubectl get pods -n external-secrets -o wide
kubectl describe pod -n external-secrets -l app.kubernetes.io/name=external-secrets | grep -i serviceaccount
kubectl get sa external-secrets -n prod -o yaml | grep role-arn -A2
aws iam get-role --role-name ExternalSecretsRole
aws iam get-role --role-name ExternalSecretsRole --query "Role.AssumeRolePolicyDocument"
ls
vi trust-policy.json
aws iam update-assume-role-policy   --role-name ExternalSecretsRole   --policy-document file://trust-policy.json
kubectl rollout restart deployment external-secrets -n external-secrets
kubectl get secretstore -n prod
ls
vi externalsecret.yaml
kubectl apply -f externalsecret.yaml
kubectl get crd | grep external
kubectl get crd | grep secrets
kubectl apply -f externalsecret.yaml
kubectl api-resources | grep -i externalsecret
ls
viexternalsecret.yaml
vi externalsecret.yaml
kubectl apply -f externalsecret.yaml
kubectl get pods externalsecret
kubectl get externalsecrets
kubectl get externalsecret
kubectl get externalsecret -n prod
ls
ls -lrt
cat externalsecret.yaml
kubectl describe externalsecret mysql-prod-secret -n prod
ls
vi externalsecret.yaml
kubectl apply -f externalsecret.yaml
kubectl get externalsecret -n prod
vi backend.yaml
kubectl apply -f backend.yaml
kubectl get pods -n prod
vi backend-service.yaml
kubectl apply -f backend-service.yaml
kubectl gets svc
kubectl get svc
kubectl get svc -A
kubectl run test --rm -it   --image=curlimages/curl   -n prod -- sh
kubectl exec -n prod deploy/backend -it -- env | grep DB_
kubectl exec -n prod deploy/backend -it -- apt update && apt install -y netcat
sudo su -
kubectl logs -n prod deploy/backend --tail=100
kubectl exec -n prod deploy/backend -it -- env | grep DB_
kubectl exec -n prod deploy/backend -it -- sh
kubectl run test --rm -it   --image=curlimages/curl   -n prod -- sh

# !/bin/bash
# 1. 建立所有必要的資料夾
mkdir -p .github/workflows \
infra-terraform/management \
infra-terraform/modules/networking-vpc \
infra-terraform/modules/compute-jenkins \
infra-terraform/modules/cluster-eks \
infra-terraform/modules/container-registry \
infra-terraform/modules/dns-route53 \
infra-terraform/environments/dev \
ansible-automation/inventory \
ansible-automation/roles/docker-setup/tasks \
ansible-automation/roles/jenkins-init/tasks \
docker/app/2135_mini_finance \
kubernetes-manifests/deployments \
kubernetes-manifests/services \
kubernetes-manifests/ingress \
scripts

# 2. 建立所有核心檔案 (初始為空檔案)
touch infra-terraform/management/main.tf \
infra-terraform/management/outputs.tf \
infra-terraform/environments/dev/main.tf \
infra-terraform/environments/dev/variables.tf \
infra-terraform/environments/dev/terraform.tfvars \
infra-terraform/environments/dev/outputs.tf \
ansible-automation/inventory/hosts.ini \
ansible-automation/site.yml \
docker/app/Dockerfile \
kubernetes-manifests/deployments/web-deploy.yaml \
kubernetes-manifests/deployments/web-hpa.yaml \
kubernetes-manifests/services/web-service.yaml \
kubernetes-manifests/ingress/web-ingress.yaml \
scripts/scaling-test.sh \
Jenkinsfile .gitignore README.md LICENSE
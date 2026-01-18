pipeline {
    agent any
    
    environment {
        // 請確保這裡換成你 Terraform 輸出的實際 ECR 網址
        ECR_REGISTRY = "514015205949.dkr.ecr.us-east-1.amazonaws.com"
        REPO_NAME    = "mini-finance-app"
        IMAGE_TAG    = "${env.BUILD_NUMBER}"
        AWS_REGION   = "us-east-1"
    }

    stages {
        stage('Checkout') {
            steps {
                // 確保分支名稱正確
                git branch: 'dev', url: 'https://github.com/jamesstop1201/DevopsFlow.git'
            }
        }

        stage('Docker Login') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
            }
        }

        stage('Build & Push Image') {
            steps {
                script{ 
                    dir('docker/app'){
                        // 打包你的 Nginx 鏡像
                        sh "docker build -t ${REPO_NAME}:${IMAGE_TAG} -f Dockerfile ."

                        // 標記並推送到 ECR
                        sh "docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${REPO_NAME}:${IMAGE_TAG}"
                        sh "docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${REPO_NAME}:latest"

                        sh "docker push ${ECR_REGISTRY}/${REPO_NAME}:${IMAGE_TAG}"
                        sh "docker push ${ECR_REGISTRY}/${REPO_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    // 修正 Jenkins 帳號的 kubeconfig 格式
                    sh "aws eks update-kubeconfig --region us-east-1 --name mini-finance-cluster"
                    sh "sed -i 's/v1alpha1/v1beta1/g' ~/.kube/config"
                    
                    // 替換變數並部署
                    sh "kubectl apply -f kubernetes-manifests/deployments/web-deploy.yaml"
                    sh "kubectl set image deployment/mini-finance-deploy mini-finance=${env.IMAGE_URI}"
                    sh "kubectl rollout status deployment/mini-finance-deploy"
                    }
            }
        }
    }
}
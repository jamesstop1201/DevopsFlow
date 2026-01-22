pipeline {
    agent any
    
    environment {
        ECR_REGISTRY = "514015205949.dkr.ecr.us-east-1.amazonaws.com"
        REPO_NAME    = "mini-finance-app"
        AWS_REGION   = "us-east-1"
    }

    stages {
        stage('Checkout') {
            steps {
                // 使用 checkout scm 自動抓取觸發的分支 (main 或 dev)
                checkout scm
            }
        }

        stage('Docker Login') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
            }
        }

        stage('Build & Push Image') {
            steps {
                script { 
                    dir('docker/app'){
                        def branch = env.BRANCH_NAME ?: "unknown"
                        echo "偵測到目前分支為: ${branch}"
                        if (branch == 'main') {
                            env.DEPLOY_TAG = "v-${env.BUILD_NUMBER}"
                            echo "執行 Main 分支流程: Tag 為 ${env.DEPLOY_TAG} 並更新 latest"
                    
                            sh "docker build -t ${REPO_NAME}:${env.DEPLOY_TAG} ."
                            sh "docker tag ${REPO_NAME}:${env.DEPLOY_TAG} ${ECR_REGISTRY}/${REPO_NAME}:${env.DEPLOY_TAG}"
                            sh "docker tag ${REPO_NAME}:${env.DEPLOY_TAG} ${ECR_REGISTRY}/${REPO_NAME}:latest"

                            sh "docker push ${ECR_REGISTRY}/${REPO_NAME}:${env.DEPLOY_TAG}"
                            sh "docker push ${ECR_REGISTRY}/${REPO_NAME}:latest"
                        }
                        else if (branch == 'dev') {
                            def devTag = "dev-${env.BUILD_NUMBER}"
                            echo "執行 Dev 分支流程: 僅 Tag 為 ${devTag}"
                    
                            sh "docker build -t ${REPO_NAME}:${devTag} ."
                            sh "docker tag ${REPO_NAME}:${devTag} ${ECR_REGISTRY}/${REPO_NAME}:${devTag}"

                            sh "docker push ${ECR_REGISTRY}/${REPO_NAME}:${devTag}"
                        } 
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def fullImageUri = "${env.ECR_REGISTRY}/${env.REPO_NAME}:${env.DEPLOY_TAG}"
                    echo "Debug: 正在部署正式環境 (Main Branch)..."
                    echo "使用影像: ${fullImageUri}"
                    
                    // 套用 K8s 設定
                    sh "kubectl apply -f kubernetes-manifests/deployments/web-deploy.yaml"
                    
                    // 滾動更新 Image
                    sh "kubectl set image deployment/mini-finance-deploy mini-finance=${fullImageUri}"
                    
                    // 等待部署完成
                    sh "kubectl rollout status deployment/mini-finance-deploy"

                    // 啟動 service
                    sh "kubectl apply -f kubernetes-manifests/services/web-svc.yaml"
                }
            }
        }
    }
}
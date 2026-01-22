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
                        // 重新定義邏輯
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


                        // // 區分 dev 和 main 的 Tag，防止覆蓋 latest
                        // def isMainBranch = (env.BRANCH_NAME == 'main')
                        
                        // // 設定 Tag 名稱：main 用 v-123, dev 用 dev-123
                        // def currentTag = isMainBranch ? "v-${env.BUILD_NUMBER}" : "dev-${env.BUILD_NUMBER}"
                        
                        // echo "目前分支: ${env.BRANCH_NAME}, 準備建置 Tag: ${currentTag}"

                        // // 1. 建置 Docker Image
                        // sh "docker build -t ${REPO_NAME}:${currentTag} -f Dockerfile ."

                        // // 2. 推送帶有版號的 Image (dev 和 main 都會推這個)
                        // sh "docker tag ${REPO_NAME}:${currentTag} ${ECR_REGISTRY}/${REPO_NAME}:${currentTag}"
                        // sh "docker push ${ECR_REGISTRY}/${REPO_NAME}:${currentTag}"

                        // // 3. 只有 main 分支才更新 'latest' 標籤
                        // if (isMainBranch) {
                        //     echo "這是 main 分支，更新 latest 標籤..."
                        //     sh "docker tag ${REPO_NAME}:${currentTag} ${ECR_REGISTRY}/${REPO_NAME}:latest"
                        //     sh "docker push ${ECR_REGISTRY}/${REPO_NAME}:latest"
                        // } else {
                        //     echo "這是 dev 分支，跳過推送 latest 標籤。"
                        // }
                        
                        // // 將 Tag 存入環境變數供後續 Deploy 使用
                        // env.DEPLOY_TAG = currentTag
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            // 【修改 3】核心需求：只有 main 分支才執行部署
            when {
                branch 'main'
            }
            steps {
                script {
                    def fullImageUri = "${env.ECR_REGISTRY}/${env.REPO_NAME}:${env.DEPLOY_TAG}"
                    echo "Debug: 正在部署正式環境 (Main Branch)..."
                    echo "使用影像: ${fullImageUri}"
                    
                    // 修正 Jenkins 帳號的 kubeconfig
                    sh "aws eks update-kubeconfig --region us-east-1 --name mini-finance-cluster"
                    // 確保 API 版本相容性
                    sh "sed -i 's/v1alpha1/v1beta1/g' ~/.kube/config"
                    
                    // 套用 K8s 設定
                    sh "kubectl apply -f kubernetes-manifests/deployments/web-deploy.yaml"
                    
                    // 滾動更新 Image
                    sh "kubectl set image deployment/mini-finance-deploy mini-finance=${fullImageUri}"
                    
                    // 等待部署完成
                    sh "kubectl rollout status deployment/mini-finance-deploy"
                }
            }
        }
    }
}
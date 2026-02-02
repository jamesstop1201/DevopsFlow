# DevOps Lifecycle實作


## 📖 專案簡介 (Introduction)
這是一個展示完整 DevOps Lifecycle 的專案。
透過 Infrastructure as Code (IaC) 與 CI/CD 流水線，在 AWS EKS 上構建一個具備高可用性、自動擴展與負載均衡能力的靜態網頁託管環境，展示了**從基礎設施到應用部署的完整 DevOps 實踐**。

---
## 🏗️ 系統架構 (System Architecture)

### 雲端基礎設施 (Cloud Infrastructure)

``` mermaid 
flowchart LR
 subgraph STAGE_1["1. CI Build 持續整合"]
    direction TB
        Git["GitHub"]
        Dev["Dev"]
        Jen["Jenkins"]
        ECR[("Amazon ECR")]
  end
 subgraph STAGE_2["2. CD Deploy 持續部署"]
    direction TB
        EKS_API["EKS"]
        Deploy["部署控制器 Deployment"]
  end
 subgraph STAGE_3["3. Runtime & Traffic 運行監控"]
    direction TB
        Pods["應用程式容器 Pods"]
        ALB["AWS ALB 負載平衡"]
        HPA["自動伸縮 HPA"]
        Metrics["Metrics"]
  end
    Dev -- Git Push --> Git
    Git -. 自動觸發 Webhook .-> Jen
    Jen -- Build & Push --> ECR
    Jen -- 部署指令 kubectl apply --> EKS_API
    EKS_API --> Deploy
    Deploy -- Pull Image --> ECR
    ALB -- 轉發流量 Forward --> Pods
    HPA -- 動態增減 Auto Scale --> Deploy
    Metrics -. 數據監控 Monitor .-> HPA
    Deploy --> Pods
    Ingress["路由規則 Ingress"] -. 自動建立 Provision .-> ALB

     ECR:::storage
    classDef build fill:#f9f9f9,stroke:#666,stroke-width:2px
    classDef storage fill:#fff5e6,stroke:#FF9900,stroke-width:2px
    classDef cluster fill:#f0f7ff,stroke:#326CE5,stroke-width:2px
    classDef traffic fill:#e6fffa,stroke:#00b5ad,stroke-width:2px
```

> **架構說明**：
> 本循環採用 **AWS EKS** 為核心，整合外部 DNS 與 CI/CD 自動化流程。
> 架構邏輯分為以下三個部分：
> #### 1. 🌐 流量存取與路由 (Traffic Flow)
> 使用者的請求透過以下路徑進入系統，確保高可用性與安全性：
> * **負載平衡**：Route 53 將流量導向 **AWS Application Load Balancer (ALB)**。此 ALB 是由 K8s 內部的 **AWS Load Balancer Controller** 根據 Ingress 規則自動佈建與管理。
> * **服務轉發**：ALB 根據路由規則將請求分發至 EKS Cluster 內的 **Application Pods** 進行處理。
> 
> #### 2. 🔄 CI/CD 自動化部署 (Continuous Deployment)
> 從程式碼提交到上線，實現全自動化：
> * 開發者推送到 **Git Repository** 後自動觸發 **Jenkins**。
> * **Build & Push**：Jenkins 建置 Docker Image 並推送至 **Amazon ECR**。
> * **Deploy**：Jenkins 透過 `kubectl` 指令與 **EKS API Server** 溝通，更新 Deployment 設定，觸發 Cluster 下載最新的 Image 並重啟 Pods。
>
> #### 3. 📈 彈性擴展與自動化管理 (Auto-scaling & Orchestration)
> 為了應對流量波動，系統實作了自動擴展機制：
> * **Metrics Server** 持續蒐集 Pods 的資源使用數據 (如 CPU/Memory)。
> * **HPA (Horizontal Pod Autoscaler)** 根據監測到的數據判斷負載。當 CPU 使用率超過設定閾值時，自動通知 Deployment 增加 Pod 的副本數 (Replicas)，反之則縮減，實現真正的雲端彈性。

---

## 🛠️ 技術堆疊 (Tech Stack)

| 領域 | 工具 | 專案中的具體實作與亮點 (Highlights) |
| :--- | :--- | :--- |
| **Cloud** | **AWS** | 採用生產級架構，規劃 **VPC 公私有子網**。EKS 叢集部署於私有子網，僅透過 NAT Gateway 連網。 |
| **IaC** | **Terraform** | **基礎設施即程式碼**。從零開始佈建 VPC、EKS、ECR 及節點，並實作 State Locking 與 S3 儲存，確保環境一致性。 |
| **Config** | **Ansible** | **自動化環境配置**。自動安裝 Jenkins 依賴，並自動處理 `kubeconfig` 權限轉移，解決 CI Server 存取 K8s 的痛點。 |
| **Container** | **Docker** | **映像檔最佳化**。使用 Multi-stage Builds 技術，分離編譯與執行環境，顯著縮小 Image 體積並提升安全性。 |
| **K8s** | **EKS** | **微服務調度**。解決 Pod 與 AWS 資源整合問題（如 ALB Controller），並配置 HPA 應對流量。 |
| **CI/CD** | **Jenkins** | **全自動流水線**。撰寫 `Jenkinsfile` 串聯 Build、Push 到 Deploy 流程，實現 Code Commit 即部署的 GitOps 體驗。 |

---

## 🚀 核心功能與亮點 (Key Features)
* **1. 基礎設施全自動化 (Infrastructure as Code)**
    * 使用 Terraform 從零打造包含 VPC、Subnet 到 EKS 叢集的全套雲端環境，實現了「**一行指令建立整個雲端機房**」的可重複性與穩定性。

* **2. 環境與權限自動配置 (Auto-Configuration)**
    * 解決了手動設定伺服器最容易出錯的依賴問題。利用 Ansible 「**自動安裝所需套件，並自動處理 Jenkins 與 EKS 之間的權限認證**」 (kubeconfig)，讓 CI Server 能順暢地控制 K8s 叢集。

* **3. Pipeline分流策略 (Multi-Branch Strategy)**
    * 設計了多條 Pipeline 規則，將「開發分支 (Dev)」與「主線分支 (Main)」的流程完全隔離。這確保了測試階段的 Image 不會意外覆蓋掉生產環境的版本，避免了多人協作時常見的衝突。

* **4. 端到端持續交付 (End-to-End Delivery)**
    * 實現「Code Push 即上線」的自動化閉環。一旦偵測到新版本，系統自動接手後續所有工作：從 Docker Image 打包、上傳 ECR、更新 EKS Deployment 到重啟服務。

---

## 💻 快速開始 (Getting Started)

### 前置需求 (Prerequisites)

在開始部署之前，請確保你的執行環境 (Local Machine) 已安裝以下工具，並具備適當的雲端權限。

---

#### 1. 本地工具 (Local CLI Tools)
* 本專案依賴以下工具進行自動化佈建，請確保版本符合要求：

| 工具 | 最低版本要求 | 用途說明 |
| :--- | :--- | :--- |

---

#### 2. 帳號與權限 (Accounts & Credentials)

---

#### 3. 環境變數設定 (Configuration)

---

## ⚡ 快速部署步驟 (Deployment Steps)

### Step 1: 專案初始化 (Clone & Init)
首先將專案下載至本地，並進入專案目錄。

```bash
git clone https://github.com/jamesstop1201/DevopsFlow.git
cd DevopsFlow
```

### Step 2：佈建雲端基礎設施（Terraform）

#### 2-1. 建立 Terraform Backend（S3 Bucket）

目的：集中且安全地管理 Terraform state。

```bash
cd infra-terraform/management
terraform init
terraform plan
terraform apply -auto-approve
```

**重要動作：**

* Terraform 執行完成後，終端機會輸出一組 `bucket_name`，請複製該名稱
* 編輯檔案 `infra-terraform/environments/dev/main.tf`
* 將 bucket 名稱填入下列設定後，再進行下一步
```hcl
bucket = "<your_bucket_name>"
```

---

#### 2-2. 佈建主要基礎設施（VPC / EKS / EC2）

此步驟會建立 Jenkins Server 與 Kubernetes（EKS）叢集。

```bash
cd ../../infra-terraform/environments
terraform init
terraform plan
terraform apply -auto-approve
```

Terraform 執行完成後，請記下以下輸出資訊（後續步驟會使用）：

* `jenkins_server_public_ip`：Jenkins Server 公網 IP

---

### Step 3：自動化環境配置（Ansible）

#### 3-1. 前置準備（Windows 使用者）

Windows 原生不支援 Ansible，請使用 **WSL（Ubuntu）** 執行以下指令。

```bash
sudo apt update && sudo apt install ansible -y
ansible --version
```

確認能正常顯示版本號，即表示安裝成功。

---
#### 3-2. 更新 Inventory 設定

編輯檔案：

```
ansible-automation/inventory/hosts.ini
```

將 `[jenkins_server]` 底下的 IP，替換為 Terraform 輸出的 `jenkins_server_public_ip`。

---

#### 3-3. 執行 Playbook

進入 Ansible 目錄並開始安裝 Jenkins 與相關依賴。

```bash
cd ansible-automation
ansible-playbook -i inventory/hosts.ini site.yaml
```

若執行過程中沒有出現 `ERROR`，即代表安裝成功。

---

### Step 4：驗證安裝結果（Verification）

#### 4-1. SSH 登入 Jenkins Server

```bash
ssh -i "key.pem" ubuntu@<jenkins_server_public_ip>
```

---

#### 4-2. 驗證指令

```bash
sudo -u jenkins kubectl --version
sudo -u ubuntu kubectl --version
docker ps
```

---

#### 成功標準

* `kubectl --version` 能正常顯示版本號
* `docker ps` 能正常執行（即使沒有容器）
* 未出現 `Forbidden`、`Config not found` 等權限或設定錯誤

符合以上條件，即代表自動化環境建置完成。

---

### Step 5: 設定 Jenkins (Jenkins Setup)

最後，我們需要登入 Jenkins 網頁介面完成初始化設定，並建立第一條流水線。

#### 5-1. 取得初始管理員密碼 (Unlock Jenkins)
在本地終端機執行以下指令，直接從遠端抓取解鎖密碼：

```bash
# 請將 <key.pem> 與 <jenkins_ip> 替換為實際值
ssh -i "key.pem" ubuntu@<jenkins_server_public_ip> "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
複製終端機顯示的那串亂碼密碼。
```

#### 5-2. 網頁初始化 (Web Config)
1. 開啟瀏覽器，前往：http://<jenkins_server_public_ip>:8080

2. 貼上剛剛複製的密碼。

3. 點選 "Install suggested plugins" (安裝建議套件)，等待安裝完成。

4. Create Admin User: 設定你的個人帳號密碼 (Admin User)。

5. 設定完成後，點擊 "Save and Finish" 進入 Jenkins 主頁。
   
#### 5-3. github 建立 webhook
1. 專案-Settings-Webhooks-Add webhook
2. Payload URL 輸入： http://<你的-Jenkins-EC2-公有IP>:8080/github-webhook/
3. Content type: 選擇 application/json
4. Secret: 保持空白
5. Active: 勾選
   
#### 5-4. 建立 Multibranch Pipeline
***為了支援多分支開發 (Git Flow)，我們將建立一個多分支流水線。***

1. 點擊左側選單的 "New Item" (新增作業)。

2. 輸入專案名稱 mini-fiance-ci。

3. 選擇 "Multibranch Pipeline" (多分支流水線)，並點擊 OK。

4. Branch Sources (分支來源):

* 點選 "Add source" -> 選擇 "GitHub"。

* Repository HTTPS URL: 貼上本專案的 GitHub URL (例如: https://github.com/jamesstop1201/DevopsFlow.git)。

5. 點擊 "Save" (儲存)。
   * Save 之後預設會在每個branch 跑一次 Jenkinsfile ，可以在 jenkins網頁上看到跑的結果及LOG
  **自動觸發: 儲存後，Jenkins 會自動掃描該 Repo 的所有分支。如果偵測到 `Jenkinsfile`，它就會自動觸發第一次 Build。**

---

### Step 6: 觸發流水線 (Trigger Pipeline)

1. 本專案採用 **Git Flow** 分流策略，不同分支對應不同的流水線行為：
   
   * **`dev` 分支 (CI Only)**：僅執行建置 (Build) 與測試，並將 Docker Image 推送到 ECR，**不會**部署到 EKS。
   * **`main` 分支 (CI + CD)**：完整流程。除了推送 ECR 之外，會包含 **Deploy** 階段，將靜態網頁平台正式部署至 EKS 叢集。

2. 若要驗證應用程式是否成功上線至 K8s，請確保程式碼已推送到 `main` 分支：

```bash
# 1. 切換至 main 分支
git checkout main

# 2. 隨意修改一個檔案或合併 dev 分支
# (例如：git merge dev)

# 3. 推送至 GitHub (這將觸發 Jenkins 的 Deploy 邏輯)
git push origin main
```

3. 回到 Jenkins Dashboard，你會看到 `main` 分支的 Pipeline 開始執行，並在最後多出一個 **Deploy** 階段。待執行顯示綠燈後，即可透過 Load Balancer URL 存取網頁。

#### 取得Load Balancer URL

執行指令：

```bash
kubectl get svc mini-finance-service
```
輸出範例：
```hcl

NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP                                            PORT(S)        AGE
mini-finance-service   LoadBalancer   10.100.200.50   xxxxxx.us-east-1.elb.amazonaws.com   80:31234/TCP   5m
這裡的 EXTERNAL-IP 就是你的 Load Balancer URL。
```

---

## 🧹 專案清理 (Clean Up)

為了避免產生額外的 AWS 費用，測試完畢後請務必依照以下順序銷毀資源。

### Step 1: 清除應用層資源 (Jenkins Server)
請先 SSH 進入 **Jenkins Server**，執行以下指令來清空 Kubernetes 資源與 ECR 映像檔。
*(這是為了防止 Terraform 因 ECR 非空或 Load Balancer 未釋放而導致銷毀失敗)*

```bash
# 1. SSH 進入 Jenkins Server
ssh -i "your-key.pem" ubuntu@<jenkins_ip>

# 刪除 K8s 內的服務與負載平衡器 (這會觸發 AWS 刪除 ALB)
kubectl delete svc --all

# 刪除所有部署與相關資源
kubectl delete pvc,deployments,statefulsets,daemonsets,jobs --all

# 強制清空 ECR 內的所有 Images (Terraform 無法刪除有內容的 Repo)
aws ecr batch-delete-image \
    --repository-name mini-finance-ecr \
    --image-ids "$(aws ecr list-images --repository-name mini-finance-ecr --query 'imageIds[*]' --output json)"
```

### Step 2: 銷毀雲端基礎設施 (Local Machine)
回到你的本機電腦，依照順序由外而內銷毀基礎設施。

1. 銷毀主要環境 (EKS, VPC, EC2)

```Bash
cd infra-terraform/environments/dev
terraform destroy -auto-approve
```
2. 銷毀狀態管理後端 (S3 Bucket) (注意：執行此步驟後，Terraform State 將會遺失)

```Bash
cd ../../infra-terraform/management
terraform destroy -auto-approve
⚠️ 注意： terraform destroy 執行時間較長 (約 15-20 分鐘)，請勿中斷終端機連線，直到出現 Destroy complete! 訊息為止。
```
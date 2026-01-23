# DevOps Lifecycle實作


## 📖 專案簡介 (Introduction)
這是一個展示完整 DevOps Lifecycle 的專案。本專案透過 Infrastructure as Code (IaC) 與 CI/CD 流水線，在 AWS EKS 上構建一個具備高可用性、自動擴展與負載均衡能力的靜態網頁託管環境，展示了**從基礎設施到應用部署的完整 DevOps 實踐**。

---
## 🏗️ 系統架構 (System Architecture)

### 雲端基礎設施 (Cloud Infrastructure)

``` mermaid 
graph TD
    %% --- 樣式定義區 ---
    %% AWS Core: 橘底白字
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#fff;
    %% K8s Core: 藍底白字
    classDef k8s fill:#326CE5,stroke:#fff,stroke-width:1px,color:#fff;
    %% CI/CD: 灰色底
    classDef cicd fill:#666,stroke:#fff,stroke-width:1px,color:#fff;
    %% External: 白底黑字 (在深色模式也會強制顯示白底以保持清晰)
    classDef ext fill:#ffffff,stroke:#333,stroke-width:1px,color:#333;

    %% --- 外部角色 ---
    Dev[Developer] -->|Git Push| Git[GitHub]
    User((End User)) -->|HTTPS| GD[GoDaddy]

    Git -.->|Webhook| Jen

    subgraph CI_CD_Pipeline [CI/CD Tools]
        direction TB
        Jen[Jenkins Server]
    end

    %% --- AWS 雲端環境區塊 ---
    subgraph AWS_Cloud [AWS Cloud Environment]
        %% 使用 Hex Code 修正 rgba 錯誤，#fff5e6 是極淺橘色
        style AWS_Cloud fill:#fff5e6,stroke:#FF9900,stroke-width:2px,stroke-dasharray: 5 5
        
        ECR[(Amazon ECR)]
        
        %% EKS 叢集
        subgraph EKS_Cluster [Amazon EKS Cluster]
            %% #f0f7ff 是極淺藍色
            style EKS_Cluster fill:#f0f7ff,stroke:#326CE5,stroke-width:2px
            
            EKS_API[EKS API Server]
            Deploy[Deployment]
            Pods(Application Pods)
            
            Metrics[Metrics Server] -.-> HPA[HPA]
            HPA -->|Scale| Deploy
            Deploy -->|Replicas| Pods
            Ingress[Ingress Resource]
        end

        LBC[AWS LB Controller]
        ALB[Application Load Balancer]
        R53[Route 53]

        %% 互動線條
        Jen -->|1. Build & Push| ECR
        Jen -->|2. kubectl apply| EKS_API
        EKS_API --> Deploy
        EKS_API --> Ingress
        
        ECR -.->|Pull Image| Pods
        
        LBC -.->|Watch| Ingress
        LBC -->|Provision| ALB
        R53 -->|Alias Record| ALB
        ALB -->|Forward| Pods
    end

    GD -->|DNS| R53

    %% --- 應用樣式 ---
    class Dev,Git,GD,User ext;
    class Jen cicd;
    class ECR,ALB,R53,LBC aws;
    class EKS_API,Deploy,Pods,HPA,Ingress,Metrics k8s;
```

> **架構說明**：
> 本循環採用 **AWS EKS** 為核心，整合外部 DNS 與 CI/CD 自動化流程。
> 架構邏輯分為以下三個部分：
> #### 1. 🌐 流量存取與路由 (Traffic Flow)
> 使用者的請求透過以下路徑進入系統，確保高可用性與安全性：
> * **DNS 解析**：使用者存取 URL 時，首先經由 **GoDaddy** 解析，指引至 **AWS Route 53**。
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
    * 使用 Terraform 從零打造包含 VPC、Subnet 到 EKS 叢集的全套雲端環境，實現了「一行指令建立整個雲端機房」的可重複性與穩定性。

* **2. 環境與權限自動配置 (Auto-Configuration)**
    * 解決了手動設定伺服器最容易出錯的依賴問題。利用 Ansible 自動安裝所需套件，並自動處理 Jenkins 與 EKS 之間的權限認證 (kubeconfig)，讓 CI Server 能順暢地控制 K8s 叢集。

* **3. Pipeline分流策略 (Multi-Branch Strategy)**
    * 設計了多條 Pipeline 規則，將「開發分支 (Dev)」與「主線分支 (Main)」的流程完全隔離。這確保了測試階段的 Image 不會意外覆蓋掉生產環境的版本，避免了多人協作時常見的衝突。

* **4. 端到端持續交付 (End-to-End Delivery)**
    * 實現「Code Push 即上線」的自動化閉環。一旦偵測到新版本，系統自動接手後續所有工作：從 Docker Image 打包、上傳 ECR、更新 EKS Deployment 到重啟服務。


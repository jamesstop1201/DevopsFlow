# DevOpsFlow

## 專案說明
本專案以實際施行 DevOps 架構與交付流程為核心，工具選擇僅作為支撐自動化、可維運性與可擴展性的手段，而非展示工具數量。

## 自動化雲端架構 - 實施步驟說明
本專案依實務 DevOps 流程設計，從狀態管理、基礎設施撥備，到 CI/CD 與系統驗證，逐步建立自動化、可擴展的雲端架構。

---

### 階段 1：Bootstrap（Remote State 初始化）
- 使用 Terraform 建立 S3 Bucket 與 DynamoDB
- **重點：保持狀態一致性，避免多人或重複執行衝突**

### 階段 2：Infrastructure Provisioning（Terraform）
- 配置 Terraform Backend，建立 VPC、ECR、Jenkins EC2、EKS Cluster
- **重點：網路與資源分層，避免服務暴露於公網**

### 階段 3：Configuration Management（Ansible）
- Ansible 配置 Jenkins 節點，安裝 Docker、Jenkins、kubectl、aws-cli
- **重點：基礎設施與系統設定分離，降低耦合**

### 階段 4：Continuous Integration（CI）
- Jenkins Pipeline 負責 Build & Push Docker Image
- **重點：CI 專注產出可部署 Artifact**

### 階段 5：Deployment & Auto Scaling（CD / Kubernetes）
- Kubernetes Deployment 部署應用，多副本 + HPA + Ingress
- **重點：CD 與自動擴展由 Kubernetes 控制，而非 Pipeline**

### 階段 6：Domain & Access（Route 53）
- 設定 Route 53 網域 Alias 指向 ALB
- **重點：存取入口與底層部署解耦**

### 階段 7：Validation（SQE / SRE 視角）
- 驗證 Terraform Plan、HPA、Pod 自癒、Rolling Update
- **重點：系統行為符合預期，而非功能測試**

---

## 總結
**流程重點：架構責任劃分、自動化程度、系統穩定性驗證**  
工具以目前已學習的技術為主，非專案展示目的。

---

## 核心技術與工具

| 使用工具 | 說明 |
|---|---|
| AWS | 雲端基礎設施與受管服務平台 |
| Terraform | 基礎設施宣告式管理（IaC） |
| S3 + DynamoDB | Terraform Remote State 儲存與狀態鎖定 |
| Ansible | Jenkins 節點環境自動化配置 |
| Jenkins | 持續整合（Build / Package） |
| Docker | 應用程式容器化 |
| Amazon ECR | Docker Image 儲存與漏洞掃描 |
| Kubernetes (EKS) | 應用部署、自癒與自動擴展 |
| Kubernetes Deployment | Rolling Update 與版本發佈 |
| ALB + Ingress | 對外流量導入與負載平衡 |
| Route 53 | 網域名稱解析 |
| GitHub | 原始碼與 Pipeline 管理 |
| Scaling / Self-healing Test | 驗證高可用與系統穩定性 |

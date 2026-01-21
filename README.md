# DevopsFlow

**DevopsFlow** 是一個整合了 CI/CD 自動化流水線、基礎設施即程式碼 (IaC) 與容器化管理的 DevOps 實作專案。
本專案旨在展示如何將軟體開發流程（從程式碼提交到部署）進行全自動化，以解決手動部署耗時且易錯的問題，並實現高可用性的雲端架構。

##  專案簡介 (Introduction)

本專案實作了一套完整的 DevOps 解決方案，涵蓋以下核心能力：
- **持續整合/持續部署 (CI/CD)**：使用 Jenkins 建立自動化流水線。
- **容器化技術 (Containerization)**：利用 Docker 打包應用程式，確保環境一致性。
- **容器編排 (Orchestration)**：使用 Kubernetes (EKS) 進行叢集管理與服務部署。
- **基礎設施即程式碼 (IaC)**：透過 Terraform 自動化管理 AWS 雲端資源 (EC2, S3, VPC, EKS)。

本專案使用了以下工具與技術：

| 分類 | 工具/服務 | 用途 |
| --- | --- | --- |
| **CI/CD** | Jenkins, GitHub Actions | 自動化建置、測試與部署 |
| **環境配置** | Ansible | **伺服器環境配置、套件安裝與自動化維運** |
| **容器化** | Docker | 應用程式容器化 |
| **部屬管理** | Kubernetes (Amazon EKS) | 容器自動化部署與管理 |
| **IaC** | Terraform | AWS 基礎設施配置與狀態管理 |
| **Cloud** | AWS (EC2, S3, VPC, RDS, ALB) | 雲端運算資源 |
| **Scripting** | Bash Shell | 自動化腳本與工具 |
| **Version Control** | Git, GitHub | 程式碼版本控制 |

##  架構流程 (Architecture)

1.  **Code Commit**: 開發者將程式碼推送到 GitHub。
2.  **Build & Test**: Jenkins 觸發 Pipeline，執行單元測試與程式碼掃描。
3.  **Package**: 建置 Docker Image 並推送到 Image Registry (Docker Hub/ECR)。
4.  **Provision**: Terraform 檢查並更新 AWS 基礎設施 (EKS 叢集、網路配置等)。
5.  **Deploy**: 透過 `kubectl` 或 Helm 將應用程式部署至 K8s 叢集。
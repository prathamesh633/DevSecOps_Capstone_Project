# DevSecOps Capstone Project Architecture

Here is the high-level architecture diagram representing the continuous integration, continuous deployment, and multi-cloud infrastructure setup for this project.

The diagram is generated using Mermaid.js and renders natively on GitHub.

```mermaid
flowchart TD
    classDef section fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef workflow fill:#fff,stroke:#666,stroke-width:1px,color:#333;
    classDef tool fill:#e3f2fd,stroke:#1565c0,stroke-width:1px,color:#000;
    classDef aws fill:#fff7e6,stroke:#ff9900,stroke-width:2px,color:#232f3e;
    classDef azure fill:#eaf7ff,stroke:#00a4ef,stroke-width:2px,color:#000;
    classDef k8s fill:#f3e8fa,stroke:#326ce5,stroke-width:2px,color:#000;
    
    %% CI/CD Section
    subgraph CICD ["CI/CD Pipelines (GitHub Actions)"]
        direction LR
        
        subgraph SecPipelines ["Security Workflows"]
            direction TB
            SAST["SAST<br/>(SonarQube)"]:::tool
            SCA["SCA / Container Scan<br/>(Trivy)"]:::tool
            IaC["IaC Scan<br/>(Checkov, TFSec)"]:::tool
        end
        
        subgraph DeployInfra ["Deploy Infrastructure"]
            direction TB
            TF["Terraform<br/>Apply"]:::tool
            AWS_Prov["AWS<br/>Provider"]:::aws
            Azure_Prov["Azure<br/>Provider"]:::azure
            TF --> AWS_Prov
            TF --> Azure_Prov
        end
        
        subgraph DeployK8s ["Deploy Kubernetes"]
            direction TB
            KCTL["Kubectl<br/>Apply"]:::tool
            Deploy_Man["Manifests<br/>(Deployment, Service)"]:::k8s
            KCTL --> Deploy_Man
        end

    end

    %% Multi-Cloud Infrastructure Section
    subgraph MultiCloud ["Multi-Cloud Infrastructure"]
        direction LR
        
        subgraph AWS ["AWS Cloud"]
            direction TB
            VPC["AWS VPC"]:::aws
            S3["S3 Remote<br/>State Bucket"]:::aws
            EKS["Amazon EKS<br/>Cluster"]:::aws
            RDS["Amazon RDS<br/>(PostgreSQL)"]:::aws
            ECR["Amazon ECR"]:::aws
            
            VPC --- EKS
            VPC --- RDS
            VPC --- ECR
        end
        
        subgraph Azure ["Azure Cloud"]
            direction TB
            VNet["Azure VNet"]:::azure
            AKS["Azure AKS<br/>Cluster"]:::azure
            AZ_PG["Azure PostgreSQL<br/>Flexible Server"]:::azure
            ACR["Azure ACR"]:::azure
            
            VNet --- AKS
            VNet --- AZ_PG
            VNet --- ACR
        end
    end

    %% Kubernetes Environment Section
    subgraph Env ["Kubernetes Environment (EKS / AKS)"]
        direction LR
        FE["Frontend Web<br/>(React/Node.js)"]:::tool
        BE["Backend API<br/>(Python)"]:::tool
        DB[("Database<br/>(PostgreSQL)")]:::tool
        
        FE -->|REST API| BE
        BE -->|SQL Query| DB
    end

    %% Workflow Connections
    SecPipelines -->|Triggers on Success| DeployInfra
    DeployInfra -->|Provisions| MultiCloud
    SecPipelines -->|Triggers on Success| DeployK8s
    DeployK8s -->|Deploys to| EKS
    DeployK8s -->|Deploys to| AKS

    %% Infrastructure to Pods mapped connection
    EKS -.->|Hosts| Env
    AKS -.->|Hosts| Env
```

## Overview of Components

### 1. CI/CD (GitHub Actions Workflows)
- **Security Workflows:** Pipeline steps ensuring code and infrastructure are secure before deployment. We explicitly utilize Checkov and TFSec for IaC, Trivy for container and dependency scanning, and SonarQube for SAST.
- **Infrastructure Pipeline:** Terraform authenticates securely to AWS and Azure to provision the underlying networks, container registries, managed databases, and Kubernetes clusters.
- **Kubernetes Pipeline:** `kubectl` is utilized to apply `.yaml` manifests containing deployments, pods, and services to either of the provisioned Kubernetes clusters.

### 2. Multi-Cloud Infrastructure
- **AWS Components:** Virtual Private Cloud (VPC), S3 (for remote state management), Amazon Elastic Kubernetes Service (EKS) for container orchestration, Application Load Balancer (ALB), Amazon Elastic Container Registry (ECR), and Amazon Relational Database Service (RDS - PostgreSQL).
- **Azure Components:** Virtual Network (VNet), Azure Kubernetes Service (AKS), Azure Container Registry (ACR), and Azure PostgreSQL Flexible Server. 

### 3. Kubernetes Environment
- The application stack contains a scalable Frontend user interface (React/Node.js) communicating with a Backend API service (Python). Both services connect accurately to the designated backend PostgreSQL database (which can be hosted as a container inside the cluster *or* routed to the managed AWS RDS/Azure PostgreSQL instances depending on the environment configuration).

import base64
import zlib
import urllib.request
import os

mermaid_code = """graph TD
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef github fill:#181717,stroke:#fff,stroke-width:2px,color:#fff;
    classDef scan fill:#f39c12,stroke:#fff,stroke-width:2px,color:#fff;
    classDef build fill:#2980b9,stroke:#fff,stroke-width:2px,color:#fff;
    classDef deploy fill:#27ae60,stroke:#fff,stroke-width:2px,color:#fff;
    classDef cloud fill:#FF9900,stroke:#fff,stroke-width:2px,color:#fff;
    
    Dev([👨‍💻 Developer]) --> |Push Code| Repo(GitHub Repository):::github
    Repo --> |Trigger| CI(⚙️ GitHub Actions CI/CD):::build
    
    subgraph "Phase 1: Security & Quality Scans (Shift-Left)"
        CI --> SAST[🔍 SonarQube<br/>SAST & Code Quality]:::scan
        CI --> SCA[📦 Snyk<br/>Open-Source Dependencies]:::scan
        CI --> IAC1[🛡️ Checkov<br/>Terraform Misconfigs]:::scan
        CI --> IAC2[🔒 tfsec<br/>AWS/Azure IaC]:::scan
        CI --> K8S[🐳 Trivy<br/>Docker & K8s Manifests]:::scan
    end
    
    SAST --> Gate{Security<br/>Gates Pass?}
    SCA --> Gate
    IAC1 --> Gate
    IAC2 --> Gate
    K8S --> Gate
    
    Gate -- No --> Fail[❌ Pipeline Fails<br/>Alert Developer]
    Gate -- Yes --> BuildPhase
    
    subgraph "Phase 2: Build & Push"
        BuildPhase(🔨 Build Docker Image):::build --> PushImage(📤 Push to Container Registry):::build
    end
    
    PushImage --> DeployPhase
    
    subgraph "Phase 3: Provision & Deploy"
        DeployPhase(🚀 Terraform Apply):::deploy --> Cloud(☁️ AWS / Azure Cloud):::cloud
        Cloud --> Kube(☸️ Kubernetes Cluster<br/>Pods, Services, Policies):::deploy
    end
    
    Kube --> EndUser([🌍 End Users])
"""

try:
    compressed = zlib.compress(mermaid_code.encode('utf-8'), 9)
    encoded = base64.urlsafe_b64encode(compressed).decode('ascii')
    
    url = f"https://kroki.io/mermaid/png/{encoded}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    
    with urllib.request.urlopen(req) as response:
        with open("architecture.png", "wb") as f:
            f.write(response.read())
            
    if os.path.exists("architecture.png") and os.path.getsize("architecture.png") > 0:
        print("Successfully generated architecture.png")
    else:
        print("Failed: Image is empty")
        
except Exception as e:
    print(f"Error: {e}")

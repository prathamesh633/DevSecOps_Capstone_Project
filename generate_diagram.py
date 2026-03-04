import base64
import zlib
import urllib.request
import os

plantuml_code = """@startuml
!define AWSPuml https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/v18.0/dist
!include AWSPuml/AWSCommon.puml
!include AWSPuml/DeveloperTools/CodeCommit.puml
!include AWSPuml/DeveloperTools/CodeBuild.puml
!include AWSPuml/Containers/ElasticKubernetesService.puml
!include AWSPuml/General/User.puml
!include AWSPuml/SecurityIdentityCompliance/Inspector.puml

skinparam defaultTextAlignment center
skinparam rectangle {
    BackgroundColor White
    BorderColor #888888
}

User(dev, "Developer", "Pushes code")
CodeCommit(repo, "GitHub Repository", "Source Control")
CodeBuild(ci, "GitHub Actions", "CI/CD Pipeline")

dev -> repo : Push Code
repo -> ci : Webhook Trigger

rectangle "Phase 1: Security Scans (Shift-Left)" {
    Inspector(sast, "SonarQube", "SAST & Code Quality")
    Inspector(sca, "Snyk", "SCA Dependencies")
    Inspector(iac, "Checkov / tfsec", "IaC Security")
}

ci -down-> sast
ci -down-> sca
ci -down-> iac

rectangle "Phase 2: Build & Container Security" {
    agent "Docker Build & Push" as docker
    Inspector(trivy, "Trivy", "Container Image Scan")
}

sast -down-> docker
sca -down-> docker
iac -down-> docker

docker -right-> trivy : Image Scan

rectangle "Phase 3: Provision (IaC) & Deploy" {
    agent "Terraform Apply" as tf
    ElasticKubernetesService(eks, "Kubernetes Cluster", "AWS / Azure")
}

trivy -down-> tf : Deploy if Secure
tf -right-> eks : Provision Infrastructure

@enduml"""

try:
    compressed = zlib.compress(plantuml_code.encode('utf-8'), 9)
    encoded = base64.urlsafe_b64encode(compressed).decode('ascii')
    
    url = f"https://kroki.io/plantuml/png/{encoded}"
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

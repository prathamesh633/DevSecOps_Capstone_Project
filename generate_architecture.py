from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions

from diagrams.onprem.container import Docker
from diagrams.onprem.iac import Terraform
from diagrams.aws.compute import EKS
from diagrams.azure.compute import AKS
from diagrams.custom import Custom
from diagrams.programming.framework import React
from diagrams.programming.language import Python
from diagrams.onprem.database import PostgreSQL
import urllib.request
import os

# Download custom icons
icons = {
    "snyk.png": "https://avatars.githubusercontent.com/u/10746780?s=200&v=4",
    "checkov.png": "https://avatars.githubusercontent.com/u/62040183?s=200&v=4",
    "trivy.png": "https://avatars.githubusercontent.com/u/53232655?s=200&v=4",
    "tfsec.png": "https://avatars.githubusercontent.com/u/49221191?s=200&v=4",
    "sonarqube.png": "https://avatars.githubusercontent.com/u/6134372?s=200&v=4"
}

for filename, url in icons.items():
    if not os.path.exists(filename):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response:
                with open(filename, "wb") as f:
                    f.write(response.read())
        except Exception as e:
            print(f"Failed to download {url}: {e}")

# Generate Architecture
graph_attr = {
    "fontsize": "24",
    "bgcolor": "transparent"
}

with Diagram("DevSecOps Pipeline & Architecture", show=False, filename="architecture_new", direction="LR", graph_attr=graph_attr):

    with Cluster("Developer Workflow"):
        repo = Github("Source Code")
        dev1 = React("Frontend (React)")
        dev2 = Python("Backend (Flask)")
        [dev1, dev2] >> repo

    ci = GithubActions("CI/CD Pipeline")
    repo >> Edge(label="Push Code") >> ci

    with Cluster("Phase 1: Shift-Left Security Scans"):
        sast = Custom("SAST (SonarQube)", "sonarqube.png")
        sca = Custom("SCA (Snyk)", "snyk.png")
        iac_checkov = Custom("IaC Scan (Checkov)", "checkov.png")
        iac_tfsec = Custom("IaC Scan (tfsec)", "tfsec.png")
        scans = [sast, sca, iac_checkov, iac_tfsec]

    ci >> Edge(label="Trigger Scans") >> scans

    with Cluster("Phase 2: Build & Container Security"):
        build = Docker("Build Image")
        container_scan = Custom("Container Scan (Trivy)", "trivy.png")
        repo_push = Docker("Push to Registry")
        
    scans >> Edge(color="green", label="Pass") >> build
    build >> container_scan
    container_scan >> Edge(color="green", label="Pass") >> repo_push

    with Cluster("Phase 3: Provisioning & Deployment"):
        tf = Terraform("Infrastructure as Code")
        with Cluster("Cloud Environment (AWS / Azure)"):
            k8s = EKS("Kubernetes Cluster")
            db = PostgreSQL("Database")
            k8s - db

    repo_push >> tf
    tf >> Edge(label="Provision/Deploy") >> k8s

print("Successfully generated architecture_new.png")

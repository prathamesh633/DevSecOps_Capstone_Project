# Security Compliance Frameworks for DevOps Engineers

---

# 1. SOC 2 (System and Organization Controls 2)

## What is SOC 2?

SOC 2 is a **security compliance framework created by the AICPA (American Institute of Certified Public Accountants).**

It evaluates how well a company protects:

- Security
- Availability
- Processing Integrity
- Confidentiality
- Privacy

SOC 2 is especially important for:

- SaaS companies
- Cloud providers
- Tech startups handling customer data

### SOC 2 Types

- **SOC 2 Type I** → Evaluates design of controls at a specific point in time  
- **SOC 2 Type II** → Evaluates effectiveness of controls over a period (usually **3–12 months**)

---

## Why SOC 2 is Important

- Required by enterprise customers before signing contracts
- Builds trust with clients
- Demonstrates strong security posture
- Reduces business risk
- Often mandatory for **B2B SaaS companies**

### Without SOC 2

- Companies may lose enterprise deals
- Security posture appears weak
- Higher legal and data breach risk

---

# DevOps Engineer Role in SOC 2

DevOps engineers are responsible for implementing **technical security controls**.

## 1. Infrastructure Security

- IAM role-based access control (AWS IAM, Azure RBAC)
- Least privilege access
- MFA enforcement
- Secure VPC architecture

---

## 2. CI/CD Security

- Secure Jenkins / GitHub Actions pipelines
- Protect secrets (AWS Secrets Manager, HashiCorp Vault)
- Avoid hardcoded credentials
- Implement branch protection rules

---

## 3. Logging & Monitoring

- Enable AWS CloudTrail
- Centralized logging (ELK, Datadog)
- Audit log retention
- Alerting for suspicious activity

---

## 4. Change Management

- Infrastructure as Code (Terraform)
- Pull request approvals
- Version control for infrastructure changes
- Documented deployment processes

---

## 5. Backup & Availability

- Automated backups
- Disaster recovery planning
- High availability architecture (ALB, Auto Scaling)

---

# 2. ISO 27001

## What is ISO 27001?

**ISO/IEC 27001** is an international standard for:

> **Information Security Management System (ISMS)**

It defines how organizations should **systematically manage sensitive data.**

It focuses on:

- Risk assessment
- Security policies
- Incident management
- Continuous improvement

Unlike SOC 2 (which is **audit-based**), **ISO 27001 is a certification standard.**

---

## Why ISO 27001 is Important

- Globally recognized security certification
- Required in European and international markets
- Encourages strong governance and documentation
- Demonstrates mature security processes

It proves that:

- Risks are properly managed
- Structured security processes are followed
- Security is embedded in company culture

---

# DevOps Engineer Role in ISO 27001

ISO 27001 includes **Annex A controls** (technical + administrative).

DevOps engineers mainly support **technical security controls.**

---

## 1. Risk Management Implementation

- Secure architecture design
- Reduce attack surface
- Implement network segmentation

---

## 2. Access Control (Annex A.9)

- Implement RBAC
- Perform IAM audits
- Remove inactive users
- Enforce strong password policies

---

## 3. Cryptography (Annex A.10)

- Enforce HTTPS everywhere
- Manage TLS certificates
- Encrypt data at rest (EBS, S3 encryption)
- Manage keys using AWS KMS

---

## 4. Operations Security (Annex A.12)

- Patch management
- Vulnerability scanning (Trivy, Snyk)
- Secure system configurations

---

## 5. Incident Management

- Monitoring systems
- Alerting pipelines
- Log retention policies
- Forensic log availability

---

# 3. CIS (Center for Internet Security)

## What is CIS?

CIS provides:

1. **CIS Benchmarks** → Secure configuration guidelines  
2. **CIS Controls** → Security best practices  
3. **CIS Hardened Images** → Pre-secured AMIs

### Examples of CIS Benchmarks

- CIS AWS Foundations Benchmark
- CIS Kubernetes Benchmark
- CIS Docker Benchmark
- CIS Linux Benchmark

---

## Why CIS is Important

- Reduces infrastructure misconfigurations
- Prevents common security vulnerabilities
- Provides industry-standard hardening baselines
- Often referenced in **SOC 2 and ISO audits**

CIS is **very practical and implementation-focused.**

---

# DevOps Engineer Role in CIS

CIS implementation is heavily **DevOps-driven**.

---

## 1. OS Hardening

- Disable root login
- Enforce SSH key authentication
- Configure firewalls
- Enforce file permission policies

---

## 2. Docker Hardening

- Avoid privileged containers
- Use read-only root filesystem
- Perform container image vulnerability scanning
- Avoid running containers as root

---

## 3. Kubernetes Hardening

- Enforce RBAC
- Implement Pod Security Policies
- Configure Network Policies
- Secure Kubernetes API server

---

## 4. Cloud Hardening

- Prevent public S3 buckets
- Restrict security groups
- Enable CloudTrail logging
- Rotate access keys regularly

---

# Real DevOps Implementation Example

### Disable Root SSH Login (CIS Linux Benchmark)

```bash
sudo nano /etc/ssh/sshd_config
PermitRootLogin no
```

### Example in Terraform

```hcl
enable_key_rotation = true
```

---

# Framework Comparison (DevOps Perspective)

| Framework | Type | Focus | DevOps Impact |
|--------|--------|--------|--------|
| SOC 2 | Audit | Trust & Controls | Logging, IAM, CI/CD security |
| ISO 27001 | Certification | ISMS & Risk Management | Policies + technical controls |
| CIS | Technical Benchmark | System Hardening | Direct infrastructure implementation |

---

# Why DevOps Engineers Must Understand These Frameworks

DevOps teams:

- Control infrastructure
- Manage CI/CD pipelines
- Implement cloud security
- Automate deployments
- Own observability and monitoring

Most security audit findings originate from:

- Poor IAM configuration
- Misconfigured S3 buckets
- Missing logging
- Lack of encryption
- Weak change management

These responsibilities are **directly owned by DevOps teams.**
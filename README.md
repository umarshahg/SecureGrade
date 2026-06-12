# SecureGrade — Secure Student Result Portal
## CYC386 Secure Software Design & Development
### COMSATS University Islamabad — Spring 2026

---

## Team Members

| Name | Registration No | Role |
|---|---|---|
| Muhammad Umar Shah | SP23-BCT-040 | Lead Developer |
| Muhammad Awais | SP23-BCT-040 | Security Analyst |
| Muhammad Umair Nazir | SP23-BCT-038 | DevSecOps Engineer |

**Instructor:** Muhammad Ahmad Nawaz

---

## Project Overview

SecureGrade is a secure, cloud-native, microservices-based
Student Result Portal implementing enterprise-level security
practices across the full Software Development Lifecycle.

---

## Architecture

- **4 Microservices:** Auth, Result, Grade, Admin
- **Database:** PostgreSQL (encrypted at rest)
- **Cache:** Redis (TLS-enabled sessions)
- **Event Bus:** Apache Kafka
- **Secrets:** HashiCorp Vault
- **Container:** Docker (hardened, multi-stage)
- **Orchestration:** Kubernetes (CIS benchmarked)
- **IaC:** Terraform

---

## Security Controls Implemented

- JWT RS256 Authentication
- RBAC + ABAC Authorization
- IDOR Prevention
- SQL Injection Prevention
- XSS Prevention
- CSV Injection Prevention
- Rate Limiting
- Input Validation
- Audit Logging
- TLS 1.3 everywhere
- Content Security Policy
- Zero Trust Architecture

---

## Security Testing Results

| Tool | Finding | Status |
|---|---|---|
| SonarQube SAST | Issues found | Fixed |
| CodeQL SAST | 16 issues found | 12 fixed |
| OWASP ZAP DAST | CSP alerts | Documented |
| Trivy Image Scan | 50 CVEs found | 44 fixed |
| API Pentesting | 10 tests | All passed |

---

## Project Structure
securegarde/

├── src/                  ← Microservices source code

│   ├── auth-service/     ← Authentication (port 3001)

│   ├── result-service/   ← Results (port 3002)

│   ├── grade-service/    ← Grades (port 3003)

│   └── admin-service/    ← Admin (port 3004)

├── k8s/                  ← Kubernetes manifests

├── iac/                  ← Terraform + Vault IaC

├── docs/                 ← Project documentation

├── reports/              ← Security scan reports

├── scripts/              ← Database init scripts

└── .github/workflows/    ← CI/CD pipelines

---

## Quick Start

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/SecureGrade.git

# Start with Docker Compose
cd SecureGrade
docker compose up -d

# Verify services
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
curl http://localhost:3004/health
```

---

## Security Frameworks Applied

- OWASP ASVS v5.0
- NIST CSF
- NIST SP 800-207 (Zero Trust)
- MITRE ATT&CK
- SABSA
- ISO/IEC 27034
- CSA CCM
- CIS Docker Benchmark
- CIS Kubernetes Benchmark

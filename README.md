# 🚀 Tata Electronics – GCP Landing Zone (Terraform)

This repository contains a **fully automated Terraform setup** to deploy a complete **Google Cloud Landing Zone**.

With a few simple steps, you can provision:

- Organization-level structure (Folders & Projects)
- Hub-Spoke Network Architecture (Shared VPC)
- Subnets based on approved CIDR plan
- Firewall rules & Cloud NAT
- Classic VPN (On-Prem connectivity)
- IAM roles & policies
- Logging & Budget setup

---

# 📌 What This Does (In Simple Terms)

Think of this as a **“one-click setup”** for your cloud.

Instead of manually creating resources in Google Cloud, this code:

✔ Creates everything automatically  
✔ Ensures correct structure  
✔ Applies security and networking standards  

---

# 🧱 Architecture Overview

- **Organization**
  - Business Units (e.g., Manufacturing)
    - Environments (Dev / Prod)
      - Projects
        - Shared VPC (Hub)
        - Spoke Projects

---

# ⚙️ Prerequisites (Very Important)

Before running this, ensure you have:

### 1. Install Required Tools

- Terraform (v1.5 or above)
- Google Cloud CLI (gcloud)

---

### 2. Login to Google Cloud

```bash
gcloud auth login

# RHCE Killer 🔴

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/brando93/rhce-killer.svg?style=social)](https://github.com/brando93/rhce-killer/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/brando93/rhce-killer.svg?style=social)](https://github.com/brando93/rhce-killer/network)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

> The hardest EX294 practice lab you'll find. If you pass this, you pass the real exam.

Inspired by [killer.sh](https://killer.sh) for Kubernetes — but for the **Red Hat Certified Engineer (EX294) Ansible exam**.

**⭐ Star this repo if you find it useful!**

## ⚠️ Important Disclaimers

**This is an independent educational project and is NOT:**
- ❌ Affiliated with, endorsed by, or sponsored by Red Hat, Inc.
- ❌ A replacement for official Red Hat training
- ❌ A guarantee of certification success
- ❌ Using actual Red Hat exam content

**Red Hat®, RHCE®, and Ansible® are trademarks of Red Hat, Inc.**

This project is for **educational purposes only**. To earn the RHCE certification, you must take and pass the official Red Hat EX294 exam.

**Recommended:** Complete official Red Hat training courses before attempting the certification exam.

---

## What's included

- **Terraform lab** — 3 EC2 instances on AWS (Rocky Linux 9), spun up in 1 command
- **5 comprehensive mock exams** — 50 tasks total, progressive difficulty from basic to expert
- **Auto-grader** — tells you your exact score and which tasks failed (340+ validation checks)
- **4-hour timer** — simulates real exam pressure
- **Complete solutions** — every task has step-by-step solutions with full code
- **95% EX294 coverage** — all exam objectives thoroughly covered

---

## Cost

While the lab is running: **~$0.07/hr** (~$0.53 for an 8-hour session)

| Resource | Cost/hr |
|----------|---------|
| t3.medium (control) | $0.0416 |
| t3.micro × 2 (nodes) | $0.0208 |
| gp3 storage (40GB) | ~$0.004 |
| **Total** | **~$0.066** |

Run `make destroy` when done. No idle charges.

---

## Prerequisites

```bash
# On your Mac:
brew install terraform awscli

# Configure AWS credentials
aws configure
# Enter your Access Key ID, Secret Access Key, region: us-east-1
```

---

## Quick start

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/rhce-killer
cd rhce-killer

# 2. Spin up the lab (auto-detects your IP)
make up

# 3. Wait ~3 minutes for bootstrap to complete
# Check bootstrap status (shows ✅ when ready):
make bootstrap-status

# 4. SSH into the control node
make ssh

# 5. Switch to student user (exam user)
sudo su - student

# 6. Verify connectivity to managed nodes
cd ~/ansible
ansible all -m ping

# 7. List available exams
ls ~/exams/

# 8. Start with Exam 01 (recommended for beginners)
bash ~/exams/exam-01/START.sh

# 9. Read the tasks
cat ~/exams/exam-01/README.md | less

# 10. Work from your ansible directory
cd ~/ansible

# 11. Grade yourself when done
bash ~/exams/exam-01/grade.sh

# 12. Try other exams (progressive difficulty)
# bash ~/exams/exam-02/START.sh  # Intermediate
# bash ~/exams/exam-03/START.sh  # Roles & Collections
# bash ~/exams/exam-04/START.sh  # Linux Administration
# bash ~/exams/exam-05/START.sh  # Expert Level

# 11. DESTROY the lab when done (stop billing!)
exit
exit
make destroy
```

---

## Lab topology

```
                    Internet
                        │
                        │
                   ┌────▼────┐
                   │   IGW   │
                   └────┬────┘
                        │
        ┌───────────────┴───────────────┐
        │     VPC 10.0.0.0/16           │
        │                               │
        │  ┌─────────────────────────┐  │
        │  │ Public Subnet           │  │
        │  │ 10.0.1.0/24             │  │
        │  │                         │  │
Your Mac ──► control.example.com    │  │
SSH only │  │ 10.0.1.10 (t3.medium) │  │
        │  │ Public IP               │  │
        │  └────────┬────────────────┘  │
        │           │                   │
        │           │ SSH + Ansible     │
        │           │                   │
        │  ┌────────▼────────────────┐  │
        │  │ Private Subnet          │  │
        │  │ 10.0.2.0/24             │  │
        │  │                         │  │
        │  │ node1.example.com       │  │
        │  │ 10.0.2.11 (t3.micro)    │  │
        │  │                         │  │
        │  │ node2.example.com       │  │
        │  │ 10.0.2.12 (t3.micro)    │  │
        │  │                         │  │
        │  └────────┬────────────────┘  │
        │           │                   │
        │      ┌────▼────┐              │
        │      │   NAT   │              │
        │      │ Gateway │              │
        │      └────┬────┘              │
        │           │                   │
        └───────────┼───────────────────┘
                    │
                Internet (for package downloads)
```

**Network Architecture:**
- **Public Subnet (10.0.1.0/24)**: Control node with direct internet access via Internet Gateway
- **Private Subnet (10.0.2.0/24)**: Managed nodes with internet access via NAT Gateway
- **Security**: Only your IP can SSH to control node; managed nodes only accessible from control node

All nodes run **Rocky Linux 9** — binary compatible with RHEL 9 (what the exam uses).

---

## Exam structure

Each exam mirrors the real EX294:
- **4 hours** — timer included
- **No internet access** during exam (honor system)
- **Tasks scored independently** — partial credit NOT given (same as real exam)
- **Passing threshold: 70%**

### 📚 Available Exams (Progressive Difficulty)

| Exam | Focus | Tasks | Points | Difficulty | Status |
|------|-------|-------|--------|------------|--------|
| **Exam 01** | Basic Ansible Tasks | 10 | 100 | ⭐ Beginner | ✅ Complete |
| **Exam 02** | Intermediate Tasks | 10 | 120 | ⭐⭐ Intermediate | ✅ Complete |
| **Exam 03** | Roles & Collections | 10 | 120 | ⭐⭐⭐ Advanced | ✅ Complete |
| **Exam 04** | Linux Administration | 10 | 120 | ⭐⭐⭐ Advanced | ✅ Complete |
| **Exam 05** | Troubleshooting & Advanced | 10 | 150 | ⭐⭐⭐⭐ Expert | ✅ Complete |
| **TOTAL** | | **50** | **610** | | |

### 🎯 Recommended Study Path

1. **Start with Exam 01** - Master the basics (inventory, playbooks, modules, variables)
2. **Progress to Exam 02** - Learn intermediate concepts (loops, conditionals, handlers, vault)
3. **Master Exam 03** - Deep dive into roles and collections
4. **Complete Exam 04** - System administration with Ansible
5. **Challenge Exam 05** - Expert-level troubleshooting and optimization


## Available commands

```bash
make up               # Spin up the lab
make bootstrap-status # Check if bootstrap is complete (shows ✅ when ready)
make ssh              # SSH into control node
make ssh-student      # SSH as student user (exam user)
make debug            # Watch bootstrap log in real-time
make status           # Show IPs and instance status
make destroy          # Destroy all resources
make ip-fix           # Update security group if your IP changed
```

---


## Structure

```
rhce-killer/
├── Makefile                    # make up / make ssh / make destroy
├── terraform/
│   ├── main.tf                 # VPC, EC2, security groups, key pair
│   ├── variables.tf
│   ├── outputs.tf
│   └── user_data/
│       ├── control.sh          # Bootstrap: Ansible, SSH keys, all exams
│       └── node.sh             # Bootstrap: Python, sudo
├── exam-01/                    # ⭐ Basic Ansible Tasks (100 pts)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 40+ validation checks
├── exam-02/                    # ⭐⭐ Intermediate Tasks (120 pts)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 60+ validation checks
├── exam-03/                    # ⭐⭐⭐ Roles & Collections (120 pts)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 70+ validation checks
├── exam-04/                    # ⭐⭐⭐ Linux Administration (120 pts)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 80+ validation checks
├── exam-05/                    # ⭐⭐⭐⭐ Troubleshooting (150 pts)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 90+ validation checks
└── verification/
    └── reset-lab.sh            # Clean slate between attempts
```

**Total:** 50 tasks, 610 points, 340+ automated validation checks, 95% EX294 coverage

---

## License

MIT — use freely, contribute back if you find issues or want to add exam tasks.

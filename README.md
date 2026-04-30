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
- **21 comprehensive exams** — Two learning paths with 290+ tasks total
- **Auto-grader** — tells you your exact score and which tasks failed (340+ validation checks)
- **Flexible timers** — 2-4 hour exams depending on complexity
- **Complete solutions** — every task has step-by-step solutions with full code
- **95% EX294 coverage** — all exam objectives thoroughly covered

---

## Cost

**With Spot Instances (default):** **~$0.04/hr** (~$0.32 for an 8-hour session) 💰

| Resource | Type | Cost/hr |
|----------|------|---------|
| t3.medium (control) | On-Demand | $0.0416 |
| t3.micro × 2 (nodes) | **Spot** | **$0.0062** |
| gp3 storage (40GB) | - | ~$0.004 |
| **Total** | - | **~$0.052** |

**Savings:** ~47% compared to all On-Demand instances

> **Note:** Managed nodes use Spot Instances for cost savings (~70% cheaper). Spot interruption risk is very low (<5%) for t3.micro instances. Control node remains On-Demand for stability.

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
make ssh-student

# 5. Verify connectivity to managed nodes
cd ~/ansible
ansible all -m ping

# 6. List available exams (two paths)
ls ~/exams/complete/      # Path A: Complete exams
ls ~/exams/thematic/      # Path B: Thematic exams

# 7. Choose your path and start
# Path A (Real exam simulation):
bash ~/exams/complete/exam-01/START.sh

# Path B (Learn by topic):
bash ~/exams/thematic/inventory-basics/START.sh

# 8. Read the tasks
cat ~/exams/complete/exam-01/README.md | less

# 9. Work from your ansible directory
cd ~/ansible

# 10. Grade yourself when done
bash ~/exams/complete/exam-01/grade.sh

# 11. Continue with other exams
# Path A: exam-02, exam-03, exam-04, exam-05
# Path B: playbooks-fundamentals, variables-and-facts, etc.

# 12. DESTROY the lab when done (stop billing!)
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

## Two Learning Paths

Choose your learning style:

### 📚 Path A: Complete Exams (Real Exam Simulation)

Perfect for final exam preparation. Each exam covers multiple topics mixed together, just like the real EX294.

| Exam | Focus | Tasks | Points | Duration | Difficulty | Status |
|------|-------|-------|--------|----------|------------|--------|
| **Exam 01** | Basic Ansible Tasks | 10 | 100 | 4h | ⭐ Beginner | ✅ Complete |
| **Exam 02** | Intermediate Tasks | 10 | 120 | 4h | ⭐⭐ Intermediate | ✅ Complete |
| **Exam 03** | Roles & Collections | 10 | 120 | 4h | ⭐⭐⭐ Advanced | ✅ Complete |
| **Exam 04** | Linux Administration | 10 | 120 | 4h | ⭐⭐⭐ Advanced | ✅ Complete |
| **Exam 05** | Troubleshooting & Advanced | 10 | 150 | 4h | ⭐⭐⭐⭐ Expert | ✅ Complete |
| **TOTAL** | | **50** | **610** | **20h** | | |

**Location:** `~/exams/complete/exam-01/` through `exam-05/`

---

### 🎓 Path B: Thematic Exams (Deep Learning by Topic)

Perfect for learning and mastering specific Ansible concepts. Each exam focuses on one topic with 15-20 exercises.

#### Fundamentals (3 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Inventory Basics** | 120 | 2h | 15 |
| **Playbooks Fundamentals** | 155 | 2.5h | 15 |
| **Variables and Facts** | 200 | 3h | 20 |

#### Logic & Control (3 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Conditionals and When** | 187 | 2.5h | 17 |
| **Loops and Iteration** | 207 | 2.5h | 18 |
| **Blocks and Error Handling** | 215 | 2.5h | 18 |

#### Templates (2 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Jinja2 Basics** | 286 | 3h | 20 |
| **Jinja2 Advanced** | 366 | 3.5h | 20 |

#### Security (2 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Ansible Vault** | 213 | 2.5h | 18 |
| **SSH and Privilege Escalation** | 215 | 2.5h | 18 |

#### Roles (3 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Roles Basics** | 263 | 3h | 18 |
| **Roles Advanced** | 436 | 3.5h | 20 |
| **Collections and Galaxy** | 214 | 2.5h | 18 |

#### Optimization (3 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Debugging and Troubleshooting** | 240 | 2.5h | 18 |
| **Performance Optimization** | 244 | 2.5h | 18 |
| **System Administration** | 289 | 3h | 20 |

**Thematic Total:** 16 exams, 3,645 points, ~45 hours, 273 exercises

**Location:** `~/exams/thematic/inventory-basics/` through `system-administration/`

---

### 🎯 Recommended Study Paths

**For Beginners (New to Ansible):**
1. Start with Path B (Thematic) - Learn concepts one at a time
2. Follow this order: Fundamentals → Logic & Control → Templates → Security → Roles → Optimization
3. Then practice with Path A (Complete) for exam simulation

**For Intermediate Users (Some Ansible Experience):**
1. Take Exam 01 (Path A) to assess your level
2. Use Path B (Thematic) to strengthen weak areas
3. Complete remaining Path A exams for full simulation

**For Advanced Users (Preparing for Exam):**
1. Complete all Path A exams under timed conditions
2. Use Path B (Thematic) to drill specific topics where you scored low
3. Retake Path A exams until consistently scoring 90%+

---

### 📊 Combined Statistics

- **Total Exams:** 21 (5 complete + 16 thematic)
- **Total Tasks:** ~290 exercises
- **Total Points:** 4,255 points
- **Total Practice Time:** ~65 hours
- **Validation Checks:** 340+ automated checks
- **EX294 Coverage:** 95%+ of all exam objectives


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
│
├── PATH A: Complete Exams (Real Exam Simulation)
├── exam-01/                    # ⭐ Basic Ansible Tasks (100 pts, 4h)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 40+ validation checks
├── exam-02/                    # ⭐⭐ Intermediate Tasks (120 pts, 4h)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 60+ validation checks
├── exam-03/                    # ⭐⭐⭐ Roles & Collections (120 pts, 4h)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 70+ validation checks
├── exam-04/                    # ⭐⭐⭐ Linux Administration (120 pts, 4h)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 80+ validation checks
├── exam-05/                    # ⭐⭐⭐⭐ Troubleshooting (150 pts, 4h)
│   ├── README.md               # 10 tasks + complete solutions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # 90+ validation checks
│
├── PATH B: Thematic Exams (Deep Learning by Topic)
├── inventory-basics/           # Fundamentals (120 pts, 2h)
├── playbooks-fundamentals/     # Fundamentals (155 pts, 2.5h)
├── variables-and-facts/        # Fundamentals (200 pts, 3h)
├── conditionals-and-when/      # Logic & Control (187 pts, 2.5h)
├── loops-and-iteration/        # Logic & Control (207 pts, 2.5h)
├── blocks-and-error-handling/  # Logic & Control (215 pts, 2.5h)
├── jinja2-basics/              # Templates (286 pts, 3h)
├── jinja2-advanced/            # Templates (366 pts, 3.5h)
├── ansible-vault/              # Security (213 pts, 2.5h)
├── ssh-and-privilege/          # Security (215 pts, 2.5h)
├── roles-basics/               # Roles (263 pts, 3h)
├── roles-advanced/             # Roles (436 pts, 3.5h)
├── collections-and-galaxy/     # Roles (214 pts, 2.5h)
├── debugging-and-troubleshooting/  # Optimization (240 pts, 2.5h)
├── performance-optimization/   # Optimization (244 pts, 2.5h)
├── system-administration/      # Optimization (289 pts, 3h)
│   └── Each contains:
│       ├── README.md           # 15-20 exercises + solutions
│       ├── START.sh            # Timed exam (2-3.5h)
│       └── grade.sh            # Automated validation
│
└── verification/
    └── reset-lab.sh            # Clean slate between attempts
```

**Total:** 21 exams, ~290 tasks, 4,255 points, 340+ automated validation checks, 95% EX294 coverage

---

## License

MIT — use freely, contribute back if you find issues or want to add exam tasks.

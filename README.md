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

- **Terraform lab** — 3 EC2 instances on AWS (Rocky Linux 9), spun up by a single `make up`
- **One-command lifecycle** — `make up` chains provision → bootstrap → sync with phased progress bars; `make destroy` tears down with verification (no orphan NAT GW or EIP charges)
- **21 comprehensive exams** — two learning paths with 320+ exercises total
- **Auto-grader** — tells you your exact score and which tasks failed (390+ validation checks)
- **Flexible timers** — 2–4 hour exams depending on complexity
- **Complete solutions** — every task has step-by-step solutions with full code
- **95%+ EX294 coverage** — all exam objectives thoroughly covered, including `yum_repository`, `parted`, `rhel-system-roles.network`, Apache `mod_proxy_balancer`, and conditional LVM provisioning

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
git clone https://github.com/brando93/rhce-killer
cd rhce-killer

# 2. Spin up the lab — this single command does EVERYTHING:
#    - terraform apply (provision EC2 + VPC + SGs)
#    - poll the control node until cloud-init finishes
#    - sync all 21 exam dirs to ~/exams/complete and ~/exams/thematic
#    Total: ~5–7 minutes from cold start. Re-running is idempotent
#    (no-op against AWS, just re-syncs exam files).
make up

# 3. SSH into the control node as the exam user
make ssh-student

# 4. Verify connectivity to managed nodes
cd ~/ansible
ansible all -m ping

# 5. Choose your path (two are available)
ls ~/exams/complete/     # Path A: 5 full RHCE-style exams
ls ~/exams/thematic/     # Path B: 16 topic-focused modules

# 6. Start an exam (each ships with its own timer)
bash ~/exams/complete/exam-01/START.sh

# 7. Read the tasks
less ~/exams/complete/exam-01/README.md

# 8. Work from your ansible directory
cd ~/ansible

# 9. Grade yourself when done
bash ~/exams/complete/exam-01/grade.sh

# 10. Tear it all down when finished (with verification — no orphans)
exit
exit
make destroy
```

**What you'll see when running `make up`:**

```
  RHCE Killer — Lab setup

  [1/3] Provisioning
      ✓ Terraform apply (54.x.x.x/32) (7/7)   [████████████████████] 2m22s

  [2/3] Bootstrap
      ✓ polling control node                  [████████████████████] 3m31s

  [3/3] Sync
      ✓ Sync exams: 21 dirs (5 + 16)          [████████████████████] 7s

  ✓ Lab ready

    Control node    44.198.192.12
    Exams           5 complete · 16 thematic

    Login           make ssh-student
    Start exam-01   bash ~/exams/complete/exam-01/START.sh
    Tear down       make destroy
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
| **Exam 01** | Basic Ansible Tasks (incl. `yum_repository`) | 11 | 130 | 4h | ⭐ Beginner | ✅ Complete |
| **Exam 02** | Intermediate Tasks (incl. cluster-info template) | 11 | 135 | 4h | ⭐⭐ Intermediate | ✅ Complete |
| **Exam 03** | Roles & Collections (incl. phpinfo + balancer) | 11 | 135 | 4h | ⭐⭐⭐ Advanced | ✅ Complete |
| **Exam 04** | Linux Admin (incl. parted, conditional LVM, network role) | 13 | 180 | 4h | ⭐⭐⭐ Advanced | ✅ Complete |
| **Exam 05** | Troubleshooting & Advanced | 10 | 150 | 4h | ⭐⭐⭐⭐ Expert | ✅ Complete |
| **TOTAL** | | **56** | **730** | **20h** | | |

**Location:** `~/exams/complete/exam-01/` through `exam-05/`

---

### 🎓 Path B: Thematic Exams (Deep Learning by Topic)

Perfect for learning and mastering specific Ansible concepts. Each exam focuses on one topic with 15-20 exercises.

#### Fundamentals (3 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Inventory Basics** | 120 | 2h | 15 |
| **Playbooks Fundamentals** | 155 | 2.5h | 13 |
| **Variables and Facts** | 200 | 3h | 15 |

#### Logic & Control (3 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Conditionals and When** ¹ | 207 | 2.5h | 16 |
| **Loops and Iteration** | 207 | 2.5h | 15 |
| **Blocks and Error Handling** | 215 | 2.5h | 15 |

#### Templates (2 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Jinja2 Basics** | 286 | 3h | 20 |
| **Jinja2 Advanced** ¹ | 388 | 3.5h | 21 |

#### Security (2 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Ansible Vault** | 213 | 2.5h | 15 |
| **SSH and Privilege Escalation** | 215 | 2.5h | 16 |

#### Roles (3 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Roles Basics** | 263 | 3h | 15 |
| **Roles Advanced** ¹ | 464 | 3.5h | 21 |
| **Collections and Galaxy** | 214 | 2.5h | 15 |

#### Optimization (3 exams)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Debugging and Troubleshooting** | 240 | 2.5h | 20 |
| **Performance Optimization** | 244 | 2.5h | 15 |
| **System Administration** ¹ | 345 | 3h | 18 |

¹ Includes new exercises added after auditing the project against an
Ansible exam dump: `yum_repository`, `parted`, `rhel-system-roles.network`,
phpinfo + Apache `mod_proxy_balancer`, conditional LVM provisioning, and
cluster-inventory templating from `hostvars`.

**Thematic Total:** 16 exams, 3,976 points, ~43 hours, 265 exercises

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
- **Total Exercises:** 321
- **Total Points:** 4,706
- **Total Practice Time:** ~63 hours
- **Validation Checks:** 390+ automated checks
- **EX294 Coverage:** 95%+ of all exam objectives


## Available commands

The Makefile delegates lab lifecycle to `scripts/lab-up.sh`, which renders a
clean phased progress bar instead of dumping raw Terraform/SSH output.
Per-phase logs land in `.lab-logs/` if you want the full detail.

### Lifecycle

```bash
make up               # Full pipeline: provision → bootstrap → sync (one command).
                      # Idempotent: re-running against a live lab just re-syncs
                      # exam files in ~5 seconds.
make destroy          # Tear down with progress bar + post-destroy verification.
                      # Cleans .pem, .lab-logs/, .lab-up.tfplan*. Confirms with
                      # `terraform state list` that nothing was orphaned (no
                      # silent NAT GW or EIP charges).
make verify           # Sanity-check AWS state without destroying. Useful before
                      # bed to confirm nothing leaked.
```

### Day-to-day

```bash
make ssh-student      # SSH as student (exam user) — what you want most of the time
make ssh              # SSH as rocky (sudo-enabled, for lab maintenance)
make sync-exams       # Re-push exam files after editing locally
make status           # Show Terraform outputs (IPs, instance IDs)
make debug            # Tail /var/log/rhce-bootstrap.log on the control node
```

### Recovery

```bash
make ip-fix           # Update security group when your public IP changes
make unlock           # Force-release a stale Terraform state lock (auto-detects
                      # the lock_id, asks for confirmation)
make wait-bootstrap   # Block until bootstrap finishes (with progress bar) — useful
                      # if you ran tf-apply manually and want to wait
make bootstrap-status # One-shot bootstrap check (no polling, exits immediately)
```

---


## Structure

```
rhce-killer/
├── Makefile                    # Thin dispatcher; delegates to scripts/lab-up.sh
├── scripts/
│   └── lab-up.sh               # Lifecycle orchestrator with phased progress bars
│                               # Subcommands: up | tf-apply | wait-bootstrap |
│                               # sync-exams | destroy | verify | ready
├── terraform/
│   ├── main.tf                 # VPC, EC2, security groups, key pair
│   ├── variables.tf
│   ├── outputs.tf
│   └── user_data/
│       ├── control.sh          # Bootstrap: Ansible, SSH keys, all exams
│       └── node.sh             # Bootstrap: Python, sudo
│
├── PATH A: Complete Exams (Real Exam Simulation)
├── exam-01/                    # ⭐ Basic Ansible Tasks (130 pts, 4h, 11 tasks)
├── exam-02/                    # ⭐⭐ Intermediate Tasks (135 pts, 4h, 11 tasks)
├── exam-03/                    # ⭐⭐⭐ Roles & Collections (135 pts, 4h, 11 tasks)
├── exam-04/                    # ⭐⭐⭐ Linux Administration (180 pts, 4h, 13 tasks)
├── exam-05/                    # ⭐⭐⭐⭐ Troubleshooting (150 pts, 4h, 10 tasks)
│   └── Each contains:
│       ├── README.md           # tasks + complete solutions
│       ├── START.sh            # 4-hour timer
│       └── grade.sh            # automated validation
│
├── PATH B: Thematic Exams (Deep Learning by Topic)
├── inventory-basics/           # Fundamentals (120 pts, 15 tasks)
├── playbooks-fundamentals/     # Fundamentals (155 pts, 13 tasks)
├── variables-and-facts/        # Fundamentals (200 pts, 15 tasks)
├── conditionals-and-when/      # Logic & Control (207 pts, 16 tasks)
├── loops-and-iteration/        # Logic & Control (207 pts, 15 tasks)
├── blocks-and-error-handling/  # Logic & Control (215 pts, 15 tasks)
├── jinja2-basics/              # Templates (286 pts, 20 tasks)
├── jinja2-advanced/            # Templates (388 pts, 21 tasks)
├── ansible-vault/              # Security (213 pts, 15 tasks)
├── ssh-and-privilege/          # Security (215 pts, 16 tasks)
├── roles-basics/               # Roles (263 pts, 15 tasks)
├── roles-advanced/             # Roles (464 pts, 21 tasks)
├── collections-and-galaxy/     # Roles (214 pts, 15 tasks)
├── debugging-and-troubleshooting/  # Optimization (240 pts, 20 tasks)
├── performance-optimization/   # Optimization (244 pts, 15 tasks)
├── system-administration/      # Optimization (345 pts, 18 tasks)
│
├── verification/
│   └── reset-lab.sh            # Clean slate between attempts
│
└── .lab-logs/                  # (gitignored) Per-phase logs from `make up` —
                                # tail any file for raw Terraform/SSH output
```

**Total:** 21 exams, 321 exercises, 4,706 points, 390+ automated validation checks, 95%+ EX294 coverage

---

## License

MIT — use freely, contribute back if you find issues or want to add exam tasks.

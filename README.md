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

### AWS account requirements

The IAM user/role you're using needs at minimum these managed policies:

- `AmazonEC2FullAccess` — for instances, security groups, key pairs, EBS
- `AmazonVPCFullAccess` — for the VPC, subnets, IGW, NAT GW, EIP

If you'd rather use a least-privilege custom policy, the actions Terraform
performs are: `ec2:*Vpc*`, `ec2:*Subnet*`, `ec2:*RouteTable*`,
`ec2:*InternetGateway*`, `ec2:*NatGateway*`, `ec2:*Address*` (EIPs),
`ec2:*SecurityGroup*`, `ec2:*KeyPair*`, `ec2:*Instance*`, `ec2:DescribeImages`.

### Spot Instance gotchas

The managed nodes (`t3.micro`) run as **Spot Instances** for the ~70% price
cut. On a brand-new AWS account or in a region with low capacity you may hit
either of these:

- **`InsufficientInstanceCapacity`** — Spot pool is dry. Wait 5–10 min and
  retry `make up`, or temporarily comment out the `instance_market_options`
  block in `terraform/main.tf` to fall back to On-Demand.
- **`MaxSpotInstanceCountExceeded`** — your account's Spot quota is 0 (the
  default for new accounts in some regions). Request a quota increase from
  the AWS console: *Service Quotas → EC2 → "All Standard … Spot Instance
  Requests"* and bump to at least 2. Usually approved in minutes.

### Cost ceiling

With Spot pricing the lab costs ~$0.05/hr while running. The **silent
billers** when you forget to destroy are the NAT Gateway (~$0.045/hr) and
the Elastic IP attached to it (~$0.005/hr) — neither shows up on the EC2
dashboard. `make verify` and `make destroy` both confirm those are gone.

> **Got stung once?** Run `make auto-destroy` after `make up` — it'll tear
> the lab down automatically after 1 hour of no SSH activity. See *Idle
> protection* below.

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
| **Exam 05** | Troubleshooting & Advanced | 10 | 175 | 4h | ⭐⭐⭐⭐ Expert | ✅ Complete |
| **TOTAL** | | **56** | **755** | **20h** | | |

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

#### Modern CLI (1 exam)
| Exam | Points | Duration | Exercises |
|------|--------|----------|-----------|
| **Ansible-Navigator & Execution Environments** ² | 165 | 2.5h | 13 |

¹ Includes new exercises added after auditing the project against an
Ansible exam dump: `yum_repository`, `parted`, `rhel-system-roles.network`,
phpinfo + Apache `mod_proxy_balancer`, conditional LVM provisioning, and
cluster-inventory templating from `hostvars`.

² Real EX294 v9.x expects you to use `ansible-navigator` (not direct
`ansible-playbook`). This module drills navigator commands, EE config,
artifacts, and replays. Skipping it = 15% of the modern exam left on the
table.

**Thematic Total:** 17 exams, 4,141 points, ~45.5 hours, 278 exercises

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

- **Total Exams:** 22 (5 complete + 17 thematic)
- **Total Exercises:** 334
- **Total Points:** 4,896
- **Total Practice Time:** ~65 hours
- **Validation Checks:** 450+ automated checks
- **EX294 Coverage:** ~98% of all exam objectives (incl. modern v9.x)


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

### Idle protection (the "I left it running overnight" fix)

If you've ever closed your laptop with the lab still up and woken up to a
surprise AWS bill, run this right after `make up`:

```bash
make auto-destroy           # daemon: destroys the lab after 1h of no SSH
make auto-destroy-status    # show last activity + countdown
make auto-destroy-stop      # cancel the daemon (e.g. taking a long break)
```

The daemon polls the control node every 5 minutes via SSH and refreshes its
"last active" timestamp every time it sees an SSH session. After 1h of no
sessions (configurable via `INACTIVITY_TIMEOUT_SEC=7200 make auto-destroy`),
it runs `make destroy` for you — same robust destroy with progress + verify.

Activity log lives at `.auto-destroy.log`. Daemon survives terminal closing
(uses `nohup` + `disown`).

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
├── exam-05/                    # ⭐⭐⭐⭐ Troubleshooting (175 pts, 4h, 10 tasks)
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
├── ansible-navigator-and-ee/   # Modern CLI (165 pts, 13 tasks) ← EX294 v9.x
│
├── verification/
│   └── reset-lab.sh            # Clean slate between attempts
│
└── .lab-logs/                  # (gitignored) Per-phase logs from `make up` —
                                # tail any file for raw Terraform/SSH output
```

**Total:** 22 exams, 334 exercises, 4,896 points, 450+ automated validation checks, ~98% EX294 coverage (incl. ansible-navigator + EE for v9.x)

---

## License

MIT — use freely, contribute back if you find issues or want to add exam tasks.

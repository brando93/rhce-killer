# RHCE Killer 🔴

> The hardest EX294 practice lab you'll find. If you pass this, you pass the real exam.

Inspired by [killer.sh](https://killer.sh) for Kubernetes — but for the **Red Hat Certified Engineer (EX294) Ansible exam**.

---

## What's included

- **Terraform lab** — 3 EC2 instances on AWS (Rocky Linux 9), spun up in 1 command
- **2 full mock exams** — 10 tasks each, same format and difficulty as the real EX294
- **Auto-grader** — tells you your exact score and which tasks failed
- **4-hour timer** — simulates real exam pressure
- **Reset script** — clean slate between attempts, no need to destroy/recreate infra

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

# 7. Start exam 01
bash ~/exams/exam-01/START.sh

# 8. Read the tasks
cat ~/exams/exam-01/README.md

# 9. Work from your ansible directory
cd ~/ansible

# 10. Grade yourself when done
bash ~/exams/exam-01/grade.sh

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

### Exam topics covered (EX294 objectives)

| # | Topic | Exam weight |
|---|-------|-------------|
| 01 | Core components (inventory, cfg, ad-hoc) | 5-10% |
| 02 | Variables, facts, secrets (vault) | 15-20% |
| 03 | Task control (loops, conditions, handlers) | 10-15% |
| 04 | Files and Jinja2 templates | 15% |
| 05 | Roles (create, galaxy, requirements) | 20% |
| 06 | Content collections | 10% |
| 07 | Error handling (block/rescue/always) | 10% |
| 08 | Troubleshooting | 5% |

---

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

## Tips for the real exam

1. **Read all tasks first** — do quick/high-value tasks first
2. **ansible.cfg matters** — always verify `inventory` and `remote_user` are set
3. **Test with `--check` and `--syntax-check`** before running
4. **Vault password file** — always use `--vault-password-file`, never type it
5. **Use `ansible-doc`** — it's available during the exam, use it
6. **Tags save time** — `ansible-playbook site.yml --tags task06`
7. **`ansible_memtotal_mb`** — remember for RAM conditionals
8. **`password_hash('sha512')`** — required for user password tasks

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
│       ├── control.sh          # Bootstrap: Ansible, SSH keys, workspace
│       └── node.sh             # Bootstrap: Python, sudo
├── exam-01/
│   ├── README.md               # 10 tasks, full exam instructions
│   ├── START.sh                # 4-hour timer
│   └── grade.sh                # Auto-grader with colored output
├── exam-02/
│   └── ...                     # Second full mock exam
└── verification/
    └── reset-lab.sh            # Clean slate between attempts
```

---

## License

MIT — use freely, contribute back if you find issues or want to add exam tasks.

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

# 3. Wait ~2 minutes for bootstrap, then SSH in
make ssh

# 4. On the control node — start exam 01
bash ~/exams/exam-01/START.sh

# 5. Read the tasks
cat ~/exams/exam-01/README.md

# 6. Work from your ansible directory
cd ~/ansible

# 7. Grade yourself when done
bash ~/exams/exam-01/grade.sh

# 8. DESTROY the lab when done (stop billing!)
exit
make destroy
```

---

## Lab topology

```
Your Mac
  │
  │ SSH (port 22, your IP only)
  ▼
control.example.com  10.0.1.10  (t3.medium, public IP)
  │
  │ SSH + Ansible (internal only)
  ├──► node1.example.com  10.0.1.11  (t3.micro, private)
  └──► node2.example.com  10.0.1.12  (t3.micro, private)
```

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
make up          # Spin up the lab
make ssh         # SSH into control node
make ssh-student # SSH as student user (exam user)
make status      # Show IPs and instance status
make destroy     # Destroy all resources
make reset       # Reset exam state (keep infra)
make cost        # Show current cost estimate
make ip-update   # Update SG if your IP changed
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

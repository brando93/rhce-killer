# RHCE Killer — Practice Exam 01
## EX294: Red Hat Certified Engineer (Ansible)

---

> **Read carefully before starting.**
> This exam simulates the real EX294 format.
> Time limit: **4 hours**. No internet. No solutions visible.
> Start the timer with: `bash START.sh`

---

## Environment

| Host | IP | Role |
|------|----|------|
| control.example.com | 10.0.1.10 | Control node (you work here) |
| node1.example.com | 10.0.1.11 | Managed node |
| node2.example.com | 10.0.1.12 | Managed node |

Your working directory: `/home/student/ansible/`
Your inventory file: `/home/student/ansible/inventory`
Your config file: `/home/student/ansible/ansible.cfg`

---

## Instructions

- All work must be done as user **student** on **control.example.com**
- All playbooks and files must be created under `/home/student/ansible/`
- Do **not** modify `/etc/ansible/ansible.cfg`
- Playbooks must run without errors and without prompting for passwords
- Each task specifies its point value — partial credit is **not** given

---

## Tasks

### Task 01 — Ad-hoc commands (5 pts)
Using a single `ansible` ad-hoc command, install the package `vim-enhanced`
on all managed nodes. The package must be present after the command runs.

Save the exact command you used in a file called:
`/home/student/ansible/adhoc-vim.sh`

---

### Task 02 — File content (10 pts)
Create a playbook `motd.yml` that:
- Runs on **all managed nodes**
- Creates the file `/etc/motd` with the content:

```
Managed by Ansible. Unauthorized access prohibited.
```

- Sets file owner to `root`, group `root`, mode `0644`

---

### Task 03 — Variables and facts (10 pts)
Create a playbook `facts.yml` that:
- Runs on **all managed nodes**
- Creates the directory `/etc/ansible/facts.d/` on each node
- Deploys a custom fact file `/etc/ansible/facts.d/rhce.fact` with content:

```ini
[exam]
version=1
environment=practice
```

- In the **same playbook**, after deploying the fact, prints the value of
  `ansible_local.rhce.exam.version` using the `debug` module.

---

### Task 04 — Ansible Vault (15 pts)
Create an encrypted variable file at:
`/home/student/ansible/group_vars/all/secret.yml`

The vault password must be stored in: `/home/student/ansible/vault_pass.txt`
(The file must contain only the password string: `RedHatRHCE2024`)

The encrypted file must contain these variables:
```
db_user: dbadmin
db_password: Sup3rS3cur3!
```

Create a playbook `create-user.yml` that:
- Runs on **node1** only
- Creates a user named `{{ db_user }}` with password set to `{{ db_password }}`
  (use the `password_hash` filter with `sha512`)
- The playbook must be runnable with `--vault-password-file vault_pass.txt`

---

### Task 05 — Loops and conditionals (10 pts)
Create a playbook `packages.yml` that installs the following packages
on **all managed nodes**:

- `httpd` — only on hosts in the group `managed`
- `firewalld` — on all hosts
- `mariadb-server` — only if the host has more than **1GB of RAM**
  (use `ansible_memtotal_mb` fact)

All services must be **started and enabled**.

---

### Task 06 — Jinja2 templates (15 pts)
Create a Jinja2 template file: `/home/student/ansible/templates/vhost.conf.j2`

The template must generate an Apache virtual host config:
```
<VirtualHost *:80>
    ServerName {{ ansible_fqdn }}
    DocumentRoot /var/www/{{ ansible_hostname }}
    ErrorLog /var/log/httpd/{{ ansible_hostname }}-error.log
    CustomLog /var/log/httpd/{{ ansible_hostname }}-access.log combined
</VirtualHost>
```

Create a playbook `vhost.yml` that:
- Runs on **all managed nodes**
- Deploys the template to `/etc/httpd/conf.d/vhost.conf`
- Creates the directory `/var/www/{{ ansible_hostname }}/`
- Creates `/var/www/{{ ansible_hostname }}/index.html` with content:
  `Welcome to {{ ansible_fqdn }}`
- Restarts `httpd` only when the template changes (use a handler)

---

### Task 07 — Roles (20 pts)
Create a role called `baseline` under `/home/student/ansible/roles/`:

The role must:
1. Install packages: `firewalld`, `chrony`
2. Start and enable both services
3. Set the system timezone to `America/New_York`
   (use the `community.general.timezone` module)
4. Create a file `/etc/baseline_applied` with the content:
   `Baseline role applied on {{ ansible_date_time.date }}`
5. Add a tag `baseline` to all tasks in the role

Create a playbook `baseline.yml` that applies this role to **all managed nodes**.

---

### Task 08 — Collections and requirements (10 pts)
Create a file `/home/student/ansible/collections/requirements.yml` that
installs the following collections:

- `ansible.posix` version `>= 1.5.0`
- `community.general` version `>= 7.0.0`

Install both collections into `/home/student/ansible/collections/`
using `ansible-galaxy`.

Then create a playbook `posix-demo.yml` that:
- Runs on **node2** only
- Uses `ansible.posix.mount` to create a bind mount of `/tmp` to `/mnt/tmpbind`
  (state: `mounted`, fstype: `none`, opts: `bind`)

---

### Task 09 — Error handling (10 pts)
Create a playbook `error-handling.yml` that:
- Runs on **all managed nodes**
- Attempts to start the service `nonexistent-service`
- **Does not fail** if the service doesn't exist (use `ignore_errors` or `failed_when`)
- Regardless of the above task's result, always creates a file
  `/tmp/health-check-ran` with content `ok`
- Uses a `rescue` block to create `/tmp/service-failed` if the service task fails

---

### Task 10 — Ansible Galaxy role (15 pts)
Download and install the role `geerlingguy.apache` from Ansible Galaxy
into `/home/student/ansible/roles/`.

Create a file `/home/student/ansible/roles/requirements.yml` that
specifies this role as a requirement.

Create a playbook `galaxy-apache.yml` that:
- Runs on **node1** only
- Uses the `geerlingguy.apache` role
- Ensures Apache is running and accessible on port 80

---

## Scoring

| Task | Points |
|------|--------|
| 01 — Ad-hoc | 5 |
| 02 — File content | 10 |
| 03 — Custom facts | 10 |
| 04 — Vault | 15 |
| 05 — Loops/conditionals | 10 |
| 06 — Templates | 15 |
| 07 — Roles | 20 |
| 08 — Collections | 10 |
| 09 — Error handling | 10 |
| 10 — Galaxy role | 15 |
| **Total** | **120** |

**Passing score: 70% (84/120 points)**

---

## When you finish

```bash
bash /home/student/exams/exam-01/grade.sh
```

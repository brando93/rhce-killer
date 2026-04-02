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
| node1.example.com | 10.0.2.11 | Managed node |
| node2.example.com | 10.0.2.12 | Managed node |

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

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Ad-hoc commands

**Step 1:** Run the ad-hoc command to install vim-enhanced:

```bash
ansible managed -m ansible.builtin.dnf -a "name=vim-enhanced state=present" -i inventory --become
```

**Step 2:** Save the command to the required file:

```bash
cat > adhoc-vim.sh << 'EOF'
ansible managed -m ansible.builtin.dnf -a "name=vim-enhanced state=present" -i inventory --become
EOF
```

**Explanation:**
- `managed` targets the managed group from inventory
- `-m ansible.builtin.dnf` uses the DNF module
- `-a "name=vim-enhanced state=present"` specifies package and desired state
- `--become` escalates privileges to root

**Verification:**
```bash
ansible managed -m command -a "rpm -q vim-enhanced" -i inventory
```

---

## Solution 02 — File content

**Create the playbook `motd.yml`:**

```yaml
---
- name: Configure MOTD on managed nodes
  hosts: managed
  become: true

  tasks:
    - name: Create /etc/motd with specific content
      ansible.builtin.copy:
        content: "Managed by Ansible. Unauthorized access prohibited.\n"
        dest: /etc/motd
        owner: root
        group: root
        mode: '0644'
```

**Run the playbook:**
```bash
ansible-playbook motd.yml
```

**Explanation:**
- `ansible.builtin.copy` with `content` parameter creates file with inline content
- `owner`, `group`, and `mode` set file attributes
- `\n` adds newline at end of file

**Verification:**
```bash
ansible managed -m command -a "cat /etc/motd" -i inventory
ansible managed -m command -a "ls -l /etc/motd" -i inventory
```

---

## Solution 03 — Variables and facts

**Create the playbook `facts.yml`:**

```yaml
---
- name: Deploy custom facts
  hosts: managed
  become: true

  tasks:
    - name: Ensure facts.d directory exists
      ansible.builtin.file:
        path: /etc/ansible/facts.d
        state: directory
        mode: '0755'

    - name: Deploy custom fact file
      ansible.builtin.copy:
        content: |
          [exam]
          version=1
          environment=practice
        dest: /etc/ansible/facts.d/rhce.fact
        mode: '0644'

    - name: Reload facts to include custom facts
      ansible.builtin.setup:
        filter: ansible_local

    - name: Display custom fact value
      ansible.builtin.debug:
        var: ansible_local.rhce.exam.version
```

**Run the playbook:**
```bash
ansible-playbook facts.yml
```

**Explanation:**
- First task creates the facts.d directory
- Second task deploys the .fact file with INI format
- `ansible.builtin.setup` with filter reloads facts
- Custom facts are accessed via `ansible_local.<filename>.<section>.<key>`

**Verification:**
```bash
ansible managed -m setup -a "filter=ansible_local" -i inventory
```

---

## Solution 04 — Ansible Vault

**Step 1:** Create the vault password file:

```bash
echo "RedHatRHCE2024" > vault_pass.txt
chmod 600 vault_pass.txt
```

**Step 2:** Create the group_vars directory structure:

```bash
mkdir -p group_vars/all
```

**Step 3:** Create and encrypt the secret file:

```bash
cat > group_vars/all/secret.yml << 'EOF'
db_user: dbadmin
db_password: Sup3rS3cur3!
EOF

ansible-vault encrypt group_vars/all/secret.yml --vault-password-file vault_pass.txt
```

**Step 4:** Create the playbook `create-user.yml`:

```yaml
---
- name: Create database user
  hosts: node1.example.com
  become: true

  tasks:
    - name: Create user with encrypted password
      ansible.builtin.user:
        name: "{{ db_user }}"
        password: "{{ db_password | password_hash('sha512') }}"
        state: present
```

**Step 5:** Run the playbook:

```bash
ansible-playbook create-user.yml --vault-password-file vault_pass.txt
```

**Explanation:**
- Vault password file contains only the password string
- `ansible-vault encrypt` encrypts the file
- `password_hash('sha512')` filter creates hashed password
- Playbook automatically reads encrypted vars from group_vars/all/

**Verification:**
```bash
ansible node1.example.com -m command -a "id dbadmin" -i inventory
ansible-vault view group_vars/all/secret.yml --vault-password-file vault_pass.txt
```

---

## Solution 05 — Loops and conditionals

**Create the playbook `packages.yml`:**

```yaml
---
- name: Install and configure packages
  hosts: managed
  become: true

  tasks:
    - name: Install httpd on managed group
      ansible.builtin.dnf:
        name: httpd
        state: present
      when: inventory_hostname in groups['managed']

    - name: Install firewalld on all hosts
      ansible.builtin.dnf:
        name: firewalld
        state: present

    - name: Install mariadb-server if RAM > 1GB
      ansible.builtin.dnf:
        name: mariadb-server
        state: present
      when: ansible_memtotal_mb > 1024

    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
      when: inventory_hostname in groups['managed']

    - name: Start and enable firewalld
      ansible.builtin.service:
        name: firewalld
        state: started
        enabled: true

    - name: Start and enable mariadb
      ansible.builtin.service:
        name: mariadb
        state: started
        enabled: true
      when: ansible_memtotal_mb > 1024
```

**Run the playbook:**
```bash
ansible-playbook packages.yml
```

**Explanation:**
- `when: inventory_hostname in groups['managed']` checks group membership
- `when: ansible_memtotal_mb > 1024` checks RAM (1024 MB = 1 GB)
- Each service must be started and enabled separately

**Verification:**
```bash
ansible managed -m command -a "systemctl is-active httpd" -i inventory
ansible managed -m command -a "systemctl is-active firewalld" -i inventory
ansible managed -m command -a "systemctl is-enabled firewalld" -i inventory
```

---

## Solution 06 — Jinja2 templates

**Step 1:** Create the templates directory:

```bash
mkdir -p templates
```

**Step 2:** Create the template `templates/vhost.conf.j2`:

```jinja2
<VirtualHost *:80>
    ServerName {{ ansible_fqdn }}
    DocumentRoot /var/www/{{ ansible_hostname }}
    ErrorLog /var/log/httpd/{{ ansible_hostname }}-error.log
    CustomLog /var/log/httpd/{{ ansible_hostname }}-access.log combined
</VirtualHost>
```

**Step 3:** Create the playbook `vhost.yml`:

```yaml
---
- name: Configure Apache virtual hosts
  hosts: managed
  become: true

  tasks:
    - name: Deploy vhost configuration from template
      ansible.builtin.template:
        src: templates/vhost.conf.j2
        dest: /etc/httpd/conf.d/vhost.conf
        owner: root
        group: root
        mode: '0644'
      notify: Restart httpd

    - name: Create document root directory
      ansible.builtin.file:
        path: "/var/www/{{ ansible_hostname }}"
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Create index.html
      ansible.builtin.copy:
        content: "Welcome to {{ ansible_fqdn }}\n"
        dest: "/var/www/{{ ansible_hostname }}/index.html"
        owner: root
        group: root
        mode: '0644'

  handlers:
    - name: Restart httpd
      ansible.builtin.service:
        name: httpd
        state: restarted
```

**Run the playbook:**
```bash
ansible-playbook vhost.yml
```

**Explanation:**
- Template uses Jinja2 variables: `{{ ansible_fqdn }}` and `{{ ansible_hostname }}`
- `notify` triggers handler only when template changes
- Handler restarts httpd service
- Facts are automatically gathered and available in templates

**Verification:**
```bash
ansible managed -m command -a "cat /etc/httpd/conf.d/vhost.conf" -i inventory
ansible managed -m command -a "cat /var/www/node1/index.html" -i inventory --limit node1.example.com
```

---

## Solution 07 — Roles

**Step 1:** Create the role structure:

```bash
ansible-galaxy init roles/baseline
```

**Step 2:** Edit `roles/baseline/tasks/main.yml`:

```yaml
---
# tasks file for baseline
- name: Install required packages
  ansible.builtin.dnf:
    name:
      - firewalld
      - chrony
    state: present
  tags: baseline

- name: Start and enable firewalld
  ansible.builtin.service:
    name: firewalld
    state: started
    enabled: true
  tags: baseline

- name: Start and enable chronyd
  ansible.builtin.service:
    name: chronyd
    state: started
    enabled: true
  tags: baseline

- name: Set timezone to America/New_York
  community.general.timezone:
    name: America/New_York
  tags: baseline

- name: Create baseline_applied file
  ansible.builtin.copy:
    content: "Baseline role applied on {{ ansible_date_time.date }}\n"
    dest: /etc/baseline_applied
    owner: root
    group: root
    mode: '0644'
  tags: baseline
```

**Step 3:** Create the playbook `baseline.yml`:

```yaml
---
- name: Apply baseline configuration
  hosts: managed
  become: true

  roles:
    - baseline
```

**Run the playbook:**
```bash
ansible-playbook baseline.yml
```

**Run with tags (optional):**
```bash
ansible-playbook baseline.yml --tags baseline
```

**Explanation:**
- `ansible-galaxy init` creates role directory structure
- All tasks in role have `tags: baseline`
- `community.general.timezone` module requires community.general collection
- Role is applied using `roles:` section in playbook

**Verification:**
```bash
ansible managed -m command -a "systemctl is-active chronyd" -i inventory
ansible managed -m command -a "timedatectl" -i inventory
ansible managed -m command -a "cat /etc/baseline_applied" -i inventory
```

---

## Solution 08 — Collections and requirements

**Step 1:** Create collections directory:

```bash
mkdir -p collections
```

**Step 2:** Create `collections/requirements.yml`:

```yaml
---
collections:
  - name: ansible.posix
    version: ">=1.5.0"
  
  - name: community.general
    version: ">=7.0.0"
```

**Step 3:** Install the collections:

```bash
ansible-galaxy collection install -r collections/requirements.yml -p collections/
```

**Step 4:** Create the playbook `posix-demo.yml`:

```yaml
---
- name: Demonstrate ansible.posix.mount module
  hosts: node2.example.com
  become: true

  tasks:
    - name: Create mount point directory
      ansible.builtin.file:
        path: /mnt/tmpbind
        state: directory
        mode: '0755'

    - name: Create bind mount of /tmp
      ansible.posix.mount:
        path: /mnt/tmpbind
        src: /tmp
        fstype: none
        opts: bind
        state: mounted
```

**Run the playbook:**
```bash
ansible-playbook posix-demo.yml
```

**Explanation:**
- Collections requirements file specifies version constraints
- `-p collections/` installs to local collections directory
- `ansible.posix.mount` is FQCN (Fully Qualified Collection Name)
- Bind mount requires `fstype: none` and `opts: bind`

**Verification:**
```bash
ansible-galaxy collection list --collections-path collections/
ansible node2.example.com -m command -a "mount | grep tmpbind" -i inventory
ansible node2.example.com -m command -a "df -h /mnt/tmpbind" -i inventory
```

---

## Solution 09 — Error handling

**Create the playbook `error-handling.yml`:**

```yaml
---
- name: Demonstrate error handling
  hosts: managed
  become: true

  tasks:
    - name: Block for error handling
      block:
        - name: Attempt to start nonexistent service
          ansible.builtin.service:
            name: nonexistent-service
            state: started

      rescue:
        - name: Create service-failed file in rescue block
          ansible.builtin.copy:
            content: "Service start failed\n"
            dest: /tmp/service-failed
            mode: '0644'

      always:
        - name: Always create health-check-ran file
          ansible.builtin.copy:
            content: "ok\n"
            dest: /tmp/health-check-ran
            mode: '0644'
```

**Run the playbook:**
```bash
ansible-playbook error-handling.yml
```

**Explanation:**
- `block:` groups tasks that might fail
- `rescue:` runs only if block tasks fail
- `always:` runs regardless of success or failure
- No `ignore_errors` needed because rescue handles the failure

**Verification:**
```bash
ansible managed -m command -a "cat /tmp/health-check-ran" -i inventory
ansible managed -m command -a "cat /tmp/service-failed" -i inventory
ansible managed -m command -a "ls -l /tmp/health-check-ran /tmp/service-failed" -i inventory
```

---

## Solution 10 — Ansible Galaxy role

**Step 1:** Create `roles/requirements.yml`:

```yaml
---
roles:
  - name: geerlingguy.apache
    version: 3.2.0
```

**Step 2:** Install the role:

```bash
ansible-galaxy role install -r roles/requirements.yml -p roles/
```

**Step 3:** Create the playbook `galaxy-apache.yml`:

```yaml
---
- name: Install Apache using Galaxy role
  hosts: node1.example.com
  become: true

  roles:
    - geerlingguy.apache
```

**Run the playbook:**
```bash
ansible-playbook galaxy-apache.yml
```

**Explanation:**
- Galaxy roles are specified in roles/requirements.yml
- `-p roles/` installs to local roles directory
- Role name in playbook matches installed role name
- geerlingguy.apache role handles Apache installation and configuration

**Verification:**
```bash
ansible-galaxy role list -p roles/
ansible node1.example.com -m command -a "systemctl is-active httpd" -i inventory
ansible node1.example.com -m uri -a "url=http://node1.example.com status_code=200" -i inventory
```

---

## 🎯 Tips for Success

### General Best Practices
1. **Always test your playbooks** with `--syntax-check` first
2. **Use `--check` mode** for dry runs before actual execution
3. **Read error messages carefully** - they usually tell you what's wrong
4. **Use `ansible-doc`** to check module parameters
5. **Verify after each task** - don't wait until the end

### Common Mistakes to Avoid
- Forgetting `become: true` for tasks requiring root
- Not using FQCN for modules (e.g., `ansible.builtin.copy`)
- Incorrect indentation in YAML (use spaces, not tabs)
- Missing `--vault-password-file` when running vault-encrypted playbooks
- Not reloading facts after deploying custom facts

### Time Management
- **Read all tasks first** (5 minutes)
- **Do quick tasks first** (Tasks 01, 02, 03)
- **Leave complex tasks for later** (Tasks 07, 10)
- **Save 30 minutes** at the end for verification and fixes

### Verification Commands
```bash
# Check syntax
ansible-playbook playbook.yml --syntax-check

# Dry run
ansible-playbook playbook.yml --check

# List tasks
ansible-playbook playbook.yml --list-tasks

# Run with tags
ansible-playbook playbook.yml --tags tagname

# Increase verbosity
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vv
```

---

## 📖 Additional Resources

### Ansible Documentation Commands
```bash
# List all modules
ansible-doc -l

# Get help for specific module
ansible-doc ansible.builtin.copy
ansible-doc ansible.builtin.template
ansible-doc ansible.builtin.user

# List collections
ansible-galaxy collection list

# List roles
ansible-galaxy role list
```

### Useful Ansible Facts
```bash
# View all facts
ansible hostname -m setup

# Filter specific facts
ansible hostname -m setup -a "filter=ansible_memtotal_mb"
ansible hostname -m setup -a "filter=ansible_distribution*"
ansible hostname -m setup -a "filter=ansible_fqdn"
```

---

**Good luck with your RHCE exam preparation! 🚀**

# RHCE Killer — Roles Basics
## EX294: Mastering Ansible Roles

---

> **Intermediate Exam: Role Fundamentals**
> This exam teaches you how to create and use Ansible roles.
> Master role structure, tasks, handlers, variables, and defaults.
> Time limit: **3 hours**. Start the timer with: `bash START.sh`

---

## Environment

| Host | IP | Role |
|------|----|------|
| control.example.com | 10.0.1.10 | Control node (you work here) |
| node1.example.com | 10.0.2.11 | Managed node (Rocky Linux 9) |
| node2.example.com | 10.0.2.12 | Managed node (Rocky Linux 9) |

Your working directory: `/home/student/ansible/`
Your inventory file: `/home/student/ansible/inventory`
Your config file: `/home/student/ansible/ansible.cfg`
Your roles directory: `/home/student/ansible/roles/`

---

## Instructions

- All work must be done as user **student** on **control.example.com**
- All roles must be created under `/home/student/ansible/roles/`
- Playbooks must be created under `/home/student/ansible/`
- Roles must follow standard directory structure
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, variables-and-facts, jinja2-basics

You should know:
- How to write playbooks
- How to use variables
- How to use templates
- Basic file operations

---

## Tasks

### Task 01 — Create Basic Role Structure (15 pts)

Create a role named `webserver` with proper directory structure:
```
roles/webserver/
  tasks/
  handlers/
  templates/
  files/
  vars/
  defaults/
  meta/
```

Use `ansible-galaxy init` command.

**Requirements:**
- Use `ansible-galaxy init`
- Create in `/home/student/ansible/roles/`
- All standard directories present
- Proper structure

---

### Task 02 — Role with Tasks (15 pts)

Create a role `apache` that:
- Installs `httpd` package
- Starts and enables `httpd` service
- Creates tasks in `tasks/main.yml`

Create playbook `use-apache.yml` that applies the role to all managed nodes.

**Requirements:**
- Role in `roles/apache/`
- Tasks in `tasks/main.yml`
- Playbook uses role
- Service running

---

### Task 03 — Role with Handler (18 pts)

Create a role `nginx` that:
- Installs `nginx` package
- Copies config file to `/etc/nginx/nginx.conf`
- Notifies handler to restart nginx
- Handler defined in `handlers/main.yml`

**Requirements:**
- Role in `roles/nginx/`
- Handler restarts service
- Config change triggers handler
- Use notify

---

### Task 04 — Role with Template (20 pts)

Create a role `webapp` that:
- Creates template `index.html.j2` with:
  ```html
  <h1>Server: {{ inventory_hostname }}</h1>
  <p>Environment: {{ app_env }}</p>
  ```
- Deploys to `/var/www/html/index.html`
- Uses template from `templates/` directory

**Requirements:**
- Template in `templates/index.html.j2`
- Task uses template module
- Variables substituted
- File deployed

---

### Task 05 — Role with Files (15 pts)

Create a role `static` that:
- Copies static file `logo.txt` from `files/` directory
- Deploys to `/var/www/html/logo.txt`
- File contains: "Company Logo"

**Requirements:**
- File in `files/logo.txt`
- Task uses copy module with src
- File deployed to managed nodes

---

### Task 06 — Role with Default Variables (18 pts)

Create a role `database` that:
- Defines default variables in `defaults/main.yml`:
  ```yaml
  db_port: 3306
  db_name: mydb
  ```
- Creates config file using these variables
- Variables can be overridden

**Requirements:**
- Defaults in `defaults/main.yml`
- Task uses variables
- Can override in playbook
- Lowest precedence

---

### Task 07 — Role with Vars (18 pts)

Create a role `cache` under `/home/student/ansible/roles/cache` that
configures an in-memory cache config file on every managed node. The
goal is to see how `vars/main.yml` takes precedence over `defaults/main.yml`.

- Create `defaults/main.yml` with:
  ```yaml
  cache_port: 6379
  cache_maxmemory: 128mb
  cache_bind: 127.0.0.1
  ```
- Create `vars/main.yml` with HIGHER precedence values:
  ```yaml
  cache_port: 6380
  cache_maxmemory: 256mb
  ```
- `tasks/main.yml` deploys `/etc/cache.conf` using `ansible.builtin.copy`
  with `content:` rendering each variable, e.g.:
  ```
  port = 6380
  maxmemory = 256mb
  bind = 127.0.0.1
  ```
- Owner `root`, mode `0644`
- Notice that `cache_bind` comes from defaults (not overridden) while
  `cache_port` and `cache_maxmemory` come from `vars/main.yml`

Create a playbook `cache.yml` at `/home/student/ansible/` that applies
the role to `managed` with `become: true`.

After running, on any managed node you should see:
```bash
cat /etc/cache.conf
# port = 6380
# maxmemory = 256mb
# bind = 127.0.0.1
```

---

### Task 08 — Role Dependencies (20 pts)

You'll create THREE roles that depend on each other to demonstrate the
`dependencies:` mechanism. The goal: when you apply only the top role,
the dependencies execute first automatically.

- Create role `base` at `/home/student/ansible/roles/base`. Its
  `tasks/main.yml` writes `/tmp/base-installed.txt` with content
  `base role ran at {{ ansible_date_time.iso8601 }}`.
- Create role `apache` at `/home/student/ansible/roles/apache`. Its
  `tasks/main.yml` writes `/tmp/apache-installed.txt` with content
  `apache role ran at {{ ansible_date_time.iso8601 }}`.
- Create role `wordpress` at `/home/student/ansible/roles/wordpress`:
  - `meta/main.yml` declares dependencies on `base` AND `apache`
    using the `dependencies:` key
  - `tasks/main.yml` writes `/tmp/wordpress-installed.txt` with content
    `wordpress role ran at {{ ansible_date_time.iso8601 }}`

Create a playbook `wordpress.yml` that applies ONLY the `wordpress` role
to `managed` with `become: true`. Running it must produce all three
output files on every managed node, in this execution order: `base` →
`apache` → `wordpress` (you can verify by comparing the timestamps).

After running, on any managed node:
```bash
ls -la /tmp/*-installed.txt
head -1 /tmp/base-installed.txt
head -1 /tmp/apache-installed.txt
head -1 /tmp/wordpress-installed.txt
```

---

### Task 09 — Role with Multiple Task Files (20 pts)

Create role `fullstack` at `/home/student/ansible/roles/fullstack` that
splits its work across three task files instead of one giant
`main.yml`. The role installs and configures a simple Apache web stack
on every managed node.

Required files:
- `tasks/main.yml` — orchestrator only; uses `import_tasks` to pull in
  the three files below in order:
  ```yaml
  ---
  - name: Install packages
    ansible.builtin.import_tasks: install.yml

  - name: Configure application
    ansible.builtin.import_tasks: configure.yml

  - name: Start service
    ansible.builtin.import_tasks: service.yml
  ```
- `tasks/install.yml` — installs `httpd` package via `ansible.builtin.dnf`
- `tasks/configure.yml` — uses `ansible.builtin.copy` to deploy
  `/var/www/html/index.html` with content:
  ```
  Fullstack role from {{ ansible_hostname }} — phase: configure OK
  ```
- `tasks/service.yml` — starts and enables `httpd` via
  `ansible.builtin.service`

Create a playbook `fullstack.yml` at `/home/student/ansible/` that
applies the role to `managed` with `become: true`.

After running, on any managed node:
```bash
systemctl is-active httpd       # active
curl -s http://localhost        # Fullstack role from node1 — phase: configure OK
```

---

### Task 10 — Apply Role to Specific Hosts (15 pts)

Create playbook `apply-managed.yml` at `/home/student/ansible/` that
applies the `apache` role from Task 08 ONLY to the `managed` group
(the only managed-node group in your inventory besides `control`).

- `hosts: managed` (NOT `all`, NOT `webservers` — they don't exist
  in this lab inventory)
- `become: true`
- `roles:` section lists `apache`
- The play must NOT touch the control node

After running, the apache role's marker file must exist on every
managed node and NOT on control:
```bash
ansible managed -b -m shell -a 'test -f /tmp/apache-installed.txt && echo present'
# node1.example.com | CHANGED | rc=0 >>
# present
# node2.example.com | CHANGED | rc=0 >>
# present

ansible control -b -m shell -a 'test -f /tmp/apache-installed.txt'
# control.example.com | FAILED | rc=1  (file should NOT exist)
```

---

### Task 11 — Role with Tags (18 pts)

Create role `monitoring` at `/home/student/ansible/roles/monitoring`
that demonstrates per-task tagging. The role installs a lightweight
metrics agent **using packages that actually exist in the lab's repos**
(no Nagios or Prometheus — they need external repos that aren't enabled).

Split the work into three task files like Task 09, with each `import_tasks`
call tagged separately:

- `tasks/main.yml`:
  ```yaml
  ---
  - name: Install metrics agent
    ansible.builtin.import_tasks: install.yml
    tags: [install]

  - name: Configure metrics agent
    ansible.builtin.import_tasks: config.yml
    tags: [config]

  - name: Manage service
    ansible.builtin.import_tasks: service.yml
    tags: [service]
  ```
- `tasks/install.yml` — installs `sysstat` via `ansible.builtin.dnf`
  (ships in BaseOS/AppStream, no extra repo needed)
- `tasks/config.yml` — uses `ansible.builtin.lineinfile` to set
  `ENABLED="true"` in `/etc/sysconfig/sysstat`
- `tasks/service.yml` — starts and enables the `sysstat` service via
  `ansible.builtin.service`

Create a playbook `monitoring.yml` at `/home/student/ansible/` that
applies the role to `managed` with `become: true`.

The grader will run the play three times with different tag selectors
to confirm each task file runs independently:

```bash
# Only the install file:
ansible-playbook monitoring.yml --tags install

# Only the config file:
ansible-playbook monitoring.yml --tags config

# Skip the service file:
ansible-playbook monitoring.yml --skip-tags service

# Full run:
ansible-playbook monitoring.yml
```

After a full run, on any managed node:
```bash
rpm -q sysstat                            # sysstat-X.Y.Z
grep '^ENABLED' /etc/sysconfig/sysstat    # ENABLED="true"
systemctl is-active sysstat               # active
```

---

### Task 12 — Role with Conditionals (18 pts)

Create role `firewall` that:
- Installs firewalld only on Rocky Linux
- Uses `when: ansible_distribution == "Rocky"`
- Skips on other distributions

**Requirements:**
- Conditional in tasks
- OS-specific logic
- Skips when condition false
- Proper when clause

---

### Task 13 — Role with Loops (15 pts)

Create role `users` that:
- Creates multiple users from list
- List defined in `defaults/main.yml`:
  ```yaml
  user_list:
    - alice
    - bob
    - charlie
  ```
- Uses loop in task

**Requirements:**
- Loop in task
- List in defaults
- All users created
- Proper loop syntax

---

### Task 14 — Role with Blocks (18 pts)

Create role `secure` that:
- Uses block/rescue/always
- Block installs security packages
- Rescue handles failures
- Always displays message

**Requirements:**
- Block structure in tasks
- Rescue section present
- Always section present
- Error handling

---

### Task 15 — Multiple Roles in Playbook (20 pts)

Create playbook `full-stack.yml` that:
- Applies multiple roles:
  - `apache`
  - `database`
  - `cache`
- Runs on all managed nodes
- Roles run in order

**Requirements:**
- Multiple roles listed
- Proper syntax
- All roles execute
- Correct order

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Basic Role Structure | 15 |
| 02 | Role with Tasks | 15 |
| 03 | Role with Handler | 18 |
| 04 | Role with Template | 20 |
| 05 | Role with Files | 15 |
| 06 | Default Variables | 18 |
| 07 | Vars Variables | 18 |
| 08 | Role Dependencies | 20 |
| 09 | Multiple Task Files | 20 |
| 10 | Apply to Specific Hosts | 15 |
| 11 | Role with Tags | 18 |
| 12 | Role with Conditionals | 18 |
| 13 | Role with Loops | 15 |
| 14 | Role with Blocks | 18 |
| 15 | Multiple Roles | 20 |
| **Total** | | **263** |

**Passing score: 70% (184/263 points)**

---

## When you finish

```bash
bash /home/student/exams/roles-basics/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

---

## Solution 01 — Create Basic Role Structure

```bash
# Navigate to roles directory
cd /home/student/ansible/roles

# Create role structure
ansible-galaxy init webserver

# Verify structure
tree webserver
```

**Expected structure:**
```
webserver/
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```

**Explanation:**
- `ansible-galaxy init` creates standard structure
- All directories created automatically
- YAML files have basic structure
- Ready to add content

---

## Solution 02 — Role with Tasks

```bash
# Create role
cd /home/student/ansible/roles
ansible-galaxy init apache
```

**File: roles/apache/tasks/main.yml**
```yaml
---
- name: Install httpd
  ansible.builtin.dnf:
    name: httpd
    state: present

- name: Start and enable httpd
  ansible.builtin.service:
    name: httpd
    state: started
    enabled: true
```

**Playbook: use-apache.yml**
```yaml
---
- name: Apply apache role
  hosts: all
  become: true
  
  roles:
    - apache
```

**Run:**
```bash
ansible-playbook use-apache.yml
```

---

## Solution 03 — Role with Handler

```bash
# Create role
ansible-galaxy init nginx
```

**File: roles/nginx/tasks/main.yml**
```yaml
---
- name: Install nginx
  ansible.builtin.dnf:
    name: nginx
    state: present

- name: Copy nginx config
  ansible.builtin.copy:
    src: nginx.conf
    dest: /etc/nginx/nginx.conf
    mode: '0644'
  notify: restart nginx
```

**File: roles/nginx/handlers/main.yml**
```yaml
---
- name: restart nginx
  ansible.builtin.service:
    name: nginx
    state: restarted
```

**File: roles/nginx/files/nginx.conf**
```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
        }
    }
}
```

---

## Solution 04 — Role with Template

```bash
# Create role
ansible-galaxy init webapp
```

**File: roles/webapp/templates/index.html.j2**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Web Application</title>
</head>
<body>
    <h1>Server: {{ inventory_hostname }}</h1>
    <p>Environment: {{ app_env }}</p>
</body>
</html>
```

**File: roles/webapp/tasks/main.yml**
```yaml
---
- name: Deploy index.html from template
  ansible.builtin.template:
    src: index.html.j2
    dest: /var/www/html/index.html
    mode: '0644'
```

**File: roles/webapp/defaults/main.yml**
```yaml
---
app_env: production
```

**Playbook: use-webapp.yml**
```yaml
---
- name: Apply webapp role
  hosts: all
  become: true
  
  roles:
    - webapp
```

---

## Solution 05 — Role with Files

```bash
# Create role
ansible-galaxy init static
```

**File: roles/static/files/logo.txt**
```
Company Logo
```

**File: roles/static/tasks/main.yml**
```yaml
---
- name: Copy logo file
  ansible.builtin.copy:
    src: logo.txt
    dest: /var/www/html/logo.txt
    mode: '0644'
```

**Explanation:**
- Files in `files/` directory
- `copy` module with `src` (no path needed)
- Ansible finds file automatically
- Deployed to destination

---

## Solution 06 — Role with Default Variables

```bash
# Create role
ansible-galaxy init database
```

**File: roles/database/defaults/main.yml**
```yaml
---
db_port: 3306
db_name: mydb
db_user: dbuser
```

**File: roles/database/tasks/main.yml**
```yaml
---
- name: Create database config
  ansible.builtin.copy:
    content: |
      [database]
      port={{ db_port }}
      name={{ db_name }}
      user={{ db_user }}
    dest: /etc/db.conf
    mode: '0644'
```

**Playbook with override:**
```yaml
---
- name: Apply database role
  hosts: all
  become: true
  
  roles:
    - role: database
      db_port: 5432
      db_name: customdb
```

---

## Solution 07 — Role with Vars

**Create the skeleton:**
```bash
cd /home/student/ansible
ansible-galaxy init roles/cache
```

**File: roles/cache/defaults/main.yml**
```yaml
---
cache_port: 6379
cache_maxmemory: 128mb
cache_bind: 127.0.0.1
```

**File: roles/cache/vars/main.yml**
```yaml
---
# These OVERRIDE the defaults (vars has higher precedence)
cache_port: 6380
cache_maxmemory: 256mb
```

**File: roles/cache/tasks/main.yml**
```yaml
---
- name: Deploy /etc/cache.conf
  ansible.builtin.copy:
    content: |
      port = {{ cache_port }}
      maxmemory = {{ cache_maxmemory }}
      bind = {{ cache_bind }}
    dest: /etc/cache.conf
    owner: root
    group: root
    mode: '0644'
```

**File: /home/student/ansible/cache.yml**
```yaml
---
- name: Apply cache role
  hosts: managed
  become: true
  roles:
    - cache
```

**Run and verify:**
```bash
ansible-playbook cache.yml
ansible managed -b -m shell -a 'cat /etc/cache.conf'
# Output:
# port = 6380          ← from vars/main.yml
# maxmemory = 256mb    ← from vars/main.yml
# bind = 127.0.0.1     ← from defaults/main.yml
```

**Explanation:**
- `defaults/main.yml` is the LOWEST precedence — easy to override
- `vars/main.yml` is HIGH precedence — hard to override (only command-line
  `--extra-vars` beats it)
- `cache_bind` isn't redeclared in `vars/main.yml`, so the default wins
- Use `vars/` for role-specific values that shouldn't change across deployments

---

## Solution 08 — Role Dependencies

**Create the three roles:**
```bash
cd /home/student/ansible
ansible-galaxy init roles/base
ansible-galaxy init roles/apache
ansible-galaxy init roles/wordpress
```

**File: roles/base/tasks/main.yml**
```yaml
---
- name: Mark base role execution
  ansible.builtin.copy:
    content: "base role ran at {{ ansible_date_time.iso8601 }}\n"
    dest: /tmp/base-installed.txt
    mode: '0644'
```

**File: roles/apache/tasks/main.yml**
```yaml
---
- name: Mark apache role execution
  ansible.builtin.copy:
    content: "apache role ran at {{ ansible_date_time.iso8601 }}\n"
    dest: /tmp/apache-installed.txt
    mode: '0644'
```

**File: roles/wordpress/meta/main.yml**
```yaml
---
dependencies:
  - role: base
  - role: apache
```

**File: roles/wordpress/tasks/main.yml**
```yaml
---
- name: Mark wordpress role execution
  ansible.builtin.copy:
    content: "wordpress role ran at {{ ansible_date_time.iso8601 }}\n"
    dest: /tmp/wordpress-installed.txt
    mode: '0644'
```

**File: /home/student/ansible/wordpress.yml**
```yaml
---
- name: Deploy wordpress (with auto-resolved dependencies)
  hosts: managed
  become: true
  roles:
    - wordpress
```

**Run and verify:**
```bash
ansible-playbook wordpress.yml
ansible managed -b -m shell -a 'ls -la /tmp/*-installed.txt'
ansible node1.example.com -b -m shell -a 'head -1 /tmp/base-installed.txt'
ansible node1.example.com -b -m shell -a 'head -1 /tmp/apache-installed.txt'
ansible node1.example.com -b -m shell -a 'head -1 /tmp/wordpress-installed.txt'
```

The timestamps confirm the execution order: base → apache → wordpress.

**Explanation:**
- `meta/main.yml` dependencies run BEFORE the role itself
- Order in `dependencies:` is preserved (base first, then apache)
- The playbook only references `wordpress`; the others are pulled in automatically
- Each role's marker file lets you SEE that all 3 actually ran (no silent magic)

---

## Solution 09 — Role with Multiple Task Files

**Create the skeleton:**
```bash
cd /home/student/ansible
ansible-galaxy init roles/fullstack
```

**File: roles/fullstack/tasks/main.yml**
```yaml
---
- name: Install packages
  ansible.builtin.import_tasks: install.yml

- name: Configure application
  ansible.builtin.import_tasks: configure.yml

- name: Start service
  ansible.builtin.import_tasks: service.yml
```

**File: roles/fullstack/tasks/install.yml**
```yaml
---
- name: Install httpd
  ansible.builtin.dnf:
    name: httpd
    state: present
```

**File: roles/fullstack/tasks/configure.yml**
```yaml
---
- name: Deploy index.html
  ansible.builtin.copy:
    content: "Fullstack role from {{ ansible_hostname }} — phase: configure OK\n"
    dest: /var/www/html/index.html
    owner: root
    group: root
    mode: '0644'
```

**File: roles/fullstack/tasks/service.yml**
```yaml
---
- name: Start and enable httpd
  ansible.builtin.service:
    name: httpd
    state: started
    enabled: true
```

**File: /home/student/ansible/fullstack.yml**
```yaml
---
- name: Apply fullstack role
  hosts: managed
  become: true
  roles:
    - fullstack
```

**Run and verify:**
```bash
ansible-playbook fullstack.yml
ansible managed -b -m shell -a 'systemctl is-active httpd'
ansible managed -b -m shell -a 'curl -s http://localhost'
# Fullstack role from node1 — phase: configure OK
# Fullstack role from node2 — phase: configure OK
```

**Explanation:**
- `main.yml` becomes a thin orchestrator — easy to reason about
- `import_tasks` is STATIC (resolved at parse time); use `include_tasks`
  if you need dynamic decisions (`when:`, `loop:`)
- Splitting by phase (install / configure / service) is the canonical role layout
- The curl output proves each phase actually ran

---

## Solution 10 — Apply Role to Specific Hosts

**File: /home/student/ansible/apply-managed.yml**
```yaml
---
- name: Apply apache role only to managed hosts
  hosts: managed
  become: true
  roles:
    - apache
```

**Run and verify:**
```bash
ansible-playbook apply-managed.yml

# Marker file present on every managed node:
ansible managed -b -m shell -a 'test -f /tmp/apache-installed.txt && echo present'

# Marker file NOT present on control:
ansible control -b -m shell -a 'test -f /tmp/apache-installed.txt'
# Expected: rc=1 (file does not exist)
```

**Explanation:**
- `hosts: managed` matches ONLY the inventory's `[managed]` group
- The control node (in group `[control]`) is excluded automatically
- `webservers` does NOT exist in this lab's inventory — targeting it
  would produce an empty host list and a no-op play
- Verification check confirms BOTH conditions: present on managed, absent on control

---

## Solution 11 — Role with Tags

**Create the skeleton:**
```bash
cd /home/student/ansible
ansible-galaxy init roles/monitoring
```

**File: roles/monitoring/tasks/main.yml**
```yaml
---
- name: Install metrics agent
  ansible.builtin.import_tasks: install.yml
  tags: [install]

- name: Configure metrics agent
  ansible.builtin.import_tasks: config.yml
  tags: [config]

- name: Manage service
  ansible.builtin.import_tasks: service.yml
  tags: [service]
```

**File: roles/monitoring/tasks/install.yml**
```yaml
---
- name: Install sysstat (ships in BaseOS/AppStream — no extra repo needed)
  ansible.builtin.dnf:
    name: sysstat
    state: present
```

**File: roles/monitoring/tasks/config.yml**
```yaml
---
- name: Enable sysstat data collection
  ansible.builtin.lineinfile:
    path: /etc/sysconfig/sysstat
    regexp: '^ENABLED='
    line: 'ENABLED="true"'
    create: true
    mode: '0644'
```

**File: roles/monitoring/tasks/service.yml**
```yaml
---
- name: Start and enable sysstat
  ansible.builtin.service:
    name: sysstat
    state: started
    enabled: true
```

**File: /home/student/ansible/monitoring.yml**
```yaml
---
- name: Apply monitoring role
  hosts: managed
  become: true
  roles:
    - monitoring
```

**Run with different tag selectors:**
```bash
# Only install (sysstat package installed, nothing else):
ansible-playbook monitoring.yml --tags install

# Only config (lineinfile runs, no install or service):
ansible-playbook monitoring.yml --tags config

# Skip the service start:
ansible-playbook monitoring.yml --skip-tags service

# Full run:
ansible-playbook monitoring.yml
```

**Verify after a full run:**
```bash
ansible managed -b -m shell -a 'rpm -q sysstat'
ansible managed -b -m shell -a "grep '^ENABLED' /etc/sysconfig/sysstat"
ansible managed -b -m shell -a 'systemctl is-active sysstat'
# Expected: sysstat-X.Y.Z, ENABLED="true", active
```

**Explanation:**
- `tags:` on `import_tasks` propagates to every task inside the imported file
- Tagging at the file level (vs per-task) keeps `main.yml` clean
- `sysstat` is in BaseOS/AppStream — works without enabling any extra repo
  (unlike Nagios or Prometheus which need EPEL or upstream repos that
  aren't preconfigured in the lab)
- `--tags X` runs ONLY tasks tagged X; `--skip-tags X` runs everything EXCEPT X
- This is the standard pattern for "install-only" or "config-only" reruns
  during exam tasks

---

## Solution 12 — Role with Conditionals

```bash
# Create role
ansible-galaxy init firewall
```

**File: roles/firewall/tasks/main.yml**
```yaml
---
- name: Install firewalld on Rocky Linux
  ansible.builtin.dnf:
    name: firewalld
    state: present
  when: ansible_distribution == "Rocky"

- name: Start firewalld on Rocky Linux
  ansible.builtin.service:
    name: firewalld
    state: started
    enabled: true
  when: ansible_distribution == "Rocky"

- name: Display skip message
  ansible.builtin.debug:
    msg: "Firewalld not installed - not Rocky Linux"
  when: ansible_distribution != "Rocky"
```

---

## Solution 13 — Role with Loops

```bash
# Create role
ansible-galaxy init users
```

**File: roles/users/defaults/main.yml**
```yaml
---
user_list:
  - alice
  - bob
  - charlie
```

**File: roles/users/tasks/main.yml**
```yaml
---
- name: Create users
  ansible.builtin.user:
    name: "{{ item }}"
    state: present
  loop: "{{ user_list }}"
```

---

## Solution 14 — Role with Blocks

```bash
# Create role
ansible-galaxy init secure
```

**File: roles/secure/tasks/main.yml**
```yaml
---
- name: Security setup
  block:
    - name: Install security packages
      ansible.builtin.dnf:
        name:
          - firewalld
          - fail2ban
        state: present
    
    - name: Start security services
      ansible.builtin.service:
        name: "{{ item }}"
        state: started
      loop:
        - firewalld
        - fail2ban
  
  rescue:
    - name: Handle installation failure
      ansible.builtin.debug:
        msg: "Security package installation failed, using defaults"
  
  always:
    - name: Display completion message
      ansible.builtin.debug:
        msg: "Security setup completed"
```

---

## Solution 15 — Multiple Roles in Playbook

**Playbook: full-stack.yml**
```yaml
---
- name: Deploy full stack
  hosts: all
  become: true
  
  roles:
    - apache
    - database
    - cache
```

**Alternative with role parameters:**
```yaml
---
- name: Deploy full stack
  hosts: all
  become: true
  
  roles:
    - role: apache
    - role: database
      db_port: 5432
    - role: cache
      cache_maxmemory: 512mb
```

---

## Quick Reference: Role Structure

```
role_name/
├── defaults/          # Default variables (lowest precedence)
│   └── main.yml
├── files/            # Static files to copy
│   └── file.txt
├── handlers/         # Handlers
│   └── main.yml
├── meta/            # Role metadata and dependencies
│   └── main.yml
├── tasks/           # Main tasks
│   └── main.yml
├── templates/       # Jinja2 templates
│   └── template.j2
├── tests/           # Test playbooks
│   ├── inventory
│   └── test.yml
└── vars/            # Role variables (high precedence)
    └── main.yml
```

---

## Quick Reference: Using Roles

### In Playbook
```yaml
roles:
  - role_name
```

### With Parameters
```yaml
roles:
  - role: role_name
    var1: value1
    var2: value2
```

### Multiple Roles
```yaml
roles:
  - role1
  - role2
  - role3
```

### With Tags
```yaml
roles:
  - role: role_name
    tags: ['web', 'production']
```

---

## Best Practices

1. **Use ansible-galaxy init:**
   ```bash
   ansible-galaxy init role_name
   ```

2. **Organize tasks logically:**
   ```
   tasks/
     main.yml      # Includes other files
     install.yml   # Installation tasks
     config.yml    # Configuration tasks
     service.yml   # Service management
   ```

3. **Use defaults for customizable variables:**
   ```yaml
   # defaults/main.yml
   app_port: 8080
   app_env: production
   ```

4. **Use vars for constants:**
   ```yaml
   # vars/main.yml
   app_name: myapp
   app_version: 1.0.0
   ```

5. **Document in README.md:**
   - Role purpose
   - Variables
   - Dependencies
   - Example usage

6. **Use handlers for service restarts:**
   ```yaml
   notify: restart service
   ```

---

## Tips for RHCE Exam

1. **Create roles directory:**
   ```bash
   mkdir -p /home/student/ansible/roles
   ```

2. **Use ansible-galaxy init:**
   ```bash
   cd roles
   ansible-galaxy init role_name
   ```

3. **Test roles:**
   ```bash
   ansible-playbook playbook.yml --syntax-check
   ansible-playbook playbook.yml --check
   ```

4. **Common mistakes:**
   - Wrong directory structure
   - Files in wrong location
   - Forgetting to use role in playbook
   - Wrong variable precedence

5. **Verify role execution:**
   ```bash
   ansible-playbook playbook.yml -v
   ```

6. **List roles:**
   ```bash
   ansible-galaxy list
   ```

---

Good luck with your RHCE exam preparation! 🚀

Master Ansible roles - they're essential for organizing and reusing automation code.
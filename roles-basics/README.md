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

Create a role `cache` that:
- Defines variables in `vars/main.yml`:
  ```yaml
  cache_port: 6379
  cache_maxmemory: 256mb
  ```
- Creates config file using these variables
- Higher precedence than defaults

**Requirements:**
- Vars in `vars/main.yml`
- Task uses variables
- Higher precedence than defaults
- Cannot easily override

---

### Task 08 — Role Dependencies (20 pts)

Create role `wordpress` that:
- Depends on `apache` role
- Depends on `database` role
- Defines dependencies in `meta/main.yml`
- Dependencies run first

**Requirements:**
- Dependencies in `meta/main.yml`
- Uses `dependencies:` key
- Dependent roles run first
- Proper order

---

### Task 09 — Role with Multiple Task Files (20 pts)

Create role `fullstack` that:
- Has `tasks/main.yml` that includes:
  - `tasks/install.yml`
  - `tasks/configure.yml`
  - `tasks/service.yml`
- Uses `include_tasks` or `import_tasks`

**Requirements:**
- Multiple task files
- Main includes others
- Organized by function
- All tasks execute

---

### Task 10 — Apply Role to Specific Hosts (15 pts)

Create playbook `webservers.yml` that:
- Applies `apache` role only to `webservers` group
- Uses `roles:` keyword
- Runs on correct hosts

**Requirements:**
- Playbook targets webservers
- Uses roles section
- Role applied correctly
- Only webservers affected

---

### Task 11 — Role with Tags (18 pts)

Create role `monitoring` that:
- Has tasks with tags:
  - `install` tag for installation
  - `config` tag for configuration
  - `service` tag for service management
- Can run specific tags

**Requirements:**
- Tasks have tags
- Can run with `--tags`
- Can skip with `--skip-tags`
- Proper tagging

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

```bash
# Create role
ansible-galaxy init cache
```

**File: roles/cache/vars/main.yml**
```yaml
---
cache_port: 6379
cache_maxmemory: 256mb
cache_timeout: 300
```

**File: roles/cache/tasks/main.yml**
```yaml
---
- name: Create cache config
  ansible.builtin.copy:
    content: |
      port {{ cache_port }}
      maxmemory {{ cache_maxmemory }}
      timeout {{ cache_timeout }}
    dest: /etc/cache.conf
    mode: '0644'
```

**Explanation:**
- `vars/` has higher precedence than `defaults/`
- Harder to override
- Use for role-specific constants
- Not meant to be changed

---

## Solution 08 — Role Dependencies

```bash
# Create role
ansible-galaxy init wordpress
```

**File: roles/wordpress/meta/main.yml**
```yaml
---
dependencies:
  - role: apache
  - role: database
```

**File: roles/wordpress/tasks/main.yml**
```yaml
---
- name: Install WordPress
  ansible.builtin.debug:
    msg: "WordPress installation (dependencies already run)"
```

**Playbook:**
```yaml
---
- name: Deploy WordPress
  hosts: all
  become: true
  
  roles:
    - wordpress
```

**Explanation:**
- Dependencies run before role
- Listed in `meta/main.yml`
- Automatic execution
- Proper order guaranteed

---

## Solution 09 — Role with Multiple Task Files

```bash
# Create role
ansible-galaxy init fullstack
```

**File: roles/fullstack/tasks/main.yml**
```yaml
---
- name: Include installation tasks
  ansible.builtin.import_tasks: install.yml

- name: Include configuration tasks
  ansible.builtin.import_tasks: configure.yml

- name: Include service tasks
  ansible.builtin.import_tasks: service.yml
```

**File: roles/fullstack/tasks/install.yml**
```yaml
---
- name: Install packages
  ansible.builtin.dnf:
    name:
      - httpd
      - php
      - mariadb-server
    state: present
```

**File: roles/fullstack/tasks/configure.yml**
```yaml
---
- name: Configure application
  ansible.builtin.copy:
    content: "<?php phpinfo(); ?>"
    dest: /var/www/html/info.php
    mode: '0644'
```

**File: roles/fullstack/tasks/service.yml**
```yaml
---
- name: Start services
  ansible.builtin.service:
    name: "{{ item }}"
    state: started
    enabled: true
  loop:
    - httpd
    - mariadb
```

---

## Solution 10 — Apply Role to Specific Hosts

**Playbook: webservers.yml**
```yaml
---
- name: Configure web servers
  hosts: webservers
  become: true
  
  roles:
    - apache
```

**Explanation:**
- `hosts: webservers` targets group
- Role applied only to that group
- Other hosts unaffected
- Group defined in inventory

---

## Solution 11 — Role with Tags

```bash
# Create role
ansible-galaxy init monitoring
```

**File: roles/monitoring/tasks/main.yml**
```yaml
---
- name: Install monitoring packages
  ansible.builtin.dnf:
    name:
      - nagios
      - prometheus
    state: present
  tags:
    - install
    - packages

- name: Configure monitoring
  ansible.builtin.copy:
    content: "monitoring_config=true"
    dest: /etc/monitoring.conf
    mode: '0644'
  tags:
    - config
    - configuration

- name: Start monitoring service
  ansible.builtin.service:
    name: nagios
    state: started
    enabled: true
  tags:
    - service
    - start
```

**Run with tags:**
```bash
# Run only install tasks
ansible-playbook playbook.yml --tags install

# Run only config tasks
ansible-playbook playbook.yml --tags config

# Skip service tasks
ansible-playbook playbook.yml --skip-tags service
```

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
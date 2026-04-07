# RHCE Killer — Playbooks Fundamentals
## EX294: Ansible Playbook Basics & Essential Modules

---

> **Beginner-Friendly Exam: Learn Playbook Basics**
> This exam teaches you how to write Ansible playbooks from scratch.
> Master essential modules and playbook structure.
> Time limit: **2.5 hours**. Start the timer with: `bash START.sh`

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

---

## Instructions

- All work must be done as user **student** on **control.example.com**
- All playbooks must be created under `/home/student/ansible/`
- Playbooks must run without errors
- Use proper YAML syntax
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** inventory-basics (or equivalent knowledge)

You should know:
- How to create inventory files
- How to configure ansible.cfg
- Basic ad-hoc commands

---

## Tasks

### Task 01 — Create Your First Playbook (10 pts)

Create a playbook `/home/student/ansible/first-playbook.yml` that:
- Runs on **all managed nodes**
- Has a descriptive name: "My First Playbook"
- Contains one task that uses the `debug` module to display: "Hello from Ansible!"

**Requirements:**
- Use proper YAML syntax
- Include play name
- Include task name
- Use `hosts: all`

---

### Task 02 — Install Packages with Playbook (12 pts)

Create a playbook `/home/student/ansible/install-packages.yml` that:
- Runs on **all managed nodes**
- Installs the following packages:
  - `httpd`
  - `firewalld`
  - `mod_ssl`
- Uses privilege escalation (`become: true`)

**Requirements:**
- All packages must be installed in a single task using a loop
- Use `state: present`
- Playbook must be idempotent

---

### Task 03 — Manage Services (12 pts)

Create a playbook `/home/student/ansible/manage-services.yml` that:
- Runs on **all managed nodes**
- Starts and enables the `firewalld` service
- Starts and enables the `httpd` service
- Uses privilege escalation

**Requirements:**
- Use `service` or `systemd` module
- `state: started`
- `enabled: true`
- Two separate tasks (one per service)

---

### Task 04 — Create Users and Groups (15 pts)

Create a playbook `/home/student/ansible/create-users.yml` that:
- Runs on **all managed nodes**
- Creates a group named `webadmins` with GID `4000`
- Creates a user named `webadmin` with:
  - UID: `4001`
  - Primary group: `webadmins`
  - Home directory: `/home/webadmin`
  - Shell: `/bin/bash`
  - Comment: "Web Administrator"

**Requirements:**
- Use `group` module for group creation
- Use `user` module for user creation
- Use privilege escalation
- Group must be created before user

**Note:** The system already has `devuser` (UID 3001) and `developers` group (GID 3000) pre-created for other exercises.

---

### Task 05 — File and Directory Management (15 pts)

Create a playbook `/home/student/ansible/file-management.yml` that:
- Runs on **all managed nodes**
- Creates directory `/opt/app` with:
  - Mode: `0755`
  - Owner: `devuser`
  - Group: `developers`
- Creates file `/opt/app/config.txt` with:
  - Content: "Application Configuration"
  - Mode: `0644`
  - Owner: `devuser`
  - Group: `developers`

**Requirements:**
- Use `file` module for directory
- Use `copy` module with `content` for file
- Use privilege escalation
- Directory must be created before file

---

### Task 06 — Copy Files from Control Node (12 pts)

Create a playbook `/home/student/ansible/copy-files.yml` that:
- First, create a local file `/home/student/ansible/files/index.html` with content:
  ```html
  <html>
  <body>
  <h1>Welcome to {{ inventory_hostname }}</h1>
  </body>
  </html>
  ```
- Copies this file to `/var/www/html/index.html` on **all managed nodes**
- Sets file permissions to `0644`
- Sets owner to `apache` and group to `apache`

**Requirements:**
- Create `files/` directory first
- Use `copy` module
- Use privilege escalation
- File must exist on managed nodes

---

### Task 07 — Lineinfile Module (12 pts)

Create a playbook `/home/student/ansible/modify-config.yml` that:
- Runs on **all managed nodes**
- Modifies `/etc/ssh/sshd_config` to set:
  - `PermitRootLogin no`
- Uses the `lineinfile` module
- Does NOT restart sshd (just modify the file)

**Requirements:**
- Use `lineinfile` module
- Use `regexp` to find the line
- Use `line` to set the value
- Use privilege escalation
- File must be modified, not replaced

---

### Task 08 — Multiple Plays in One Playbook (15 pts)

Create a playbook `/home/student/ansible/multi-play.yml` with two plays:

**Play 1:**
- Name: "Configure Web Servers"
- Runs on **node1.example.com**
- Ensures `httpd` is started and enabled

**Play 2:**
- Name: "Configure Database Servers"
- Runs on **node2.example.com**
- Installs package `mariadb-server`
- Ensures `mariadb` is started and enabled

**Requirements:**
- Two separate plays in one file
- Each play has its own `hosts` directive
- Use privilege escalation in both plays
- Proper play names

---

### Task 09 — Variables in Playbooks (15 pts)

Create a playbook `/home/student/ansible/use-variables.yml` that:
- Runs on **all managed nodes**
- Defines variables in the `vars` section:
  - `app_name: myapp`
  - `app_port: 8080`
  - `app_user: appuser`
- Creates a user with name from `app_user` variable
- Creates a file `/etc/myapp.conf` with content:
  ```
  app_name={{ app_name }}
  app_port={{ app_port }}
  app_user={{ app_user }}
  ```

**Requirements:**
- Use `vars:` section in play
- Use variables in tasks with `{{ variable_name }}`
- Use `copy` module with `content` for config file
- Use privilege escalation

---

### Task 10 — Handlers (15 pts)

Create a playbook `/home/student/ansible/use-handlers.yml` that:
- Runs on **all managed nodes**
- Copies a file `/home/student/ansible/files/httpd.conf` to `/etc/httpd/conf/httpd.conf`
  (Create a simple httpd.conf file first with content: `ServerName localhost`)
- Notifies a handler named "restart httpd"
- Handler restarts the `httpd` service

**Requirements:**
- Use `copy` module with `notify`
- Define handler in `handlers:` section
- Handler uses `service` module
- Handler only runs if file changes
- Use privilege escalation

---

### Task 11 — Gather Facts and Use Them (12 pts)

Create a playbook `/home/student/ansible/use-facts.yml` that:
- Runs on **all managed nodes**
- Gathers facts (default behavior)
- Creates a file `/tmp/system-info.txt` with content:
  ```
  Hostname: {{ ansible_hostname }}
  OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
  IP: {{ ansible_default_ipv4.address }}
  ```

**Requirements:**
- Use `copy` module with `content`
- Use Ansible facts in content
- Facts are gathered automatically
- File must contain actual system information

---

### Task 12 — Syntax Check and Dry Run (10 pts)

Create a file `/home/student/ansible/validation-commands.sh` with commands to:
1. Check syntax of `first-playbook.yml`
2. Run `install-packages.yml` in check mode (dry run)

**Requirements:**
- Use `ansible-playbook --syntax-check`
- Use `ansible-playbook --check`
- Save both commands to the file
- Make file executable

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | First Playbook | 10 |
| 02 | Install Packages | 12 |
| 03 | Manage Services | 12 |
| 04 | Users and Groups | 15 |
| 05 | File Management | 15 |
| 06 | Copy Files | 12 |
| 07 | Lineinfile | 12 |
| 08 | Multiple Plays | 15 |
| 09 | Variables | 15 |
| 10 | Handlers | 15 |
| 11 | Facts | 12 |
| 12 | Validation | 10 |
| **Total** | | **155** |

**Passing score: 70% (109/155 points)**

---

## When you finish

```bash
bash /home/student/exams/playbooks-fundamentals/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Create Your First Playbook

```yaml
---
- name: My First Playbook
  hosts: all
  
  tasks:
    - name: Display hello message
      ansible.builtin.debug:
        msg: "Hello from Ansible!"
```

**Run the playbook:**
```bash
ansible-playbook first-playbook.yml
```

**Explanation:**
- `---` starts a YAML file
- `name:` gives the play a descriptive name
- `hosts: all` targets all hosts in inventory
- `tasks:` section contains the list of tasks
- `debug` module displays messages
- `msg:` parameter specifies the message

**Key concepts:**
- Playbooks are YAML files
- Plays contain tasks
- Tasks use modules
- Indentation matters in YAML (use spaces, not tabs)

---

## Solution 02 — Install Packages with Playbook

```yaml
---
- name: Install required packages
  hosts: all
  become: true
  
  tasks:
    - name: Install httpd, firewalld, and mod_ssl
      ansible.builtin.dnf:
        name:
          - httpd
          - firewalld
          - mod_ssl
        state: present
```

**Run the playbook:**
```bash
ansible-playbook install-packages.yml
```

**Explanation:**
- `become: true` enables privilege escalation (sudo)
- `dnf` module manages packages on RHEL/Rocky Linux
- `name:` can be a list of packages
- `state: present` ensures packages are installed
- Playbook is idempotent (safe to run multiple times)

**Alternative with loop:**
```yaml
- name: Install packages
  ansible.builtin.dnf:
    name: "{{ item }}"
    state: present
  loop:
    - httpd
    - firewalld
    - mod_ssl
```

---

## Solution 03 — Manage Services

```yaml
---
- name: Manage system services
  hosts: all
  become: true
  
  tasks:
    - name: Start and enable firewalld
      ansible.builtin.service:
        name: firewalld
        state: started
        enabled: true
    
    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
```

**Run the playbook:**
```bash
ansible-playbook manage-services.yml
```

**Explanation:**
- `service` module manages system services
- `state: started` ensures service is running
- `enabled: true` ensures service starts on boot
- Two separate tasks for clarity
- Can also use `systemd` module (same syntax)

**Verification:**
```bash
ansible all -m command -a "systemctl status firewalld" --become
ansible all -m command -a "systemctl status httpd" --become
```

---

## Solution 04 — Create Users and Groups

```yaml
---
- name: Create users and groups
  hosts: all
  become: true
  
  tasks:
    - name: Create webadmins group
      ansible.builtin.group:
        name: webadmins
        gid: 4000
        state: present
    
    - name: Create webadmin user
      ansible.builtin.user:
        name: webadmin
        uid: 4001
        group: webadmins
        home: /home/webadmin
        shell: /bin/bash
        comment: "Web Administrator"
        state: present
```

**Run the playbook:**
```bash
ansible-playbook create-users.yml
```

**Explanation:**
- `group` module creates groups
- `gid` sets group ID
- `user` module creates users
- `uid` sets user ID
- `group` sets primary group
- Group must exist before user creation
- Task order matters

**Note:** The system already has `devuser` (UID 3001) and `developers` group (GID 3000) pre-created, which are used in Task 05.

**Verification:**
```bash
ansible all -m command -a "id webadmin"
ansible all -m command -a "getent group webadmins"
```

---

## Solution 05 — File and Directory Management

```yaml
---
- name: Manage files and directories
  hosts: all
  become: true
  
  tasks:
    - name: Create /opt/app directory
      ansible.builtin.file:
        path: /opt/app
        state: directory
        mode: '0755'
        owner: devuser
        group: developers
    
    - name: Create config file
      ansible.builtin.copy:
        content: "Application Configuration\n"
        dest: /opt/app/config.txt
        mode: '0644'
        owner: devuser
        group: developers
```

**Run the playbook:**
```bash
ansible-playbook file-management.yml
```

**Explanation:**
- `file` module manages files and directories
- `state: directory` creates a directory
- `mode` sets permissions (use quotes for octal)
- `copy` module with `content` creates file with inline content
- Directory must exist before creating file in it

**Verification:**
```bash
ansible all -m command -a "ls -ld /opt/app"
ansible all -m command -a "ls -l /opt/app/config.txt"
ansible all -m command -a "cat /opt/app/config.txt"
```

---

## Solution 06 — Copy Files from Control Node

First, create the source file:

```bash
mkdir -p /home/student/ansible/files

cat > /home/student/ansible/files/index.html << 'EOF'
<html>
<body>
<h1>Welcome to {{ inventory_hostname }}</h1>
</body>
</html>
EOF
```

Then create the playbook:

```yaml
---
- name: Copy files to managed nodes
  hosts: all
  become: true
  
  tasks:
    - name: Copy index.html to web root
      ansible.builtin.copy:
        src: files/index.html
        dest: /var/www/html/index.html
        mode: '0644'
        owner: apache
        group: apache
```

**Run the playbook:**
```bash
ansible-playbook copy-files.yml
```

**Explanation:**
- `copy` module transfers files from control to managed nodes
- `src` is relative to playbook location
- `dest` is absolute path on managed nodes
- Variables in source file are NOT templated (use `template` module for that)
- `apache` user/group must exist (created by httpd package)

**Verification:**
```bash
ansible all -m command -a "cat /var/www/html/index.html"
ansible all -m command -a "ls -l /var/www/html/index.html"
```

---

## Solution 07 — Lineinfile Module

```yaml
---
- name: Modify SSH configuration
  hosts: all
  become: true
  
  tasks:
    - name: Disable root login via SSH
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PermitRootLogin'
        line: 'PermitRootLogin no'
        state: present
```

**Run the playbook:**
```bash
ansible-playbook modify-config.yml
```

**Explanation:**
- `lineinfile` module modifies specific lines in files
- `regexp` finds the line to modify (^ means start of line, #? means optional #)
- `line` specifies the new content
- `state: present` ensures line exists
- Does not restart service (just modifies file)
- Idempotent (safe to run multiple times)

**Verification:**
```bash
ansible all -m command -a "grep PermitRootLogin /etc/ssh/sshd_config" --become
```

**Note:** In production, you would add a handler to restart sshd.

---

## Solution 08 — Multiple Plays in One Playbook

```yaml
---
- name: Configure Web Servers
  hosts: node1.example.com
  become: true
  
  tasks:
    - name: Ensure httpd is started and enabled
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true

- name: Configure Database Servers
  hosts: node2.example.com
  become: true
  
  tasks:
    - name: Install mariadb-server
      ansible.builtin.dnf:
        name: mariadb-server
        state: present
    
    - name: Ensure mariadb is started and enabled
      ansible.builtin.service:
        name: mariadb
        state: started
        enabled: true
```

**Run the playbook:**
```bash
ansible-playbook multi-play.yml
```

**Explanation:**
- Multiple plays in one file (separated by `---` or just new play)
- Each play has its own `hosts` directive
- Each play has its own `become` setting
- Plays run sequentially
- Useful for organizing tasks by host groups

**Verification:**
```bash
ansible node1.example.com -m command -a "systemctl status httpd"
ansible node2.example.com -m command -a "systemctl status mariadb"
```

---

## Solution 09 — Variables in Playbooks

```yaml
---
- name: Use variables in playbook
  hosts: all
  become: true
  
  vars:
    app_name: myapp
    app_port: 8080
    app_user: appuser
  
  tasks:
    - name: Create application user
      ansible.builtin.user:
        name: "{{ app_user }}"
        state: present
    
    - name: Create application config file
      ansible.builtin.copy:
        content: |
          app_name={{ app_name }}
          app_port={{ app_port }}
          app_user={{ app_user }}
        dest: /etc/myapp.conf
        mode: '0644'
```

**Run the playbook:**
```bash
ansible-playbook use-variables.yml
```

**Explanation:**
- `vars:` section defines variables at play level
- Variables are referenced with `{{ variable_name }}`
- Variables can be used in any task parameter
- `|` in YAML preserves newlines (literal block scalar)
- Variables make playbooks reusable

**Verification:**
```bash
ansible all -m command -a "cat /etc/myapp.conf"
ansible all -m command -a "id appuser"
```

---

## Solution 10 — Handlers

First, create the source file:

```bash
mkdir -p /home/student/ansible/files

cat > /home/student/ansible/files/httpd.conf << 'EOF'
ServerName localhost
EOF
```

Then create the playbook:

```yaml
---
- name: Use handlers for service restart
  hosts: all
  become: true
  
  tasks:
    - name: Copy httpd configuration
      ansible.builtin.copy:
        src: files/httpd.conf
        dest: /etc/httpd/conf/httpd.conf
        mode: '0644'
      notify: restart httpd
  
  handlers:
    - name: restart httpd
      ansible.builtin.service:
        name: httpd
        state: restarted
```

**Run the playbook:**
```bash
ansible-playbook use-handlers.yml
```

**Explanation:**
- `notify` triggers a handler when task changes
- Handlers are defined in `handlers:` section
- Handler name must match notify name exactly
- Handlers run at the end of the play
- Handlers only run if notified AND task changed
- Multiple tasks can notify the same handler
- Handler runs only once even if notified multiple times

**Verification:**
```bash
ansible all -m command -a "systemctl status httpd"
```

---

## Solution 11 — Gather Facts and Use Them

```yaml
---
- name: Use Ansible facts
  hosts: all
  gather_facts: true
  
  tasks:
    - name: Create system info file
      ansible.builtin.copy:
        content: |
          Hostname: {{ ansible_hostname }}
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
          IP: {{ ansible_default_ipv4.address }}
        dest: /tmp/system-info.txt
        mode: '0644'
```

**Run the playbook:**
```bash
ansible-playbook use-facts.yml
```

**Explanation:**
- `gather_facts: true` is default (can be omitted)
- Facts are automatically collected at play start
- Facts are accessed like variables: `{{ ansible_factname }}`
- Nested facts use dot notation: `{{ ansible_default_ipv4.address }}`
- Facts contain system information (OS, network, hardware, etc.)

**Verification:**
```bash
ansible all -m command -a "cat /tmp/system-info.txt"
```

**View all facts:**
```bash
ansible node1.example.com -m setup
```

---

## Solution 12 — Syntax Check and Dry Run

```bash
cat > /home/student/ansible/validation-commands.sh << 'EOF'
#!/bin/bash

# Check syntax
ansible-playbook first-playbook.yml --syntax-check

# Dry run (check mode)
ansible-playbook install-packages.yml --check
EOF

chmod +x /home/student/ansible/validation-commands.sh
```

**Run the commands:**
```bash
# Syntax check
ansible-playbook first-playbook.yml --syntax-check

# Dry run
ansible-playbook install-packages.yml --check
```

**Explanation:**
- `--syntax-check` validates YAML syntax without running
- `--check` runs in dry-run mode (shows what would change)
- Both are essential for testing playbooks
- Syntax check catches YAML errors
- Check mode catches logic errors

**Additional validation:**
```bash
# Check with diff
ansible-playbook install-packages.yml --check --diff

# Verbose output
ansible-playbook first-playbook.yml -v
ansible-playbook first-playbook.yml -vv
ansible-playbook first-playbook.yml -vvv
```

---

## Quick Reference: Essential Playbook Concepts

### Playbook Structure
```yaml
---
- name: Play name
  hosts: target_hosts
  become: true  # Optional: privilege escalation
  gather_facts: true  # Optional: default is true
  
  vars:  # Optional: play variables
    variable_name: value
  
  tasks:
    - name: Task name
      module_name:
        parameter: value
      notify: handler_name  # Optional
  
  handlers:  # Optional
    - name: handler_name
      module_name:
        parameter: value
```

### Common Modules
```yaml
# Debug - Display messages
- debug:
    msg: "Message"
    var: variable_name

# DNF/YUM - Package management
- dnf:
    name: package_name
    state: present|absent|latest

# Service - Service management
- service:
    name: service_name
    state: started|stopped|restarted
    enabled: yes|no

# User - User management
- user:
    name: username
    uid: 1001
    group: groupname
    shell: /bin/bash
    state: present|absent

# Group - Group management
- group:
    name: groupname
    gid: 1001
    state: present|absent

# File - File/directory management
- file:
    path: /path/to/file
    state: file|directory|absent|link
    mode: '0644'
    owner: username
    group: groupname

# Copy - Copy files
- copy:
    src: source/file
    dest: /destination/file
    mode: '0644'
    owner: username
    group: groupname

# Copy with inline content
- copy:
    content: "File content"
    dest: /destination/file

# Lineinfile - Modify lines in files
- lineinfile:
    path: /path/to/file
    regexp: '^pattern'
    line: 'new line content'
    state: present|absent

# Command - Run commands
- command:
    cmd: /path/to/command arg1 arg2
    chdir: /working/directory

# Shell - Run shell commands
- shell: |
    command1
    command2 | command3
```

### Variables
```yaml
# Define in play
vars:
  my_var: value

# Use in tasks
- debug:
    msg: "{{ my_var }}"

# Facts (automatically gathered)
- debug:
    msg: "{{ ansible_hostname }}"
    msg: "{{ ansible_distribution }}"
    msg: "{{ ansible_default_ipv4.address }}"
```

### Handlers
```yaml
tasks:
  - name: Copy config
    copy:
      src: config.conf
      dest: /etc/app/config.conf
    notify: restart app

handlers:
  - name: restart app
    service:
      name: app
      state: restarted
```

### Running Playbooks
```bash
# Basic run
ansible-playbook playbook.yml

# Syntax check
ansible-playbook playbook.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbook.yml --check

# With diff
ansible-playbook playbook.yml --check --diff

# Verbose
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vv
ansible-playbook playbook.yml -vvv

# Limit to specific hosts
ansible-playbook playbook.yml --limit node1.example.com

# Start at specific task
ansible-playbook playbook.yml --start-at-task="Task name"

# Use specific inventory
ansible-playbook playbook.yml -i inventory_file
```

---

## Best Practices

### YAML Syntax
- Use 2 spaces for indentation (not tabs)
- Start file with `---`
- Use quotes for strings with special characters
- Use `|` for multi-line strings (preserves newlines)
- Use `>` for multi-line strings (folds newlines)

### Playbook Organization
- One play per logical group of tasks
- Use descriptive names for plays and tasks
- Group related tasks together
- Use handlers for service restarts
- Use variables for values that might change

### Task Naming
- Always name your tasks
- Use descriptive names
- Start with verb (Create, Install, Configure, etc.)
- Be specific about what the task does

### Idempotency
- Use `state: present` instead of commands
- Use modules instead of shell/command when possible
- Test playbooks multiple times
- Playbooks should be safe to run repeatedly

### Variables
- Use meaningful variable names
- Define variables at appropriate scope
- Document variable purpose
- Use defaults when appropriate

### Error Handling
- Test with `--syntax-check` first
- Use `--check` mode before running
- Use `-v` for debugging
- Check return values
- Use `failed_when` for custom failure conditions

---

## Common Mistakes to Avoid

1. **Indentation errors** - Use 2 spaces, not tabs
2. **Missing quotes** - Quote strings with special characters
3. **Wrong module** - Use `copy` for files, `template` for templates
4. **Forgetting become** - Use `become: true` for privileged operations
5. **Not testing** - Always use `--syntax-check` and `--check`
6. **Hardcoding values** - Use variables for flexibility
7. **No task names** - Always name your tasks
8. **Using shell unnecessarily** - Use specific modules when available
9. **Not handling errors** - Use `ignore_errors` or `failed_when` when appropriate
10. **Complex playbooks** - Break into roles for better organization

---

## Tips for RHCE Exam

1. **Always check syntax first:**
   ```bash
   ansible-playbook playbook.yml --syntax-check
   ```

2. **Test in check mode:**
   ```bash
   ansible-playbook playbook.yml --check
   ```

3. **Use verbose mode for debugging:**
   ```bash
   ansible-playbook playbook.yml -v
   ```

4. **Remember task order matters:**
   - Create groups before users
   - Create directories before files
   - Install packages before starting services

5. **Use proper YAML syntax:**
   - 2 spaces for indentation
   - Quotes for special characters
   - Consistent formatting

6. **Verify your work:**
   ```bash
   ansible all -m command -a "command to verify"
   ```

7. **Common patterns:**
   - Install → Configure → Start → Enable
   - Create directory → Create file
   - Copy file → Notify handler

---

Good luck with your RHCE exam preparation! 🚀

Master these playbook fundamentals before moving to more advanced topics like conditionals, loops, and templates.
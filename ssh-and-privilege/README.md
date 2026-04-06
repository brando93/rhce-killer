# RHCE Killer — SSH and Privilege Escalation
## EX294: Mastering Remote Access and Sudo

---

> **Intermediate Exam: Security and Access Control**
> This exam teaches you SSH configuration and privilege escalation in Ansible.
> Master become, sudo, SSH keys, and connection parameters.
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
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, ansible-vault

You should know:
- How to write playbooks
- How to use variables
- Basic Linux permissions
- User management

---

## Tasks

### Task 01 — Basic Become (10 pts)

Create a playbook `/home/student/ansible/become-basic.yml` that:
- Runs on **all managed nodes**
- Installs package `httpd`
- Uses `become: true` at play level
- Runs as root

**Requirements:**
- Use `become: true`
- Install httpd package
- No sudo password needed (NOPASSWD configured)

---

### Task 02 — Become at Task Level (12 pts)

Create a playbook `/home/student/ansible/become-task.yml` that:
- Runs on **all managed nodes**
- Has two tasks:
  - Create file `/tmp/user-file.txt` as student (no become)
  - Create file `/opt/root-file.txt` as root (with become)

**Requirements:**
- First task: no become
- Second task: `become: true`
- Different owners for files

---

### Task 03 — Become User (15 pts)

Create a playbook `/home/student/ansible/become-user.yml` that:
- Runs on **all managed nodes**
- Creates user `appuser` as root
- Creates file `/home/appuser/app.txt` as `appuser`
- Uses `become_user: appuser`

**Requirements:**
- Use `become: true` to create user
- Use `become_user: appuser` for file
- File owned by appuser
- Use `become: true` with `become_user`

---

### Task 04 — Become Method (12 pts)

Create a playbook `/home/student/ansible/become-method.yml` that:
- Runs on **all managed nodes**
- Uses `become_method: sudo`
- Installs package `firewalld`
- Explicitly specifies sudo method

**Requirements:**
- Use `become: true`
- Use `become_method: sudo`
- Install firewalld
- Verify sudo is used

---

### Task 05 — Ansible Config Become (15 pts)

Modify `/home/student/ansible/ansible.cfg` to:
- Set `become = True` by default
- Set `become_user = root` by default
- Set `become_method = sudo` by default

Create playbook `/home/student/ansible/become-config.yml` that installs `vim-enhanced` without specifying become.

**Requirements:**
- Modify ansible.cfg
- Playbook doesn't specify become
- Uses defaults from config
- Package installs successfully

---

### Task 06 — Inventory Become Variables (15 pts)

Modify `/home/student/ansible/inventory` to:
- Set `ansible_become=true` for `webservers` group
- Set `ansible_become_user=root` for `webservers` group

Create playbook that installs `nginx` on webservers without specifying become.

**Requirements:**
- Set in inventory
- Playbook doesn't specify become
- Uses inventory variables
- Package installs successfully

---

### Task 07 — SSH Connection Variables (15 pts)

Create a playbook `/home/student/ansible/ssh-vars.yml` that:
- Runs on **node1** only
- Uses these connection variables:
  - `ansible_connection: ssh`
  - `ansible_port: 22`
  - `ansible_user: student`
- Displays connection info

**Requirements:**
- Set connection variables
- Use in playbook
- Verify connection works
- Display variables

---

### Task 08 — SSH Key Authentication (18 pts)

Generate SSH key pair and configure passwordless SSH:
- Generate key: `/home/student/.ssh/ansible_key`
- No passphrase
- Copy public key to managed nodes
- Configure ansible.cfg to use private key

**Requirements:**
- Generate SSH key pair
- Copy to all managed nodes
- Set `private_key_file` in ansible.cfg
- Test passwordless connection

---

### Task 09 — Inventory SSH Variables (15 pts)

Modify inventory to set SSH variables for node1:
```ini
node1.example.com ansible_ssh_private_key_file=/home/student/.ssh/ansible_key
```

Create playbook that connects to node1 using this key.

**Requirements:**
- Set in inventory
- Playbook uses inventory variable
- Connection successful
- No password prompt

---

### Task 10 — Become Password (18 pts)

Create a user `sudouser` that requires password for sudo:
- Create user on managed nodes
- Set sudo password
- Create playbook that uses `ansible_become_password`
- Store password in vault

**Requirements:**
- User requires sudo password
- Use `ansible_become_password` variable
- Encrypt password with vault
- Playbook runs successfully

---

### Task 11 — Connection Timeout (12 pts)

Create a playbook `/home/student/ansible/ssh-timeout.yml` that:
- Sets `ansible_ssh_timeout: 30`
- Runs on all managed nodes
- Tests connection with timeout

**Requirements:**
- Set timeout variable
- Use in playbook
- Connection succeeds
- Timeout configured

---

### Task 12 — SSH Common Args (15 pts)

Configure ansible.cfg to set SSH common arguments:
```ini
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

Create playbook that benefits from connection multiplexing.

**Requirements:**
- Set in ansible.cfg
- SSH connection reuse enabled
- Faster subsequent connections
- Verify with verbose output

---

### Task 13 — Pipelining (15 pts)

Enable SSH pipelining in ansible.cfg:
```ini
[ssh_connection]
pipelining = True
```

Create playbook that runs faster with pipelining enabled.

**Requirements:**
- Enable in ansible.cfg
- Reduces SSH connections
- Faster execution
- Verify improvement

---

### Task 14 — Privilege Escalation Flags (18 pts)

Create a playbook `/home/student/ansible/become-flags.yml` that:
- Uses `become_flags: '-H -S -n'`
- Runs command as root
- Preserves environment variables

**Requirements:**
- Use `become_flags`
- Specify sudo flags
- Command runs successfully
- Flags applied correctly

---

### Task 15 — Complex Privilege Scenario (20 pts)

Create a playbook `/home/student/ansible/privilege-complex.yml` that:
- Creates user `webadmin` with sudo access
- Creates directory `/opt/webapp` as root
- Creates file `/opt/webapp/config.txt` as webadmin
- Starts service as root
- All in one playbook with proper privilege escalation

**Requirements:**
- Multiple become scenarios
- Different users for different tasks
- Proper permissions
- All tasks succeed

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Basic Become | 10 |
| 02 | Become at Task Level | 12 |
| 03 | Become User | 15 |
| 04 | Become Method | 12 |
| 05 | Ansible Config Become | 15 |
| 06 | Inventory Become Variables | 15 |
| 07 | SSH Connection Variables | 15 |
| 08 | SSH Key Authentication | 18 |
| 09 | Inventory SSH Variables | 15 |
| 10 | Become Password | 18 |
| 11 | Connection Timeout | 12 |
| 12 | SSH Common Args | 15 |
| 13 | Pipelining | 15 |
| 14 | Privilege Escalation Flags | 18 |
| 15 | Complex Privilege Scenario | 20 |
| **Total** | | **215** |

**Passing score: 70% (151/215 points)**

---

## When you finish

```bash
bash /home/student/exams/ssh-and-privilege/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Basic Become

**Playbook: become-basic.yml**
```yaml
---
- name: Basic become example
  hosts: all
  become: true
  
  tasks:
    - name: Install httpd
      ansible.builtin.dnf:
        name: httpd
        state: present
```

**Explanation:**
- `become: true` at play level
- Applies to all tasks in play
- Runs as root (default become_user)
- No password needed (NOPASSWD sudo)

**Verification:**
```bash
ansible all -m command -a "rpm -q httpd"
```

---

## Solution 02 — Become at Task Level

**Playbook: become-task.yml**
```yaml
---
- name: Become at task level
  hosts: all
  
  tasks:
    - name: Create file as student
      ansible.builtin.copy:
        content: "Created by student\n"
        dest: /tmp/user-file.txt
        mode: '0644'
    
    - name: Create file as root
      ansible.builtin.copy:
        content: "Created by root\n"
        dest: /opt/root-file.txt
        mode: '0644'
      become: true
```

**Explanation:**
- No become at play level
- First task runs as student
- Second task uses `become: true`
- Different owners for files

**Verification:**
```bash
ansible all -m command -a "ls -l /tmp/user-file.txt"
ansible all -m command -a "ls -l /opt/root-file.txt"
```

---

## Solution 03 — Become User

**Playbook: become-user.yml**
```yaml
---
- name: Become specific user
  hosts: all
  become: true
  
  tasks:
    - name: Create appuser
      ansible.builtin.user:
        name: appuser
        state: present
    
    - name: Create file as appuser
      ansible.builtin.copy:
        content: "Application file\n"
        dest: /home/appuser/app.txt
        mode: '0644'
      become_user: appuser
```

**Explanation:**
- `become: true` at play level (runs as root)
- First task creates user as root
- Second task uses `become_user: appuser`
- File owned by appuser

**Verification:**
```bash
ansible all -m command -a "ls -l /home/appuser/app.txt"
```

---

## Solution 04 — Become Method

**Playbook: become-method.yml**
```yaml
---
- name: Specify become method
  hosts: all
  become: true
  become_method: sudo
  
  tasks:
    - name: Install firewalld
      ansible.builtin.dnf:
        name: firewalld
        state: present
```

**Explanation:**
- `become_method: sudo` explicitly uses sudo
- Other methods: su, pbrun, pfexec, doas, dzdo, ksu, runas
- sudo is default on most systems
- Useful when multiple methods available

**Verification:**
```bash
ansible all -m command -a "rpm -q firewalld"
```

---

## Solution 05 — Ansible Config Become

**Modify ansible.cfg:**
```ini
[defaults]
inventory = inventory
remote_user = student
vault_password_file = /home/student/ansible/.vault_pass
become = True
become_user = root
become_method = sudo

[privilege_escalation]
become = True
become_user = root
become_method = sudo
become_ask_pass = False
```

**Playbook: become-config.yml**
```yaml
---
- name: Use become from config
  hosts: all
  
  tasks:
    - name: Install vim-enhanced
      ansible.builtin.dnf:
        name: vim-enhanced
        state: present
```

**Explanation:**
- Config sets become defaults
- Playbook doesn't specify become
- Uses config values automatically
- Cleaner playbooks

**Verification:**
```bash
ansible all -m command -a "rpm -q vim-enhanced"
```

---

## Solution 06 — Inventory Become Variables

**Modify inventory:**
```ini
[webservers]
node1.example.com
node2.example.com

[webservers:vars]
ansible_become=true
ansible_become_user=root
```

**Playbook: become-inventory.yml**
```yaml
---
- name: Use become from inventory
  hosts: webservers
  
  tasks:
    - name: Install nginx
      ansible.builtin.dnf:
        name: nginx
        state: present
```

**Explanation:**
- Inventory sets group variables
- `ansible_become` enables privilege escalation
- `ansible_become_user` sets target user
- Playbook uses inventory settings

**Verification:**
```bash
ansible webservers -m command -a "rpm -q nginx"
```

---

## Solution 07 — SSH Connection Variables

**Playbook: ssh-vars.yml**
```yaml
---
- name: SSH connection variables
  hosts: node1.example.com
  
  vars:
    ansible_connection: ssh
    ansible_port: 22
    ansible_user: student
  
  tasks:
    - name: Display connection info
      ansible.builtin.debug:
        msg: |
          Connection: {{ ansible_connection }}
          Port: {{ ansible_port }}
          User: {{ ansible_user }}
          Host: {{ inventory_hostname }}
```

**Explanation:**
- `ansible_connection` sets connection type
- `ansible_port` sets SSH port
- `ansible_user` sets remote user
- Variables override defaults

**Run:**
```bash
ansible-playbook ssh-vars.yml
```

---

## Solution 08 — SSH Key Authentication

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f /home/student/.ssh/ansible_key -N ""

# Copy to managed nodes
ssh-copy-id -i /home/student/.ssh/ansible_key.pub student@node1.example.com
ssh-copy-id -i /home/student/.ssh/ansible_key.pub student@node2.example.com

# Test connection
ssh -i /home/student/.ssh/ansible_key student@node1.example.com "hostname"
```

**Modify ansible.cfg:**
```ini
[defaults]
private_key_file = /home/student/.ssh/ansible_key
```

**Explanation:**
- Generate RSA key pair
- `-N ""` means no passphrase
- `ssh-copy-id` copies public key
- Config sets default private key
- Passwordless authentication

**Verification:**
```bash
ansible all -m ping
```

---

## Solution 09 — Inventory SSH Variables

**Modify inventory:**
```ini
[all]
node1.example.com ansible_ssh_private_key_file=/home/student/.ssh/ansible_key
node2.example.com
```

**Playbook: ssh-key-inventory.yml**
```yaml
---
- name: Use SSH key from inventory
  hosts: node1.example.com
  
  tasks:
    - name: Test connection
      ansible.builtin.ping:
```

**Explanation:**
- Set per-host SSH key
- Overrides config default
- Useful for different keys per host
- No password prompt

**Run:**
```bash
ansible-playbook ssh-key-inventory.yml
```

---

## Solution 10 — Become Password

```bash
# Create user on managed nodes
ansible all -b -m user -a "name=sudouser state=present"

# Set password
ansible all -b -m shell -a "echo 'sudouser:SudoPass123' | chpasswd"

# Configure sudo to require password
ansible all -b -m lineinfile -a "path=/etc/sudoers.d/sudouser line='sudouser ALL=(ALL) ALL' create=yes mode=0440"
```

**Create encrypted variable:**
```bash
ansible-vault encrypt_string 'SudoPass123' --name 'ansible_become_password'
```

**Playbook: become-password.yml**
```yaml
---
- name: Use become password
  hosts: all
  become: true
  become_user: root
  
  vars:
    ansible_become_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653236336462626566653063336164663966303231363934653561363338373838316566
          3136626431626536303530376637343637346536356635620a653638643939666333613936636331
          63373764616538303034323538323661306231326635633630343137316333666133343530383630
          3438626666666137650a316638313963326662633630343761303764323566363532363361663034
          3833
  
  tasks:
    - name: Install package as sudouser
      ansible.builtin.dnf:
        name: tree
        state: present
```

**Explanation:**
- User requires sudo password
- `ansible_become_password` provides it
- Encrypted with vault
- Playbook runs successfully

---

## Solution 11 — Connection Timeout

**Playbook: ssh-timeout.yml**
```yaml
---
- name: SSH timeout configuration
  hosts: all
  
  vars:
    ansible_ssh_timeout: 30
  
  tasks:
    - name: Test connection with timeout
      ansible.builtin.ping:
    
    - name: Display timeout
      ansible.builtin.debug:
        msg: "SSH timeout set to {{ ansible_ssh_timeout }} seconds"
```

**Explanation:**
- `ansible_ssh_timeout` sets connection timeout
- Value in seconds
- Prevents hanging on slow connections
- Default is 10 seconds

**Run:**
```bash
ansible-playbook ssh-timeout.yml
```

---

## Solution 12 — SSH Common Args

**Modify ansible.cfg:**
```ini
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
```

**Playbook: ssh-multiplexing.yml**
```yaml
---
- name: SSH connection multiplexing
  hosts: all
  
  tasks:
    - name: First task
      ansible.builtin.ping:
    
    - name: Second task
      ansible.builtin.command: hostname
    
    - name: Third task
      ansible.builtin.command: uptime
```

**Explanation:**
- `ControlMaster=auto` enables multiplexing
- `ControlPersist=60s` keeps connection open
- Reuses SSH connection
- Faster execution

**Run with verbose:**
```bash
ansible-playbook ssh-multiplexing.yml -vvv
```

---

## Solution 13 — Pipelining

**Modify ansible.cfg:**
```ini
[ssh_connection]
pipelining = True
```

**Playbook: ssh-pipelining.yml**
```yaml
---
- name: SSH pipelining
  hosts: all
  
  tasks:
    - name: Task 1
      ansible.builtin.command: echo "test1"
    
    - name: Task 2
      ansible.builtin.command: echo "test2"
    
    - name: Task 3
      ansible.builtin.command: echo "test3"
```

**Explanation:**
- Pipelining reduces SSH operations
- Sends commands through existing connection
- Faster execution
- Requires `requiretty` disabled in sudoers

**Verification:**
```bash
time ansible-playbook ssh-pipelining.yml
```

---

## Solution 14 — Privilege Escalation Flags

**Playbook: become-flags.yml**
```yaml
---
- name: Become with flags
  hosts: all
  become: true
  become_flags: '-H -S -n'
  
  tasks:
    - name: Run command with sudo flags
      ansible.builtin.command: whoami
      register: result
    
    - name: Display result
      ansible.builtin.debug:
        var: result.stdout
```

**Explanation:**
- `-H` sets HOME environment variable
- `-S` reads password from stdin
- `-n` non-interactive mode
- Flags passed to sudo command

**Run:**
```bash
ansible-playbook become-flags.yml
```

---

## Solution 15 — Complex Privilege Scenario

**Playbook: privilege-complex.yml**
```yaml
---
- name: Complex privilege escalation
  hosts: all
  become: true
  
  tasks:
    - name: Create webadmin user
      ansible.builtin.user:
        name: webadmin
        state: present
        groups: wheel
        append: true
    
    - name: Configure sudo for webadmin
      ansible.builtin.lineinfile:
        path: /etc/sudoers.d/webadmin
        line: 'webadmin ALL=(ALL) NOPASSWD: ALL'
        create: true
        mode: '0440'
        validate: 'visudo -cf %s'
    
    - name: Create webapp directory as root
      ansible.builtin.file:
        path: /opt/webapp
        state: directory
        mode: '0755'
        owner: root
        group: root
    
    - name: Create config file as webadmin
      ansible.builtin.copy:
        content: "webapp_config=true\n"
        dest: /opt/webapp/config.txt
        mode: '0644'
        owner: webadmin
        group: webadmin
      become_user: webadmin
    
    - name: Install httpd as root
      ansible.builtin.dnf:
        name: httpd
        state: present
    
    - name: Start httpd service as root
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
```

**Explanation:**
- Multiple privilege escalation scenarios
- Create user as root
- Create directory as root
- Create file as specific user
- Install and start service as root
- Demonstrates real-world complexity

**Verification:**
```bash
ansible all -m command -a "ls -l /opt/webapp/"
ansible all -m command -a "systemctl status httpd"
```

---

## Quick Reference: Become Directives

### Play Level
```yaml
- name: Play
  hosts: all
  become: true
  become_user: root
  become_method: sudo
```

### Task Level
```yaml
- name: Task
  module:
    param: value
  become: true
  become_user: appuser
```

### Inventory Variables
```ini
[group:vars]
ansible_become=true
ansible_become_user=root
ansible_become_method=sudo
ansible_become_password=secret
```

### Config File
```ini
[privilege_escalation]
become = True
become_user = root
become_method = sudo
become_ask_pass = False
```

---

## Quick Reference: SSH Connection Variables

### Connection Type
```yaml
ansible_connection: ssh
ansible_connection: local
ansible_connection: docker
```

### SSH Parameters
```yaml
ansible_host: 192.168.1.100
ansible_port: 2222
ansible_user: admin
ansible_ssh_private_key_file: /path/to/key
ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
ansible_ssh_timeout: 30
```

### In Inventory
```ini
host1 ansible_host=192.168.1.100 ansible_port=2222 ansible_user=admin
```

---

## Quick Reference: Become Methods

```yaml
become_method: sudo      # Default on Linux
become_method: su        # Switch user
become_method: pbrun     # PowerBroker
become_method: pfexec    # Solaris
become_method: doas      # OpenBSD
become_method: dzdo      # Centrify
become_method: ksu       # Kerberos
become_method: runas     # Windows
```

---

## Best Practices

1. **Use NOPASSWD sudo for automation:**
   ```bash
   # /etc/sudoers.d/ansible
   ansible ALL=(ALL) NOPASSWD: ALL
   ```

2. **Set become in config for consistency:**
   ```ini
   [privilege_escalation]
   become = True
   ```

3. **Use SSH keys instead of passwords:**
   ```bash
   ssh-keygen -t rsa -b 4096
   ssh-copy-id user@host
   ```

4. **Enable pipelining for performance:**
   ```ini
   [ssh_connection]
   pipelining = True
   ```

5. **Use connection multiplexing:**
   ```ini
   [ssh_connection]
   ssh_args = -o ControlMaster=auto -o ControlPersist=60s
   ```

6. **Encrypt become passwords:**
   ```bash
   ansible-vault encrypt_string 'password' --name 'ansible_become_password'
   ```

7. **Use specific become_user when needed:**
   ```yaml
   become_user: appuser  # Not always root
   ```

---

## Common Patterns

### Service Management
```yaml
- name: Manage service
  service:
    name: httpd
    state: started
  become: true
```

### File Operations
```yaml
- name: Create file as specific user
  copy:
    content: "data"
    dest: /path/file
  become: true
  become_user: appuser
```

### Package Installation
```yaml
- name: Install packages
  dnf:
    name: "{{ item }}"
    state: present
  loop:
    - httpd
    - nginx
  become: true
```

---

## Tips for RHCE Exam

1. **Verify sudo access:**
   ```bash
   ansible all -m command -a "sudo whoami"
   ```

2. **Test SSH connectivity:**
   ```bash
   ansible all -m ping
   ```

3. **Check become configuration:**
   ```bash
   ansible-config dump | grep -i become
   ```

4. **Common mistakes:**
   - Forgetting `become: true`
   - Wrong become_user
   - SSH key not copied
   - Sudo password not provided

5. **Debug privilege issues:**
   ```bash
   ansible-playbook playbook.yml -vvv
   ```

6. **Verify file ownership:**
   ```bash
   ansible all -m command -a "ls -l /path/to/file"
   ```

---

## Troubleshooting

### Error: "Permission denied"
```bash
# Check sudo access
ansible all -m command -a "sudo -l"

# Add become
become: true
```

### Error: "Authentication failure"
```bash
# Check SSH key
ssh -i ~/.ssh/key user@host

# Copy key
ssh-copy-id -i ~/.ssh/key.pub user@host
```

### Error: "sudo: a password is required"
```bash
# Provide become password
ansible-playbook playbook.yml --ask-become-pass

# Or use vault
ansible_become_password: !vault |
  ...
```

### Error: "Connection timeout"
```bash
# Increase timeout
ansible_ssh_timeout: 60

# Check network
ping host
```

---

Good luck with your RHCE exam preparation! 🚀

Master SSH and privilege escalation - they're essential for secure automation in production.
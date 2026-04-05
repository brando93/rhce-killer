# RHCE Killer — Inventory Basics
## EX294: Ansible Inventory & Ad-hoc Commands Mastery

---

> **Beginner-Friendly Exam: Start Here!**
> This exam is the perfect entry point for Ansible beginners.
> Learn inventory management and ad-hoc commands from scratch.
> Time limit: **2 hours**. Start the timer with: `bash START.sh`

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
- All files must be created under `/home/student/ansible/`
- Do **not** modify `/etc/ansible/ansible.cfg`
- Commands must run without errors
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**None!** This is the starting point for learning Ansible.

---

## Tasks

### Task 01 — Create Basic Inventory (INI Format) (8 pts)

Create an inventory file `/home/student/ansible/inventory` in INI format with:
- A group `[webservers]` containing `node1.example.com`
- A group `[databases]` containing `node2.example.com`
- A group `[production]` containing both nodes

**Requirements:**
- Use INI format (not YAML)
- Use fully qualified domain names (FQDN)
- File must be named exactly `inventory`

---

### Task 02 — Configure ansible.cfg (8 pts)

Create `/home/student/ansible/ansible.cfg` with the following settings:
- `inventory` = `/home/student/ansible/inventory`
- `remote_user` = `student`
- `host_key_checking` = `False`

**Requirements:**
- Use `[defaults]` section
- File must be in the working directory
- Settings must be under correct section

---

### Task 03 — Test Connectivity with Ping (8 pts)

Use an ad-hoc command to ping all hosts in your inventory.

Save the exact command you used in a file:
`/home/student/ansible/adhoc-ping.sh`

**Requirements:**
- Use the `ping` module
- Target all hosts
- Command must succeed
- Save command to file

---

### Task 04 — Gather Facts from Specific Group (8 pts)

Use an ad-hoc command to gather facts from only the `webservers` group.

Save the command to:
`/home/student/ansible/adhoc-facts.sh`

**Requirements:**
- Use `setup` module
- Target only webservers group
- Command must display facts

---

### Task 05 — Install Package with Ad-hoc Command (8 pts)

Use an ad-hoc command to install the package `tree` on all managed nodes.

Save the command to:
`/home/student/ansible/adhoc-install.sh`

**Requirements:**
- Use `dnf` module
- Install on all managed nodes
- Use `become` for privilege escalation
- Package must be present after command

---

### Task 06 — Create Directory with Ad-hoc Command (8 pts)

Use an ad-hoc command to create the directory `/opt/ansible-test` on all managed nodes with:
- Mode: `0755`
- Owner: `root`
- Group: `root`

Save the command to:
`/home/student/ansible/adhoc-mkdir.sh`

**Requirements:**
- Use `file` module
- Create on all managed nodes
- Use `become`
- Directory must exist with correct permissions

---

### Task 07 — Copy File with Ad-hoc Command (8 pts)

First, create a file `/home/student/ansible/test.txt` with content: `Hello Ansible`

Then use an ad-hoc command to copy this file to `/tmp/test.txt` on all managed nodes.

Save the command to:
`/home/student/ansible/adhoc-copy.sh`

**Requirements:**
- Use `copy` module
- Copy to all managed nodes
- File must exist on remote nodes
- Content must match source

---

### Task 08 — Host Patterns - Wildcards (8 pts)

Create an inventory file `/home/student/ansible/inventory-patterns` with:
- Hosts: `web1.example.com`, `web2.example.com`, `db1.example.com`, `db2.example.com`
- Group `[all_web]` using wildcard pattern `web*.example.com`
- Group `[all_db]` using wildcard pattern `db*.example.com`

**Requirements:**
- Use INI format
- Use wildcard patterns in group definitions
- All 4 hosts must be defined

---

### Task 09 — Host Patterns - Ranges (8 pts)

Create an inventory file `/home/student/ansible/inventory-ranges` with:
- Hosts using range: `server[1:4].example.com` (creates server1, server2, server3, server4)
- Group `[app]` containing `server[1:2].example.com`
- Group `[cache]` containing `server[3:4].example.com`

**Requirements:**
- Use range notation
- All hosts must be in appropriate groups

---

### Task 10 — Group Variables (8 pts)

Create the directory structure and file:
`/home/student/ansible/group_vars/webservers.yml`

Define the following variables:
```yaml
http_port: 80
max_clients: 200
```

**Requirements:**
- Use YAML format
- File must be in `group_vars/` directory
- Variables must be accessible to webservers group

---

### Task 11 — Host Variables (8 pts)

Create the directory structure and file:
`/home/student/ansible/host_vars/node1.example.com.yml`

Define the following variables:
```yaml
server_role: primary
backup_enabled: true
```

**Requirements:**
- Use YAML format
- File must be in `host_vars/` directory
- Variables must be accessible to node1

---

### Task 12 — Parent and Child Groups (8 pts)

Create an inventory file `/home/student/ansible/inventory-hierarchy` with:
- Group `[web]` containing `node1.example.com`
- Group `[db]` containing `node2.example.com`
- Parent group `[production:children]` containing both `web` and `db` groups

**Requirements:**
- Use `:children` syntax for parent group
- Both child groups must be included

---

### Task 13 — Inventory Variables in INI Format (8 pts)

Create an inventory file `/home/student/ansible/inventory-vars` with:
- Host `node1.example.com` with variable `ansible_port=22`
- Host `node2.example.com` with variable `ansible_port=22`
- Group `[all:vars]` with variable `ansible_user=student`

**Requirements:**
- Use INI format
- Variables must be defined inline
- Use `[all:vars]` for group variables

---

### Task 14 — List Inventory Hosts (8 pts)

Use the `ansible-inventory` command to list all hosts in your inventory.

Save the command to:
`/home/student/ansible/adhoc-list-hosts.sh`

**Requirements:**
- Use `ansible-inventory` command
- List all hosts
- Output should show host details

---

### Task 15 — Verify Inventory Structure (8 pts)

Use the `ansible-inventory` command to display your inventory in graph format.

Save the command to:
`/home/student/ansible/adhoc-graph.sh`

**Requirements:**
- Use `ansible-inventory --graph`
- Command must show inventory hierarchy
- Save to specified file

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Basic Inventory (INI) | 8 |
| 02 | ansible.cfg Configuration | 8 |
| 03 | Ping Module | 8 |
| 04 | Setup Module | 8 |
| 05 | DNF Module | 8 |
| 06 | File Module | 8 |
| 07 | Copy Module | 8 |
| 08 | Wildcard Patterns | 8 |
| 09 | Range Patterns | 8 |
| 10 | Group Variables | 8 |
| 11 | Host Variables | 8 |
| 12 | Parent/Child Groups | 8 |
| 13 | Inventory Variables | 8 |
| 14 | List Hosts | 8 |
| 15 | Graph Inventory | 8 |
| **Total** | | **120** |

**Passing score: 70% (84/120 points)**

---

## When you finish

```bash
bash /home/student/exams/inventory-basics/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Create Basic Inventory (INI Format)

Create the inventory file:

```bash
cat > /home/student/ansible/inventory << 'EOF'
[webservers]
node1.example.com

[databases]
node2.example.com

[production]
node1.example.com
node2.example.com
EOF
```

**Explanation:**
- INI format uses `[groupname]` for group headers
- Hosts are listed one per line under their group
- Hosts can belong to multiple groups
- Use FQDN (fully qualified domain names)

**Verification:**
```bash
cat /home/student/ansible/inventory
```

---

## Solution 02 — Configure ansible.cfg

Create the configuration file:

```bash
cat > /home/student/ansible/ansible.cfg << 'EOF'
[defaults]
inventory = /home/student/ansible/inventory
remote_user = student
host_key_checking = False
EOF
```

**Explanation:**
- `[defaults]` section contains general settings
- `inventory` points to your inventory file
- `remote_user` sets the default SSH user
- `host_key_checking = False` disables SSH key verification (for lab use only)

**Verification:**
```bash
cat /home/student/ansible/ansible.cfg
ansible --version  # Shows config file location
```

---

## Solution 03 — Test Connectivity with Ping

Create the command file:

```bash
cat > /home/student/ansible/adhoc-ping.sh << 'EOF'
ansible all -m ping
EOF

chmod +x /home/student/ansible/adhoc-ping.sh
```

**Run the command:**
```bash
ansible all -m ping
```

**Explanation:**
- `ansible` is the ad-hoc command tool
- `all` targets all hosts in inventory
- `-m ping` uses the ping module
- Ping module tests Python connectivity, not ICMP

**Expected output:**
```
node1.example.com | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
node2.example.com | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## Solution 04 — Gather Facts from Specific Group

Create the command file:

```bash
cat > /home/student/ansible/adhoc-facts.sh << 'EOF'
ansible webservers -m setup
EOF

chmod +x /home/student/ansible/adhoc-facts.sh
```

**Run the command:**
```bash
ansible webservers -m setup
```

**Explanation:**
- `webservers` targets only the webservers group
- `-m setup` uses the setup module (fact gathering)
- Setup module collects system information (facts)
- Facts include OS, IP addresses, memory, CPU, etc.

**Filter facts (optional):**
```bash
ansible webservers -m setup -a "filter=ansible_distribution*"
```

---

## Solution 05 — Install Package with Ad-hoc Command

Create the command file:

```bash
cat > /home/student/ansible/adhoc-install.sh << 'EOF'
ansible all -m dnf -a "name=tree state=present" --become
EOF

chmod +x /home/student/ansible/adhoc-install.sh
```

**Run the command:**
```bash
ansible all -m dnf -a "name=tree state=present" --become
```

**Explanation:**
- `all` targets all managed nodes
- `-m dnf` uses the DNF package manager module
- `-a "name=tree state=present"` specifies package and desired state
- `--become` escalates privileges (sudo)
- `state=present` ensures package is installed

**Verification:**
```bash
ansible all -m command -a "tree --version"
```

---

## Solution 06 — Create Directory with Ad-hoc Command

Create the command file:

```bash
cat > /home/student/ansible/adhoc-mkdir.sh << 'EOF'
ansible all -m file -a "path=/opt/ansible-test state=directory mode=0755 owner=root group=root" --become
EOF

chmod +x /home/student/ansible/adhoc-mkdir.sh
```

**Run the command:**
```bash
ansible all -m file -a "path=/opt/ansible-test state=directory mode=0755 owner=root group=root" --become
```

**Explanation:**
- `-m file` uses the file module
- `path=/opt/ansible-test` specifies directory location
- `state=directory` creates a directory
- `mode=0755` sets permissions (rwxr-xr-x)
- `owner=root group=root` sets ownership
- `--become` required for creating in /opt

**Verification:**
```bash
ansible all -m command -a "ls -ld /opt/ansible-test"
```

---

## Solution 07 — Copy File with Ad-hoc Command

First, create the source file:

```bash
echo "Hello Ansible" > /home/student/ansible/test.txt
```

Create the command file:

```bash
cat > /home/student/ansible/adhoc-copy.sh << 'EOF'
ansible all -m copy -a "src=/home/student/ansible/test.txt dest=/tmp/test.txt"
EOF

chmod +x /home/student/ansible/adhoc-copy.sh
```

**Run the command:**
```bash
ansible all -m copy -a "src=/home/student/ansible/test.txt dest=/tmp/test.txt"
```

**Explanation:**
- `-m copy` uses the copy module
- `src=` specifies source file on control node
- `dest=` specifies destination on managed nodes
- Copy module transfers files from control to managed nodes
- No `--become` needed for /tmp

**Verification:**
```bash
ansible all -m command -a "cat /tmp/test.txt"
```

---

## Solution 08 — Host Patterns - Wildcards

Create the inventory file:

```bash
cat > /home/student/ansible/inventory-patterns << 'EOF'
web1.example.com
web2.example.com
db1.example.com
db2.example.com

[all_web]
web*.example.com

[all_db]
db*.example.com
EOF
```

**Explanation:**
- First, define all hosts explicitly
- Then use wildcard patterns in groups
- `web*` matches any host starting with "web"
- `db*` matches any host starting with "db"
- Wildcards work with shell-style globbing

**Verification:**
```bash
ansible all_web -i inventory-patterns --list-hosts
ansible all_db -i inventory-patterns --list-hosts
```

---

## Solution 09 — Host Patterns - Ranges

Create the inventory file:

```bash
cat > /home/student/ansible/inventory-ranges << 'EOF'
[app]
server[1:2].example.com

[cache]
server[3:4].example.com
EOF
```

**Explanation:**
- `[1:2]` expands to 1, 2 (creates server1, server2)
- `[3:4]` expands to 3, 4 (creates server3, server4)
- Range notation is inclusive
- Can also use alphabetic ranges: `[a:d]`
- Can use leading zeros: `[01:10]`

**Verification:**
```bash
ansible app -i inventory-ranges --list-hosts
ansible cache -i inventory-ranges --list-hosts
```

---

## Solution 10 — Group Variables

Create the directory and file:

```bash
mkdir -p /home/student/ansible/group_vars

cat > /home/student/ansible/group_vars/webservers.yml << 'EOF'
---
http_port: 80
max_clients: 200
EOF
```

**Explanation:**
- `group_vars/` directory must be in same location as inventory
- Filename must match group name: `webservers.yml`
- Use YAML format
- Variables are automatically loaded for that group
- All hosts in webservers group will have these variables

**Verification:**
```bash
ansible webservers -m debug -a "var=http_port"
ansible webservers -m debug -a "var=max_clients"
```

---

## Solution 11 — Host Variables

Create the directory and file:

```bash
mkdir -p /home/student/ansible/host_vars

cat > /home/student/ansible/host_vars/node1.example.com.yml << 'EOF'
---
server_role: primary
backup_enabled: true
EOF
```

**Explanation:**
- `host_vars/` directory must be in same location as inventory
- Filename must match hostname: `node1.example.com.yml`
- Use YAML format
- Variables are automatically loaded for that specific host
- Host variables override group variables

**Verification:**
```bash
ansible node1.example.com -m debug -a "var=server_role"
ansible node1.example.com -m debug -a "var=backup_enabled"
```

---

## Solution 12 — Parent and Child Groups

Create the inventory file:

```bash
cat > /home/student/ansible/inventory-hierarchy << 'EOF'
[web]
node1.example.com

[db]
node2.example.com

[production:children]
web
db
EOF
```

**Explanation:**
- `:children` suffix creates a parent group
- Parent group contains other groups (not hosts)
- List child group names (not hosts)
- Hosts inherit from parent group variables
- Useful for organizing complex inventories

**Verification:**
```bash
ansible production -i inventory-hierarchy --list-hosts
ansible web -i inventory-hierarchy --list-hosts
ansible db -i inventory-hierarchy --list-hosts
```

---

## Solution 13 — Inventory Variables in INI Format

Create the inventory file:

```bash
cat > /home/student/ansible/inventory-vars << 'EOF'
node1.example.com ansible_port=22
node2.example.com ansible_port=22

[all:vars]
ansible_user=student
EOF
```

**Explanation:**
- Variables can be defined inline with hosts
- Format: `hostname variable=value`
- `[all:vars]` section defines variables for all hosts
- `[groupname:vars]` defines variables for a group
- Inline variables are space-separated

**Verification:**
```bash
ansible all -i inventory-vars -m debug -a "var=ansible_user"
ansible all -i inventory-vars -m debug -a "var=ansible_port"
```

---

## Solution 14 — List Inventory Hosts

Create the command file:

```bash
cat > /home/student/ansible/adhoc-list-hosts.sh << 'EOF'
ansible-inventory --list
EOF

chmod +x /home/student/ansible/adhoc-list-hosts.sh
```

**Run the command:**
```bash
ansible-inventory --list
```

**Explanation:**
- `ansible-inventory` is a tool for working with inventory
- `--list` shows all hosts and variables in JSON format
- Shows complete inventory structure
- Includes all variables (group_vars, host_vars, etc.)

**Alternative formats:**
```bash
ansible-inventory --list -y  # YAML format
ansible-inventory --host node1.example.com  # Single host details
```

---

## Solution 15 — Verify Inventory Structure

Create the command file:

```bash
cat > /home/student/ansible/adhoc-graph.sh << 'EOF'
ansible-inventory --graph
EOF

chmod +x /home/student/ansible/adhoc-graph.sh
```

**Run the command:**
```bash
ansible-inventory --graph
```

**Explanation:**
- `--graph` displays inventory in tree format
- Shows group hierarchy
- Shows which hosts belong to which groups
- Useful for visualizing complex inventories

**Example output:**
```
@all:
  |--@ungrouped:
  |--@webservers:
  |  |--node1.example.com
  |--@databases:
  |  |--node2.example.com
  |--@production:
  |  |--node1.example.com
  |  |--node2.example.com
```

**With variables:**
```bash
ansible-inventory --graph --vars
```

---

## Quick Reference: Essential Commands

### Inventory Commands
```bash
# List all hosts
ansible all --list-hosts

# List hosts in a group
ansible webservers --list-hosts

# Show inventory structure
ansible-inventory --graph

# Show inventory with variables
ansible-inventory --list

# Verify inventory file
ansible-inventory --list -i /path/to/inventory
```

### Ad-hoc Commands
```bash
# Ping all hosts
ansible all -m ping

# Run command
ansible all -m command -a "uptime"

# Run shell command (with pipes)
ansible all -m shell -a "ps aux | grep ssh"

# Install package
ansible all -m dnf -a "name=httpd state=present" --become

# Start service
ansible all -m service -a "name=httpd state=started" --become

# Copy file
ansible all -m copy -a "src=/local/file dest=/remote/file"

# Create directory
ansible all -m file -a "path=/opt/dir state=directory" --become

# Gather facts
ansible all -m setup

# Filter facts
ansible all -m setup -a "filter=ansible_distribution*"
```

### Host Patterns
```bash
# All hosts
ansible all -m ping

# Specific host
ansible node1.example.com -m ping

# Specific group
ansible webservers -m ping

# Multiple groups (OR)
ansible webservers:databases -m ping

# Intersection (AND)
ansible webservers:&production -m ping

# Exclusion (NOT)
ansible all:!databases -m ping

# Wildcard
ansible web* -m ping

# Range
ansible server[1:5] -m ping
```

### Configuration
```bash
# Show config
ansible-config dump

# Show config file location
ansible --version

# List all config options
ansible-config list

# View specific setting
ansible-config dump | grep inventory
```

---

## Common Patterns

### Inventory Organization
```ini
# Simple inventory
[web]
web1.example.com
web2.example.com

[db]
db1.example.com

# With variables
[web]
web1.example.com http_port=80
web2.example.com http_port=8080

[web:vars]
ansible_user=webadmin

# Parent groups
[production:children]
web
db

[production:vars]
environment=prod
```

### Variable Precedence (lowest to highest)
1. Group vars (all)
2. Group vars (parent)
3. Group vars (child)
4. Host vars
5. Playbook vars
6. Command line vars (-e)

### Best Practices
- Use FQDN for hostnames
- Organize inventory by function, not location
- Use group_vars and host_vars for variables
- Keep inventory in version control
- Document your inventory structure
- Use meaningful group names
- Test inventory with --list-hosts

---

## Tips for RHCE Exam

1. **Always verify your inventory:**
   ```bash
   ansible all --list-hosts
   ansible-inventory --graph
   ```

2. **Test connectivity first:**
   ```bash
   ansible all -m ping
   ```

3. **Use --check for dry runs:**
   ```bash
   ansible all -m dnf -a "name=httpd state=present" --check
   ```

4. **Remember to use --become:**
   - Package installation
   - Service management
   - File operations in system directories

5. **Save ad-hoc commands:**
   - Always save commands to files as requested
   - Make them executable: `chmod +x file.sh`

6. **Verify your work:**
   - Run commands to verify changes
   - Check file contents
   - Verify permissions and ownership

7. **Common mistakes to avoid:**
   - Forgetting --become
   - Using short hostnames instead of FQDN
   - Not saving commands to files
   - Incorrect file paths

---

Good luck with your RHCE exam preparation! 🚀

This exam covers the absolute fundamentals. Master these concepts before moving to more advanced topics.
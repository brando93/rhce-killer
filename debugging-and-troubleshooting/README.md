# RHCE Killer — Debugging and Troubleshooting
## EX294: Mastering Ansible Debugging

---

> **Intermediate Exam: Debug and Troubleshoot**
> This exam teaches you how to debug and troubleshoot Ansible playbooks.
> Master debug module, verbose output, and troubleshooting techniques.
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
- Use debugging techniques to solve problems
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, variables-and-facts

You should know:
- How to write playbooks
- How to use variables
- Basic module usage
- Command line basics

---

## Tasks

### Task 01 — Basic Debug Module (10 pts)

Create playbook `debug-basic.yml` that:
- Runs on **all managed nodes**
- Uses `debug` module to display message "Hello from {{ inventory_hostname }}"
- Shows hostname in output

**Requirements:**
- Use `debug` module
- Use `msg` parameter
- Display variable
- Runs successfully

---

### Task 02 — Debug Variable (12 pts)

Create playbook `debug-var.yml` that:
- Defines variable `app_version: 1.0.0`
- Uses `debug` module with `var` parameter
- Displays the variable value

**Requirements:**
- Use `debug` module
- Use `var` parameter
- Display variable content
- Shows variable name and value

---

### Task 03 — Debug with Verbosity (12 pts)

Create playbook `debug-verbosity.yml` that:
- Has debug task with `verbosity: 2`
- Message only shows with `-vv` or higher
- Hidden in normal output

**Requirements:**
- Use `verbosity` parameter
- Message hidden by default
- Shows with `-vv`
- Proper verbosity level

---

### Task 04 — Debug Registered Variable (15 pts)

Create playbook `debug-register.yml` that:
- Runs command `hostname`
- Registers output
- Debugs entire registered variable
- Shows all registered data

**Requirements:**
- Use `register`
- Use `debug` with `var`
- Display registered variable
- Shows stdout, rc, etc.

---

### Task 05 — Debug Specific Registered Field (12 pts)

Create playbook `debug-field.yml` that:
- Runs command and registers
- Debugs only `stdout` field
- Uses dot notation

**Requirements:**
- Register command output
- Debug specific field
- Use `var: result.stdout`
- Shows only stdout

---

### Task 06 — Debug with Conditional (15 pts)

Create playbook `debug-when.yml` that:
- Debugs message only on node1
- Uses `when` condition
- Skips on other hosts

**Requirements:**
- Use `debug` with `when`
- Conditional based on hostname
- Shows on node1 only
- Skipped on others

---

### Task 07 — Debug Facts (12 pts)

Create playbook `debug-facts.yml` that:
- Displays `ansible_distribution`
- Displays `ansible_memtotal_mb`
- Displays `ansible_processor_vcpus`
- Uses debug module

**Requirements:**
- Debug multiple facts
- Separate tasks
- Shows fact values
- All facts displayed

---

### Task 08 — Debug with Loop (15 pts)

Create playbook `debug-loop.yml` that:
- Loops over list of items
- Debugs each item
- Shows loop iteration

**Requirements:**
- Use `loop` with debug
- Display each item
- Shows all iterations
- Proper loop syntax

---

### Task 09 — Syntax Check (10 pts)

Create playbook `syntax-test.yml` with intentional syntax error, then:
- Run `--syntax-check`
- Identify error
- Fix syntax
- Verify with syntax check

**Requirements:**
- Use `--syntax-check` flag
- Identify error location
- Fix the error
- Playbook passes check

---

### Task 10 — Check Mode (Dry Run) (12 pts)

Create playbook `check-mode.yml` that:
- Creates file `/tmp/test.txt`
- Run with `--check` flag
- Verify no changes made
- Shows what would happen

**Requirements:**
- Use `--check` flag
- No actual changes
- Shows intended changes
- Dry run successful

---

### Task 11 — Diff Mode (15 pts)

Create playbook `diff-mode.yml` that:
- Modifies file content
- Run with `--diff` flag
- Shows differences
- Displays before/after

**Requirements:**
- Use `--diff` flag
- Shows file changes
- Before and after visible
- Diff output clear

---

### Task 12 — Step Mode (12 pts)

Create playbook `step-mode.yml` with multiple tasks:
- Run with `--step` flag
- Confirm each task
- Shows interactive execution

**Requirements:**
- Use `--step` flag
- Multiple tasks
- Interactive prompts
- Can skip tasks

---

### Task 13 — Start at Task (15 pts)

Create playbook `start-at.yml` with 5 tasks:
- Run with `--start-at-task` flag
- Start from specific task
- Skip earlier tasks

**Requirements:**
- Use `--start-at-task` flag
- Specify task name
- Earlier tasks skipped
- Starts at correct task

---

### Task 14 — Limit Hosts (12 pts)

Create playbook `limit-hosts.yml` that runs on all:
- Run with `--limit` flag
- Execute only on node1
- Other hosts skipped

**Requirements:**
- Use `--limit` flag
- Specify single host
- Only that host affected
- Others skipped

---

### Task 15 — List Tasks (10 pts)

Create playbook `list-tasks.yml`:
- Run with `--list-tasks` flag
- Display all tasks
- No execution

**Requirements:**
- Use `--list-tasks` flag
- Shows task list
- No execution
- All tasks listed

---

### Task 16 — List Tags (10 pts)

Create playbook `list-tags.yml` with tagged tasks:
- Run with `--list-tags` flag
- Display all tags
- No execution

**Requirements:**
- Tasks have tags
- Use `--list-tags` flag
- Shows all tags
- No execution

---

### Task 17 — Verbose Output Levels (15 pts)

Create playbook `verbose-test.yml`:
- Run with `-v`, `-vv`, `-vvv`, `-vvvv`
- Observe different output levels
- Document differences

**Requirements:**
- Test all verbosity levels
- Observe output differences
- Understand each level
- Document findings

---

### Task 18 — Debug Ansible Configuration (12 pts)

Use `ansible-config` command to:
- List all configuration
- View specific setting
- Dump current config

**Requirements:**
- Use `ansible-config list`
- Use `ansible-config dump`
- View specific settings
- Understand output

---

### Task 19 — Debug Inventory (12 pts)

Use `ansible-inventory` command to:
- List all hosts
- Show host variables
- Display in JSON/YAML

**Requirements:**
- Use `ansible-inventory --list`
- Use `ansible-inventory --host`
- Show variables
- Proper format

---

### Task 20 — Troubleshoot Failed Playbook (20 pts)

Given broken playbook `broken.yml`:
- Identify all errors
- Fix syntax errors
- Fix logic errors
- Make playbook work

**Requirements:**
- Find all errors
- Fix each error
- Playbook runs successfully
- All tasks execute

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Basic Debug Module | 10 |
| 02 | Debug Variable | 12 |
| 03 | Debug with Verbosity | 12 |
| 04 | Debug Registered Variable | 15 |
| 05 | Debug Specific Field | 12 |
| 06 | Debug with Conditional | 15 |
| 07 | Debug Facts | 12 |
| 08 | Debug with Loop | 15 |
| 09 | Syntax Check | 10 |
| 10 | Check Mode | 12 |
| 11 | Diff Mode | 15 |
| 12 | Step Mode | 12 |
| 13 | Start at Task | 15 |
| 14 | Limit Hosts | 12 |
| 15 | List Tasks | 10 |
| 16 | List Tags | 10 |
| 17 | Verbose Output | 15 |
| 18 | Debug Config | 12 |
| 19 | Debug Inventory | 12 |
| 20 | Troubleshoot Playbook | 20 |
| **Total** | | **240** |

**Passing score: 70% (168/240 points)**

---

## When you finish

```bash
bash /home/student/exams/debugging-and-troubleshooting/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

---

## Solution 01 — Basic Debug Module

**Playbook: debug-basic.yml**
```yaml
---
- name: Basic debug example
  hosts: all
  
  tasks:
    - name: Display hello message
      ansible.builtin.debug:
        msg: "Hello from {{ inventory_hostname }}"
```

**Run:**
```bash
ansible-playbook debug-basic.yml
```

**Output:**
```
TASK [Display hello message] ***
ok: [node1.example.com] => {
    "msg": "Hello from node1.example.com"
}
ok: [node2.example.com] => {
    "msg": "Hello from node2.example.com"
}
```

---

## Solution 02 — Debug Variable

**Playbook: debug-var.yml**
```yaml
---
- name: Debug variable
  hosts: all
  
  vars:
    app_version: 1.0.0
  
  tasks:
    - name: Display app version
      ansible.builtin.debug:
        var: app_version
```

**Output:**
```
TASK [Display app version] ***
ok: [node1.example.com] => {
    "app_version": "1.0.0"
}
```

**Difference between msg and var:**
- `msg`: Displays custom message
- `var`: Displays variable name and value

---

## Solution 03 — Debug with Verbosity

**Playbook: debug-verbosity.yml**
```yaml
---
- name: Debug with verbosity
  hosts: all
  
  tasks:
    - name: Always visible
      ansible.builtin.debug:
        msg: "This always shows"
    
    - name: Verbose level 1
      ansible.builtin.debug:
        msg: "This shows with -v"
        verbosity: 1
    
    - name: Verbose level 2
      ansible.builtin.debug:
        msg: "This shows with -vv"
        verbosity: 2
```

**Run:**
```bash
# Normal (level 0)
ansible-playbook debug-verbosity.yml

# Verbose level 1
ansible-playbook debug-verbosity.yml -v

# Verbose level 2
ansible-playbook debug-verbosity.yml -vv
```

---

## Solution 04 — Debug Registered Variable

**Playbook: debug-register.yml**
```yaml
---
- name: Debug registered variable
  hosts: all
  
  tasks:
    - name: Run hostname command
      ansible.builtin.command: hostname
      register: hostname_result
      changed_when: false
    
    - name: Display entire registered variable
      ansible.builtin.debug:
        var: hostname_result
```

**Output shows:**
```json
{
    "changed": false,
    "cmd": ["hostname"],
    "delta": "0:00:00.003",
    "end": "2024-01-15 10:30:00",
    "rc": 0,
    "start": "2024-01-15 10:30:00",
    "stderr": "",
    "stderr_lines": [],
    "stdout": "node1.example.com",
    "stdout_lines": ["node1.example.com"]
}
```

---

## Solution 05 — Debug Specific Registered Field

**Playbook: debug-field.yml**
```yaml
---
- name: Debug specific field
  hosts: all
  
  tasks:
    - name: Get system info
      ansible.builtin.command: uname -a
      register: system_info
      changed_when: false
    
    - name: Display only stdout
      ansible.builtin.debug:
        var: system_info.stdout
    
    - name: Display only return code
      ansible.builtin.debug:
        var: system_info.rc
```

**Access nested fields:**
```yaml
var: result.stdout
var: result.stdout_lines[0]
var: result.rc
```

---

## Solution 06 — Debug with Conditional

**Playbook: debug-when.yml**
```yaml
---
- name: Conditional debug
  hosts: all
  
  tasks:
    - name: Debug on node1 only
      ansible.builtin.debug:
        msg: "This is node1"
      when: inventory_hostname == "node1.example.com"
    
    - name: Debug on high memory systems
      ansible.builtin.debug:
        msg: "High memory: {{ ansible_memtotal_mb }} MB"
      when: ansible_memtotal_mb > 2048
```

---

## Solution 07 — Debug Facts

**Playbook: debug-facts.yml**
```yaml
---
- name: Debug facts
  hosts: all
  
  tasks:
    - name: Display OS distribution
      ansible.builtin.debug:
        var: ansible_distribution
    
    - name: Display total memory
      ansible.builtin.debug:
        var: ansible_memtotal_mb
    
    - name: Display CPU count
      ansible.builtin.debug:
        var: ansible_processor_vcpus
    
    - name: Display all in one message
      ansible.builtin.debug:
        msg: |
          OS: {{ ansible_distribution }}
          Memory: {{ ansible_memtotal_mb }} MB
          CPUs: {{ ansible_processor_vcpus }}
```

---

## Solution 08 — Debug with Loop

**Playbook: debug-loop.yml**
```yaml
---
- name: Debug with loop
  hosts: all
  
  vars:
    packages:
      - httpd
      - nginx
      - mariadb-server
  
  tasks:
    - name: Display each package
      ansible.builtin.debug:
        msg: "Package: {{ item }}"
      loop: "{{ packages }}"
    
    - name: Display with index
      ansible.builtin.debug:
        msg: "{{ loop.index }}: {{ item }}"
      loop: "{{ packages }}"
      loop_control:
        extended: true
```

---

## Solution 09 — Syntax Check

**Broken playbook: syntax-test.yml**
```yaml
---
- name: Syntax test
  hosts: all
  
  tasks:
    - name: Task with error
      ansible.builtin.debug
        msg: "Missing colon"  # ERROR: Missing colon after debug
```

**Check syntax:**
```bash
ansible-playbook syntax-test.yml --syntax-check
```

**Error output:**
```
ERROR! Syntax Error while loading YAML.
  mapping values are not allowed here
```

**Fixed version:**
```yaml
---
- name: Syntax test
  hosts: all
  
  tasks:
    - name: Task fixed
      ansible.builtin.debug:
        msg: "Fixed with colon"
```

---

## Solution 10 — Check Mode (Dry Run)

**Playbook: check-mode.yml**
```yaml
---
- name: Check mode test
  hosts: all
  become: true
  
  tasks:
    - name: Create file
      ansible.builtin.copy:
        content: "Test content"
        dest: /tmp/test.txt
        mode: '0644'
    
    - name: Install package
      ansible.builtin.dnf:
        name: vim-enhanced
        state: present
```

**Run in check mode:**
```bash
ansible-playbook check-mode.yml --check
```

**Verify no changes:**
```bash
ansible all -m command -a "ls /tmp/test.txt"  # Should not exist
```

---

## Solution 11 — Diff Mode

**Playbook: diff-mode.yml**
```yaml
---
- name: Diff mode test
  hosts: all
  
  tasks:
    - name: Create initial file
      ansible.builtin.copy:
        content: |
          Line 1
          Line 2
          Line 3
        dest: /tmp/diff-test.txt
        mode: '0644'
    
    - name: Modify file
      ansible.builtin.copy:
        content: |
          Line 1
          Line 2 modified
          Line 3
          Line 4 added
        dest: /tmp/diff-test.txt
        mode: '0644'
```

**Run with diff:**
```bash
ansible-playbook diff-mode.yml --diff
```

**Output shows:**
```diff
--- before: /tmp/diff-test.txt
+++ after: /tmp/diff-test.txt
@@ -1,3 +1,4 @@
 Line 1
-Line 2
+Line 2 modified
 Line 3
+Line 4 added
```

---

## Solution 12 — Step Mode

**Playbook: step-mode.yml**
```yaml
---
- name: Step mode test
  hosts: all
  
  tasks:
    - name: Task 1
      ansible.builtin.debug:
        msg: "First task"
    
    - name: Task 2
      ansible.builtin.debug:
        msg: "Second task"
    
    - name: Task 3
      ansible.builtin.debug:
        msg: "Third task"
```

**Run in step mode:**
```bash
ansible-playbook step-mode.yml --step
```

**Interactive prompts:**
```
Perform task: Task 1 (y/n/c): y
Perform task: Task 2 (y/n/c): n  # Skip
Perform task: Task 3 (y/n/c): c  # Continue without asking
```

---

## Solution 13 — Start at Task

**Playbook: start-at.yml**
```yaml
---
- name: Start at task test
  hosts: all
  
  tasks:
    - name: Task 1 - Preparation
      ansible.builtin.debug:
        msg: "Preparing"
    
    - name: Task 2 - Installation
      ansible.builtin.debug:
        msg: "Installing"
    
    - name: Task 3 - Configuration
      ansible.builtin.debug:
        msg: "Configuring"
    
    - name: Task 4 - Service
      ansible.builtin.debug:
        msg: "Starting service"
    
    - name: Task 5 - Verification
      ansible.builtin.debug:
        msg: "Verifying"
```

**Start from specific task:**
```bash
ansible-playbook start-at.yml --start-at-task="Task 3 - Configuration"
```

**Result:** Tasks 1 and 2 skipped, starts at Task 3

---

## Solution 14 — Limit Hosts

**Playbook: limit-hosts.yml**
```yaml
---
- name: Limit hosts test
  hosts: all
  
  tasks:
    - name: Display hostname
      ansible.builtin.debug:
        msg: "Running on {{ inventory_hostname }}"
```

**Run with limit:**
```bash
# Single host
ansible-playbook limit-hosts.yml --limit node1.example.com

# Multiple hosts
ansible-playbook limit-hosts.yml --limit "node1.example.com,node2.example.com"

# Group
ansible-playbook limit-hosts.yml --limit webservers

# Pattern
ansible-playbook limit-hosts.yml --limit "node*"
```

---

## Solution 15 — List Tasks

**Playbook: list-tasks.yml**
```yaml
---
- name: List tasks test
  hosts: all
  
  tasks:
    - name: Install packages
      ansible.builtin.debug:
        msg: "Installing"
    
    - name: Configure application
      ansible.builtin.debug:
        msg: "Configuring"
    
    - name: Start services
      ansible.builtin.debug:
        msg: "Starting"
```

**List tasks:**
```bash
ansible-playbook list-tasks.yml --list-tasks
```

**Output:**
```
playbook: list-tasks.yml

  play #1 (all): List tasks test    TAGS: []
    tasks:
      Install packages    TAGS: []
      Configure application    TAGS: []
      Start services    TAGS: []
```

---

## Solution 16 — List Tags

**Playbook: list-tags.yml**
```yaml
---
- name: List tags test
  hosts: all
  
  tasks:
    - name: Install packages
      ansible.builtin.debug:
        msg: "Installing"
      tags:
        - install
        - packages
    
    - name: Configure application
      ansible.builtin.debug:
        msg: "Configuring"
      tags:
        - config
        - setup
    
    - name: Start services
      ansible.builtin.debug:
        msg: "Starting"
      tags:
        - service
        - start
```

**List tags:**
```bash
ansible-playbook list-tags.yml --list-tags
```

**Output:**
```
playbook: list-tags.yml

  play #1 (all): List tags test    TAGS: []
      TASK TAGS: [config, install, packages, service, setup, start]
```

---

## Solution 17 — Verbose Output Levels

**Playbook: verbose-test.yml**
```yaml
---
- name: Verbose output test
  hosts: all
  
  tasks:
    - name: Simple task
      ansible.builtin.ping:
```

**Test verbosity levels:**
```bash
# Level 0 (default) - Minimal output
ansible-playbook verbose-test.yml

# Level 1 (-v) - Shows task results
ansible-playbook verbose-test.yml -v

# Level 2 (-vv) - Shows task results and configuration
ansible-playbook verbose-test.yml -vv

# Level 3 (-vvv) - Shows connection debugging
ansible-playbook verbose-test.yml -vvv

# Level 4 (-vvvv) - Shows SSH debugging
ansible-playbook verbose-test.yml -vvvv
```

**Verbosity levels:**
- `-v`: Task results
- `-vv`: Task results + task configuration
- `-vvv`: Connection debugging
- `-vvvv`: SSH protocol debugging

---

## Solution 18 — Debug Ansible Configuration

```bash
# List all configuration options
ansible-config list

# Dump current configuration
ansible-config dump

# Dump only changed settings
ansible-config dump --only-changed

# View specific setting
ansible-config dump | grep inventory

# View configuration file locations
ansible-config view
```

**Useful commands:**
```bash
# Show where settings come from
ansible-config dump --only-changed -v

# List all inventory settings
ansible-config list | grep inventory
```

---

## Solution 19 — Debug Inventory

```bash
# List all hosts
ansible-inventory --list

# List in YAML format
ansible-inventory --list -y

# Show specific host
ansible-inventory --host node1.example.com

# Show host variables
ansible-inventory --host node1.example.com -y

# Graph inventory
ansible-inventory --graph

# Graph with variables
ansible-inventory --graph --vars
```

**Example output:**
```bash
$ ansible-inventory --list -y
all:
  children:
    ungrouped: {}
    webservers:
      hosts:
        node1.example.com:
          ansible_host: 10.0.2.11
        node2.example.com:
          ansible_host: 10.0.2.12
```

---

## Solution 20 — Troubleshoot Failed Playbook

**Broken playbook: broken.yml**
```yaml
---
- name: Broken playbook
  hosts: all
  become true  # ERROR 1: Missing colon
  
  vars
    app_port: 8080  # ERROR 2: Missing colon
  
  tasks:
    - name: Install package
      ansible.builtin.dnf
        name: httpd  # ERROR 3: Missing colon
        state: present
    
    - name: Start service
      ansible.builtin.service:
        name: httpd
        state: started
      when inventory_hostname == "node1"  # ERROR 4: Missing colon
```

**Fixed playbook:**
```yaml
---
- name: Fixed playbook
  hosts: all
  become: true  # FIXED 1
  
  vars:  # FIXED 2
    app_port: 8080
  
  tasks:
    - name: Install package
      ansible.builtin.dnf:  # FIXED 3
        name: httpd
        state: present
    
    - name: Start service
      ansible.builtin.service:
        name: httpd
        state: started
      when: inventory_hostname == "node1"  # FIXED 4
```

---

## Quick Reference: Debug Commands

### Playbook Execution
```bash
ansible-playbook playbook.yml                    # Normal run
ansible-playbook playbook.yml --syntax-check     # Check syntax
ansible-playbook playbook.yml --check            # Dry run
ansible-playbook playbook.yml --diff             # Show diffs
ansible-playbook playbook.yml --step             # Interactive
ansible-playbook playbook.yml -v                 # Verbose
ansible-playbook playbook.yml -vvv               # Very verbose
```

### Selective Execution
```bash
ansible-playbook playbook.yml --limit host       # Limit hosts
ansible-playbook playbook.yml --tags tag         # Run tags
ansible-playbook playbook.yml --skip-tags tag    # Skip tags
ansible-playbook playbook.yml --start-at-task "Task Name"  # Start at task
```

### Information
```bash
ansible-playbook playbook.yml --list-tasks       # List tasks
ansible-playbook playbook.yml --list-tags        # List tags
ansible-playbook playbook.yml --list-hosts       # List hosts
```

---

## Quick Reference: Debug Module

### Basic Usage
```yaml
- debug:
    msg: "Message"

- debug:
    var: variable_name

- debug:
    msg: "Value: {{ variable }}"
```

### With Verbosity
```yaml
- debug:
    msg: "Debug message"
    verbosity: 2  # Shows with -vv
```

### With Conditional
```yaml
- debug:
    msg: "Conditional message"
  when: condition
```

---

## Best Practices

1. **Use debug liberally during development:**
   ```yaml
   - debug:
       var: result
   ```

2. **Use verbosity for detailed debugging:**
   ```yaml
   - debug:
       msg: "Detailed info"
       verbosity: 2
   ```

3. **Always syntax check first:**
   ```bash
   ansible-playbook playbook.yml --syntax-check
   ```

4. **Use check mode before applying:**
   ```bash
   ansible-playbook playbook.yml --check --diff
   ```

5. **Debug registered variables:**
   ```yaml
   - command: some_command
     register: result
   - debug:
       var: result
   ```

6. **Use step mode for complex playbooks:**
   ```bash
   ansible-playbook playbook.yml --step
   ```

---

## Tips for RHCE Exam

1. **Know verbosity levels:**
   - `-v`: Basic
   - `-vv`: More detail
   - `-vvv`: Connection debug
   - `-vvvv`: SSH debug

2. **Use syntax check:**
   ```bash
   ansible-playbook playbook.yml --syntax-check
   ```

3. **Test with check mode:**
   ```bash
   ansible-playbook playbook.yml --check
   ```

4. **Debug variables:**
   ```yaml
   - debug:
       var: variable_name
   ```

5. **Common mistakes:**
   - Missing colons
   - Wrong indentation
   - Undefined variables
   - Wrong module names

6. **Quick debugging:**
   ```bash
   ansible-playbook playbook.yml -vv --check --diff
   ```

---

Good luck with your RHCE exam preparation! 🚀

Master debugging - it's essential for troubleshooting and developing reliable playbooks.
# RHCE Killer — Conditionals and When
## EX294: Mastering Ansible Conditional Logic

---

> **Intermediate Exam: Control Flow Mastery**
> This exam teaches you how to use conditional logic in Ansible.
> Master when conditions, failed_when, and changed_when.
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
- Use proper conditional syntax
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, variables-and-facts

You should know:
- How to write playbooks
- How to use variables
- How to use Ansible facts
- Basic module usage

---

## Tasks

### Task 01 — Basic When Condition with Equality (10 pts)

Create a playbook `/home/student/ansible/when-basic.yml` that:
- Runs on **all managed nodes**
- Defines a variable `environment: production`
- Has a task that displays "This is a production server" **only when** `environment` equals `production`
- Has another task that displays "This is not production" **only when** `environment` does not equal `production`

**Requirements:**
- Use `when` condition
- Use `==` for equality
- Use `!=` for inequality
- Both tasks should use `debug` module

---

### Task 02 — When with Facts - OS Detection (12 pts)

Create a playbook `/home/student/ansible/when-os.yml` that:
- Runs on **all managed nodes**
- Installs `httpd` **only on** Rocky Linux systems
- Installs `apache2` **only on** Ubuntu systems (won't match in our lab, but show the logic)
- Uses `ansible_distribution` fact

**Requirements:**
- Use `when` with `ansible_distribution`
- Use `==` operator
- Use `become: true`
- Two separate tasks

---

### Task 03 — When with Numeric Comparison (12 pts)

Create a playbook `/home/student/ansible/when-memory.yml` that:
- Runs on **all managed nodes**
- Displays "High memory system" if total memory is greater than 2048 MB
- Displays "Standard memory system" if total memory is between 1024 and 2048 MB
- Displays "Low memory system" if total memory is less than 1024 MB
- Uses `ansible_memtotal_mb` fact

**Requirements:**
- Use `when` with `>`, `>=`, `<`, `<=` operators
- Use `and` for range checking
- Three separate debug tasks

---

### Task 04 — Multiple Conditions with AND (15 pts)

Create a playbook `/home/student/ansible/when-and.yml` that:
- Runs on **all managed nodes**
- Installs `firewalld` **only if**:
  - System has more than 1 CPU core **AND**
  - System has more than 1GB of RAM
- Uses `ansible_processor_vcpus` and `ansible_memtotal_mb` facts

**Requirements:**
- Use `when` with multiple conditions
- Use `and` operator (or list format)
- Use `become: true`
- Single task with multiple conditions

---

### Task 05 — Multiple Conditions with OR (12 pts)

Create a playbook `/home/student/ansible/when-or.yml` that:
- Runs on **all managed nodes**
- Displays "Web or Database server" if hostname contains "web" **OR** "db"
- Uses `ansible_hostname` or `inventory_hostname`

**Requirements:**
- Use `when` with `or` operator
- Use `in` operator for string matching
- Use `debug` module

---

### Task 06 — When with 'in' Operator (12 pts)

Create a playbook `/home/student/ansible/when-in.yml` that:
- Runs on **all managed nodes**
- Creates directory `/opt/webserver` **only if** host is in the `webservers` group
- Creates directory `/opt/database` **only if** host is in the `databases` group
- Uses `group_names` magic variable

**Requirements:**
- Use `when` with `in` operator
- Use `group_names` magic variable
- Use `become: true`
- Two separate tasks

---

### Task 07 — When with 'is defined' (12 pts)

Create a playbook `/home/student/ansible/when-defined.yml` that:
- Runs on **all managed nodes**
- Defines a variable `app_port: 8080` in vars section
- Has a task that creates file `/tmp/port.txt` with content of `app_port` **only if** `app_port` is defined
- Has another task that displays "Port not defined" **only if** `app_port` is not defined

**Requirements:**
- Use `when` with `is defined`
- Use `when` with `is not defined`
- Use `copy` module with `content`

---

### Task 08 — When with Boolean Variables (10 pts)

Create a playbook `/home/student/ansible/when-boolean.yml` that:
- Runs on **all managed nodes**
- Defines variables:
  - `enable_firewall: true`
  - `enable_selinux: false`
- Starts `firewalld` service **only if** `enable_firewall` is true
- Displays "SELinux is disabled" **only if** `enable_selinux` is false

**Requirements:**
- Use `when` with boolean variables
- Use `when: variable` for true
- Use `when: not variable` for false
- Use `become: true` for service task

---

### Task 09 — When with String Matching (12 pts)

Create a playbook `/home/student/ansible/when-string.yml` that:
- Runs on **all managed nodes**
- Displays "Node 1 detected" if `inventory_hostname` starts with "node1"
- Displays "Node 2 detected" if `inventory_hostname` starts with "node2"
- Uses `startswith()` filter or `is match()` test

**Requirements:**
- Use `when` with string matching
- Use `inventory_hostname` variable
- Two separate debug tasks

---

### Task 10 — failed_when Customization (15 pts)

Create a playbook `/home/student/ansible/failed-when.yml` that:
- Runs on **all managed nodes**
- Executes command `grep student /etc/passwd`
- Uses `register` to capture output
- Uses `failed_when` to mark as failed **only if** return code is greater than 1
  (Return code 0 = found, 1 = not found, 2+ = error)

**Requirements:**
- Use `command` module
- Use `register` keyword
- Use `failed_when` with `rc` (return code)
- Task should not fail if user not found (rc=1)

---

### Task 11 — changed_when Customization (15 pts)

Create a playbook `/home/student/ansible/changed-when.yml` that:
- Runs on **all managed nodes**
- Executes command `cat /etc/hostname`
- Uses `register` to capture output
- Uses `changed_when: false` to never report as changed

**Requirements:**
- Use `command` module
- Use `register` keyword
- Use `changed_when: false`
- Task should always show as "ok" not "changed"

---

### Task 12 — When with Register (15 pts)

Create a playbook `/home/student/ansible/when-register.yml` that:
- Runs on **all managed nodes**
- Checks if package `httpd` is installed using `rpm -q httpd`
- Registers the result
- **Only if httpd is NOT installed**:
  - Installs httpd
  - Starts and enables httpd

**Requirements:**
- Use `command` module with `rpm -q`
- Use `register` keyword
- Use `failed_when: false` on check task
- Use `when` with `rc != 0` for installation
- Use `become: true`

---

### Task 13 — Complex Conditionals (18 pts)

Create a playbook `/home/student/ansible/when-complex.yml` that:
- Runs on **all managed nodes**
- Installs `nginx` **only if ALL** of these conditions are true:
  - OS is Rocky Linux
  - Memory is greater than 1GB
  - Hostname contains "web"
  - Package `httpd` is NOT installed

**Requirements:**
- Check for httpd first with `rpm -q httpd`
- Register the result
- Use multiple `when` conditions with `and`
- Use facts and registered variables
- Use `become: true`

---

### Task 14 — When with Nested Conditions (15 pts)

Create a playbook `/home/student/ansible/when-nested.yml` that:
- Runs on **all managed nodes**
- Creates file `/tmp/server-type.txt` with content based on conditions:
  - If memory > 2GB AND CPU > 2: "High Performance Server"
  - If memory > 1GB AND CPU > 1: "Standard Server"
  - Otherwise: "Basic Server"

**Requirements:**
- Use three separate tasks with different `when` conditions
- Use `ansible_memtotal_mb` and `ansible_processor_vcpus`
- Use `copy` module with `content`
- Only one file should be created (most specific condition first)

---

### Task 15 — When with List Membership (12 pts)

Create a playbook `/home/student/ansible/when-list.yml` that:
- Runs on **all managed nodes**
- Defines a list variable:
  ```yaml
  allowed_hosts:
    - node1.example.com
    - node2.example.com
  ```
- Displays "Host is allowed" **only if** `inventory_hostname` is in the `allowed_hosts` list
- Displays "Host is not allowed" **only if** `inventory_hostname` is not in the list

**Requirements:**
- Use `when` with `in` operator
- Use `when` with `not in` operator
- Use list variable
- Two debug tasks

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Basic When (==, !=) | 10 |
| 02 | When with Facts (OS) | 12 |
| 03 | Numeric Comparison | 12 |
| 04 | Multiple Conditions (AND) | 15 |
| 05 | Multiple Conditions (OR) | 12 |
| 06 | When with 'in' | 12 |
| 07 | When with 'is defined' | 12 |
| 08 | Boolean Variables | 10 |
| 09 | String Matching | 12 |
| 10 | failed_when | 15 |
| 11 | changed_when | 15 |
| 12 | When with Register | 15 |
| 13 | Complex Conditionals | 18 |
| 14 | Nested Conditions | 15 |
| 15 | List Membership | 12 |
| **Total** | | **187** |

**Passing score: 70% (131/187 points)**

---

## When you finish

```bash
bash /home/student/exams/conditionals-and-when/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Basic When Condition with Equality

```yaml
---
- name: Basic when conditions
  hosts: all
  
  vars:
    environment: production
  
  tasks:
    - name: Display production message
      ansible.builtin.debug:
        msg: "This is a production server"
      when: environment == "production"
    
    - name: Display non-production message
      ansible.builtin.debug:
        msg: "This is not production"
      when: environment != "production"
```

**Explanation:**
- `when` clause evaluates condition before running task
- `==` tests for equality
- `!=` tests for inequality
- Condition must be true for task to run
- No quotes needed around variable names in when
- Quotes needed around string values

**Run:**
```bash
ansible-playbook when-basic.yml
```

---

## Solution 02 — When with Facts - OS Detection

```yaml
---
- name: OS-specific package installation
  hosts: all
  become: true
  
  tasks:
    - name: Install httpd on Rocky Linux
      ansible.builtin.dnf:
        name: httpd
        state: present
      when: ansible_distribution == "Rocky"
    
    - name: Install apache2 on Ubuntu
      ansible.builtin.apt:
        name: apache2
        state: present
      when: ansible_distribution == "Ubuntu"
```

**Explanation:**
- `ansible_distribution` fact contains OS name
- Different package managers for different OS
- `dnf` for Rocky/RHEL/CentOS
- `apt` for Ubuntu/Debian
- Task skipped if condition false

**Verification:**
```bash
ansible all -m setup -a "filter=ansible_distribution"
```

---

## Solution 03 — When with Numeric Comparison

```yaml
---
- name: Memory-based conditionals
  hosts: all
  
  tasks:
    - name: Display high memory message
      ansible.builtin.debug:
        msg: "High memory system"
      when: ansible_memtotal_mb > 2048
    
    - name: Display standard memory message
      ansible.builtin.debug:
        msg: "Standard memory system"
      when: ansible_memtotal_mb >= 1024 and ansible_memtotal_mb <= 2048
    
    - name: Display low memory message
      ansible.builtin.debug:
        msg: "Low memory system"
      when: ansible_memtotal_mb < 1024
```

**Explanation:**
- Numeric comparisons: `>`, `<`, `>=`, `<=`, `==`, `!=`
- `and` combines multiple conditions
- All conditions must be true for `and`
- `ansible_memtotal_mb` gives memory in megabytes
- Conditions evaluated in order

**Check memory:**
```bash
ansible all -m setup -a "filter=ansible_memtotal_mb"
```

---

## Solution 04 — Multiple Conditions with AND

```yaml
---
- name: Install with multiple conditions
  hosts: all
  become: true
  
  tasks:
    - name: Install firewalld if conditions met
      ansible.builtin.dnf:
        name: firewalld
        state: present
      when:
        - ansible_processor_vcpus > 1
        - ansible_memtotal_mb > 1024
```

**Explanation:**
- List format for `when` = implicit `and`
- All conditions must be true
- Alternative syntax: `when: ansible_processor_vcpus > 1 and ansible_memtotal_mb > 1024`
- List format is more readable
- Each condition on separate line

**Alternative syntax:**
```yaml
when: ansible_processor_vcpus > 1 and ansible_memtotal_mb > 1024
```

---

## Solution 05 — Multiple Conditions with OR

```yaml
---
- name: OR conditions example
  hosts: all
  
  tasks:
    - name: Display message for web or db servers
      ansible.builtin.debug:
        msg: "Web or Database server"
      when: "'web' in ansible_hostname or 'db' in ansible_hostname"
```

**Explanation:**
- `or` means at least one condition must be true
- `in` operator checks if substring exists
- Must use quotes around entire condition with `or`
- `ansible_hostname` contains short hostname
- Alternative: use `inventory_hostname`

**Alternative with inventory_hostname:**
```yaml
when: "'web' in inventory_hostname or 'db' in inventory_hostname"
```

---

## Solution 06 — When with 'in' Operator

```yaml
---
- name: Group membership conditionals
  hosts: all
  become: true
  
  tasks:
    - name: Create webserver directory
      ansible.builtin.file:
        path: /opt/webserver
        state: directory
        mode: '0755'
      when: "'webservers' in group_names"
    
    - name: Create database directory
      ansible.builtin.file:
        path: /opt/database
        state: directory
        mode: '0755'
      when: "'databases' in group_names"
```

**Explanation:**
- `group_names` is a magic variable (list of groups for current host)
- `in` checks if item exists in list
- Quotes around group name
- Task runs only if host is in specified group
- Useful for role-based configurations

**Check group membership:**
```bash
ansible all -m debug -a "var=group_names"
```

---

## Solution 07 — When with 'is defined'

```yaml
---
- name: Check if variable is defined
  hosts: all
  
  vars:
    app_port: 8080
  
  tasks:
    - name: Create port file if variable defined
      ansible.builtin.copy:
        content: "{{ app_port }}\n"
        dest: /tmp/port.txt
        mode: '0644'
      when: app_port is defined
    
    - name: Display message if not defined
      ansible.builtin.debug:
        msg: "Port not defined"
      when: app_port is not defined
```

**Explanation:**
- `is defined` tests if variable exists
- `is not defined` tests if variable doesn't exist
- Useful for optional variables
- Prevents errors from undefined variables
- Can also use `is undefined`

**Alternative:**
```yaml
when: app_port is undefined  # Same as 'is not defined'
```

---

## Solution 08 — When with Boolean Variables

```yaml
---
- name: Boolean conditionals
  hosts: all
  become: true
  
  vars:
    enable_firewall: true
    enable_selinux: false
  
  tasks:
    - name: Start firewalld if enabled
      ansible.builtin.service:
        name: firewalld
        state: started
      when: enable_firewall
    
    - name: Display SELinux message
      ansible.builtin.debug:
        msg: "SELinux is disabled"
      when: not enable_selinux
```

**Explanation:**
- Boolean variables: `true` or `false`
- `when: variable` runs if true
- `when: not variable` runs if false
- No comparison operator needed
- Clean and readable syntax

**Alternative syntax:**
```yaml
when: enable_firewall == true
when: enable_selinux == false
```

---

## Solution 09 — When with String Matching

```yaml
---
- name: String matching conditionals
  hosts: all
  
  tasks:
    - name: Display node1 message
      ansible.builtin.debug:
        msg: "Node 1 detected"
      when: inventory_hostname is match("node1.*")
    
    - name: Display node2 message
      ansible.builtin.debug:
        msg: "Node 2 detected"
      when: inventory_hostname is match("node2.*")
```

**Explanation:**
- `is match()` uses regex patterns
- `.*` matches any characters
- `^` matches start of string
- Alternative: use `startswith()` filter
- `inventory_hostname` from inventory file

**Alternative with startswith:**
```yaml
when: inventory_hostname.startswith('node1')
```

---

## Solution 10 — failed_when Customization

```yaml
---
- name: Custom failure conditions
  hosts: all
  
  tasks:
    - name: Check if user exists
      ansible.builtin.command: grep student /etc/passwd
      register: grep_result
      failed_when: grep_result.rc > 1
      changed_when: false
```

**Explanation:**
- `register` saves task output
- `rc` is return code (0=success, non-zero=failure)
- `failed_when` customizes failure condition
- `grep` return codes:
  - 0 = pattern found
  - 1 = pattern not found
  - 2+ = error
- `changed_when: false` prevents "changed" status

**Verification:**
```bash
ansible all -m command -a "grep student /etc/passwd"
```

---

## Solution 11 — changed_when Customization

```yaml
---
- name: Custom changed status
  hosts: all
  
  tasks:
    - name: Read hostname
      ansible.builtin.command: cat /etc/hostname
      register: hostname_content
      changed_when: false
```

**Explanation:**
- `changed_when: false` always marks as "ok"
- Useful for read-only operations
- Prevents unnecessary "changed" status
- `command` module normally shows as "changed"
- Better for idempotency reporting

**Alternative conditions:**
```yaml
changed_when: hostname_content.rc != 0  # Changed only if failed
changed_when: "'error' in hostname_content.stdout"  # Changed if error in output
```

---

## Solution 12 — When with Register

```yaml
---
- name: Conditional installation based on check
  hosts: all
  become: true
  
  tasks:
    - name: Check if httpd is installed
      ansible.builtin.command: rpm -q httpd
      register: httpd_check
      failed_when: false
      changed_when: false
    
    - name: Install httpd if not present
      ansible.builtin.dnf:
        name: httpd
        state: present
      when: httpd_check.rc != 0
    
    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
      when: httpd_check.rc != 0
```

**Explanation:**
- First task checks package status
- `register` saves result
- `failed_when: false` prevents failure
- `rc != 0` means package not installed
- Subsequent tasks use registered variable
- Idempotent approach

---

## Solution 13 — Complex Conditionals

```yaml
---
- name: Complex conditional logic
  hosts: all
  become: true
  
  tasks:
    - name: Check if httpd is installed
      ansible.builtin.command: rpm -q httpd
      register: httpd_check
      failed_when: false
      changed_when: false
    
    - name: Install nginx with complex conditions
      ansible.builtin.dnf:
        name: nginx
        state: present
      when:
        - ansible_distribution == "Rocky"
        - ansible_memtotal_mb > 1024
        - "'web' in ansible_hostname"
        - httpd_check.rc != 0
```

**Explanation:**
- Multiple conditions in list format
- All must be true (implicit `and`)
- Combines facts and registered variables
- Order doesn't matter for evaluation
- Clean and readable format

---

## Solution 14 — When with Nested Conditions

```yaml
---
- name: Nested conditional logic
  hosts: all
  
  tasks:
    - name: Create file for high performance server
      ansible.builtin.copy:
        content: "High Performance Server\n"
        dest: /tmp/server-type.txt
        mode: '0644'
      when:
        - ansible_memtotal_mb > 2048
        - ansible_processor_vcpus > 2
    
    - name: Create file for standard server
      ansible.builtin.copy:
        content: "Standard Server\n"
        dest: /tmp/server-type.txt
        mode: '0644'
      when:
        - ansible_memtotal_mb > 1024
        - ansible_memtotal_mb <= 2048
        - ansible_processor_vcpus > 1
        - ansible_processor_vcpus <= 2
    
    - name: Create file for basic server
      ansible.builtin.copy:
        content: "Basic Server\n"
        dest: /tmp/server-type.txt
        mode: '0644'
      when:
        - ansible_memtotal_mb <= 1024
        - ansible_processor_vcpus <= 1
```

**Explanation:**
- Most specific conditions first
- Only one task will run
- Range checking with `and`
- Each task creates same file
- Last matching condition wins

---

## Solution 15 — When with List Membership

```yaml
---
- name: List membership conditionals
  hosts: all
  
  vars:
    allowed_hosts:
      - node1.example.com
      - node2.example.com
  
  tasks:
    - name: Display allowed message
      ansible.builtin.debug:
        msg: "Host is allowed"
      when: inventory_hostname in allowed_hosts
    
    - name: Display not allowed message
      ansible.builtin.debug:
        msg: "Host is not allowed"
      when: inventory_hostname not in allowed_hosts
```

**Explanation:**
- `in` checks list membership
- `not in` checks non-membership
- List defined in vars section
- Useful for whitelisting/blacklisting
- Clean syntax

---

## Quick Reference: Conditional Operators

### Comparison Operators
```yaml
when: variable == "value"     # Equal
when: variable != "value"     # Not equal
when: variable > 100          # Greater than
when: variable < 100          # Less than
when: variable >= 100         # Greater than or equal
when: variable <= 100         # Less than or equal
```

### Logical Operators
```yaml
# AND (all must be true)
when:
  - condition1
  - condition2

when: condition1 and condition2

# OR (at least one must be true)
when: condition1 or condition2

# NOT
when: not condition
```

### Membership Tests
```yaml
when: "'string' in variable"      # Substring in string
when: "item in list"              # Item in list
when: "'group' in group_names"    # Group membership
```

### Existence Tests
```yaml
when: variable is defined         # Variable exists
when: variable is not defined     # Variable doesn't exist
when: variable is undefined       # Same as 'is not defined'
```

### String Tests
```yaml
when: variable is match("regex")           # Regex match
when: variable is search("pattern")        # Pattern search
when: variable.startswith("prefix")        # Starts with
when: variable.endswith("suffix")          # Ends with
```

### Boolean Tests
```yaml
when: boolean_var                 # True
when: not boolean_var             # False
when: boolean_var == true         # Explicit true
when: boolean_var == false        # Explicit false
```

### Register Tests
```yaml
when: result.rc == 0              # Return code
when: result.failed               # Task failed
when: result.changed              # Task changed
when: result.skipped              # Task skipped
when: "'text' in result.stdout"   # Output contains text
```

---

## Common Patterns

### OS-Specific Tasks
```yaml
when: ansible_distribution == "Rocky"
when: ansible_os_family == "RedHat"
when: ansible_distribution_major_version == "9"
```

### Memory-Based Decisions
```yaml
when: ansible_memtotal_mb > 2048
when: ansible_memtotal_mb >= 1024 and ansible_memtotal_mb < 2048
```

### CPU-Based Decisions
```yaml
when: ansible_processor_vcpus > 2
when: ansible_processor_cores >= 4
```

### Network-Based Decisions
```yaml
when: ansible_default_ipv4.address is match("192.168.*")
when: "'10.0.1' in ansible_default_ipv4.address"
```

### Group Membership
```yaml
when: "'webservers' in group_names"
when: inventory_hostname in groups['databases']
```

### Package Check Pattern
```yaml
- command: rpm -q package_name
  register: pkg_check
  failed_when: false
  changed_when: false

- dnf:
    name: package_name
    state: present
  when: pkg_check.rc != 0
```

---

## Best Practices

1. **Use list format for multiple AND conditions:**
   ```yaml
   when:
     - condition1
     - condition2
   ```

2. **Use quotes for OR conditions:**
   ```yaml
   when: "condition1 or condition2"
   ```

3. **Always use failed_when: false for checks:**
   ```yaml
   - command: check_command
     register: result
     failed_when: false
   ```

4. **Use changed_when for read-only operations:**
   ```yaml
   - command: cat /etc/hostname
     changed_when: false
   ```

5. **Test conditions with debug first:**
   ```yaml
   - debug:
       var: ansible_memtotal_mb
   ```

6. **Use meaningful variable names:**
   ```yaml
   when: is_production_server
   # Better than: when: env == "prod"
   ```

7. **Document complex conditions:**
   ```yaml
   # Install only on high-spec production web servers
   when:
     - ansible_memtotal_mb > 2048
     - "'web' in group_names"
     - environment == "production"
   ```

---

## Tips for RHCE Exam

1. **Test conditions with debug:**
   ```bash
   ansible all -m debug -a "var=ansible_distribution"
   ```

2. **Use ansible-playbook --check:**
   ```bash
   ansible-playbook playbook.yml --check
   ```

3. **Remember operator precedence:**
   - `not` has highest precedence
   - `and` before `or`
   - Use parentheses for clarity

4. **Common mistakes:**
   - Forgetting quotes around strings
   - Using `=` instead of `==`
   - Mixing `and`/`or` without quotes
   - Not using `failed_when: false` for checks

5. **Verify facts before using:**
   ```bash
   ansible hostname -m setup -a "filter=ansible_*"
   ```

6. **Test each condition separately:**
   - Start with simple conditions
   - Add complexity gradually
   - Test after each addition

---

Good luck with your RHCE exam preparation! 🚀

Master these conditional patterns - they're essential for writing flexible, reusable playbooks.
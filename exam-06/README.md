# RHCE Killer — Practice Exam 06
## EX294: Magic Variables, Facts & Conditionals Mastery

---

> **Specialized Exam: Facts & Conditionals**
> This exam focuses exclusively on Ansible facts, magic variables, and conditional logic.
> Master these concepts to excel in the RHCE exam.
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

---

## Instructions

- All work must be done as user **student** on **control.example.com**
- All playbooks and files must be created under `/home/student/ansible/`
- Do **not** modify `/etc/ansible/ansible.cfg`
- Playbooks must run without errors and without prompting for passwords
- Each task specifies its point value — partial credit is **not** given

---

## Tasks

### Task 01 — Ansible Facts Discovery (10 pts)

Create a playbook `facts-discovery.yml` that:
- Runs on **all managed nodes**
- Displays the following facts using the `debug` module:
  - Operating system distribution (e.g., "Rocky")
  - OS major version (e.g., "9")
  - Total memory in MB
  - Number of processor cores
  - Default IPv4 address
  - Hostname (short name, not FQDN)

Each fact must be displayed with a descriptive label.

---

### Task 02 — Conditional Package Installation (15 pts)

Create a playbook `conditional-packages.yml` that:
- Runs on **all managed nodes**
- Installs `httpd` **only if** the system has more than 1GB of RAM
- Installs `nginx` **only if** the system has 1GB or less of RAM
- Uses the `ansible_memtotal_mb` fact for the condition
- Ensures the installed service is started and enabled

---

### Task 03 — OS-Specific Configuration (15 pts)

Create a playbook `os-specific.yml` that:
- Runs on **all managed nodes**
- Creates a file `/etc/system-info.txt` with different content based on OS:
  - If OS is Rocky Linux: "This is a Rocky Linux system"
  - If OS is CentOS: "This is a CentOS system"
  - If OS is Ubuntu: "This is an Ubuntu system"
  - For any other OS: "Unknown operating system"
- Uses `ansible_distribution` fact
- File must be owned by root with mode 0644

---

### Task 04 — Magic Variables - Inventory Information (15 pts)

Create a playbook `inventory-info.yml` that:
- Runs on **node1** only
- Creates a file `/tmp/inventory-report.txt` containing:
  - List of all hosts in the inventory (one per line)
  - List of all groups in the inventory (one per line)
  - List of all hosts in the 'managed' group (one per line)
- Uses magic variables: `groups`, `group_names`, `inventory_hostname`
- Use Jinja2 template or lineinfile module

---

### Task 05 — Conditional Tasks Based on Hostname (10 pts)

Create a playbook `hostname-conditional.yml` that:
- Runs on **all managed nodes**
- Creates directory `/opt/node1-data` **only on node1**
- Creates directory `/opt/node2-data` **only on node2**
- Uses `inventory_hostname` or `ansible_hostname` for conditions
- Directories must have mode 0755

---

### Task 06 — Network Facts and Conditionals (15 pts)

Create a playbook `network-check.yml` that:
- Runs on **all managed nodes**
- Displays a message "Node is in 10.0.2.0/24 network" if the default IPv4 address starts with "10.0.2"
- Displays a message "Node is in 10.0.1.0/24 network" if the default IPv4 address starts with "10.0.1"
- Creates a file `/etc/network-zone.conf` with content:
  - "zone=private" if in 10.0.2.0/24
  - "zone=public" if in 10.0.1.0/24
- Uses `ansible_default_ipv4.address` fact

---

### Task 07 — Custom Facts (15 pts)

Create a playbook `custom-facts.yml` that:
- Runs on **all managed nodes**
- Creates a custom fact file `/etc/ansible/facts.d/app.fact` with INI format:
```ini
[application]
name=webapp
version=2.0
environment=production
```
- In the **same playbook**, after creating the fact:
  - Reloads facts using `setup` module
  - Displays the custom fact value: `ansible_local.app.application.name`
  - Creates a file `/tmp/app-info.txt` with content: "Application: webapp, Version: 2.0"

---

### Task 08 — Multiple Conditions with 'and'/'or' (15 pts)

Create a playbook `multi-conditions.yml` that:
- Runs on **all managed nodes**
- Installs package `firewalld` **only if**:
  - System has more than 1 CPU core **AND**
  - System has more than 1GB of RAM
- Uses `ansible_processor_vcpus` and `ansible_memtotal_mb` facts
- Starts and enables firewalld service if installed
- Uses proper conditional syntax with `and`

---

### Task 09 — Hostvars - Access Facts from Other Hosts (20 pts)

Create a playbook `hostvars-demo.yml` that:
- Runs on **node1** only
- Creates a file `/tmp/cluster-info.txt` containing:
  - node1's IP address
  - node2's IP address
  - node1's hostname
  - node2's hostname
- Uses `hostvars` magic variable to access node2's facts from node1
- Format example:
```
Node1 IP: 10.0.2.11
Node2 IP: 10.0.2.12
Node1 Hostname: node1.example.com
Node2 Hostname: node2.example.com
```

---

### Task 10 — Fact Caching and Performance (10 pts)

Create a playbook `fact-gathering.yml` that:
- Runs on **all managed nodes**
- Disables automatic fact gathering (`gather_facts: false`)
- Manually gathers only network facts using `setup` module with filter
- Displays only the default IPv4 address
- Creates a file `/tmp/ip-only.txt` with just the IP address

**Bonus:** Explain in a comment why selective fact gathering improves performance.

---

### Task 11 — When with Register (15 pts)

Create a playbook `register-conditional.yml` that:
- Runs on **all managed nodes**
- Checks if package `httpd` is installed using `rpm -q httpd` command
- Registers the result
- **Only if httpd is NOT installed**:
  - Installs httpd
  - Starts and enables httpd service
- Uses `when` with `register` and `failed` or `rc` check

---

### Task 12 — Loop with Conditionals (20 pts)

Create a playbook `loop-conditionals.yml` that:
- Runs on **all managed nodes**
- Defines a list of packages:
```yaml
packages:
  - name: httpd
    required_memory: 512
  - name: postgresql
    required_memory: 2048
  - name: redis
    required_memory: 1024
```
- Loops through the packages
- Installs each package **only if** system has enough memory (MB)
- Uses `when` inside loop with `ansible_memtotal_mb` fact
- Displays a message for each package indicating if it was installed or skipped

---

### Task 13 — Group Membership Conditionals (10 pts)

Create a playbook `group-conditional.yml` that:
- Runs on **all managed nodes**
- Creates file `/etc/node-type.conf` with content:
  - "type=control" if host is in 'control' group
  - "type=managed" if host is in 'managed' group
- Uses `group_names` magic variable
- File must be owned by root with mode 0644

---

### Task 14 — Ansible Version and Environment Facts (10 pts)

Create a playbook `ansible-env.yml` that:
- Runs on **localhost** (control node)
- Creates a file `/tmp/ansible-info.txt` containing:
  - Ansible version
  - Python version
  - Current user running the playbook
  - Current working directory
- Uses `ansible_version`, `ansible_python_version`, `ansible_user_id`, `ansible_env.PWD`

---

### Task 15 — Advanced: Failed_when and Changed_when (15 pts)

Create a playbook `custom-status.yml` that:
- Runs on **all managed nodes**
- Executes command: `grep -q 'student' /etc/passwd`
- Uses `failed_when` to mark as failed only if return code is greater than 1
- Uses `changed_when` to mark as changed only if return code is 0
- Registers the result and displays appropriate message based on outcome

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Facts Discovery | 10 |
| 02 | Conditional Packages | 15 |
| 03 | OS-Specific Config | 15 |
| 04 | Magic Variables - Inventory | 15 |
| 05 | Hostname Conditionals | 10 |
| 06 | Network Facts | 15 |
| 07 | Custom Facts | 15 |
| 08 | Multiple Conditions | 15 |
| 09 | Hostvars | 20 |
| 10 | Fact Gathering | 10 |
| 11 | Register + When | 15 |
| 12 | Loop + Conditionals | 20 |
| 13 | Group Membership | 10 |
| 14 | Ansible Environment | 10 |
| 15 | Failed/Changed When | 15 |
| **Total** | | **200** |

**Passing score: 70% (140/200 points)**

---

## When you finish

```bash
bash /home/student/exams/exam-06/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Facts Discovery

```yaml
---
- name: Discover and display Ansible facts
  hosts: managed
  gather_facts: true

  tasks:
    - name: Display OS distribution
      ansible.builtin.debug:
        msg: "Operating System: {{ ansible_distribution }}"

    - name: Display OS major version
      ansible.builtin.debug:
        msg: "OS Version: {{ ansible_distribution_major_version }}"

    - name: Display total memory
      ansible.builtin.debug:
        msg: "Total Memory: {{ ansible_memtotal_mb }} MB"

    - name: Display CPU cores
      ansible.builtin.debug:
        msg: "CPU Cores: {{ ansible_processor_vcpus }}"

    - name: Display default IPv4 address
      ansible.builtin.debug:
        msg: "IP Address: {{ ansible_default_ipv4.address }}"

    - name: Display hostname
      ansible.builtin.debug:
        msg: "Hostname: {{ ansible_hostname }}"
```

**Run:**
```bash
ansible-playbook facts-discovery.yml
```

**Explanation:**
- `gather_facts: true` collects all system facts
- Facts are accessed using `ansible_*` variables
- `ansible_memtotal_mb` gives memory in megabytes
- `ansible_processor_vcpus` gives virtual CPU count
- `ansible_default_ipv4.address` accesses nested dictionary

---

## Solution 02 — Conditional Package Installation

```yaml
---
- name: Install packages based on memory
  hosts: managed
  become: true

  tasks:
    - name: Install httpd if memory > 1GB
      ansible.builtin.dnf:
        name: httpd
        state: present
      when: ansible_memtotal_mb > 1024

    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
      when: ansible_memtotal_mb > 1024

    - name: Install nginx if memory <= 1GB
      ansible.builtin.dnf:
        name: nginx
        state: present
      when: ansible_memtotal_mb <= 1024

    - name: Start and enable nginx
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true
      when: ansible_memtotal_mb <= 1024
```

**Explanation:**
- `when` clause evaluates condition before running task
- `ansible_memtotal_mb` is compared with numeric value
- Each service task has same condition as installation task
- `>` and `<=` operators work with numeric comparisons

---

## Solution 03 — OS-Specific Configuration

```yaml
---
- name: Create OS-specific configuration
  hosts: managed
  become: true

  tasks:
    - name: Create system-info.txt for Rocky Linux
      ansible.builtin.copy:
        content: "This is a Rocky Linux system\n"
        dest: /etc/system-info.txt
        owner: root
        group: root
        mode: '0644'
      when: ansible_distribution == "Rocky"

    - name: Create system-info.txt for CentOS
      ansible.builtin.copy:
        content: "This is a CentOS system\n"
        dest: /etc/system-info.txt
        owner: root
        group: root
        mode: '0644'
      when: ansible_distribution == "CentOS"

    - name: Create system-info.txt for Ubuntu
      ansible.builtin.copy:
        content: "This is an Ubuntu system\n"
        dest: /etc/system-info.txt
        owner: root
        group: root
        mode: '0644'
      when: ansible_distribution == "Ubuntu"

    - name: Create system-info.txt for unknown OS
      ansible.builtin.copy:
        content: "Unknown operating system\n"
        dest: /etc/system-info.txt
        owner: root
        group: root
        mode: '0644'
      when: ansible_distribution not in ["Rocky", "CentOS", "Ubuntu"]
```

**Explanation:**
- `ansible_distribution` contains OS name
- `==` operator for exact string match
- `not in` operator for exclusion check
- Multiple tasks with different conditions for each OS

---

## Solution 04 — Magic Variables - Inventory Information

```yaml
---
- name: Display inventory information
  hosts: node1.example.com
  gather_facts: false

  tasks:
    - name: Create inventory report
      ansible.builtin.copy:
        content: |
          All Hosts:
          {% for host in groups['all'] %}
          {{ host }}
          {% endfor %}
          
          All Groups:
          {% for group in groups.keys() %}
          {{ group }}
          {% endfor %}
          
          Managed Group Hosts:
          {% for host in groups['managed'] %}
          {{ host }}
          {% endfor %}
        dest: /tmp/inventory-report.txt
        mode: '0644'
```

**Explanation:**
- `groups` is a magic variable containing all inventory groups
- `groups['all']` lists all hosts
- `groups.keys()` lists all group names
- `groups['managed']` lists hosts in managed group
- Jinja2 `for` loop iterates through lists

---

## Solution 05 — Conditional Tasks Based on Hostname

```yaml
---
- name: Create hostname-specific directories
  hosts: managed
  become: true

  tasks:
    - name: Create directory for node1
      ansible.builtin.file:
        path: /opt/node1-data
        state: directory
        mode: '0755'
      when: inventory_hostname == "node1.example.com"

    - name: Create directory for node2
      ansible.builtin.file:
        path: /opt/node2-data
        state: directory
        mode: '0755'
      when: inventory_hostname == "node2.example.com"
```

**Explanation:**
- `inventory_hostname` contains the host's name from inventory
- Can also use `ansible_hostname` for short hostname
- `==` operator for exact match
- Each task runs only on matching host

---

## Solution 06 — Network Facts and Conditionals

```yaml
---
- name: Check network and create zone config
  hosts: managed
  become: true

  tasks:
    - name: Display message for private network
      ansible.builtin.debug:
        msg: "Node is in 10.0.2.0/24 network"
      when: ansible_default_ipv4.address is match("10.0.2.*")

    - name: Display message for public network
      ansible.builtin.debug:
        msg: "Node is in 10.0.1.0/24 network"
      when: ansible_default_ipv4.address is match("10.0.1.*")

    - name: Create network zone config for private
      ansible.builtin.copy:
        content: "zone=private\n"
        dest: /etc/network-zone.conf
        mode: '0644'
      when: ansible_default_ipv4.address is match("10.0.2.*")

    - name: Create network zone config for public
      ansible.builtin.copy:
        content: "zone=public\n"
        dest: /etc/network-zone.conf
        mode: '0644'
      when: ansible_default_ipv4.address is match("10.0.1.*")
```

**Explanation:**
- `ansible_default_ipv4.address` accesses nested fact
- `is match()` test uses regex pattern
- `.*` matches any characters after prefix
- Alternative: use `startswith()` filter

---

## Solution 07 — Custom Facts

```yaml
---
- name: Create and use custom facts
  hosts: managed
  become: true

  tasks:
    - name: Ensure facts.d directory exists
      ansible.builtin.file:
        path: /etc/ansible/facts.d
        state: directory
        mode: '0755'

    - name: Create custom fact file
      ansible.builtin.copy:
        content: |
          [application]
          name=webapp
          version=2.0
          environment=production
        dest: /etc/ansible/facts.d/app.fact
        mode: '0644'

    - name: Reload facts to include custom facts
      ansible.builtin.setup:
        filter: ansible_local

    - name: Display custom fact
      ansible.builtin.debug:
        msg: "Application Name: {{ ansible_local.app.application.name }}"

    - name: Create app info file
      ansible.builtin.copy:
        content: "Application: {{ ansible_local.app.application.name }}, Version: {{ ansible_local.app.application.version }}\n"
        dest: /tmp/app-info.txt
        mode: '0644'
```

**Explanation:**
- Custom facts must be in `/etc/ansible/facts.d/`
- File must have `.fact` extension
- INI format: `[section]` then `key=value`
- `setup` module with `filter` reloads specific facts
- Access via `ansible_local.<filename>.<section>.<key>`

---

## Solution 08 — Multiple Conditions with 'and'

```yaml
---
- name: Install firewalld with multiple conditions
  hosts: managed
  become: true

  tasks:
    - name: Install firewalld if conditions met
      ansible.builtin.dnf:
        name: firewalld
        state: present
      when:
        - ansible_processor_vcpus > 1
        - ansible_memtotal_mb > 1024

    - name: Start and enable firewalld
      ansible.builtin.service:
        name: firewalld
        state: started
        enabled: true
      when:
        - ansible_processor_vcpus > 1
        - ansible_memtotal_mb > 1024
```

**Explanation:**
- Multiple `when` conditions in list format = implicit `and`
- Alternative syntax: `when: ansible_processor_vcpus > 1 and ansible_memtotal_mb > 1024`
- Both conditions must be true for task to run
- `ansible_processor_vcpus` gives CPU core count

---

## Solution 09 — Hostvars - Access Facts from Other Hosts

```yaml
---
- name: Access facts from other hosts using hostvars
  hosts: node1.example.com
  gather_facts: true

  tasks:
    - name: Gather facts from all hosts first
      ansible.builtin.setup:
      delegate_to: "{{ item }}"
      delegate_facts: true
      loop:
        - node1.example.com
        - node2.example.com

    - name: Create cluster info file
      ansible.builtin.copy:
        content: |
          Node1 IP: {{ hostvars['node1.example.com']['ansible_default_ipv4']['address'] }}
          Node2 IP: {{ hostvars['node2.example.com']['ansible_default_ipv4']['address'] }}
          Node1 Hostname: {{ hostvars['node1.example.com']['ansible_fqdn'] }}
          Node2 Hostname: {{ hostvars['node2.example.com']['ansible_fqdn'] }}
        dest: /tmp/cluster-info.txt
        mode: '0644'
```

**Explanation:**
- `hostvars` is a magic variable containing facts from all hosts
- Syntax: `hostvars['hostname']['fact_name']`
- Must gather facts from target hosts first
- `delegate_to` runs task on different host
- `delegate_facts` stores facts for delegated host

---

## Solution 10 — Fact Gathering and Performance

```yaml
---
- name: Selective fact gathering for performance
  hosts: managed
  gather_facts: false  # Disable automatic gathering

  tasks:
    # Performance tip: Gathering all facts takes 2-3 seconds per host
    # Filtering to specific facts reduces this to <1 second
    - name: Gather only network facts
      ansible.builtin.setup:
        filter: ansible_default_ipv4

    - name: Display only IP address
      ansible.builtin.debug:
        msg: "IP: {{ ansible_default_ipv4.address }}"

    - name: Create IP-only file
      ansible.builtin.copy:
        content: "{{ ansible_default_ipv4.address }}\n"
        dest: /tmp/ip-only.txt
        mode: '0644'
```

**Explanation:**
- `gather_facts: false` disables automatic fact collection
- `setup` module with `filter` gathers specific facts only
- `filter` accepts wildcards: `ansible_default_*`
- Improves performance when only few facts needed
- Reduces playbook execution time significantly

---

## Solution 11 — When with Register

```yaml
---
- name: Conditional installation based on package check
  hosts: managed
  become: true

  tasks:
    - name: Check if httpd is installed
      ansible.builtin.command: rpm -q httpd
      register: httpd_check
      failed_when: false  # Don't fail if package not found
      changed_when: false  # This is just a check, not a change

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
- `register` saves task output to variable
- `httpd_check.rc` contains return code (0 = success, non-zero = failure)
- `failed_when: false` prevents task from failing
- `changed_when: false` marks task as not changed
- `when: httpd_check.rc != 0` runs only if package not found

---

## Solution 12 — Loop with Conditionals

```yaml
---
- name: Install packages based on memory requirements
  hosts: managed
  become: true

  vars:
    packages:
      - name: httpd
        required_memory: 512
      - name: postgresql
        required_memory: 2048
      - name: redis
        required_memory: 1024

  tasks:
    - name: Install packages if memory sufficient
      ansible.builtin.dnf:
        name: "{{ item.name }}"
        state: present
      loop: "{{ packages }}"
      when: ansible_memtotal_mb >= item.required_memory
      register: install_result

    - name: Display installation status
      ansible.builtin.debug:
        msg: >
          Package {{ item.item.name }} was
          {% if item.changed %}installed{% else %}skipped (insufficient memory){% endif %}
      loop: "{{ install_result.results }}"
      when: item is not skipped
```

**Explanation:**
- `loop` iterates through list of dictionaries
- `item.name` and `item.required_memory` access dictionary keys
- `when` inside loop evaluates per iteration
- `ansible_memtotal_mb >= item.required_memory` compares values
- `register` with loop creates list of results
- Second task displays status for each package

---

## Solution 13 — Group Membership Conditionals

```yaml
---
- name: Create config based on group membership
  hosts: all
  become: true

  tasks:
    - name: Create config for control nodes
      ansible.builtin.copy:
        content: "type=control\n"
        dest: /etc/node-type.conf
        owner: root
        group: root
        mode: '0644'
      when: "'control' in group_names"

    - name: Create config for managed nodes
      ansible.builtin.copy:
        content: "type=managed\n"
        dest: /etc/node-type.conf
        owner: root
        group: root
        mode: '0644'
      when: "'managed' in group_names"
```

**Explanation:**
- `group_names` is a magic variable listing groups for current host
- `'groupname' in group_names` checks membership
- Alternative: `when: inventory_hostname in groups['managed']`
- Runs on `hosts: all` to cover both groups

---

## Solution 14 — Ansible Version and Environment Facts

```yaml
---
- name: Display Ansible environment information
  hosts: localhost
  gather_facts: true
  connection: local

  tasks:
    - name: Create Ansible info file
      ansible.builtin.copy:
        content: |
          Ansible Version: {{ ansible_version.full }}
          Python Version: {{ ansible_python_version }}
          Current User: {{ ansible_user_id }}
          Working Directory: {{ ansible_env.PWD }}
        dest: /tmp/ansible-info.txt
        mode: '0644'

    - name: Display the information
      ansible.builtin.debug:
        msg: |
          Ansible: {{ ansible_version.full }}
          Python: {{ ansible_python_version }}
          User: {{ ansible_user_id }}
          PWD: {{ ansible_env.PWD }}
```

**Explanation:**
- `ansible_version.full` gives complete version string
- `ansible_python_version` shows Python interpreter version
- `ansible_user_id` shows current user running playbook
- `ansible_env` dictionary contains environment variables
- `ansible_env.PWD` accesses current directory
- `hosts: localhost` runs on control node

---

## Solution 15 — Failed_when and Changed_when

```yaml
---
- name: Custom task status with failed_when and changed_when
  hosts: managed
  become: true

  tasks:
    - name: Check if student user exists
      ansible.builtin.command: grep -q 'student' /etc/passwd
      register: grep_result
      failed_when: grep_result.rc > 1  # Only fail if error (rc=2), not if not found (rc=1)
      changed_when: grep_result.rc == 0  # Mark as changed only if found

    - name: Display result based on outcome
      ansible.builtin.debug:
        msg: >
          {% if grep_result.rc == 0 %}
          User 'student' exists in /etc/passwd
          {% elif grep_result.rc == 1 %}
          User 'student' not found in /etc/passwd
          {% else %}
          Error occurred while checking
          {% endif %}
```

**Explanation:**
- `failed_when` customizes failure condition
- `changed_when` customizes changed status
- `grep -q` return codes:
  - 0 = pattern found
  - 1 = pattern not found
  - 2 = error occurred
- `rc > 1` means only actual errors cause failure
- `rc == 0` means task shows as changed only when user found
- Useful for idempotent checks that shouldn't fail

---

## Quick Reference: Most Common Facts

### System Information
```yaml
ansible_distribution          # OS name (Rocky, CentOS, Ubuntu)
ansible_distribution_version  # Full version (9.1)
ansible_distribution_major_version  # Major version (9)
ansible_os_family            # OS family (RedHat, Debian)
ansible_kernel               # Kernel version
```

### Hardware
```yaml
ansible_memtotal_mb          # Total RAM in MB
ansible_processor_vcpus      # Number of CPU cores
ansible_processor_cores      # Physical cores
ansible_architecture         # CPU architecture (x86_64)
```

### Network
```yaml
ansible_default_ipv4.address    # Primary IP address
ansible_default_ipv4.interface  # Primary interface name
ansible_all_ipv4_addresses      # List of all IPs
ansible_fqdn                    # Fully qualified domain name
ansible_hostname                # Short hostname
```

### Storage
```yaml
ansible_mounts               # List of mounted filesystems
ansible_devices              # Dictionary of block devices
```

### Magic Variables
```yaml
inventory_hostname           # Host name from inventory
inventory_hostname_short     # Short hostname
group_names                  # List of groups for current host
groups                       # Dictionary of all groups and hosts
hostvars                     # Facts from all hosts
ansible_play_hosts           # List of hosts in current play
ansible_version              # Ansible version info
```

### Environment
```yaml
ansible_env                  # Environment variables dictionary
ansible_user_id              # Current user
ansible_python_version       # Python version
```

---

## Tips for RHCE Exam

1. **Always check fact names**: Use `ansible hostname -m setup` to see all facts
2. **Use filters**: `ansible hostname -m setup -a "filter=ansible_default_*"`
3. **Test conditions**: Use `debug` module to verify fact values before using in `when`
4. **Remember syntax**: 
   - Facts: `ansible_factname`
   - Custom facts: `ansible_local.filename.section.key`
   - Magic variables: `inventory_hostname`, `groups`, `hostvars`
5. **Nested facts**: Use bracket or dot notation: `ansible_default_ipv4['address']` or `ansible_default_ipv4.address`
6. **Conditionals**: 
   - Comparison: `==`, `!=`, `>`, `<`, `>=`, `<=`
   - Membership: `in`, `not in`
   - Tests: `is defined`, `is not defined`, `is match()`, `is search()`
   - Logic: `and`, `or`, `not`

---

## Common Patterns

### Check if package is installed
```yaml
- command: rpm -q package_name
  register: result
  failed_when: false
  changed_when: false

- name: Install if not present
  dnf:
    name: package_name
    state: present
  when: result.rc != 0
```

### OS-specific tasks
```yaml
- name: Task for RedHat family
  ...
  when: ansible_os_family == "RedHat"

- name: Task for Debian family
  ...
  when: ansible_os_family == "Debian"
```

### Memory-based decisions
```yaml
when: ansible_memtotal_mb > 2048  # More than 2GB
when: ansible_memtotal_mb >= 1024  # At least 1GB
```

### Network-based decisions
```yaml
when: ansible_default_ipv4.address is match("192.168.*")
when: ansible_default_ipv4.address.startswith("10.0")
```

### Group membership
```yaml
when: "'webservers' in group_names"
when: inventory_hostname in groups['databases']
```

---

Good luck with your RHCE exam preparation! 🚀
# RHCE Killer — Practice Exam 02
## EX294: Red Hat Certified Engineer (Ansible) - Intermediate

---

> **Read carefully before starting.**
> This exam builds on Exam 01 with more advanced topics.
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

### Task 01 — Advanced Loops with Dictionaries (10 pts)

Create a playbook `users.yml` that:
- Runs on **all managed nodes**
- Creates the following users with specific attributes:

```yaml
users:
  - name: alice
    uid: 2001
    groups: wheel
    shell: /bin/bash
  - name: bob
    uid: 2002
    groups: developers
    shell: /bin/zsh
  - name: charlie
    uid: 2003
    groups: operators
    shell: /bin/bash
```

- Each user must have their UID, supplementary groups, and shell set correctly
- Create the groups `developers` and `operators` if they don't exist
- Use a loop to iterate over the dictionary

---

### Task 02 — Complex Conditionals with Facts (10 pts)

Create a playbook `system-info.yml` that:
- Runs on **all managed nodes**
- Creates a file `/etc/system-classification.txt` with content based on system facts:
  - If RAM >= 2GB: "Classification: High Performance"
  - If RAM >= 1GB and < 2GB: "Classification: Standard"
  - If RAM < 1GB: "Classification: Low Resource"
- Adds a second line with: "OS Family: {{ ansible_os_family }}"
- Adds a third line with: "Processor Count: {{ ansible_processor_vcpus }}"
- File must be owned by root with mode 0644

---

### Task 03 — Multiple Handlers and Notifications (10 pts)

Create a playbook `web-config.yml` that:
- Runs on **node1** only
- Installs `httpd` and `mod_ssl`
- Copies a configuration file `/tmp/httpd-custom.conf` to `/etc/httpd/conf.d/custom.conf`
  (Create the source file with content: `ServerTokens Prod`)
- Modifies `/etc/httpd/conf/httpd.conf` to change `ServerAdmin` to `admin@example.com`
  (use `lineinfile` module)
- Notifies **two different handlers**:
  - Handler 1: Restart httpd (only if config changes)
  - Handler 2: Check httpd status (always runs after restart)

---

### Task 04 — Block, Rescue, and Always (15 pts)

Create a playbook `backup-system.yml` that:
- Runs on **all managed nodes**
- Uses a `block` to:
  - Create directory `/backup`
  - Copy `/etc/hosts` to `/backup/hosts.backup`
  - Create a file `/backup/backup-success.txt` with content "Backup completed"
- Uses `rescue` to:
  - Create `/backup/backup-failed.txt` with content "Backup failed: {{ ansible_failed_result.msg }}"
  - Log the error to `/var/log/backup-errors.log`
- Uses `always` to:
  - Create `/backup/backup-attempted.txt` with timestamp
  - Set permissions on `/backup` directory to 0755

---

### Task 05 — Register Variables and Debug (10 pts)

Create a playbook `disk-check.yml` that:
- Runs on **all managed nodes**
- Executes command `df -h /` and registers the output
- Uses `debug` to display:
  - The full command output
  - Only the stdout
  - The return code
- Creates a file `/tmp/disk-report.txt` with the stdout content
- Fails the playbook if disk usage on `/` is above 80%
  (parse the output and use `failed_when`)

---

### Task 06 — Advanced Jinja2 Templates with Loops (15 pts)

Create a template `templates/services-report.j2` that generates:

```
System Services Report
======================
Hostname: {{ ansible_hostname }}
FQDN: {{ ansible_fqdn }}
Generated: {{ ansible_date_time.date }} {{ ansible_date_time.time }}

Network Interfaces:
{% for interface in ansible_interfaces %}
  - {{ interface }}: {{ ansible_facts[interface]['ipv4']['address'] | default('N/A') }}
{% endfor %}

Mounted Filesystems:
{% for mount in ansible_mounts %}
  - {{ mount.mount }} ({{ mount.fstype }}): {{ mount.size_total | human_readable }}
{% endfor %}
```

Create a playbook `generate-report.yml` that:
- Runs on **all managed nodes**
- Deploys the template to `/var/www/html/system-report.html`
- Creates the directory if it doesn't exist

---

### Task 07 — File Modules (copy, fetch, lineinfile, blockinfile) (15 pts)

Create a playbook `file-operations.yml` that:
- Runs on **all managed nodes**
- Uses `copy` to create `/etc/app-config.conf` with content:
  ```
  [app]
  name=myapp
  version=1.0
  ```
- Uses `lineinfile` to add `debug=true` to the `[app]` section
- Uses `blockinfile` to add a new section:
  ```
  [database]
  host=localhost
  port=5432
  ```
- Uses `fetch` to retrieve `/etc/hostname` from each node to `fetched/{{ inventory_hostname }}/hostname`
- Creates a backup of `/etc/app-config.conf` before modifications

---

### Task 08 — Package Management with Conditionals (10 pts)

Create a playbook `install-tools.yml` that:
- Runs on **all managed nodes**
- Installs different packages based on OS family:
  - RedHat family: `vim-enhanced`, `wget`, `curl`, `net-tools`
  - Debian family: `vim`, `wget`, `curl`, `net-tools`
- Uses `ansible_os_family` fact for conditionals
- Ensures all packages are at the latest version
- Creates a file `/etc/tools-installed.txt` listing all installed packages

---

### Task 09 — Service Management and Systemd (10 pts)

Create a playbook `service-control.yml` that:
- Runs on **node2** only
- Installs `chronyd`
- Configures chronyd to start at boot
- Checks if `chronyd` is running using `service_facts` module
- Registers the service state
- Creates `/tmp/chrony-status.txt` with content:
  - "Service: chronyd"
  - "Status: {{ service_state }}"
  - "Enabled: {{ service_enabled }}"
- Uses `systemd` module to reload daemon if needed

---

### Task 10 — Multi-file Ansible Vault (15 pts)

Create **two** encrypted files:

1. `/home/student/ansible/group_vars/all/database.yml`:
```yaml
db_host: db.example.com
db_port: 5432
db_name: production
```

2. `/home/student/ansible/group_vars/all/api_keys.yml`:
```yaml
api_key: ABC123XYZ789
api_secret: SECRET_KEY_HERE
```

Both files must be encrypted with password: `Exam02Secure!`
Store the password in: `/home/student/ansible/vault_pass_exam02.txt`

Create a playbook `deploy-config.yml` that:
- Runs on **node1** only
- Creates `/etc/app/database.conf` with content:
  ```
  DB_HOST={{ db_host }}
  DB_PORT={{ db_port }}
  DB_NAME={{ db_name }}
  ```
- Creates `/etc/app/api.conf` with content:
  ```
  API_KEY={{ api_key }}
  API_SECRET={{ api_secret }}
  ```
- Both files must be owned by root with mode 0600
- Playbook must run with `--vault-password-file vault_pass_exam02.txt`

---

## Scoring

| Task | Points |
|------|--------|
| 01 — Advanced Loops | 10 |
| 02 — Complex Conditionals | 10 |
| 03 — Multiple Handlers | 10 |
| 04 — Block/Rescue/Always | 15 |
| 05 — Register & Debug | 10 |
| 06 — Advanced Templates | 15 |
| 07 — File Modules | 15 |
| 08 — Package Management | 10 |
| 09 — Service Management | 10 |
| 10 — Multi-file Vault | 15 |
| **Total** | **120** |

**Passing score: 70% (84/120 points)**

---

## When you finish

```bash
bash /home/student/exams/exam-02/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

---

## Solution 01 — Advanced Loops with Dictionaries

**Step 1:** Create the playbook `users.yml`:

```yaml
---
- name: Create users with advanced loop
  hosts: managed
  become: true
  
  vars:
    users:
      - name: alice
        uid: 2001
        groups: wheel
        shell: /bin/bash
      - name: bob
        uid: 2002
        groups: developers
        shell: /bin/zsh
      - name: charlie
        uid: 2003
        groups: operators
        shell: /bin/bash

  tasks:
    - name: Ensure required groups exist
      ansible.builtin.group:
        name: "{{ item }}"
        state: present
      loop:
        - developers
        - operators

    - name: Create users with specific attributes
      ansible.builtin.user:
        name: "{{ item.name }}"
        uid: "{{ item.uid }}"
        groups: "{{ item.groups }}"
        shell: "{{ item.shell }}"
        state: present
      loop: "{{ users }}"
```

**Run:**
```bash
ansible-playbook users.yml
```

**Verification:**
```bash
ansible managed -m command -a "id alice" -i inventory
ansible managed -m command -a "getent passwd bob" -i inventory
```

---

## Solution 02 — Complex Conditionals with Facts

**Create playbook `system-info.yml`:**

```yaml
---
- name: Create system classification file
  hosts: managed
  become: true

  tasks:
    - name: Set classification based on RAM
      ansible.builtin.set_fact:
        classification: >-
          {%- if ansible_memtotal_mb >= 2048 -%}
          High Performance
          {%- elif ansible_memtotal_mb >= 1024 -%}
          Standard
          {%- else -%}
          Low Resource
          {%- endif -%}

    - name: Create system classification file
      ansible.builtin.copy:
        content: |
          Classification: {{ classification }}
          OS Family: {{ ansible_os_family }}
          Processor Count: {{ ansible_processor_vcpus }}
        dest: /etc/system-classification.txt
        owner: root
        group: root
        mode: '0644'
```

**Run:**
```bash
ansible-playbook system-info.yml
```

**Verification:**
```bash
ansible managed -m command -a "cat /etc/system-classification.txt" -i inventory
```

---

## Solution 03 — Multiple Handlers and Notifications

**Step 1:** Create source file:
```bash
echo "ServerTokens Prod" > /tmp/httpd-custom.conf
```

**Step 2:** Create playbook `web-config.yml`:

```yaml
---
- name: Configure web server with multiple handlers
  hosts: node1.example.com
  become: true

  tasks:
    - name: Install httpd and mod_ssl
      ansible.builtin.dnf:
        name:
          - httpd
          - mod_ssl
        state: present

    - name: Copy custom configuration
      ansible.builtin.copy:
        src: /tmp/httpd-custom.conf
        dest: /etc/httpd/conf.d/custom.conf
        owner: root
        group: root
        mode: '0644'
      notify:
        - Restart httpd
        - Check httpd status

    - name: Modify ServerAdmin in httpd.conf
      ansible.builtin.lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^ServerAdmin'
        line: 'ServerAdmin admin@example.com'
      notify:
        - Restart httpd
        - Check httpd status

  handlers:
    - name: Restart httpd
      ansible.builtin.service:
        name: httpd
        state: restarted

    - name: Check httpd status
      ansible.builtin.command:
        cmd: systemctl status httpd
      register: httpd_status
      changed_when: false

    - name: Display httpd status
      ansible.builtin.debug:
        var: httpd_status.stdout_lines
```

**Run:**
```bash
ansible-playbook web-config.yml
```

---

## Solution 04 — Block, Rescue, and Always

**Create playbook `backup-system.yml`:**

```yaml
---
- name: Backup system with error handling
  hosts: managed
  become: true

  tasks:
    - name: Backup operations with error handling
      block:
        - name: Create backup directory
          ansible.builtin.file:
            path: /backup
            state: directory
            mode: '0755'

        - name: Copy hosts file to backup
          ansible.builtin.copy:
            src: /etc/hosts
            dest: /backup/hosts.backup
            remote_src: true

        - name: Create success marker
          ansible.builtin.copy:
            content: "Backup completed\n"
            dest: /backup/backup-success.txt

      rescue:
        - name: Create failure marker
          ansible.builtin.copy:
            content: "Backup failed: {{ ansible_failed_result.msg }}\n"
            dest: /backup/backup-failed.txt

        - name: Log error
          ansible.builtin.lineinfile:
            path: /var/log/backup-errors.log
            line: "{{ ansible_date_time.iso8601 }}: {{ ansible_failed_result.msg }}"
            create: true

      always:
        - name: Create attempt marker with timestamp
          ansible.builtin.copy:
            content: "Backup attempted at {{ ansible_date_time.iso8601 }}\n"
            dest: /backup/backup-attempted.txt

        - name: Ensure backup directory permissions
          ansible.builtin.file:
            path: /backup
            state: directory
            mode: '0755'
```

**Run:**
```bash
ansible-playbook backup-system.yml
```

---

## Solution 05 — Register Variables and Debug

**Create playbook `disk-check.yml`:**

```yaml
---
- name: Check disk usage and report
  hosts: managed
  become: true

  tasks:
    - name: Get disk usage for root filesystem
      ansible.builtin.command:
        cmd: df -h /
      register: disk_usage
      changed_when: false

    - name: Display full command output
      ansible.builtin.debug:
        var: disk_usage

    - name: Display stdout only
      ansible.builtin.debug:
        var: disk_usage.stdout

    - name: Display return code
      ansible.builtin.debug:
        var: disk_usage.rc

    - name: Create disk report file
      ansible.builtin.copy:
        content: "{{ disk_usage.stdout }}\n"
        dest: /tmp/disk-report.txt

    - name: Parse disk usage percentage
      ansible.builtin.set_fact:
        disk_percent: "{{ disk_usage.stdout_lines[1].split()[4] | regex_replace('%', '') | int }}"

    - name: Fail if disk usage above 80%
      ansible.builtin.fail:
        msg: "Disk usage is {{ disk_percent }}% which exceeds 80% threshold"
      when: disk_percent | int > 80
      failed_when: disk_percent | int > 80
```

**Run:**
```bash
ansible-playbook disk-check.yml
```

---

## Solution 06 — Advanced Jinja2 Templates with Loops

**Step 1:** Create `templates/services-report.j2`:

```jinja2
System Services Report
======================
Hostname: {{ ansible_hostname }}
FQDN: {{ ansible_fqdn }}
Generated: {{ ansible_date_time.date }} {{ ansible_date_time.time }}

Network Interfaces:
{% for interface in ansible_interfaces %}
{% if ansible_facts[interface]['ipv4'] is defined %}
  - {{ interface }}: {{ ansible_facts[interface]['ipv4']['address'] }}
{% else %}
  - {{ interface }}: N/A
{% endif %}
{% endfor %}

Mounted Filesystems:
{% for mount in ansible_mounts %}
  - {{ mount.mount }} ({{ mount.fstype }}): {{ (mount.size_total / 1024 / 1024 / 1024) | round(2) }} GB
{% endfor %}
```

**Step 2:** Create playbook `generate-report.yml`:

```yaml
---
- name: Generate system report
  hosts: managed
  become: true

  tasks:
    - name: Ensure directory exists
      ansible.builtin.file:
        path: /var/www/html
        state: directory
        mode: '0755'

    - name: Deploy report template
      ansible.builtin.template:
        src: templates/services-report.j2
        dest: /var/www/html/system-report.html
        owner: root
        group: root
        mode: '0644'
```

**Run:**
```bash
ansible-playbook generate-report.yml
```

---

## Solution 07 — File Modules

**Create playbook `file-operations.yml`:**

```yaml
---
- name: Demonstrate file modules
  hosts: managed
  become: true

  tasks:
    - name: Create initial config file
      ansible.builtin.copy:
        content: |
          [app]
          name=myapp
          version=1.0
        dest: /etc/app-config.conf
        owner: root
        group: root
        mode: '0644'
        backup: true

    - name: Add debug line to app section
      ansible.builtin.lineinfile:
        path: /etc/app-config.conf
        insertafter: '^\[app\]'
        line: 'debug=true'
        backup: true

    - name: Add database section
      ansible.builtin.blockinfile:
        path: /etc/app-config.conf
        block: |
          [database]
          host=localhost
          port=5432
        backup: true

    - name: Fetch hostname from nodes
      ansible.builtin.fetch:
        src: /etc/hostname
        dest: fetched/{{ inventory_hostname }}/hostname
        flat: true
```

**Run:**
```bash
ansible-playbook file-operations.yml
```

---

## Solution 08 — Package Management with Conditionals

**Create playbook `install-tools.yml`:**

```yaml
---
- name: Install tools based on OS family
  hosts: managed
  become: true

  tasks:
    - name: Install tools on RedHat family
      ansible.builtin.dnf:
        name:
          - vim-enhanced
          - wget
          - curl
          - net-tools
        state: latest
      when: ansible_os_family == "RedHat"

    - name: Install tools on Debian family
      ansible.builtin.apt:
        name:
          - vim
          - wget
          - curl
          - net-tools
        state: latest
        update_cache: true
      when: ansible_os_family == "Debian"

    - name: Get list of installed packages
      ansible.builtin.package_facts:
        manager: auto

    - name: Create tools installed file
      ansible.builtin.copy:
        content: |
          Installed Tools:
          - vim/vim-enhanced
          - wget
          - curl
          - net-tools
        dest: /etc/tools-installed.txt
```

**Run:**
```bash
ansible-playbook install-tools.yml
```

---

## Solution 09 — Service Management and Systemd

**Create playbook `service-control.yml`:**

```yaml
---
- name: Manage chronyd service
  hosts: node2.example.com
  become: true

  tasks:
    - name: Install chronyd
      ansible.builtin.dnf:
        name: chrony
        state: present

    - name: Enable and start chronyd
      ansible.builtin.systemd:
        name: chronyd
        state: started
        enabled: true
        daemon_reload: true

    - name: Gather service facts
      ansible.builtin.service_facts:

    - name: Set service state variables
      ansible.builtin.set_fact:
        service_state: "{{ ansible_facts.services['chronyd.service'].state }}"
        service_enabled: "{{ ansible_facts.services['chronyd.service'].status }}"

    - name: Create status file
      ansible.builtin.copy:
        content: |
          Service: chronyd
          Status: {{ service_state }}
          Enabled: {{ service_enabled }}
        dest: /tmp/chrony-status.txt
```

**Run:**
```bash
ansible-playbook service-control.yml
```

---

## Solution 10 — Multi-file Ansible Vault

**Step 1:** Create vault password file:
```bash
echo "Exam02Secure!" > vault_pass_exam02.txt
chmod 600 vault_pass_exam02.txt
```

**Step 2:** Create and encrypt first file:
```bash
mkdir -p group_vars/all

cat > group_vars/all/database.yml << 'EOF'
db_host: db.example.com
db_port: 5432
db_name: production
EOF

ansible-vault encrypt group_vars/all/database.yml --vault-password-file vault_pass_exam02.txt
```

**Step 3:** Create and encrypt second file:
```bash
cat > group_vars/all/api_keys.yml << 'EOF'
api_key: ABC123XYZ789
api_secret: SECRET_KEY_HERE
EOF

ansible-vault encrypt group_vars/all/api_keys.yml --vault-password-file vault_pass_exam02.txt
```

**Step 4:** Create playbook `deploy-config.yml`:

```yaml
---
- name: Deploy configuration files
  hosts: node1.example.com
  become: true

  tasks:
    - name: Create app config directory
      ansible.builtin.file:
        path: /etc/app
        state: directory
        mode: '0755'

    - name: Deploy database configuration
      ansible.builtin.copy:
        content: |
          DB_HOST={{ db_host }}
          DB_PORT={{ db_port }}
          DB_NAME={{ db_name }}
        dest: /etc/app/database.conf
        owner: root
        group: root
        mode: '0600'

    - name: Deploy API configuration
      ansible.builtin.copy:
        content: |
          API_KEY={{ api_key }}
          API_SECRET={{ api_secret }}
        dest: /etc/app/api.conf
        owner: root
        group: root
        mode: '0600'
```

**Run:**
```bash
ansible-playbook deploy-config.yml --vault-password-file vault_pass_exam02.txt
```

**Verification:**
```bash
ansible-vault view group_vars/all/database.yml --vault-password-file vault_pass_exam02.txt
ansible node1.example.com -m command -a "cat /etc/app/database.conf" -i inventory --become
```

---

## 🎯 Tips for Exam 02

### Key Concepts Covered
1. **Advanced Loops**: Iterating over complex data structures
2. **Conditionals**: Multi-level decision making with facts
3. **Handlers**: Multiple handlers and notification chains
4. **Error Handling**: Block/rescue/always patterns
5. **Register**: Capturing and using command output
6. **Templates**: Advanced Jinja2 with loops and filters
7. **File Operations**: All major file manipulation modules
8. **Conditionals**: OS-specific package management
9. **Services**: Systemd and service_facts
10. **Vault**: Multiple encrypted files

### Common Pitfalls
- Forgetting to create groups before assigning users
- Not using `remote_src: true` when copying files on remote host
- Missing `changed_when: false` on check commands
- Not handling undefined variables in templates
- Forgetting `daemon_reload` after systemd changes

### Time Management
- Tasks 01-03: 30 minutes (straightforward)
- Tasks 04-06: 60 minutes (moderate complexity)
- Tasks 07-10: 90 minutes (complex, multiple steps)
- Reserve 30 minutes for testing and fixes

---

**Good luck with Exam 02! 🚀**
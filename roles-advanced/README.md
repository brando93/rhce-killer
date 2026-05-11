# RHCE Killer — Roles Advanced
## EX294: Advanced Role Techniques

---

> **Advanced Exam: Role Mastery**
> This exam teaches you advanced Ansible role techniques.
> Master role variables, includes, imports, and complex scenarios.
> Time limit: **3.5 hours**. Start the timer with: `bash START.sh`

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
- Use advanced role features
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** roles-basics, jinja2-advanced, blocks-and-error-handling

You should know:
- Basic role structure
- Role variables and precedence
- Templates and filters
- Error handling

---

## Tasks

### Task 01 — Role with include_role (20 pts)

Create playbook `dynamic-roles.yml` that:
- Uses `include_role` to dynamically include `apache` role
- Includes role based on condition
- Uses `when` clause with include_role

**Requirements:**
- Use `include_role` module
- Dynamic inclusion
- Conditional execution
- Role runs when condition true

---

### Task 02 — Role with import_role (18 pts)

Create playbook `static-roles.yml` that:
- Uses `import_role` to statically import `nginx` role
- Import happens at parse time
- Can use with tags

**Requirements:**
- Use `import_role` module
- Static import
- Works with --tags
- Parse-time inclusion

---

### Task 03 — Role Variable Precedence (22 pts)

Create role `config` that demonstrates variable precedence:
- Define same variable in:
  - `defaults/main.yml`: `app_port: 8080`
  - `vars/main.yml`: `app_port: 9090`
  - Playbook: `app_port: 7070`
- Show which value wins

**Requirements:**
- Variable in multiple places
- Understand precedence
- vars/ beats defaults/
- Playbook beats vars/

---

### Task 04 — Role with set_fact (20 pts)

Create role `dynamic` that:
- Uses `set_fact` to create dynamic variables
- Calculates values based on facts
- Uses facts in subsequent tasks

**Requirements:**
- Use `set_fact` module
- Create dynamic variables
- Use in later tasks
- Fact-based logic

---

### Task 05 — Role with register and set_fact (22 pts)

Create role `checker` that:
- Runs command and registers output
- Uses `set_fact` to process output
- Makes decision based on result

**Requirements:**
- Use `register`
- Use `set_fact`
- Process registered data
- Conditional logic

---

### Task 06 — Role with include_vars (20 pts)

Create role `environment` that:
- Has multiple var files:
  - `vars/dev.yml`
  - `vars/prod.yml`
- Uses `include_vars` to load based on environment
- Dynamic variable loading

**Requirements:**
- Multiple var files
- Use `include_vars`
- Load based on variable
- Dynamic selection

---

### Task 07 — Role with Nested Includes (22 pts)

Create role `complex` that:
- Main tasks include other task files
- Included files include more files
- Multi-level inclusion
- Proper organization

**Requirements:**
- Nested includes
- Multiple levels
- Organized structure
- All tasks execute

---

### Task 08 — Role with Pre and Post Tasks (20 pts)

Create playbook `ordered-execution.yml` that:
- Has `pre_tasks` section
- Applies roles
- Has `post_tasks` section
- Shows execution order

**Requirements:**
- Use `pre_tasks`
- Use `post_tasks`
- Roles in middle
- Correct order

---

### Task 09 — Role with Delegation (22 pts)

Create role `deploy` that:
- Runs tasks on managed nodes
- Delegates specific task to localhost
- Uses `delegate_to`

**Requirements:**
- Use `delegate_to`
- Task runs on different host
- Proper delegation
- Correct execution

---

### Task 10 — Role with run_once (18 pts)

Create role `cluster` that:
- Has task that runs only once
- Uses `run_once: true`
- Runs on first host only

**Requirements:**
- Use `run_once`
- Task executes once
- Not repeated per host
- Proper usage

---

### Task 11 — Role with Custom Facts (25 pts)

Create role `facts` that:
- Creates custom fact file in `/etc/ansible/facts.d/`
- Fact file is executable script or JSON
- Custom facts available as `ansible_local`

**Requirements:**
- Create facts.d directory
- Create fact file
- Facts available
- Use in tasks

---

### Task 12 — Role with Ansible Vault (22 pts)

Create role `secrets` that:
- Loads encrypted variables from `vars/vault.yml`
- Uses vault-encrypted values
- Deploys secrets securely

**Requirements:**
- Encrypted var file
- Use in role
- Vault integration
- Secure handling

---

### Task 13 — Role with Complex Dependencies (25 pts)

Create role `application` that:
- Has multiple dependencies with parameters
- Dependencies have their own dependencies
- Complex dependency tree

**Requirements:**
- Multiple dependencies
- Pass parameters to dependencies
- Nested dependencies
- Proper execution order

---

### Task 14 — Role with allow_duplicates (20 pts)

Create role `logger` that:
- Can be applied multiple times
- Uses `allow_duplicates: true` in meta
- Each application has different parameters

**Requirements:**
- Set `allow_duplicates`
- Apply role multiple times
- Different parameters each time
- All executions happen

---

### Task 15 — Role with role_path (18 pts)

Create playbook that:
- Searches for roles in multiple paths
- Uses `roles_path` in ansible.cfg
- Finds roles in custom locations

**Requirements:**
- Configure `roles_path`
- Multiple directories
- Roles found correctly
- Proper search order

---

### Task 16 — Role with Ansible Galaxy Requirements (25 pts)

Create `requirements.yml` file that:
- Lists roles to install from Galaxy
- Specifies versions
- Uses `ansible-galaxy install -r requirements.yml`

**Requirements:**
- Create requirements.yml
- List roles with versions
- Install with ansible-galaxy
- Roles available

---

### Task 17 — Role with Meta Runtime (20 pts)

Create role with `meta/runtime.yml` that:
- Specifies minimum Ansible version
- Lists required collections
- Defines runtime requirements

**Requirements:**
- Create meta/runtime.yml
- Specify requirements
- Proper format
- Valid configuration

---

### Task 18 — Role with Argument Spec (25 pts)

Create role with `meta/argument_specs.yml` that:
- Defines required variables
- Specifies variable types
- Validates input

**Requirements:**
- Create argument_specs.yml
- Define required vars
- Type validation
- Proper specification

---

### Task 19 — Role with Collections (22 pts)

Create role that:
- Uses modules from collections
- Specifies collection in FQCN format
- Uses `ansible.builtin` and other collections

**Requirements:**
- Use FQCN for modules
- Multiple collections
- Proper syntax
- Collections available

---

### Task 20 — Complex Multi-Role Scenario (30 pts)

Create complete infrastructure playbook that:
- Uses 5+ roles
- Has role dependencies
- Uses pre_tasks and post_tasks
- Includes conditional role application
- Uses tags for selective execution
- Demonstrates all advanced concepts

**Requirements:**
- Multiple roles
- Dependencies
- Conditionals
- Tags
- Pre/post tasks
- Complete scenario

---

### Task 21 — phpinfo + Apache mod_proxy_balancer (28 pts)

Build TWO custom roles using `ansible-galaxy init` that together implement
the classic "phpinfo backend + Apache load balancer" RHCE exercise.

**Inventory groups assumed:**
- `webservers` (node1, node2) — backend Apache + PHP nodes
- `balancers` (control or a third node) — front-end load balancer

**Role 1: `phpinfo`**
- Location: `/home/student/ansible/roles/phpinfo`
- Installs `httpd` and `php`
- Drops a templated `/var/www/html/index.php` that prints
  `<?php phpinfo(); ?>` plus the line `Backend: {{ ansible_hostname }}`
- Opens HTTP through `firewalld` (`service: http`)
- Starts and enables `httpd`
- Notifies a handler `restart httpd` on config changes

**Role 2: `balancer`**
- Location: `/home/student/ansible/roles/balancer`
- Installs `httpd`
- Drops a templated `/etc/httpd/conf.d/balancer.conf` with a
  `<Proxy "balancer://mycluster">` block listing **every host in
  `groups['webservers']`** (loop over the group; do NOT hardcode IPs)
- Configures `ProxyPass "/" "balancer://mycluster/"` and matching
  `ProxyPassReverse`
- Opens HTTP through `firewalld`
- Starts and enables `httpd`

**Master playbook: `site.yml`**
- One play applies the `phpinfo` role to `webservers`
- A second play applies the `balancer` role to `balancers`

**Verification:**
```bash
# Backends respond directly:
curl http://node1/index.php | grep "Backend: node1"
curl http://node2/index.php | grep "Backend: node2"

# Repeated requests to the balancer hit different backends:
for i in 1 2 3 4; do curl -s http://control/ | grep "Backend:"; done
```

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | include_role | 20 |
| 02 | import_role | 18 |
| 03 | Variable Precedence | 22 |
| 04 | set_fact | 20 |
| 05 | register and set_fact | 22 |
| 06 | include_vars | 20 |
| 07 | Nested Includes | 22 |
| 08 | Pre and Post Tasks | 20 |
| 09 | Delegation | 22 |
| 10 | run_once | 18 |
| 11 | Custom Facts | 25 |
| 12 | Ansible Vault | 22 |
| 13 | Complex Dependencies | 25 |
| 14 | allow_duplicates | 20 |
| 15 | role_path | 18 |
| 16 | Galaxy Requirements | 25 |
| 17 | Meta Runtime | 20 |
| 18 | Argument Spec | 25 |
| 19 | Collections | 22 |
| 20 | Complex Scenario | 30 |
| 21 | phpinfo + mod_proxy_balancer | 28 |
| **Total** | | **464** |

**Passing score: 70% (325/464 points)**

---

## When you finish

```bash
bash /home/student/exams/roles-advanced/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

---

## Solution 01 — Role with include_role

**Playbook: dynamic-roles.yml**
```yaml
---
- name: Dynamic role inclusion
  hosts: all
  become: true
  
  vars:
    install_apache: true
  
  tasks:
    - name: Include apache role conditionally
      ansible.builtin.include_role:
        name: apache
      when: install_apache
```

**Explanation:**
- `include_role` is dynamic (runtime)
- Can use with conditionals
- Role included only when condition true
- Useful for optional roles

---

## Solution 02 — Role with import_role

**Playbook: static-roles.yml**
```yaml
---
- name: Static role import
  hosts: all
  become: true
  
  tasks:
    - name: Import nginx role
      ansible.builtin.import_role:
        name: nginx
      tags:
        - nginx
        - webserver
```

**Explanation:**
- `import_role` is static (parse-time)
- Processed before execution
- Works with tags
- Cannot use with conditionals on import itself

**Run with tags:**
```bash
ansible-playbook static-roles.yml --tags nginx
```

---

## Solution 03 — Role Variable Precedence

**Role: config**

**File: roles/config/defaults/main.yml**
```yaml
---
app_port: 8080
```

**File: roles/config/vars/main.yml**
```yaml
---
app_port: 9090
```

**File: roles/config/tasks/main.yml**
```yaml
---
- name: Display port
  ansible.builtin.debug:
    msg: "App port is: {{ app_port }}"
```

**Playbook: precedence-test.yml**
```yaml
---
- name: Test variable precedence
  hosts: all
  
  vars:
    app_port: 7070
  
  roles:
    - config
```

**Result:** Shows 7070 (playbook vars win)

**Precedence order (low to high):**
1. defaults/main.yml (lowest)
2. vars/main.yml
3. Playbook vars
4. Extra vars (highest)

---

## Solution 04 — Role with set_fact

**Role: dynamic**

**File: roles/dynamic/tasks/main.yml**
```yaml
---
- name: Calculate memory percentage
  ansible.builtin.set_fact:
    memory_percent: "{{ (ansible_memfree_mb / ansible_memtotal_mb * 100) | round(2) }}"

- name: Display memory info
  ansible.builtin.debug:
    msg: "Free memory: {{ memory_percent }}%"

- name: Set server tier based on memory
  ansible.builtin.set_fact:
    server_tier: "{{ 'high' if ansible_memtotal_mb > 4096 else 'standard' }}"

- name: Display server tier
  ansible.builtin.debug:
    msg: "Server tier: {{ server_tier }}"
```

**Explanation:**
- `set_fact` creates variables at runtime
- Can use facts and calculations
- Facts persist for playbook duration
- Useful for dynamic decisions

---

## Solution 05 — Role with register and set_fact

**Role: checker**

**File: roles/checker/tasks/main.yml**
```yaml
---
- name: Check disk usage
  ansible.builtin.command: df -h /
  register: disk_check
  changed_when: false

- name: Extract disk usage percentage
  ansible.builtin.set_fact:
    disk_usage: "{{ disk_check.stdout_lines[1].split()[4] }}"

- name: Display disk usage
  ansible.builtin.debug:
    msg: "Disk usage: {{ disk_usage }}"

- name: Set alert status
  ansible.builtin.set_fact:
    disk_alert: "{{ disk_usage | replace('%', '') | int > 80 }}"

- name: Display alert if needed
  ansible.builtin.debug:
    msg: "WARNING: Disk usage is high!"
  when: disk_alert
```

---

## Solution 06 — Role with include_vars

**Role: environment**

**File: roles/environment/vars/dev.yml**
```yaml
---
env_name: development
db_host: localhost
db_port: 3306
debug: true
```

**File: roles/environment/vars/prod.yml**
```yaml
---
env_name: production
db_host: db.example.com
db_port: 3306
debug: false
```

**File: roles/environment/tasks/main.yml**
```yaml
---
- name: Load environment variables
  ansible.builtin.include_vars:
    file: "{{ environment }}.yml"

- name: Display environment
  ansible.builtin.debug:
    msg: "Environment: {{ env_name }}, Debug: {{ debug }}"
```

**Playbook:**
```yaml
---
- name: Use environment role
  hosts: all
  
  vars:
    environment: prod
  
  roles:
    - environment
```

---

## Solution 07 — Role with Nested Includes

**Role: complex**

**File: roles/complex/tasks/main.yml**
```yaml
---
- name: Include base setup
  ansible.builtin.include_tasks: base/setup.yml

- name: Include application tasks
  ansible.builtin.include_tasks: application/main.yml
```

**File: roles/complex/tasks/base/setup.yml**
```yaml
---
- name: Include system tasks
  ansible.builtin.include_tasks: system.yml

- name: Include network tasks
  ansible.builtin.include_tasks: network.yml
```

**File: roles/complex/tasks/base/system.yml**
```yaml
---
- name: Update system
  ansible.builtin.debug:
    msg: "System update"
```

**File: roles/complex/tasks/base/network.yml**
```yaml
---
- name: Configure network
  ansible.builtin.debug:
    msg: "Network configuration"
```

**File: roles/complex/tasks/application/main.yml**
```yaml
---
- name: Install application
  ansible.builtin.debug:
    msg: "Application installation"
```

---

## Solution 08 — Role with Pre and Post Tasks

**Playbook: ordered-execution.yml**
```yaml
---
- name: Demonstrate execution order
  hosts: all
  become: true
  
  pre_tasks:
    - name: Pre-task 1
      ansible.builtin.debug:
        msg: "This runs BEFORE roles"
    
    - name: Update cache
      ansible.builtin.dnf:
        update_cache: true
  
  roles:
    - apache
    - database
  
  post_tasks:
    - name: Post-task 1
      ansible.builtin.debug:
        msg: "This runs AFTER roles"
    
    - name: Verify services
      ansible.builtin.service:
        name: httpd
        state: started
```

**Execution order:**
1. pre_tasks
2. roles
3. post_tasks

---

## Solution 09 — Role with Delegation

**Role: deploy**

**File: roles/deploy/tasks/main.yml**
```yaml
---
- name: Build application on localhost
  ansible.builtin.command: echo "Building application"
  delegate_to: localhost
  run_once: true

- name: Copy artifact to managed nodes
  ansible.builtin.copy:
    content: "Application artifact"
    dest: /opt/app/artifact.txt
    mode: '0644'

- name: Deploy on managed nodes
  ansible.builtin.debug:
    msg: "Deploying on {{ inventory_hostname }}"
```

**Explanation:**
- `delegate_to` runs task on different host
- Build once on localhost
- Deploy to all managed nodes
- Efficient workflow

---

## Solution 10 — Role with run_once

**Role: cluster**

**File: roles/cluster/tasks/main.yml**
```yaml
---
- name: Initialize cluster (run once)
  ansible.builtin.debug:
    msg: "Initializing cluster configuration"
  run_once: true

- name: Join cluster (run on all)
  ansible.builtin.debug:
    msg: "{{ inventory_hostname }} joining cluster"
```

**Explanation:**
- `run_once` executes on first host only
- Useful for cluster initialization
- Other tasks run on all hosts
- Efficient for one-time operations

---

## Solution 11 — Role with Custom Facts

**Role: facts**

**File: roles/facts/tasks/main.yml**
```yaml
---
- name: Create facts.d directory
  ansible.builtin.file:
    path: /etc/ansible/facts.d
    state: directory
    mode: '0755'

- name: Create custom fact file
  ansible.builtin.copy:
    content: |
      #!/bin/bash
      echo "{\"app_version\": \"1.0.0\", \"app_env\": \"production\"}"
    dest: /etc/ansible/facts.d/custom.fact
    mode: '0755'

- name: Reload facts
  ansible.builtin.setup:

- name: Display custom facts
  ansible.builtin.debug:
    msg: "App version: {{ ansible_local.custom.app_version }}"
```

**Alternative JSON format:**
```json
{
  "app_version": "1.0.0",
  "app_env": "production"
}
```

---

## Solution 12 — Role with Ansible Vault

**Role: secrets**

```bash
# Create encrypted vars file
ansible-vault create roles/secrets/vars/vault.yml
```

**Content:**
```yaml
vault_db_password: "SecretDBPass123"
vault_api_key: "SecretAPIKey456"
```

**File: roles/secrets/tasks/main.yml**
```yaml
---
- name: Include vault variables
  ansible.builtin.include_vars:
    file: vault.yml

- name: Use encrypted password
  ansible.builtin.debug:
    msg: "DB Password is encrypted"
  no_log: true

- name: Create config with secrets
  ansible.builtin.copy:
    content: |
      db_password={{ vault_db_password }}
      api_key={{ vault_api_key }}
    dest: /etc/app/secrets.conf
    mode: '0600'
  no_log: true
```

---

## Solution 13 — Role with Complex Dependencies

**Role: application**

**File: roles/application/meta/main.yml**
```yaml
---
dependencies:
  - role: common
    vars:
      common_packages:
        - vim
        - git
  
  - role: apache
    vars:
      apache_port: 8080
  
  - role: database
    vars:
      db_name: appdb
      db_user: appuser
  
  - role: cache
    vars:
      cache_size: 512mb
```

**Explanation:**
- Multiple dependencies with parameters
- Each dependency can have its own dependencies
- Parameters passed to each role
- Execution order: dependencies first, then role

---

## Solution 14 — Role with allow_duplicates

**Role: logger**

**File: roles/logger/meta/main.yml**
```yaml
---
allow_duplicates: true
```

**File: roles/logger/tasks/main.yml**
```yaml
---
- name: Log message
  ansible.builtin.lineinfile:
    path: /var/log/app.log
    line: "{{ log_message }} - {{ ansible_date_time.iso8601 }}"
    create: true
    mode: '0644'
```

**Playbook:**
```yaml
---
- name: Use logger multiple times
  hosts: all
  become: true
  
  roles:
    - role: logger
      log_message: "Application started"
    
    - role: logger
      log_message: "Configuration loaded"
    
    - role: logger
      log_message: "Services initialized"
```

---

## Solution 15 — Role with role_path

**Modify ansible.cfg:**
```ini
[defaults]
roles_path = /home/student/ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
```

**Explanation:**
- Multiple directories separated by colon
- Searched in order
- First match wins
- Allows organization of roles

**Verify:**
```bash
ansible-config dump | grep roles_path
```

---

## Solution 16 — Role with Ansible Galaxy Requirements

**File: requirements.yml**
```yaml
---
roles:
  - name: geerlingguy.apache
    version: 3.1.4
  
  - name: geerlingguy.mysql
    version: 4.3.0
  
  - name: geerlingguy.nginx
    version: 2.8.0
  
  - src: https://github.com/user/role.git
    name: custom_role
    version: main

collections:
  - name: community.general
    version: 5.5.0
  
  - name: ansible.posix
    version: 1.4.0
```

**Install:**
```bash
ansible-galaxy install -r requirements.yml
ansible-galaxy collection install -r requirements.yml
```

---

## Solution 17 — Role with Meta Runtime

**File: roles/myapp/meta/runtime.yml**
```yaml
---
requires_ansible: '>=2.10'

action_groups:
  myapp:
    - myapp_module
    - myapp_info

plugin_routing:
  modules:
    old_module:
      redirect: new_module
```

---

## Solution 18 — Role with Argument Spec

**File: roles/webapp/meta/argument_specs.yml**
```yaml
---
argument_specs:
  main:
    short_description: Web application role
    description:
      - Deploys and configures web application
    
    options:
      app_port:
        description: Application port
        type: int
        required: true
      
      app_name:
        description: Application name
        type: str
        required: true
      
      app_env:
        description: Environment
        type: str
        required: false
        default: production
        choices:
          - development
          - staging
          - production
      
      enable_ssl:
        description: Enable SSL
        type: bool
        required: false
        default: false
```

---

## Solution 19 — Role with Collections

**File: roles/modern/tasks/main.yml**
```yaml
---
- name: Use builtin module
  ansible.builtin.debug:
    msg: "Using FQCN"

- name: Use community module
  community.general.timezone:
    name: America/New_York

- name: Use posix module
  ansible.posix.firewalld:
    service: http
    state: enabled
    permanent: true
```

**Explanation:**
- FQCN: Fully Qualified Collection Name
- Format: `namespace.collection.module`
- `ansible.builtin` for core modules
- Explicit and clear

---

## Solution 20 — Complex Multi-Role Scenario

**Playbook: infrastructure.yml**
```yaml
---
- name: Deploy complete infrastructure
  hosts: all
  become: true
  
  vars:
    deploy_web: true
    deploy_db: true
    environment: production
  
  pre_tasks:
    - name: Update system
      ansible.builtin.dnf:
        name: '*'
        state: latest
        update_cache: true
      tags: ['never', 'update']
    
    - name: Create app user
      ansible.builtin.user:
        name: appuser
        state: present
      tags: ['always']
  
  roles:
    - role: common
      tags: ['common', 'base']
    
    - role: security
      tags: ['security', 'base']
    
    - role: apache
      when: deploy_web
      tags: ['web', 'apache']
    
    - role: nginx
      when: deploy_web and environment == 'production'
      tags: ['web', 'nginx']
    
    - role: database
      when: deploy_db
      tags: ['database', 'db']
    
    - role: cache
      tags: ['cache', 'redis']
    
    - role: monitoring
      tags: ['monitoring']
  
  post_tasks:
    - name: Verify all services
      ansible.builtin.service:
        name: "{{ item }}"
        state: started
      loop:
        - httpd
        - nginx
        - mariadb
      tags: ['verify']
    
    - name: Send notification
      ansible.builtin.debug:
        msg: "Deployment completed successfully"
      tags: ['always']
```

**Run examples:**
```bash
# Full deployment
ansible-playbook infrastructure.yml

# Only web servers
ansible-playbook infrastructure.yml --tags web

# Skip monitoring
ansible-playbook infrastructure.yml --skip-tags monitoring

# Only base setup
ansible-playbook infrastructure.yml --tags base
```

---

## Quick Reference: include vs import

### include_role (Dynamic)
```yaml
- include_role:
    name: role_name
  when: condition
```
- Runtime decision
- Can use with when
- Cannot use with tags on include

### import_role (Static)
```yaml
- import_role:
    name: role_name
  tags: tag_name
```
- Parse-time inclusion
- Works with tags
- Cannot use with when on import

---

## Quick Reference: Variable Precedence

**From lowest to highest:**
1. role defaults
2. inventory file/script group vars
3. inventory group_vars/all
4. playbook group_vars/all
5. inventory group_vars/*
6. playbook group_vars/*
7. inventory file/script host vars
8. inventory host_vars/*
9. playbook host_vars/*
10. host facts
11. play vars
12. play vars_prompt
13. play vars_files
14. role vars
15. block vars
16. task vars
17. include_vars
18. set_facts
19. role params
20. include params
21. extra vars (always win)

---

## Solution 21 — phpinfo + Apache mod_proxy_balancer

**Create the two role skeletons:**
```bash
cd /home/student/ansible
ansible-galaxy init roles/phpinfo
ansible-galaxy init roles/balancer
```

**File: roles/phpinfo/tasks/main.yml**
```yaml
---
- name: Install Apache and PHP
  ansible.builtin.dnf:
    name:
      - httpd
      - php
    state: present

- name: Deploy phpinfo page
  ansible.builtin.template:
    src: index.php.j2
    dest: /var/www/html/index.php
    owner: root
    group: root
    mode: '0644'
  notify: restart httpd

- name: Open HTTP in firewalld
  ansible.posix.firewalld:
    service: http
    permanent: true
    immediate: true
    state: enabled

- name: Start and enable httpd
  ansible.builtin.service:
    name: httpd
    state: started
    enabled: true
```

**File: roles/phpinfo/templates/index.php.j2**
```jinja
<?php
echo "Backend: {{ ansible_hostname }}<br>";
phpinfo();
?>
```

**File: roles/phpinfo/handlers/main.yml**
```yaml
---
- name: restart httpd
  ansible.builtin.service:
    name: httpd
    state: restarted
```

**File: roles/balancer/tasks/main.yml**
```yaml
---
- name: Install Apache (proxy modules ship with httpd)
  ansible.builtin.dnf:
    name: httpd
    state: present

- name: Deploy balancer virtual host
  ansible.builtin.template:
    src: balancer.conf.j2
    dest: /etc/httpd/conf.d/balancer.conf
    owner: root
    group: root
    mode: '0644'
  notify: restart httpd

- name: Open HTTP in firewalld
  ansible.posix.firewalld:
    service: http
    permanent: true
    immediate: true
    state: enabled

- name: Start and enable httpd
  ansible.builtin.service:
    name: httpd
    state: started
    enabled: true
```

**File: roles/balancer/templates/balancer.conf.j2**
```apache
<Proxy "balancer://mycluster">
{% for host in groups['webservers'] %}
    BalancerMember "http://{{ hostvars[host].ansible_default_ipv4.address }}"
{% endfor %}
</Proxy>

ProxyPass        "/" "balancer://mycluster/"
ProxyPassReverse "/" "balancer://mycluster/"
```

**File: roles/balancer/handlers/main.yml**
```yaml
---
- name: restart httpd
  ansible.builtin.service:
    name: httpd
    state: restarted
```

**File: site.yml**
```yaml
---
- name: Configure backend phpinfo nodes
  hosts: webservers
  become: true
  roles:
    - phpinfo

- name: Configure front-end balancer
  hosts: balancers
  become: true
  roles:
    - balancer
```

**Run and verify:**
```bash
ansible-playbook site.yml
curl http://node1/index.php | grep "Backend: node1"
curl http://node2/index.php | grep "Backend: node2"
for i in 1 2 3 4; do curl -s http://<balancer>/ | grep "Backend:"; done
```

**Explanation:**
- The balancer template loops over `groups['webservers']` and pulls each backend's
  IP from `hostvars` — adding/removing a backend in the inventory is the only
  change needed to scale
- `mod_proxy` and `mod_proxy_balancer` are loaded by Apache's default
  configuration on RHEL/Rocky 9; no extra `LoadModule` is required
- Notifying `restart httpd` from both `tasks/main.yml` ensures config changes
  always take effect without forcing a restart on every run
- Two separate plays let you assign each role to its correct host group

---

## Best Practices

1. **Use include_role for conditional:**
   ```yaml
   - include_role:
       name: optional_role
     when: feature_enabled
   ```

2. **Use import_role for tags:**
   ```yaml
   - import_role:
       name: tagged_role
     tags: deployment
   ```

3. **Document argument specs:**
   ```yaml
   # meta/argument_specs.yml
   argument_specs:
     main:
       options:
         required_var:
           required: true
   ```

4. **Use FQCN for clarity:**
   ```yaml
   ansible.builtin.copy:
   community.general.timezone:
   ```

5. **Organize complex roles:**
   ```
   tasks/
     main.yml
     install/
       main.yml
     configure/
       main.yml
   ```

---

## Tips for RHCE Exam

1. **Know include vs import:**
   - include = dynamic (runtime)
   - import = static (parse-time)

2. **Understand precedence:**
   - defaults < vars < playbook vars < extra vars

3. **Use pre_tasks/post_tasks:**
   - pre_tasks → roles → post_tasks

4. **Test with tags:**
   ```bash
   ansible-playbook playbook.yml --tags test
   ```

5. **Verify role structure:**
   ```bash
   tree roles/role_name
   ```

6. **Common mistakes:**
   - Wrong precedence assumptions
   - Using when with import_role
   - Forgetting allow_duplicates
   - Wrong FQCN syntax

---

Good luck with your RHCE exam preparation! 🚀

Master advanced role techniques - they're essential for enterprise-scale automation.
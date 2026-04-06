# RHCE Killer — Jinja2 Basics
## EX294: Mastering Ansible Templates

---

> **Intermediate Exam: Template Fundamentals**
> This exam teaches you how to use Jinja2 templates in Ansible.
> Master variable substitution, filters, and basic template syntax.
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
- All playbooks and templates must be created under `/home/student/ansible/`
- Templates should be in `/home/student/ansible/templates/` directory
- Playbooks must run without errors
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, variables-and-facts

You should know:
- How to write playbooks
- How to use variables
- How to use facts
- Basic file operations

---

## Tasks

### Task 01 — Basic Variable Substitution (10 pts)

Create a playbook `/home/student/ansible/template-basic.yml` that:
- Runs on **all managed nodes**
- Creates template `/home/student/ansible/templates/basic.j2` with content:
  ```
  Server: {{ inventory_hostname }}
  IP: {{ ansible_default_ipv4.address }}
  ```
- Uses `template` module to deploy to `/tmp/server-info.txt`
- Uses `become: true`

**Requirements:**
- Create template file in templates/ directory
- Use `{{ variable }}` syntax
- Use `template` module
- Deploy to all nodes

---

### Task 02 — Template with Variables (12 pts)

Create a playbook `/home/student/ansible/template-vars.yml` that:
- Runs on **all managed nodes**
- Defines variables:
  - `app_name: myapp`
  - `app_port: 8080`
  - `app_env: production`
- Creates template `app-config.j2` with:
  ```
  Application: {{ app_name }}
  Port: {{ app_port }}
  Environment: {{ app_env }}
  ```
- Deploys to `/opt/app/config.txt`
- Uses `become: true`

**Requirements:**
- Define variables in playbook
- Create template file
- Use template module
- Create parent directory if needed

---

### Task 03 — Template with Facts (12 pts)

Create a playbook `/home/student/ansible/template-facts.yml` that:
- Runs on **all managed nodes**
- Creates template `system-info.j2` with:
  ```
  Hostname: {{ ansible_hostname }}
  OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
  Memory: {{ ansible_memtotal_mb }} MB
  CPUs: {{ ansible_processor_vcpus }}
  ```
- Deploys to `/tmp/system-info.txt`

**Requirements:**
- Use Ansible facts
- Create template file
- Use template module
- No become needed

---

### Task 04 — Upper Filter (10 pts)

Create a playbook `/home/student/ansible/template-upper.yml` that:
- Runs on **all managed nodes**
- Defines variable `server_name: webserver`
- Creates template `uppercase.j2` with:
  ```
  Server Name: {{ server_name | upper }}
  ```
- Deploys to `/tmp/uppercase.txt`

**Requirements:**
- Use `| upper` filter
- Create template file
- Result should be "WEBSERVER"

---

### Task 05 — Lower Filter (10 pts)

Create a playbook `/home/student/ansible/template-lower.yml` that:
- Runs on **all managed nodes**
- Defines variable `company_name: ACME Corp`
- Creates template `lowercase.j2` with:
  ```
  Company: {{ company_name | lower }}
  ```
- Deploys to `/tmp/lowercase.txt`

**Requirements:**
- Use `| lower` filter
- Create template file
- Result should be "acme corp"

---

### Task 06 — Default Filter (15 pts)

Create a playbook `/home/student/ansible/template-default.yml` that:
- Runs on **all managed nodes**
- Does NOT define variable `custom_port`
- Creates template `default.j2` with:
  ```
  Port: {{ custom_port | default(80) }}
  ```
- Deploys to `/tmp/default.txt`

**Requirements:**
- Use `| default()` filter
- Variable should not be defined
- Result should be "Port: 80"

---

### Task 07 — Replace Filter (12 pts)

Create a playbook `/home/student/ansible/template-replace.yml` that:
- Runs on **all managed nodes**
- Defines variable `message: Hello World`
- Creates template `replace.j2` with:
  ```
  Original: {{ message }}
  Modified: {{ message | replace('World', 'Ansible') }}
  ```
- Deploys to `/tmp/replace.txt`

**Requirements:**
- Use `| replace()` filter
- Create template file
- Result should show "Hello Ansible"

---

### Task 08 — Join Filter (15 pts)

Create a playbook `/home/student/ansible/template-join.yml` that:
- Runs on **all managed nodes**
- Defines list variable:
  ```yaml
  packages:
    - httpd
    - nginx
    - firewalld
  ```
- Creates template `join.j2` with:
  ```
  Packages: {{ packages | join(', ') }}
  ```
- Deploys to `/tmp/packages.txt`

**Requirements:**
- Use `| join()` filter
- Create template file
- Result should be comma-separated list

---

### Task 09 — Length Filter (12 pts)

Create a playbook `/home/student/ansible/template-length.yml` that:
- Runs on **all managed nodes**
- Defines list variable with 5 items
- Creates template `length.j2` with:
  ```
  Total items: {{ items | length }}
  ```
- Deploys to `/tmp/length.txt`

**Requirements:**
- Use `| length` filter
- Create template file
- Result should be "Total items: 5"

---

### Task 10 — Min and Max Filters (15 pts)

Create a playbook `/home/student/ansible/template-minmax.yml` that:
- Runs on **all managed nodes**
- Defines list: `numbers: [10, 25, 5, 30, 15]`
- Creates template `minmax.j2` with:
  ```
  Minimum: {{ numbers | min }}
  Maximum: {{ numbers | max }}
  ```
- Deploys to `/tmp/minmax.txt`

**Requirements:**
- Use `| min` and `| max` filters
- Create template file
- Results should be 5 and 30

---

### Task 11 — Unique Filter (12 pts)

Create a playbook `/home/student/ansible/template-unique.yml` that:
- Runs on **all managed nodes**
- Defines list: `items: ['a', 'b', 'a', 'c', 'b']`
- Creates template `unique.j2` with:
  ```
  Unique items: {{ items | unique | join(', ') }}
  ```
- Deploys to `/tmp/unique.txt`

**Requirements:**
- Use `| unique` filter
- Combine with `| join()`
- Remove duplicates

---

### Task 12 — Sort Filter (15 pts)

Create a playbook `/home/student/ansible/template-sort.yml` that:
- Runs on **all managed nodes**
- Defines list: `names: ['charlie', 'alice', 'bob']`
- Creates template `sort.j2` with:
  ```
  Sorted: {{ names | sort | join(', ') }}
  Reverse: {{ names | sort(reverse=true) | join(', ') }}
  ```
- Deploys to `/tmp/sort.txt`

**Requirements:**
- Use `| sort` filter
- Use `sort(reverse=true)` for descending
- Create template file

---

### Task 13 — To JSON Filter (15 pts)

Create a playbook `/home/student/ansible/template-json.yml` that:
- Runs on **all managed nodes**
- Defines dictionary:
  ```yaml
  config:
    host: localhost
    port: 8080
    debug: true
  ```
- Creates template `json.j2` with:
  ```
  {{ config | to_json }}
  ```
- Deploys to `/tmp/config.json`

**Requirements:**
- Use `| to_json` filter
- Create valid JSON output
- Create template file

---

### Task 14 — To YAML Filter (15 pts)

Create a playbook `/home/student/ansible/template-yaml.yml` that:
- Runs on **all managed nodes**
- Defines dictionary:
  ```yaml
  settings:
    database: mysql
    cache: redis
    queue: rabbitmq
  ```
- Creates template `yaml.j2` with:
  ```
  {{ settings | to_yaml }}
  ```
- Deploys to `/tmp/settings.yaml`

**Requirements:**
- Use `| to_yaml` filter
- Create valid YAML output
- Create template file

---

### Task 15 — Multiple Filters Chained (18 pts)

Create a playbook `/home/student/ansible/template-chain.yml` that:
- Runs on **all managed nodes**
- Defines list: `servers: ['web1', 'web2', 'db1', 'web3']`
- Creates template `chain.j2` that:
  - Filters servers containing 'web'
  - Sorts them
  - Converts to uppercase
  - Joins with comma
- Deploys to `/tmp/chain.txt`

**Requirements:**
- Use multiple filters: `select`, `sort`, `upper`, `join`
- Chain filters with `|`
- Result: "WEB1, WEB2, WEB3"

---

### Task 16 — Template with Math (15 pts)

Create a playbook `/home/student/ansible/template-math.yml` that:
- Runs on **all managed nodes**
- Defines variables:
  - `memory_mb: 2048`
  - `disk_gb: 100`
- Creates template `math.j2` with:
  ```
  Memory GB: {{ (memory_mb / 1024) | round(2) }}
  Disk TB: {{ (disk_gb / 1024) | round(3) }}
  ```
- Deploys to `/tmp/math.txt`

**Requirements:**
- Use math operations in template
- Use `| round()` filter
- Create template file

---

### Task 17 — Template with Hostname Manipulation (15 pts)

Create a playbook `/home/student/ansible/template-hostname.yml` that:
- Runs on **all managed nodes**
- Creates template `hostname.j2` with:
  ```
  Full: {{ inventory_hostname }}
  Short: {{ inventory_hostname.split('.')[0] }}
  Domain: {{ inventory_hostname.split('.')[1:] | join('.') }}
  ```
- Deploys to `/tmp/hostname-parts.txt`

**Requirements:**
- Use `.split()` method
- Use list slicing `[0]` and `[1:]`
- Use `| join()` filter

---

### Task 18 — Template with Conditional Content (18 pts)

Create a playbook `/home/student/ansible/template-conditional.yml` that:
- Runs on **all managed nodes**
- Defines variable `environment: production`
- Creates template `conditional.j2` with:
  ```
  {% if environment == 'production' %}
  Debug: false
  LogLevel: error
  {% else %}
  Debug: true
  LogLevel: debug
  {% endif %}
  ```
- Deploys to `/tmp/conditional.txt`

**Requirements:**
- Use `{% if %}` statement
- Use `{% else %}` clause
- Use `{% endif %}` to close
- Create template file

---

### Task 19 — Template with Loop (20 pts)

Create a playbook `/home/student/ansible/template-loop.yml` that:
- Runs on **all managed nodes**
- Defines list:
  ```yaml
  users:
    - alice
    - bob
    - charlie
  ```
- Creates template `loop.j2` with:
  ```
  Users:
  {% for user in users %}
  - {{ user }}
  {% endfor %}
  ```
- Deploys to `/tmp/users.txt`

**Requirements:**
- Use `{% for %}` loop
- Use `{% endfor %}` to close
- Create list format output

---

### Task 20 — Complex Template (25 pts)

Create a playbook `/home/student/ansible/template-complex.yml` that:
- Runs on **all managed nodes**
- Defines variables:
  ```yaml
  services:
    - name: httpd
      port: 80
      enabled: true
    - name: nginx
      port: 8080
      enabled: false
    - name: mysql
      port: 3306
      enabled: true
  ```
- Creates template `services.j2` with:
  ```
  Active Services:
  {% for service in services %}
  {% if service.enabled %}
  - {{ service.name }} on port {{ service.port }}
  {% endif %}
  {% endfor %}
  ```
- Deploys to `/tmp/active-services.txt`

**Requirements:**
- Use `{% for %}` loop
- Use `{% if %}` condition inside loop
- Access dictionary keys
- Create template file

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Basic Variable Substitution | 10 |
| 02 | Template with Variables | 12 |
| 03 | Template with Facts | 12 |
| 04 | Upper Filter | 10 |
| 05 | Lower Filter | 10 |
| 06 | Default Filter | 15 |
| 07 | Replace Filter | 12 |
| 08 | Join Filter | 15 |
| 09 | Length Filter | 12 |
| 10 | Min and Max Filters | 15 |
| 11 | Unique Filter | 12 |
| 12 | Sort Filter | 15 |
| 13 | To JSON Filter | 15 |
| 14 | To YAML Filter | 15 |
| 15 | Multiple Filters Chained | 18 |
| 16 | Template with Math | 15 |
| 17 | Hostname Manipulation | 15 |
| 18 | Conditional Content | 18 |
| 19 | Template with Loop | 20 |
| 20 | Complex Template | 25 |
| **Total** | | **286** |

**Passing score: 70% (200/286 points)**

---

## When you finish

```bash
bash /home/student/exams/jinja2-basics/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Basic Variable Substitution

**Template: templates/basic.j2**
```jinja2
Server: {{ inventory_hostname }}
IP: {{ ansible_default_ipv4.address }}
```

**Playbook: template-basic.yml**
```yaml
---
- name: Basic template example
  hosts: all
  become: true
  
  tasks:
    - name: Deploy basic template
      ansible.builtin.template:
        src: templates/basic.j2
        dest: /tmp/server-info.txt
        mode: '0644'
```

**Explanation:**
- `{{ variable }}` syntax for variable substitution
- `template` module processes Jinja2 templates
- `src` is relative to playbook directory
- Variables replaced with actual values
- Facts available automatically

**Verification:**
```bash
ansible all -m command -a "cat /tmp/server-info.txt"
```

---

## Solution 02 — Template with Variables

**Template: templates/app-config.j2**
```jinja2
Application: {{ app_name }}
Port: {{ app_port }}
Environment: {{ app_env }}
```

**Playbook: template-vars.yml**
```yaml
---
- name: Template with variables
  hosts: all
  become: true
  
  vars:
    app_name: myapp
    app_port: 8080
    app_env: production
  
  tasks:
    - name: Create app directory
      ansible.builtin.file:
        path: /opt/app
        state: directory
        mode: '0755'
    
    - name: Deploy app config
      ansible.builtin.template:
        src: templates/app-config.j2
        dest: /opt/app/config.txt
        mode: '0644'
```

**Explanation:**
- Variables defined in `vars` section
- Available in template automatically
- Create parent directory first
- Template module handles file creation

---

## Solution 03 — Template with Facts

**Template: templates/system-info.j2**
```jinja2
Hostname: {{ ansible_hostname }}
OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
Memory: {{ ansible_memtotal_mb }} MB
CPUs: {{ ansible_processor_vcpus }}
```

**Playbook: template-facts.yml**
```yaml
---
- name: Template with facts
  hosts: all
  
  tasks:
    - name: Deploy system info
      ansible.builtin.template:
        src: templates/system-info.j2
        dest: /tmp/system-info.txt
        mode: '0644'
```

**Explanation:**
- Facts gathered automatically
- Access with `ansible_*` prefix
- No need to define variables
- Different values per host

**Check facts:**
```bash
ansible all -m setup -a "filter=ansible_hostname"
```

---

## Solution 04 — Upper Filter

**Template: templates/uppercase.j2**
```jinja2
Server Name: {{ server_name | upper }}
```

**Playbook: template-upper.yml**
```yaml
---
- name: Upper filter example
  hosts: all
  
  vars:
    server_name: webserver
  
  tasks:
    - name: Deploy uppercase template
      ansible.builtin.template:
        src: templates/uppercase.j2
        dest: /tmp/uppercase.txt
        mode: '0644'
```

**Explanation:**
- `| upper` converts to uppercase
- Filter applied with pipe operator
- Original variable unchanged
- Result: "WEBSERVER"

---

## Solution 05 — Lower Filter

**Template: templates/lowercase.j2**
```jinja2
Company: {{ company_name | lower }}
```

**Playbook: template-lower.yml**
```yaml
---
- name: Lower filter example
  hosts: all
  
  vars:
    company_name: ACME Corp
  
  tasks:
    - name: Deploy lowercase template
      ansible.builtin.template:
        src: templates/lowercase.j2
        dest: /tmp/lowercase.txt
        mode: '0644'
```

**Explanation:**
- `| lower` converts to lowercase
- Useful for normalization
- Result: "acme corp"

---

## Solution 06 — Default Filter

**Template: templates/default.j2**
```jinja2
Port: {{ custom_port | default(80) }}
```

**Playbook: template-default.yml**
```yaml
---
- name: Default filter example
  hosts: all
  
  tasks:
    - name: Deploy default template
      ansible.builtin.template:
        src: templates/default.j2
        dest: /tmp/default.txt
        mode: '0644'
```

**Explanation:**
- `| default()` provides fallback value
- Used when variable undefined
- Prevents template errors
- Result: "Port: 80"

**With defined variable:**
```yaml
vars:
  custom_port: 8080
# Result: "Port: 8080"
```

---

## Solution 07 — Replace Filter

**Template: templates/replace.j2**
```jinja2
Original: {{ message }}
Modified: {{ message | replace('World', 'Ansible') }}
```

**Playbook: template-replace.yml**
```yaml
---
- name: Replace filter example
  hosts: all
  
  vars:
    message: Hello World
  
  tasks:
    - name: Deploy replace template
      ansible.builtin.template:
        src: templates/replace.j2
        dest: /tmp/replace.txt
        mode: '0644'
```

**Explanation:**
- `| replace(old, new)` substitutes text
- First argument: text to find
- Second argument: replacement text
- Case-sensitive by default

---

## Solution 08 — Join Filter

**Template: templates/join.j2**
```jinja2
Packages: {{ packages | join(', ') }}
```

**Playbook: template-join.yml**
```yaml
---
- name: Join filter example
  hosts: all
  
  vars:
    packages:
      - httpd
      - nginx
      - firewalld
  
  tasks:
    - name: Deploy join template
      ansible.builtin.template:
        src: templates/join.j2
        dest: /tmp/packages.txt
        mode: '0644'
```

**Explanation:**
- `| join()` converts list to string
- Argument is separator
- Result: "httpd, nginx, firewalld"
- Useful for creating comma-separated lists

---

## Solution 09 — Length Filter

**Template: templates/length.j2**
```jinja2
Total items: {{ items | length }}
```

**Playbook: template-length.yml**
```yaml
---
- name: Length filter example
  hosts: all
  
  vars:
    items:
      - item1
      - item2
      - item3
      - item4
      - item5
  
  tasks:
    - name: Deploy length template
      ansible.builtin.template:
        src: templates/length.j2
        dest: /tmp/length.txt
        mode: '0644'
```

**Explanation:**
- `| length` returns number of items
- Works with lists and strings
- Result: "Total items: 5"

---

## Solution 10 — Min and Max Filters

**Template: templates/minmax.j2**
```jinja2
Minimum: {{ numbers | min }}
Maximum: {{ numbers | max }}
```

**Playbook: template-minmax.yml**
```yaml
---
- name: Min and max filters
  hosts: all
  
  vars:
    numbers:
      - 10
      - 25
      - 5
      - 30
      - 15
  
  tasks:
    - name: Deploy minmax template
      ansible.builtin.template:
        src: templates/minmax.j2
        dest: /tmp/minmax.txt
        mode: '0644'
```

**Explanation:**
- `| min` returns smallest value
- `| max` returns largest value
- Works with numeric lists
- Results: 5 and 30

---

## Solution 11 — Unique Filter

**Template: templates/unique.j2**
```jinja2
Unique items: {{ items | unique | join(', ') }}
```

**Playbook: template-unique.yml**
```yaml
---
- name: Unique filter example
  hosts: all
  
  vars:
    items:
      - a
      - b
      - a
      - c
      - b
  
  tasks:
    - name: Deploy unique template
      ansible.builtin.template:
        src: templates/unique.j2
        dest: /tmp/unique.txt
        mode: '0644'
```

**Explanation:**
- `| unique` removes duplicates
- Returns list with unique items
- Can chain with other filters
- Result: "a, b, c"

---

## Solution 12 — Sort Filter

**Template: templates/sort.j2**
```jinja2
Sorted: {{ names | sort | join(', ') }}
Reverse: {{ names | sort(reverse=true) | join(', ') }}
```

**Playbook: template-sort.yml**
```yaml
---
- name: Sort filter example
  hosts: all
  
  vars:
    names:
      - charlie
      - alice
      - bob
  
  tasks:
    - name: Deploy sort template
      ansible.builtin.template:
        src: templates/sort.j2
        dest: /tmp/sort.txt
        mode: '0644'
```

**Explanation:**
- `| sort` sorts list ascending
- `sort(reverse=true)` sorts descending
- Alphabetical for strings
- Numeric for numbers

**Results:**
```
Sorted: alice, bob, charlie
Reverse: charlie, bob, alice
```

---

## Solution 13 — To JSON Filter

**Template: templates/json.j2**
```jinja2
{{ config | to_json }}
```

**Playbook: template-json.yml**
```yaml
---
- name: To JSON filter
  hosts: all
  
  vars:
    config:
      host: localhost
      port: 8080
      debug: true
  
  tasks:
    - name: Deploy JSON template
      ansible.builtin.template:
        src: templates/json.j2
        dest: /tmp/config.json
        mode: '0644'
```

**Explanation:**
- `| to_json` converts to JSON format
- Creates valid JSON output
- Useful for config files
- Handles nested structures

**Output:**
```json
{"host": "localhost", "port": 8080, "debug": true}
```

---

## Solution 14 — To YAML Filter

**Template: templates/yaml.j2**
```jinja2
{{ settings | to_yaml }}
```

**Playbook: template-yaml.yml**
```yaml
---
- name: To YAML filter
  hosts: all
  
  vars:
    settings:
      database: mysql
      cache: redis
      queue: rabbitmq
  
  tasks:
    - name: Deploy YAML template
      ansible.builtin.template:
        src: templates/yaml.j2
        dest: /tmp/settings.yaml
        mode: '0644'
```

**Explanation:**
- `| to_yaml` converts to YAML format
- Creates valid YAML output
- Preserves structure
- Useful for config files

**Output:**
```yaml
database: mysql
cache: redis
queue: rabbitmq
```

---

## Solution 15 — Multiple Filters Chained

**Template: templates/chain.j2**
```jinja2
{{ servers | select('search', 'web') | list | sort | map('upper') | join(', ') }}
```

**Playbook: template-chain.yml**
```yaml
---
- name: Chained filters
  hosts: all
  
  vars:
    servers:
      - web1
      - web2
      - db1
      - web3
  
  tasks:
    - name: Deploy chain template
      ansible.builtin.template:
        src: templates/chain.j2
        dest: /tmp/chain.txt
        mode: '0644'
```

**Explanation:**
- Filters applied left to right
- `select('search', 'web')` filters items
- `list` converts to list
- `sort` sorts alphabetically
- `map('upper')` applies upper to each
- `join(', ')` creates string

**Result:** "WEB1, WEB2, WEB3"

---

## Solution 16 — Template with Math

**Template: templates/math.j2**
```jinja2
Memory GB: {{ (memory_mb / 1024) | round(2) }}
Disk TB: {{ (disk_gb / 1024) | round(3) }}
```

**Playbook: template-math.yml**
```yaml
---
- name: Math in templates
  hosts: all
  
  vars:
    memory_mb: 2048
    disk_gb: 100
  
  tasks:
    - name: Deploy math template
      ansible.builtin.template:
        src: templates/math.j2
        dest: /tmp/math.txt
        mode: '0644'
```

**Explanation:**
- Math operations in templates
- Use parentheses for order
- `| round()` rounds decimals
- Argument is decimal places

**Results:**
```
Memory GB: 2.0
Disk TB: 0.098
```

---

## Solution 17 — Template with Hostname Manipulation

**Template: templates/hostname.j2**
```jinja2
Full: {{ inventory_hostname }}
Short: {{ inventory_hostname.split('.')[0] }}
Domain: {{ inventory_hostname.split('.')[1:] | join('.') }}
```

**Playbook: template-hostname.yml**
```yaml
---
- name: Hostname manipulation
  hosts: all
  
  tasks:
    - name: Deploy hostname template
      ansible.builtin.template:
        src: templates/hostname.j2
        dest: /tmp/hostname-parts.txt
        mode: '0644'
```

**Explanation:**
- `.split('.')` splits string into list
- `[0]` gets first element
- `[1:]` gets all except first
- `| join('.')` rejoins with dots

**Example output:**
```
Full: node1.example.com
Short: node1
Domain: example.com
```

---

## Solution 18 — Template with Conditional Content

**Template: templates/conditional.j2**
```jinja2
{% if environment == 'production' %}
Debug: false
LogLevel: error
{% else %}
Debug: true
LogLevel: debug
{% endif %}
```

**Playbook: template-conditional.yml**
```yaml
---
- name: Conditional template
  hosts: all
  
  vars:
    environment: production
  
  tasks:
    - name: Deploy conditional template
      ansible.builtin.template:
        src: templates/conditional.j2
        dest: /tmp/conditional.txt
        mode: '0644'
```

**Explanation:**
- `{% if %}` starts condition
- `{% else %}` alternative branch
- `{% endif %}` closes condition
- Different content based on variable

**Output (production):**
```
Debug: false
LogLevel: error
```

---

## Solution 19 — Template with Loop

**Template: templates/loop.j2**
```jinja2
Users:
{% for user in users %}
- {{ user }}
{% endfor %}
```

**Playbook: template-loop.yml**
```yaml
---
- name: Template with loop
  hosts: all
  
  vars:
    users:
      - alice
      - bob
      - charlie
  
  tasks:
    - name: Deploy loop template
      ansible.builtin.template:
        src: templates/loop.j2
        dest: /tmp/users.txt
        mode: '0644'
```

**Explanation:**
- `{% for %}` starts loop
- `{% endfor %}` closes loop
- Loop variable available inside
- Generates repeated content

**Output:**
```
Users:
- alice
- bob
- charlie
```

---

## Solution 20 — Complex Template

**Template: templates/services.j2**
```jinja2
Active Services:
{% for service in services %}
{% if service.enabled %}
- {{ service.name }} on port {{ service.port }}
{% endif %}
{% endfor %}
```

**Playbook: template-complex.yml**
```yaml
---
- name: Complex template
  hosts: all
  
  vars:
    services:
      - name: httpd
        port: 80
        enabled: true
      - name: nginx
        port: 8080
        enabled: false
      - name: mysql
        port: 3306
        enabled: true
  
  tasks:
    - name: Deploy complex template
      ansible.builtin.template:
        src: templates/services.j2
        dest: /tmp/active-services.txt
        mode: '0644'
```

**Explanation:**
- Combines loop and conditional
- Nested control structures
- Access dictionary keys
- Filters items dynamically

**Output:**
```
Active Services:
- httpd on port 80
- mysql on port 3306
```

---

## Quick Reference: Jinja2 Syntax

### Variable Substitution
```jinja2
{{ variable }}
{{ dict.key }}
{{ list[0] }}
```

### Filters
```jinja2
{{ variable | filter }}
{{ variable | filter(arg) }}
{{ variable | filter1 | filter2 }}
```

### Conditionals
```jinja2
{% if condition %}
  content
{% elif other_condition %}
  other content
{% else %}
  default content
{% endif %}
```

### Loops
```jinja2
{% for item in list %}
  {{ item }}
{% endfor %}
```

### Comments
```jinja2
{# This is a comment #}
```

---

## Common Filters

### String Filters
```jinja2
{{ string | upper }}           # UPPERCASE
{{ string | lower }}           # lowercase
{{ string | capitalize }}      # Capitalize
{{ string | title }}           # Title Case
{{ string | replace('old', 'new') }}
{{ string | trim }}            # Remove whitespace
```

### List Filters
```jinja2
{{ list | join(', ') }}        # Join with separator
{{ list | length }}            # Count items
{{ list | first }}             # First item
{{ list | last }}              # Last item
{{ list | unique }}            # Remove duplicates
{{ list | sort }}              # Sort ascending
{{ list | sort(reverse=true) }} # Sort descending
{{ list | min }}               # Minimum value
{{ list | max }}               # Maximum value
```

### Default and Optional
```jinja2
{{ variable | default('default') }}
{{ variable | default(omit) }}
{{ dict | default({}) }}
```

### Type Conversion
```jinja2
{{ value | int }}              # Convert to integer
{{ value | float }}            # Convert to float
{{ value | string }}           # Convert to string
{{ value | bool }}             # Convert to boolean
```

### Format Conversion
```jinja2
{{ dict | to_json }}           # Convert to JSON
{{ dict | to_yaml }}           # Convert to YAML
{{ dict | to_nice_json }}      # Pretty JSON
{{ dict | to_nice_yaml }}      # Pretty YAML
```

### Math Filters
```jinja2
{{ number | abs }}             # Absolute value
{{ number | round }}           # Round to integer
{{ number | round(2) }}        # Round to 2 decimals
```

---

## Best Practices

1. **Use meaningful variable names:**
   ```jinja2
   {{ server_hostname }}
   # Better than: {{ h }}
   ```

2. **Provide defaults for optional variables:**
   ```jinja2
   {{ custom_port | default(80) }}
   ```

3. **Chain filters for readability:**
   ```jinja2
   {{ servers | select('match', 'web.*') | list | sort }}
   ```

4. **Use whitespace control:**
   ```jinja2
   {%- if condition -%}
   content
   {%- endif -%}
   ```

5. **Comment complex logic:**
   ```jinja2
   {# Filter web servers and sort by name #}
   {% for server in servers | select('search', 'web') | sort %}
   ```

6. **Validate template syntax:**
   ```bash
   ansible-playbook playbook.yml --syntax-check
   ```

---

## Tips for RHCE Exam

1. **Create templates directory:**
   ```bash
   mkdir -p /home/student/ansible/templates
   ```

2. **Test templates:**
   ```bash
   ansible-playbook playbook.yml --check
   ```

3. **Verify output:**
   ```bash
   ansible all -m command -a "cat /path/to/file"
   ```

4. **Common mistakes:**
   - Wrong template path
   - Missing `templates/` directory
   - Syntax errors in template
   - Undefined variables

5. **Debug templates:**
   ```yaml
   - template:
       src: template.j2
       dest: /tmp/debug.txt
   - command: cat /tmp/debug.txt
     register: result
   - debug:
       var: result.stdout_lines
   ```

6. **Check available variables:**
   ```bash
   ansible hostname -m setup
   ansible hostname -m debug -a "var=hostvars[inventory_hostname]"
   ```

---

Good luck with your RHCE exam preparation! 🚀

Master Jinja2 templates - they're essential for creating dynamic configuration files.
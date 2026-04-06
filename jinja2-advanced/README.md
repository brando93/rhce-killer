# RHCE Killer — Jinja2 Advanced
## EX294: Advanced Template Techniques

---

> **Advanced Exam: Template Mastery**
> This exam teaches you advanced Jinja2 techniques in Ansible.
> Master complex filters, tests, macros, and template inheritance.
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

---

## Instructions

- All work must be done as user **student** on **control.example.com**
- All playbooks and templates must be created under `/home/student/ansible/`
- Templates should be in `/home/student/ansible/templates/` directory
- Playbooks must run without errors
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** jinja2-basics, variables-and-facts, conditionals-and-when

You should know:
- Basic Jinja2 syntax
- Variable substitution
- Basic filters
- Conditionals and loops in templates

---

## Tasks

### Task 01 — Regex Replace Filter (15 pts)

Create a playbook `/home/student/ansible/template-regex.yml` that:
- Runs on **all managed nodes**
- Defines variable: `ip_address: 192.168.1.100`
- Creates template `regex.j2` that replaces dots with dashes using regex
- Result should be: `192-168-1-100`
- Deploys to `/tmp/regex.txt`

**Requirements:**
- Use `| regex_replace()` filter
- Pattern: `\.` (escaped dot)
- Replacement: `-`
- Create template file

---

### Task 02 — Regex Search Filter (15 pts)

Create a playbook `/home/student/ansible/template-search.yml` that:
- Runs on **all managed nodes**
- Defines list: `logs: ['ERROR: failed', 'INFO: success', 'ERROR: timeout']`
- Creates template `search.j2` that filters only ERROR lines
- Uses `regex_search()` or `select()` with regex
- Deploys to `/tmp/errors.txt`

**Requirements:**
- Use `select('match', 'ERROR.*')` or similar
- Filter list items
- Display only error messages
- Create template file

---

### Task 03 — Map Filter (18 pts)

Create a playbook `/home/student/ansible/template-map.yml` that:
- Runs on **all managed nodes**
- Defines list of dicts:
  ```yaml
  users:
    - name: alice
      uid: 1001
    - name: bob
      uid: 1002
  ```
- Creates template `map.j2` that extracts only names using `map`
- Result: `alice, bob`
- Deploys to `/tmp/names.txt`

**Requirements:**
- Use `| map(attribute='name')` filter
- Extract specific attribute
- Join with comma
- Create template file

---

### Task 04 — Selectattr Filter (18 pts)

Create a playbook `/home/student/ansible/template-selectattr.yml` that:
- Runs on **all managed nodes**
- Defines list:
  ```yaml
  servers:
    - name: web1
      type: web
      active: true
    - name: db1
      type: database
      active: false
    - name: web2
      type: web
      active: true
  ```
- Creates template that selects only active web servers
- Uses `selectattr()` filter
- Deploys to `/tmp/active-web.txt`

**Requirements:**
- Use `selectattr('type', 'equalto', 'web')`
- Chain with `selectattr('active')`
- Display server names
- Create template file

---

### Task 05 — Rejectattr Filter (15 pts)

Create a playbook `/home/student/ansible/template-rejectattr.yml` that:
- Runs on **all managed nodes**
- Uses same servers list as Task 04
- Creates template that excludes inactive servers
- Uses `rejectattr()` filter
- Deploys to `/tmp/active-servers.txt`

**Requirements:**
- Use `rejectattr('active', 'equalto', false)`
- Or `rejectattr('active', 'false')`
- Display remaining servers
- Create template file

---

### Task 06 — Groupby Filter (20 pts)

Create a playbook `/home/student/ansible/template-groupby.yml` that:
- Runs on **all managed nodes**
- Defines list:
  ```yaml
  servers:
    - name: web1
      type: web
    - name: web2
      type: web
    - name: db1
      type: database
  ```
- Creates template that groups servers by type
- Uses `groupby()` filter
- Deploys to `/tmp/grouped.txt`

**Requirements:**
- Use `| groupby('type')`
- Loop over groups
- Display group name and items
- Create template file

---

### Task 07 — Combine Filter (18 pts)

Create a playbook `/home/student/ansible/template-combine.yml` that:
- Runs on **all managed nodes**
- Defines two dictionaries:
  ```yaml
  defaults:
    host: localhost
    port: 80
    debug: false
  custom:
    port: 8080
    ssl: true
  ```
- Creates template that merges them using `combine`
- Custom values override defaults
- Deploys to `/tmp/config.txt`

**Requirements:**
- Use `| combine()` filter
- Merge dictionaries
- Show final configuration
- Create template file

---

### Task 08 — Ternary Filter (15 pts)

Create a playbook `/home/student/ansible/template-ternary.yml` that:
- Runs on **all managed nodes**
- Defines variable: `is_production: true`
- Creates template using ternary operator:
  ```jinja2
  Environment: {{ is_production | ternary('production', 'development') }}
  ```
- Deploys to `/tmp/environment.txt`

**Requirements:**
- Use `| ternary()` filter
- First arg: value if true
- Second arg: value if false
- Create template file

---

### Task 09 — Zip Filter (18 pts)

Create a playbook `/home/student/ansible/template-zip.yml` that:
- Runs on **all managed nodes**
- Defines two lists:
  ```yaml
  names: ['alice', 'bob', 'charlie']
  ages: [25, 30, 35]
  ```
- Creates template that pairs them using `zip`
- Format: `alice: 25, bob: 30, charlie: 35`
- Deploys to `/tmp/users-ages.txt`

**Requirements:**
- Use `| zip()` filter
- Loop over paired items
- Access with `item.0` and `item.1`
- Create template file

---

### Task 10 — Flatten Filter (15 pts)

Create a playbook `/home/student/ansible/template-flatten.yml` that:
- Runs on **all managed nodes**
- Defines nested list:
  ```yaml
  nested:
    - [1, 2, 3]
    - [4, 5]
    - [6]
  ```
- Creates template that flattens to single list
- Uses `flatten` filter
- Deploys to `/tmp/flat.txt`

**Requirements:**
- Use `| flatten` filter
- Convert nested to flat list
- Display all items
- Create template file

---

### Task 11 — Batch Filter (18 pts)

Create a playbook `/home/student/ansible/template-batch.yml` that:
- Runs on **all managed nodes**
- Defines list: `items: [1, 2, 3, 4, 5, 6, 7, 8]`
- Creates template that groups into batches of 3
- Uses `batch()` filter
- Deploys to `/tmp/batches.txt`

**Requirements:**
- Use `| batch(3)` filter
- Loop over batches
- Display each batch
- Create template file

---

### Task 12 — Slice Filter (18 pts)

Create a playbook `/home/student/ansible/template-slice.yml` that:
- Runs on **all managed nodes**
- Defines list: `servers: ['web1', 'web2', 'web3', 'web4', 'web5', 'web6']`
- Creates template that divides into 3 equal groups
- Uses `slice()` filter
- Deploys to `/tmp/slices.txt`

**Requirements:**
- Use `| slice(3)` filter
- Distribute evenly
- Display each slice
- Create template file

---

### Task 13 — Custom Tests (20 pts)

Create a playbook `/home/student/ansible/template-tests.yml` that:
- Runs on **all managed nodes**
- Defines variable: `port: 80`
- Creates template using tests:
  ```jinja2
  {% if port is number %}
  Port is numeric: {{ port }}
  {% endif %}
  {% if port is even %}
  Port is even
  {% endif %}
  ```
- Deploys to `/tmp/tests.txt`

**Requirements:**
- Use `is number` test
- Use `is even` test
- Use `is odd` test
- Create template file

---

### Task 14 — Set Variables in Template (20 pts)

Create a playbook `/home/student/ansible/template-set.yml` that:
- Runs on **all managed nodes**
- Creates template that:
  - Sets variable inside template using `{% set %}`
  - Calculates total from list
  - Uses the variable multiple times
- Deploys to `/tmp/calculated.txt`

**Requirements:**
- Use `{% set variable = value %}`
- Perform calculations
- Reuse set variables
- Create template file

---

### Task 15 — Macro Definition (22 pts)

Create a playbook `/home/student/ansible/template-macro.yml` that:
- Runs on **all managed nodes**
- Creates template with macro:
  ```jinja2
  {% macro user_info(name, uid) %}
  User: {{ name }} (UID: {{ uid }})
  {% endmacro %}
  ```
- Calls macro multiple times with different arguments
- Deploys to `/tmp/macro.txt`

**Requirements:**
- Define macro with `{% macro %}`
- Accept parameters
- Call macro multiple times
- Create template file

---

### Task 16 — Include Template (20 pts)

Create a playbook `/home/student/ansible/template-include.yml` that:
- Runs on **all managed nodes**
- Creates two templates:
  - `header.j2`: Contains header text
  - `main-include.j2`: Includes header using `{% include %}`
- Deploys to `/tmp/included.txt`

**Requirements:**
- Create separate header template
- Use `{% include 'header.j2' %}`
- Main template includes header
- Create both template files

---

### Task 17 — Loop with Index (18 pts)

Create a playbook `/home/student/ansible/template-loop-index.yml` that:
- Runs on **all managed nodes**
- Defines list: `items: ['first', 'second', 'third']`
- Creates template that shows index and item:
  ```jinja2
  {% for item in items %}
  {{ loop.index }}: {{ item }}
  {% endfor %}
  ```
- Deploys to `/tmp/indexed.txt`

**Requirements:**
- Use `loop.index` (1-based)
- Or `loop.index0` (0-based)
- Display position and value
- Create template file

---

### Task 18 — Loop with First/Last (18 pts)

Create a playbook `/home/student/ansible/template-loop-special.yml` that:
- Runs on **all managed nodes**
- Creates template that:
  - Marks first item with "START"
  - Marks last item with "END"
  - Uses `loop.first` and `loop.last`
- Deploys to `/tmp/marked.txt`

**Requirements:**
- Use `{% if loop.first %}`
- Use `{% if loop.last %}`
- Mark special items
- Create template file

---

### Task 19 — Whitespace Control (20 pts)

Create a playbook `/home/student/ansible/template-whitespace.yml` that:
- Runs on **all managed nodes**
- Creates template with whitespace control:
  ```jinja2
  {%- for item in items -%}
  {{ item }}
  {%- endfor -%}
  ```
- Removes extra blank lines
- Deploys to `/tmp/compact.txt`

**Requirements:**
- Use `{%-` to strip before
- Use `-%}` to strip after
- Control whitespace
- Create template file

---

### Task 20 — Complex Multi-Level Template (25 pts)

Create a playbook `/home/student/ansible/template-complex.yml` that:
- Runs on **all managed nodes**
- Defines complex data structure:
  ```yaml
  infrastructure:
    production:
      web:
        - name: web1
          ip: 10.0.1.10
        - name: web2
          ip: 10.0.1.11
      database:
        - name: db1
          ip: 10.0.2.10
    staging:
      web:
        - name: web-staging
          ip: 10.0.3.10
  ```
- Creates template that:
  - Loops through environments
  - Loops through server types
  - Loops through servers
  - Formats as structured output
- Deploys to `/tmp/infrastructure.txt`

**Requirements:**
- Use nested loops
- Access nested dictionaries
- Format output clearly
- Create template file

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Regex Replace | 15 |
| 02 | Regex Search | 15 |
| 03 | Map Filter | 18 |
| 04 | Selectattr Filter | 18 |
| 05 | Rejectattr Filter | 15 |
| 06 | Groupby Filter | 20 |
| 07 | Combine Filter | 18 |
| 08 | Ternary Filter | 15 |
| 09 | Zip Filter | 18 |
| 10 | Flatten Filter | 15 |
| 11 | Batch Filter | 18 |
| 12 | Slice Filter | 18 |
| 13 | Custom Tests | 20 |
| 14 | Set Variables | 20 |
| 15 | Macro Definition | 22 |
| 16 | Include Template | 20 |
| 17 | Loop with Index | 18 |
| 18 | Loop First/Last | 18 |
| 19 | Whitespace Control | 20 |
| 20 | Complex Multi-Level | 25 |
| **Total** | | **366** |

**Passing score: 70% (256/366 points)**

---

## When you finish

```bash
bash /home/student/exams/jinja2-advanced/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Regex Replace Filter

**Template: templates/regex.j2**
```jinja2
{{ ip_address | regex_replace('\.', '-') }}
```

**Playbook: template-regex.yml**
```yaml
---
- name: Regex replace example
  hosts: all
  
  vars:
    ip_address: 192.168.1.100
  
  tasks:
    - name: Deploy regex template
      ansible.builtin.template:
        src: templates/regex.j2
        dest: /tmp/regex.txt
        mode: '0644'
```

**Explanation:**
- `regex_replace(pattern, replacement)` uses regex
- `\.` matches literal dot (escaped)
- `-` is replacement character
- Result: `192-168-1-100`

**Common patterns:**
```jinja2
{{ text | regex_replace('[^a-zA-Z0-9]', '') }}  # Remove special chars
{{ text | regex_replace('\s+', ' ') }}          # Normalize whitespace
{{ text | regex_replace('^(.{10}).*', '\1') }}  # Truncate to 10 chars
```

---

## Solution 02 — Regex Search Filter

**Template: templates/search.j2**
```jinja2
{% for log in logs | select('match', 'ERROR.*') %}
{{ log }}
{% endfor %}
```

**Playbook: template-search.yml**
```yaml
---
- name: Regex search example
  hosts: all
  
  vars:
    logs:
      - 'ERROR: failed'
      - 'INFO: success'
      - 'ERROR: timeout'
  
  tasks:
    - name: Deploy search template
      ansible.builtin.template:
        src: templates/search.j2
        dest: /tmp/errors.txt
        mode: '0644'
```

**Explanation:**
- `select('match', pattern)` filters list
- `match` requires full string match
- `search` matches anywhere in string
- Returns filtered list

**Alternative:**
```jinja2
{% for log in logs if log is match('ERROR.*') %}
{{ log }}
{% endfor %}
```

---

## Solution 03 — Map Filter

**Template: templates/map.j2**
```jinja2
{{ users | map(attribute='name') | join(', ') }}
```

**Playbook: template-map.yml**
```yaml
---
- name: Map filter example
  hosts: all
  
  vars:
    users:
      - name: alice
        uid: 1001
      - name: bob
        uid: 1002
  
  tasks:
    - name: Deploy map template
      ansible.builtin.template:
        src: templates/map.j2
        dest: /tmp/names.txt
        mode: '0644'
```

**Explanation:**
- `map(attribute='key')` extracts attribute from dicts
- Returns list of values
- Useful for extracting specific fields
- Can chain with other filters

**Other map uses:**
```jinja2
{{ numbers | map('abs') }}              # Apply function
{{ items | map(attribute='name') | list }}  # Convert to list
```

---

## Solution 04 — Selectattr Filter

**Template: templates/selectattr.j2**
```jinja2
Active Web Servers:
{% for server in servers | selectattr('type', 'equalto', 'web') | selectattr('active') %}
- {{ server.name }}
{% endfor %}
```

**Playbook: template-selectattr.yml**
```yaml
---
- name: Selectattr filter example
  hosts: all
  
  vars:
    servers:
      - name: web1
        type: web
        active: true
      - name: db1
        type: database
        active: false
      - name: web2
        type: web
        active: true
  
  tasks:
    - name: Deploy selectattr template
      ansible.builtin.template:
        src: templates/selectattr.j2
        dest: /tmp/active-web.txt
        mode: '0644'
```

**Explanation:**
- `selectattr(attribute, test, value)` filters dicts
- First filter: type equals 'web'
- Second filter: active is true
- Chains multiple conditions
- Returns filtered list

**Tests available:**
- `equalto`: equals value
- `match`: regex match
- `defined`: attribute exists
- `none`: attribute is None

---

## Solution 05 — Rejectattr Filter

**Template: templates/rejectattr.j2**
```jinja2
Active Servers:
{% for server in servers | rejectattr('active', 'equalto', false) %}
- {{ server.name }} ({{ server.type }})
{% endfor %}
```

**Playbook: template-rejectattr.yml**
```yaml
---
- name: Rejectattr filter example
  hosts: all
  
  vars:
    servers:
      - name: web1
        type: web
        active: true
      - name: db1
        type: database
        active: false
      - name: web2
        type: web
        active: true
  
  tasks:
    - name: Deploy rejectattr template
      ansible.builtin.template:
        src: templates/rejectattr.j2
        dest: /tmp/active-servers.txt
        mode: '0644'
```

**Explanation:**
- `rejectattr()` is opposite of `selectattr()`
- Excludes items matching condition
- Same syntax as selectattr
- Useful for filtering out items

---

## Solution 06 — Groupby Filter

**Template: templates/groupby.j2**
```jinja2
Servers by Type:
{% for type, group in servers | groupby('type') %}

{{ type | upper }}:
{% for server in group %}
  - {{ server.name }}
{% endfor %}
{% endfor %}
```

**Playbook: template-groupby.yml**
```yaml
---
- name: Groupby filter example
  hosts: all
  
  vars:
    servers:
      - name: web1
        type: web
      - name: web2
        type: web
      - name: db1
        type: database
  
  tasks:
    - name: Deploy groupby template
      ansible.builtin.template:
        src: templates/groupby.j2
        dest: /tmp/grouped.txt
        mode: '0644'
```

**Explanation:**
- `groupby(attribute)` groups by attribute value
- Returns list of (key, group) tuples
- Loop unpacks to key and group
- Group contains matching items
- Useful for categorization

---

## Solution 07 — Combine Filter

**Template: templates/combine.j2**
```jinja2
{% set final_config = defaults | combine(custom) %}
Configuration:
{% for key, value in final_config.items() %}
{{ key }}: {{ value }}
{% endfor %}
```

**Playbook: template-combine.yml**
```yaml
---
- name: Combine filter example
  hosts: all
  
  vars:
    defaults:
      host: localhost
      port: 80
      debug: false
    custom:
      port: 8080
      ssl: true
  
  tasks:
    - name: Deploy combine template
      ansible.builtin.template:
        src: templates/combine.j2
        dest: /tmp/config.txt
        mode: '0644'
```

**Explanation:**
- `combine()` merges dictionaries
- Later values override earlier
- Non-overlapping keys preserved
- Useful for config merging

**Deep merge:**
```jinja2
{{ dict1 | combine(dict2, recursive=True) }}
```

---

## Solution 08 — Ternary Filter

**Template: templates/ternary.j2**
```jinja2
Environment: {{ is_production | ternary('production', 'development') }}
Debug: {{ is_production | ternary('false', 'true') }}
```

**Playbook: template-ternary.yml**
```yaml
---
- name: Ternary filter example
  hosts: all
  
  vars:
    is_production: true
  
  tasks:
    - name: Deploy ternary template
      ansible.builtin.template:
        src: templates/ternary.j2
        dest: /tmp/environment.txt
        mode: '0644'
```

**Explanation:**
- `ternary(true_val, false_val)` is inline if/else
- First arg returned if true
- Second arg returned if false
- Cleaner than if/else for simple cases

**Comparison:**
```jinja2
# Ternary
{{ condition | ternary('yes', 'no') }}

# If/else
{% if condition %}yes{% else %}no{% endif %}
```

---

## Solution 09 — Zip Filter

**Template: templates/zip.j2**
```jinja2
Users and Ages:
{% for name, age in names | zip(ages) %}
{{ name }}: {{ age }}
{% endfor %}
```

**Playbook: template-zip.yml**
```yaml
---
- name: Zip filter example
  hosts: all
  
  vars:
    names:
      - alice
      - bob
      - charlie
    ages:
      - 25
      - 30
      - 35
  
  tasks:
    - name: Deploy zip template
      ansible.builtin.template:
        src: templates/zip.j2
        dest: /tmp/users-ages.txt
        mode: '0644'
```

**Explanation:**
- `zip()` pairs items from multiple lists
- Like Python's zip function
- Stops at shortest list
- Returns tuples

**Alternative access:**
```jinja2
{% for pair in names | zip(ages) %}
{{ pair[0] }}: {{ pair[1] }}
{% endfor %}
```

---

## Solution 10 — Flatten Filter

**Template: templates/flatten.j2**
```jinja2
Flattened List:
{% for item in nested | flatten %}
{{ item }}
{% endfor %}
```

**Playbook: template-flatten.yml**
```yaml
---
- name: Flatten filter example
  hosts: all
  
  vars:
    nested:
      - [1, 2, 3]
      - [4, 5]
      - [6]
  
  tasks:
    - name: Deploy flatten template
      ansible.builtin.template:
        src: templates/flatten.j2
        dest: /tmp/flat.txt
        mode: '0644'
```

**Explanation:**
- `flatten` converts nested lists to flat
- Removes one level of nesting
- Use `flatten(levels=2)` for deeper
- Useful for combining lists

**Deep flatten:**
```jinja2
{{ deeply_nested | flatten(levels=3) }}
```

---

## Solution 11 — Batch Filter

**Template: templates/batch.j2**
```jinja2
Batches of 3:
{% for batch in items | batch(3) %}
Batch {{ loop.index }}: {{ batch | join(', ') }}
{% endfor %}
```

**Playbook: template-batch.yml**
```yaml
---
- name: Batch filter example
  hosts: all
  
  vars:
    items: [1, 2, 3, 4, 5, 6, 7, 8]
  
  tasks:
    - name: Deploy batch template
      ansible.builtin.template:
        src: templates/batch.j2
        dest: /tmp/batches.txt
        mode: '0644'
```

**Explanation:**
- `batch(n)` groups items into batches of n
- Last batch may be smaller
- Returns list of lists
- Useful for pagination

**With fill value:**
```jinja2
{{ items | batch(3, fill_with='X') }}
# Fills incomplete batches
```

---

## Solution 12 — Slice Filter

**Template: templates/slice.j2**
```jinja2
Divided into 3 groups:
{% for group in servers | slice(3) %}
Group {{ loop.index }}:
{% for server in group %}
  - {{ server }}
{% endfor %}
{% endfor %}
```

**Playbook: template-slice.yml**
```yaml
---
- name: Slice filter example
  hosts: all
  
  vars:
    servers:
      - web1
      - web2
      - web3
      - web4
      - web5
      - web6
  
  tasks:
    - name: Deploy slice template
      ansible.builtin.template:
        src: templates/slice.j2
        dest: /tmp/slices.txt
        mode: '0644'
```

**Explanation:**
- `slice(n)` divides into n groups
- Distributes evenly
- Different from batch (which uses size)
- Useful for load balancing

---

## Solution 13 — Custom Tests

**Template: templates/tests.j2**
```jinja2
{% if port is number %}
Port is numeric: {{ port }}
{% endif %}

{% if port is even %}
Port is even
{% endif %}

{% if port is divisibleby(10) %}
Port is divisible by 10
{% endif %}
```

**Playbook: template-tests.yml**
```yaml
---
- name: Custom tests example
  hosts: all
  
  vars:
    port: 80
  
  tasks:
    - name: Deploy tests template
      ansible.builtin.template:
        src: templates/tests.j2
        dest: /tmp/tests.txt
        mode: '0644'
```

**Explanation:**
- Tests check conditions
- Used with `is` keyword
- Return boolean
- Many built-in tests available

**Common tests:**
```jinja2
{% if var is defined %}
{% if var is undefined %}
{% if var is none %}
{% if var is number %}
{% if var is string %}
{% if var is even %}
{% if var is odd %}
{% if var is divisibleby(3) %}
```

---

## Solution 14 — Set Variables in Template

**Template: templates/calculated.j2**
```jinja2
{% set numbers = [10, 20, 30, 40, 50] %}
{% set total = numbers | sum %}
{% set average = (total / (numbers | length)) | round(2) %}

Numbers: {{ numbers | join(', ') }}
Total: {{ total }}
Average: {{ average }}
Count: {{ numbers | length }}
```

**Playbook: template-set.yml**
```yaml
---
- name: Set variables example
  hosts: all
  
  tasks:
    - name: Deploy set template
      ansible.builtin.template:
        src: templates/calculated.j2
        dest: /tmp/calculated.txt
        mode: '0644'
```

**Explanation:**
- `{% set var = value %}` creates template variable
- Scope limited to template
- Can perform calculations
- Reusable within template

---

## Solution 15 — Macro Definition

**Template: templates/macro.j2**
```jinja2
{% macro user_info(name, uid) %}
User: {{ name }} (UID: {{ uid }})
{% endmacro %}

System Users:
{{ user_info('alice', 1001) }}
{{ user_info('bob', 1002) }}
{{ user_info('charlie', 1003) }}
```

**Playbook: template-macro.yml**
```yaml
---
- name: Macro example
  hosts: all
  
  tasks:
    - name: Deploy macro template
      ansible.builtin.template:
        src: templates/macro.j2
        dest: /tmp/macro.txt
        mode: '0644'
```

**Explanation:**
- `{% macro name(params) %}` defines reusable block
- Like a function in programming
- Can accept parameters
- Call with `{{ macro_name(args) }}`
- Reduces duplication

---

## Solution 16 — Include Template

**Template: templates/header.j2**
```jinja2
=================================
    System Configuration
=================================
```

**Template: templates/main-include.j2**
```jinja2
{% include 'header.j2' %}

Server: {{ inventory_hostname }}
IP: {{ ansible_default_ipv4.address }}
```

**Playbook: template-include.yml**
```yaml
---
- name: Include template example
  hosts: all
  
  tasks:
    - name: Deploy include template
      ansible.builtin.template:
        src: templates/main-include.j2
        dest: /tmp/included.txt
        mode: '0644'
```

**Explanation:**
- `{% include 'file.j2' %}` inserts another template
- Path relative to templates directory
- Included template processed first
- Useful for headers/footers
- Promotes reusability

---

## Solution 17 — Loop with Index

**Template: templates/indexed.j2**
```jinja2
Items with Index:
{% for item in items %}
{{ loop.index }}: {{ item }}
{% endfor %}

Zero-based Index:
{% for item in items %}
{{ loop.index0 }}: {{ item }}
{% endfor %}
```

**Playbook: template-loop-index.yml**
```yaml
---
- name: Loop index example
  hosts: all
  
  vars:
    items:
      - first
      - second
      - third
  
  tasks:
    - name: Deploy indexed template
      ansible.builtin.template:
        src: templates/indexed.j2
        dest: /tmp/indexed.txt
        mode: '0644'
```

**Explanation:**
- `loop.index` is 1-based counter
- `loop.index0` is 0-based counter
- Available inside for loops
- Useful for numbering

**Other loop variables:**
```jinja2
{{ loop.first }}      # True on first iteration
{{ loop.last }}       # True on last iteration
{{ loop.length }}     # Total iterations
{{ loop.revindex }}   # Reverse index (1-based)
{{ loop.revindex0 }}  # Reverse index (0-based)
```

---

## Solution 18 — Loop with First/Last

**Template: templates/marked.j2**
```jinja2
{% for item in ['alpha', 'beta', 'gamma'] %}
{% if loop.first %}START -> {% endif %}{{ item }}{% if loop.last %} <- END{% endif %}
{% endfor %}
```

**Playbook: template-loop-special.yml**
```yaml
---
- name: Loop first/last example
  hosts: all
  
  tasks:
    - name: Deploy marked template
      ansible.builtin.template:
        src: templates/marked.j2
        dest: /tmp/marked.txt
        mode: '0644'
```

**Explanation:**
- `loop.first` true on first iteration
- `loop.last` true on last iteration
- Useful for special formatting
- Add separators, markers, etc.

---

## Solution 19 — Whitespace Control

**Template: templates/compact.j2**
```jinja2
{%- for item in ['a', 'b', 'c'] -%}
{{ item }}
{%- endfor -%}
```

**Playbook: template-whitespace.yml**
```yaml
---
- name: Whitespace control example
  hosts: all
  
  tasks:
    - name: Deploy compact template
      ansible.builtin.template:
        src: templates/compact.j2
        dest: /tmp/compact.txt
        mode: '0644'
```

**Explanation:**
- `{%-` strips whitespace before
- `-%}` strips whitespace after
- Controls blank lines
- Creates compact output

**Without control:**
```
a

b

c
```

**With control:**
```
abc
```

---

## Solution 20 — Complex Multi-Level Template

**Template: templates/infrastructure.j2**
```jinja2
Infrastructure Overview
=======================

{% for env_name, env_data in infrastructure.items() %}
Environment: {{ env_name | upper }}
{% for type_name, servers in env_data.items() %}
  Type: {{ type_name | capitalize }}
{% for server in servers %}
    - {{ server.name }}: {{ server.ip }}
{% endfor %}
{% endfor %}

{% endfor %}
```

**Playbook: template-complex.yml**
```yaml
---
- name: Complex template example
  hosts: all
  
  vars:
    infrastructure:
      production:
        web:
          - name: web1
            ip: 10.0.1.10
          - name: web2
            ip: 10.0.1.11
        database:
          - name: db1
            ip: 10.0.2.10
      staging:
        web:
          - name: web-staging
            ip: 10.0.3.10
  
  tasks:
    - name: Deploy complex template
      ansible.builtin.template:
        src: templates/infrastructure.j2
        dest: /tmp/infrastructure.txt
        mode: '0644'
```

**Explanation:**
- Three levels of nesting
- `.items()` for dictionary iteration
- Access nested data structures
- Format with indentation
- Real-world infrastructure example

---

## Quick Reference: Advanced Filters

### Regex Filters
```jinja2
{{ text | regex_replace('pattern', 'replacement') }}
{{ text | regex_search('pattern') }}
{{ text | regex_findall('pattern') }}
```

### List Manipulation
```jinja2
{{ list | map(attribute='key') }}
{{ list | selectattr('key', 'test', value) }}
{{ list | rejectattr('key', 'test', value) }}
{{ list | groupby('attribute') }}
{{ list | flatten }}
{{ list | batch(3) }}
{{ list | slice(3) }}
{{ list1 | zip(list2) }}
```

### Dictionary Operations
```jinja2
{{ dict1 | combine(dict2) }}
{{ dict | dict2items }}
{{ list | items2dict }}
```

### Conditional
```jinja2
{{ condition | ternary('true_val', 'false_val') }}
```

---

## Quick Reference: Tests

### Type Tests
```jinja2
{% if var is string %}
{% if var is number %}
{% if var is boolean %}
{% if var is mapping %}  {# dict #}
{% if var is sequence %}  {# list #}
```

### Value Tests
```jinja2
{% if var is defined %}
{% if var is undefined %}
{% if var is none %}
{% if var is even %}
{% if var is odd %}
{% if var is divisibleby(n) %}
```

### String Tests
```jinja2
{% if var is match('pattern') %}
{% if var is search('pattern') %}
{% if var is lower %}
{% if var is upper %}
```

---

## Quick Reference: Loop Variables

```jinja2
{{ loop.index }}      # 1, 2, 3, ...
{{ loop.index0 }}     # 0, 1, 2, ...
{{ loop.revindex }}   # ..., 3, 2, 1
{{ loop.revindex0 }}  # ..., 2, 1, 0
{{ loop.first }}      # True on first
{{ loop.last }}       # True on last
{{ loop.length }}     # Total iterations
{{ loop.cycle('odd', 'even') }}  # Alternate values
```

---

## Best Practices

1. **Use meaningful macro names:**
   ```jinja2
   {% macro format_user(name, uid) %}
   ```

2. **Control whitespace for clean output:**
   ```jinja2
   {%- for item in list -%}
   ```

3. **Use set for complex calculations:**
   ```jinja2
   {% set result = (value * 1.1) | round(2) %}
   ```

4. **Group related filters:**
   ```jinja2
   {{ servers | selectattr('active') | map(attribute='name') | sort }}
   ```

5. **Comment complex logic:**
   ```jinja2
   {# Filter active web servers and sort by name #}
   ```

6. **Test templates incrementally:**
   - Start simple
   - Add complexity gradually
   - Test after each addition

---

## Tips for RHCE Exam

1. **Know filter syntax:**
   ```bash
   ansible-doc -t filter regex_replace
   ```

2. **Test regex patterns:**
   ```python
   python3 -c "import re; print(re.sub(r'\.', '-', '192.168.1.1'))"
   ```

3. **Debug template output:**
   ```yaml
   - template:
       src: test.j2
       dest: /tmp/test.txt
   - command: cat /tmp/test.txt
     register: output
   - debug:
       var: output.stdout_lines
   ```

4. **Common mistakes:**
   - Wrong filter syntax
   - Missing `| list` after select/reject
   - Incorrect regex escaping
   - Forgetting to close macros

5. **Verify complex templates:**
   ```bash
   ansible-playbook playbook.yml --check --diff
   ```

---

Good luck with your RHCE exam preparation! 🚀

Master advanced Jinja2 - it's essential for creating sophisticated, dynamic configurations.
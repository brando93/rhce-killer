# RHCE Killer — Data Manipulation & Filters
## EX294: Transforming Facts and Inventory into Deliverables

---

> **Fundamentals Exam: Data Shaping**
> This exam drills the bridge between data sources (facts, magic variables,
> inventory) and exam deliverables (config files, reports, /etc/hosts).
> Master the filter chains the real EX294 reuses task after task.
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
- All playbooks and files must be created under `/home/student/ansible/`
- Do **not** modify `/etc/ansible/ansible.cfg`
- Playbooks must run without errors and without prompting for passwords
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** `inventory-basics`, `playbooks-fundamentals`, `variables-and-facts`

You should know:
- How to gather facts (`ansible.builtin.setup`)
- How to access magic variables (`hostvars`, `groups`, `inventory_hostname`)
- How to read inventory variables (`group_vars/`, `host_vars/`)
- Basic playbook structure (`set_fact`, `debug`, `template`, `copy`)

---

## Tasks

### Task 01 — Memory in GB with 2 decimals (5 pts)

Create a playbook `mem-report.yml` that:
- Runs on **all managed nodes**
- Writes a file `/tmp/mem-report.txt` with one line per host:
  `node1.example.com: 1.84 GB`
- Uses the `template` module with a `.j2` file
- Computes the value as `ansible_memtotal_mb / 1024 | round(2)`

---

### Task 02 — Default filter for missing facts (5 pts)

Create a playbook `safe-report.yml` that:
- Runs on **all managed nodes**
- Writes a file `/tmp/safe-report.txt` with one line per host:
  `node1.example.com  cpu=2  arch=x86_64  serial=NONE`
- Reads `ansible_processor_vcpus`, `ansible_architecture`, and
  `ansible_product_serial`
- Applies `| default('NONE')` to every fact lookup so the template never
  fails on missing data

---

### Task 03 — Build /etc/hosts from inventory (10 pts)

Create a playbook `etc-hosts.yml` that:
- First gathers facts on **all** hosts so `hostvars` is fully populated
- Then generates `/etc/hosts` on **all managed nodes** with one line
  per host in `groups['all']`:
  `10.0.2.11  node1.example.com node1`
- Uses a template that loops over `groups['all']`
- Reads each IP from `hostvars[host].ansible_default_ipv4.address`
- File owned by root, mode 0644

---

### Task 04 — Count hosts in groups (5 pts)

Create a playbook `host-counts.yml` that:
- Runs on **localhost** only
- Uses `debug` to print a single message:
  `TOTAL: 3 hosts. MANAGED: 2 hosts. CONTROL: 1 host.`
- Uses `groups['all'] | length`, `groups['managed'] | length`, and
  `groups['control'] | length`

---

### Task 05 — Extract kernel major.minor (5 pts)

Create a playbook `kernel-version.yml` that:
- Runs on **all managed nodes**
- Uses `set_fact` to define `kernel_short` containing only the
  major.minor part of `ansible_kernel`
  (e.g. `5.14.0-362.el9.x86_64` becomes `5.14`)
- Uses `debug` to print: `node1.example.com: kernel 5.14`
- Uses the filter chain `ansible_kernel.split('.')[:2] | join('.')`

---

### Task 06 — Filter mounts above 80% usage (12 pts)

Create a playbook `mount-alert.yml` that:
- Runs on **all managed nodes**
- Writes a file `/tmp/full-mounts.txt` listing **only** mountpoints
  where used space ≥ 80% of total
- Uses `ansible_mounts` (list of dicts with `size_total` and
  `size_available` fields)
- Format per line: `node1: /var      used=8.7GB of 10.0GB (87%)  ⚠`
- The `⚠` marker appears only on lines ≥80%

---

### Task 07 — Extract CPU model name (10 pts)

Create a playbook `cpu-model.yml` that:
- Runs on **all managed nodes**
- Uses `set_fact` to define `cpu_short` containing only the CPU model:
  `Intel(R) Xeon(R) Platinum 8259CL CPU @ 2.50GHz` → `Xeon(R) Platinum 8259CL`
- Strips the manufacturer prefix and trailing speed information
- Appends one line per host to `/tmp/cpu-models.txt`:
  `node1.example.com: Xeon(R) Platinum 8259CL`
- Uses `regex_replace`, `replace`, or `split` filters

---

### Task 08 — Map filter on a list of dicts (12 pts)

Create a playbook `users-csv.yml` that:
- Runs on **localhost** only
- Defines this variable in `vars:`:
  ```yaml
  users:
    - { name: alice, uid: 2001, shell: /bin/bash }
    - { name: bob,   uid: 2002, shell: /bin/zsh }
    - { name: cleo,  uid: 2003, shell: /bin/bash }
  ```
- Writes `/tmp/usernames.csv` containing: `alice,bob,cleo`
- Writes `/tmp/usernames-sorted.csv` with names alphabetically sorted
- Uses the filter chain `users | map(attribute='name') | join(',')`

---

### Task 09 — Combine defaults with overrides (12 pts)

Create a playbook `combine-config.yml` that:
- Runs on **localhost** only
- Defines two dicts in `vars:`:
  - `defaults`: `port: 8080, workers: 4, log_level: info, ssl: false`
  - `custom`: `port: 9090, ssl: true`
- Uses `set_fact` with `defaults | combine(custom)` to produce the merged config
- Writes the result to `/tmp/app-config.json` using `to_nice_json`
- The merged config must contain `port: 9090, ssl: true, workers: 4, log_level: info`

---

### Task 10 — Build a YAML cluster snapshot (10 pts)

Create a playbook `inventory-snapshot.yml` that:
- First gathers facts on **managed** so `hostvars` is fully populated
- Then runs on **localhost** to assemble and write the snapshot
- Uses `set_fact` with a `loop` over `groups['managed']` to build a
  dict like:
  ```yaml
  cluster:
    total_hosts: 2
    total_ram_mb: 3680
    hosts:
      - name: node1.example.com
        ip: 10.0.2.11
        os: Rocky Linux 9.3
  ```
- Writes the result to `/tmp/cluster-snapshot.yml` using `to_nice_yaml`

---

### Task 11 — System report combining math and facts (15 pts)

Create a playbook `system-report.yml` that:
- Runs on **all managed nodes**
- Uses `set_fact` to pre-compute three derived values:
  - `ram_gb = ansible_memtotal_mb / 1024 | round(2)`
  - `uptime_hours = ansible_uptime_seconds / 3600 | round(1)`
  - `kernel_short = ansible_kernel.split('.')[:2] | join('.')`
- Renders a template `templates/system-report.j2` to a per-host file
  `/tmp/system-<hostname-short>.txt` containing fields:
  Hostname, IP, OS, Kernel, Architecture, CPUs, RAM, Uptime, Generated
- Every fact lookup must use `| default('NONE')`
- Template runs on the control node via `delegate_to: control.example.com`

---

### Task 12 — Filter IPs across the inventory (15 pts)

Create a playbook `all-ips.yml` that:
- First gathers facts on **all** hosts
- Then runs on **localhost** to build the IP list
- Uses `set_fact` to assemble all IPv4 addresses from every host:
  - `groups['all'] | map('extract', hostvars, 'ansible_all_ipv4_addresses')`
  - `| flatten` to collapse the list-of-lists
  - `| reject('match', '^127\.')` to drop loopback addresses
  - `| unique | sort` to clean and order
- Writes the result to `/tmp/cluster-ips.txt`, one IP per line

---

### Task 13 — Use json_query for nested data (15 pts)

Create a playbook `query-mounts.yml` that:
- Runs on **all managed nodes**
- Uses `community.general.json_query` with the JMESPath expression
  `[*].{mount: mount, size_gb_raw: size_total}` applied to `ansible_mounts`
- Post-processes each entry to convert `size_gb_raw` (bytes) to `size_gb` (GB)
- Writes a per-host file using `to_nice_yaml`:
  ```yaml
  - mount: /
    size_gb: 9.5
  - mount: /boot
    size_gb: 1.0
  ```
- Output file: `/tmp/mounts-query.yml`

---

### Task 14 — Sort by attribute and pick first (12 pts)

Create a playbook `top-talkers.yml` that:
- First gathers facts on **all** hosts
- Then runs on **localhost** to compute the winner
- Builds a list of dicts `{name, ram_mb}` by looping over `groups['managed']`
- Sorts the list by `ram_mb` descending and picks the first element using
  `sort(attribute='ram_mb', reverse=true) | first`
- Writes `/tmp/biggest-host.txt` with content:
  `biggest=node2.example.com ram=1.85GB`

---

### Task 15 — Generate a sortable CSV report (15 pts)

Create a playbook `csv-report.yml` that:
- First gathers facts on **managed** so `hostvars` is fully populated
- Then runs on **localhost** with `become: true`
- Renders a template `templates/cluster-csv.j2` to `/tmp/cluster.csv`
- Template structure: one CSV header line plus one data row per host in
  `groups['managed']`:
  ```
  hostname,ip,os,kernel,cpus,ram_gb,uptime_hours
  node1.example.com,10.0.2.11,Rocky Linux 9.3,5.14.0-362.el9.x86_64,2,1.84,2.3
  ```
- Every `hostvars[host].X` lookup must use `| default('NONE')`
- File owned by root, mode 0644

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Memory in GB (round) | 5 |
| 02 | default('NONE') pattern | 5 |
| 03 | /etc/hosts from inventory | 10 |
| 04 | Count groups (length) | 5 |
| 05 | Kernel short (split + join) | 5 |
| 06 | Mounts >80% (selectattr) | 12 |
| 07 | CPU model normalization | 10 |
| 08 | map(attribute) + join | 12 |
| 09 | combine defaults + overrides | 12 |
| 10 | to_nice_yaml output | 10 |
| 11 | System report (math + facts) | 15 |
| 12 | hostvars + flatten + reject | 15 |
| 13 | json_query / JMESPath | 15 |
| 14 | sort attribute + first | 12 |
| 15 | CSV via template (integration) | 15 |
| **Total** | | **158** |

**Passing score: 70% (111/158 points)**

---

## When you finish

```bash
bash /home/student/exams/data-manipulation-and-filters/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
>
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Memory in GB with 2 decimals

**Playbook: mem-report.yml**
```yaml
---
- name: Gather memory facts
  hosts: managed
  gather_facts: true
  tasks: []

- name: Write memory report on control
  hosts: control
  gather_facts: false

  tasks:
    - name: Render mem-report.txt
      ansible.builtin.template:
        src: templates/mem-report.j2
        dest: /tmp/mem-report.txt
        mode: '0644'
```

**Template: templates/mem-report.j2**
```jinja
{% for host in groups['managed'] %}
{{ host }}: {{ (hostvars[host].ansible_memtotal_mb / 1024) | round(2) }} GB
{% endfor %}
```

**Run:**
```bash
ansible-playbook mem-report.yml
```

**Explanation:**
- `ansible_memtotal_mb` is always a number in megabytes
- Dividing by 1024 converts to GB; `round(2)` keeps 2 decimals
- The two-play structure gathers facts on managed first, then renders
  on control so `hostvars` is fully accessible

---

## Solution 02 — Default filter for missing facts

**Playbook: safe-report.yml**
```yaml
---
- name: Render safe report
  hosts: managed
  gather_facts: true

  tasks:
    - name: Write line per host
      ansible.builtin.lineinfile:
        path: /tmp/safe-report.txt
        line: "{{ inventory_hostname }}  cpu={{ ansible_processor_vcpus | default('NONE') }}  arch={{ ansible_architecture | default('NONE') }}  serial={{ ansible_product_serial | default('NONE') }}"
        create: true
        mode: '0644'
      delegate_to: control.example.com
```

**Run:**
```bash
ansible-playbook safe-report.yml
```

**Explanation:**
- `ansible_product_serial` is missing on most virtual machines
- Without `default()` the template fails with "is undefined"
- `| default('NONE')` returns 'NONE' when the variable is undefined
- `| default('NONE', true)` also handles empty strings

---

## Solution 03 — Build /etc/hosts from inventory

**Playbook: etc-hosts.yml**
```yaml
---
- name: Gather facts everywhere
  hosts: all
  gather_facts: true
  tasks: []

- name: Generate /etc/hosts on every managed node
  hosts: managed
  become: true
  gather_facts: false

  tasks:
    - name: Deploy /etc/hosts
      ansible.builtin.template:
        src: templates/hosts.j2
        dest: /etc/hosts
        owner: root
        group: root
        mode: '0644'
```

**Template: templates/hosts.j2**
```jinja
127.0.0.1   localhost localhost.localdomain
::1         localhost localhost.localdomain

{% for host in groups['all'] %}
{{ hostvars[host].ansible_default_ipv4.address }}  {{ host }} {{ host.split('.')[0] }}
{% endfor %}
```

**Run:**
```bash
ansible-playbook etc-hosts.yml
```

**Explanation:**
- The first play populates `hostvars` for every host
- The template loop uses `groups['all']` and `hostvars[host]`
- `host.split('.')[0]` produces the short hostname
- Loopback lines must be preserved (clobbering them breaks DNS)

---

## Solution 04 — Count hosts in groups

**Playbook: host-counts.yml**
```yaml
---
- name: Print host counts
  hosts: localhost
  gather_facts: false

  tasks:
    - name: Show counts
      ansible.builtin.debug:
        msg: "TOTAL: {{ groups['all'] | length }} hosts. MANAGED: {{ groups['managed'] | length }} hosts. CONTROL: {{ groups['control'] | length }} host."
```

**Run:**
```bash
ansible-playbook host-counts.yml
```

**Explanation:**
- `groups` is a magic variable: a dict where each key is a group name
- `| length` works on any list, dict, or string
- Running on `localhost` avoids per-host repetition

---

## Solution 05 — Extract kernel major.minor

**Playbook: kernel-version.yml**
```yaml
---
- name: Derive kernel_short
  hosts: managed
  gather_facts: true

  tasks:
    - name: Compute kernel_short
      ansible.builtin.set_fact:
        kernel_short: "{{ ansible_kernel.split('.')[:2] | join('.') }}"

    - name: Display result
      ansible.builtin.debug:
        msg: "{{ inventory_hostname }}: kernel {{ kernel_short }}"
```

**Run:**
```bash
ansible-playbook kernel-version.yml
```

**Explanation:**
- `.split('.')` is a Python method on the string object (no filter prefix)
- `[:2]` is Python-style slice (first 2 elements)
- `| join('.')` rejoins the slice with dots
- The follow-up pattern `when: kernel_short is version('5.14', '>=')`
  is common in conditional execution tasks

---

## Solution 06 — Filter mounts above 80% usage

**Playbook: mount-alert.yml**
```yaml
---
- name: Mount alerts
  hosts: managed
  gather_facts: true

  tasks:
    - name: Compute mount summary
      ansible.builtin.set_fact:
        mount_summary: |-
          {% for m in ansible_mounts %}
          {% set used = m.size_total - m.size_available %}
          {% set pct = (used / m.size_total * 100) | round | int %}
          {% if pct >= 80 %}
          {{ inventory_hostname_short }}: {{ "%-9s" | format(m.mount) }} used={{ (used / 1024**3) | round(1) }}GB of {{ (m.size_total / 1024**3) | round(1) }}GB ({{ pct }}%)  ⚠
          {% else %}
          {{ inventory_hostname_short }}: {{ "%-9s" | format(m.mount) }} used={{ (used / 1024**3) | round(1) }}GB of {{ (m.size_total / 1024**3) | round(1) }}GB ({{ pct }}%)
          {% endif %}
          {% endfor %}

    - name: Write to file
      ansible.builtin.copy:
        content: "{{ mount_summary }}"
        dest: /tmp/full-mounts.txt
        mode: '0644'
      delegate_to: control.example.com
```

**Run:**
```bash
ansible-playbook mount-alert.yml
```

**Explanation:**
- `ansible_mounts` is a list of dicts (one per mounted filesystem)
- Each dict has `mount`, `size_total`, `size_available` in bytes
- The `{% set %}` blocks pre-compute used bytes and percentage
- The `{% if %}` block appends the `⚠` marker only when usage ≥ 80%

---

## Solution 07 — Extract CPU model name

**Playbook: cpu-model.yml**
```yaml
---
- name: Normalize CPU model
  hosts: managed
  gather_facts: true

  tasks:
    - name: Strip manufacturer prefix and speed suffix
      ansible.builtin.set_fact:
        cpu_short: "{{ ansible_processor[2] | regex_replace('^Intel\\(R\\) ', '') | regex_replace(' CPU @ .*$', '') }}"

    - name: Append to file
      ansible.builtin.lineinfile:
        path: /tmp/cpu-models.txt
        line: "{{ inventory_hostname }}: {{ cpu_short }}"
        create: true
        mode: '0644'
      delegate_to: control.example.com
```

**Run:**
```bash
ansible-playbook cpu-model.yml
```

**Explanation:**
- `regex_replace` runs sequentially; strip prefix first, then suffix
- Parens in regex need escaping: `Intel\(R\)`
- For AMD CPUs, swap to `^AMD ` or use alternation
- This pattern (normalize fact for human-readable reports) is common

---

## Solution 08 — Map filter on a list of dicts

**Playbook: users-csv.yml**
```yaml
---
- name: Generate users CSV
  hosts: localhost
  gather_facts: false

  vars:
    users:
      - { name: alice, uid: 2001, shell: /bin/bash }
      - { name: bob,   uid: 2002, shell: /bin/zsh }
      - { name: cleo,  uid: 2003, shell: /bin/bash }

  tasks:
    - name: Write CSV in insertion order
      ansible.builtin.copy:
        content: "{{ users | map(attribute='name') | join(',') }}\n"
        dest: /tmp/usernames.csv
        mode: '0644'

    - name: Write sorted CSV
      ansible.builtin.copy:
        content: "{{ users | map(attribute='name') | sort | join(',') }}\n"
        dest: /tmp/usernames-sorted.csv
        mode: '0644'
```

**Run:**
```bash
ansible-playbook users-csv.yml
```

**Explanation:**
- `map(attribute='name')` extracts the `name` field from each dict
- `| sort` produces lexicographic order (use `sort(attribute='uid')` for numeric)
- `| join(',')` materializes the result as a CSV string
- The chain `map → sort → join` is the canonical list-to-string pattern

---

## Solution 09 — Combine defaults with overrides

**Playbook: combine-config.yml**
```yaml
---
- name: Build merged config
  hosts: localhost
  gather_facts: false

  vars:
    defaults:
      port: 8080
      workers: 4
      log_level: info
      ssl: false
    custom:
      port: 9090
      ssl: true

  tasks:
    - name: Merge dicts
      ansible.builtin.set_fact:
        app_config: "{{ defaults | combine(custom) }}"

    - name: Write merged config as JSON
      ansible.builtin.copy:
        content: "{{ app_config | to_nice_json }}\n"
        dest: /tmp/app-config.json
        mode: '0644'
```

**Run:**
```bash
ansible-playbook combine-config.yml
```

**Explanation:**
- `combine` merges keys with `custom` overriding `defaults`
- For nested dicts, use `combine(custom, recursive=true)`
- `to_nice_json` produces 4-space indented JSON
- This pattern is used everywhere in role variable precedence

---

## Solution 10 — Build a YAML cluster snapshot

**Playbook: inventory-snapshot.yml**
```yaml
---
- name: Gather managed facts
  hosts: managed
  gather_facts: true
  tasks: []

- name: Build cluster snapshot on control
  hosts: localhost
  gather_facts: false

  tasks:
    - name: Compose hosts list
      ansible.builtin.set_fact:
        hosts_list: "{{ hosts_list | default([]) + [{
          'name': item,
          'ip': hostvars[item].ansible_default_ipv4.address,
          'os': hostvars[item].ansible_distribution ~ ' ' ~ hostvars[item].ansible_distribution_version
        }] }}"
      loop: "{{ groups['managed'] }}"

    - name: Compose final cluster dict
      ansible.builtin.set_fact:
        cluster:
          total_hosts: "{{ groups['managed'] | length }}"
          total_ram_mb: "{{ groups['managed'] | map('extract', hostvars, 'ansible_memtotal_mb') | sum }}"
          hosts: "{{ hosts_list }}"

    - name: Write snapshot
      ansible.builtin.copy:
        content: "{{ { 'cluster': cluster } | to_nice_yaml }}"
        dest: /tmp/cluster-snapshot.yml
        mode: '0644'
```

**Run:**
```bash
ansible-playbook inventory-snapshot.yml
```

**Explanation:**
- `set_fact + loop` accumulates a list across iterations
- `default([])` makes the variable safe on the first iteration
- `map('extract', hostvars, 'fact')` pulls the same fact from every host
- `| sum` aggregates a list of numbers
- `to_nice_yaml` produces multi-line indented YAML

---

## Solution 11 — System report combining math and facts

**Playbook: system-report.yml**
```yaml
---
- name: Render per-host system report
  hosts: managed
  gather_facts: true

  tasks:
    - name: Compute derived facts
      ansible.builtin.set_fact:
        ram_gb: "{{ (ansible_memtotal_mb / 1024) | round(2) }}"
        uptime_hours: "{{ (ansible_uptime_seconds / 3600) | round(1) }}"
        kernel_short: "{{ ansible_kernel.split('.')[:2] | join('.') }}"

    - name: Deploy report file
      ansible.builtin.template:
        src: templates/system-report.j2
        dest: "/tmp/system-{{ inventory_hostname_short }}.txt"
        mode: '0644'
      delegate_to: control.example.com
```

**Template: templates/system-report.j2**
```jinja
SYSTEM REPORT — {{ inventory_hostname_short }}
─────────────────────
Hostname:     {{ ansible_fqdn | default('NONE') }}
IP:           {{ ansible_default_ipv4.address | default('NONE') }}
OS:           {{ (ansible_distribution | default('NONE')) ~ ' ' ~ (ansible_distribution_version | default('')) }}
Kernel:       {{ kernel_short }} (full: {{ ansible_kernel | default('NONE') }})
Architecture: {{ ansible_architecture | default('NONE') }}
CPUs:         {{ ansible_processor_vcpus | default('NONE') }}
RAM:          {{ ram_gb }} GB
Uptime:       {{ uptime_hours }} hours
Generated:    {{ ansible_date_time.iso8601 | default('NONE') }}
```

**Run:**
```bash
ansible-playbook system-report.yml
```

**Explanation:**
- Pre-computing derived facts with `set_fact` keeps the template readable
- `delegate_to: control.example.com` runs the template task on control
  while iterating over each managed host's facts
- Every field uses `| default('NONE')` to survive missing facts

---

## Solution 12 — Filter IPs across the inventory

**Playbook: all-ips.yml**
```yaml
---
- name: Gather facts everywhere
  hosts: all
  gather_facts: true
  tasks: []

- name: Build cluster IP list
  hosts: localhost
  gather_facts: false

  tasks:
    - name: Collect all IPv4 from hostvars and filter loopback
      ansible.builtin.set_fact:
        cluster_ips: "{{ groups['all'] | map('extract', hostvars, 'ansible_all_ipv4_addresses') | flatten | reject('match', '^127\\.') | unique | sort }}"

    - name: Write IPs to file
      ansible.builtin.copy:
        content: "{{ cluster_ips | join('\n') }}\n"
        dest: /tmp/cluster-ips.txt
        mode: '0644'
```

**Run:**
```bash
ansible-playbook all-ips.yml
```

**Explanation:**
- `map('extract', hostvars, 'fact')` returns a list-of-lists
- `flatten` collapses to a single list
- `reject('match', '^127\.')` drops loopback addresses
- The double backslash is needed because YAML processes the string first
- `unique | sort` cleans duplicates and orders the output

---

## Solution 13 — Use json_query for nested data

**Playbook: query-mounts.yml**
```yaml
---
- name: JMESPath query on mounts
  hosts: managed
  gather_facts: true

  tasks:
    - name: Project mounts via JMESPath
      ansible.builtin.set_fact:
        mounts_raw: "{{ ansible_mounts | community.general.json_query('[*].{mount: mount, size_gb_raw: size_total}') }}"

    - name: Convert bytes to GB rounded
      ansible.builtin.set_fact:
        mounts_clean: "{{ mounts_clean | default([]) + [{'mount': item.mount, 'size_gb': (item.size_gb_raw / 1024**3) | round(1)}] }}"
      loop: "{{ mounts_raw }}"

    - name: Write YAML output
      ansible.builtin.copy:
        content: "{{ mounts_clean | to_nice_yaml }}"
        dest: /tmp/mounts-query.yml
        mode: '0644'
      delegate_to: control.example.com
```

**Run:**
```bash
ansible-playbook query-mounts.yml
```

**Explanation:**
- `json_query` lives in `community.general` (pre-installed in the lab)
- JMESPath `[*]` iterates a list; `.{k1: src1, k2: src2}` projects
- JMESPath cannot do arithmetic — post-process with `loop` + `set_fact`
- Use `json_query` when you have heavily nested JSON

---

## Solution 14 — Sort by attribute and pick first

**Playbook: top-talkers.yml**
```yaml
---
- name: Find biggest host
  hosts: all
  gather_facts: true
  tasks: []

- name: Pick max-RAM managed host
  hosts: localhost
  gather_facts: false

  tasks:
    - name: Build host-ram list
      ansible.builtin.set_fact:
        host_ram_list: "{{ host_ram_list | default([]) + [{'name': item, 'ram_mb': hostvars[item].ansible_memtotal_mb}] }}"
      loop: "{{ groups['managed'] }}"

    - name: Sort descending and take first
      ansible.builtin.set_fact:
        biggest: "{{ (host_ram_list | sort(attribute='ram_mb', reverse=true)) | first }}"

    - name: Write result
      ansible.builtin.copy:
        content: "biggest={{ biggest.name }} ram={{ (biggest.ram_mb / 1024) | round(2) }}GB\n"
        dest: /tmp/biggest-host.txt
        mode: '0644'
```

**Run:**
```bash
ansible-playbook top-talkers.yml
```

**Explanation:**
- `sort(attribute='ram_mb', reverse=true)` orders descending
- `| first` is shorter than `[0]` and reads better
- For top-N (N>1), use `[:N]` slice after the sort

---

## Solution 15 — Generate a sortable CSV report

**Playbook: csv-report.yml**
```yaml
---
- name: Gather managed facts
  hosts: managed
  gather_facts: true
  tasks: []

- name: Render CSV on control
  hosts: localhost
  gather_facts: false
  become: true

  tasks:
    - name: Deploy CSV
      ansible.builtin.template:
        src: templates/cluster-csv.j2
        dest: /tmp/cluster.csv
        owner: root
        group: root
        mode: '0644'
```

**Template: templates/cluster-csv.j2**
```jinja
hostname,ip,os,kernel,cpus,ram_gb,uptime_hours
{% for host in groups['managed'] %}
{{ host }},{{ hostvars[host].ansible_default_ipv4.address | default('NONE') }},{{ (hostvars[host].ansible_distribution | default('NONE')) ~ ' ' ~ (hostvars[host].ansible_distribution_version | default('')) }},{{ hostvars[host].ansible_kernel | default('NONE') }},{{ hostvars[host].ansible_processor_vcpus | default('NONE') }},{{ (hostvars[host].ansible_memtotal_mb / 1024) | round(2) }},{{ (hostvars[host].ansible_uptime_seconds / 3600) | round(1) }}
{% endfor %}
```

**Run:**
```bash
ansible-playbook csv-report.yml
```

**Explanation:**
- One long Jinja line per host keeps the CSV row predictable
- Every `hostvars[host].X` lookup uses `| default('NONE')`
- The play structure gives `localhost` access to all gathered facts
- `to_nice_*` filters are not used here because CSV needs a custom layout

---

## Quick Reference — Filter Cheatsheet

### Numeric

```yaml
{{ ansible_memtotal_mb / 1024 | round(2) }}        # MB to GB, 2 decimals
{{ ansible_uptime_seconds / 3600 | round(1) }}     # seconds to hours
{{ value | int }}                                   # cast to integer
{{ value | float }}                                 # cast to float
{{ list_of_numbers | sum }}                         # sum a list
{{ list_of_numbers | max }}                         # max in a list
```

### String

```yaml
{{ "hello world" | upper }}                         # HELLO WORLD
{{ "Hello World" | lower }}                         # hello world
{{ "  text  " | trim }}                             # text (strips whitespace)
{{ "5.14.0-362.el9" | regex_replace('-.*$', '') }}  # 5.14.0
{{ "5.14.0-362".split('-')[0] }}                    # 5.14.0
{{ "a.b.c".split('.') | join('-') }}                # a-b-c
```

### List

```yaml
{{ my_list | length }}                              # count
{{ my_list | first }}                               # first element
{{ my_list | last }}                                # last element
{{ my_list | unique | sort }}                       # dedupe + sort
{{ my_list | map(attribute='name') | join(',') }}   # extract field, CSV
{{ my_list | selectattr('active') | list }}         # keep only active=true
{{ my_list | rejectattr('disabled') | list }}       # drop disabled=true
{{ list_of_lists | flatten }}                       # collapse one level
```

### Dict

```yaml
{{ my_dict.keys() | list }}                         # keys
{{ my_dict.values() | list }}                       # values
{{ my_dict | dict2items }}                          # list of {key, value}
{{ items_list | items2dict }}                       # back to dict
{{ defaults | combine(overrides) }}                 # merge dicts
{{ defaults | combine(overrides, recursive=true) }} # deep merge
```

### Default and missing data

```yaml
{{ var | default('NONE') }}                         # use 'NONE' if undefined
{{ var | default('NONE', true) }}                   # also handle empty
{{ var | default(omit) }}                           # drop the parameter
{{ var | mandatory }}                               # fail if undefined
```

### Output formats

```yaml
{{ data | to_json }}                                # single-line JSON
{{ data | to_nice_json }}                           # 4-space indented JSON
{{ data | to_yaml }}                                # flow-style YAML
{{ data | to_nice_yaml }}                           # multi-line YAML
```

### Magic variables and hostvars

```yaml
{{ groups['all'] | length }}                        # how many hosts in inventory
{{ groups['managed'] }}                             # list of host names
{{ group_names }}                                   # groups this host belongs to
{{ hostvars[host].ansible_default_ipv4.address }}   # IP of another host
{{ play_hosts | length }}                           # hosts in current play
{{ groups['all'] | map('extract', hostvars, 'ansible_memtotal_mb') | sum }}
```

### json_query (community.general)

```yaml
{{ data | community.general.json_query('[*].name') }}              # extract names
{{ data | community.general.json_query('[?type==`web`]') }}        # filter type=web
{{ data | community.general.json_query('[*].{n: name, p: port}') }} # project
```

---

Good luck with your RHCE exam preparation! 🚀

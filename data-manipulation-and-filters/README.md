# RHCE Killer — Data Manipulation & Filters
## EX294: Turning facts into deliverables

---

> **Fundamentals: From Data Sources to Real Outputs**
> Every exam task on EX294 ends in a deliverable: a config file, a report,
> a /etc/hosts entry, a service config. You don't get points for "reading
> the fact" — you get points for **transforming** facts, inventory data,
> and magic variables into the exact format the task requires.
> Time limit: **2 hours**. Start the timer with: `bash START.sh`

---

## Why this module exists

The real RHCE EX294 v9 exam will hand you scenarios like:

- *"Create a file containing each host's IP, hostname, and total RAM in GB"*
- *"Deploy a config that lists only mounts above 80% used"*
- *"Generate `/etc/hosts` from your inventory automatically"*
- *"Write a JSON system report combining facts from every managed node"*

These are NOT separate skills — they're all the same: **fact / inventory /
magic-variable → filter chain → file or message**. This module drills
exactly that loop until it's automatic.

---

## Environment

| Host | IP | Role |
|------|----|------|
| control.example.com | 10.0.1.10 | Control node (you work here) |
| node1.example.com | 10.0.2.11 | Managed node (Rocky Linux 9) |
| node2.example.com | 10.0.2.12 | Managed node (Rocky Linux 9) |

Working directory: `/home/student/ansible/`

---

## Prerequisites

**Required:** `inventory-basics`, `playbooks-fundamentals`, `variables-and-facts`

You should know:
- How to gather facts (`ansible.builtin.setup`)
- How to access magic variables (`hostvars`, `groups`, `inventory_hostname`)
- How to read inventory variables (`group_vars/`, `host_vars/`)
- Basic playbook structure (`set_fact`, `debug`, `template`, `copy`)

---

## Instructions

- All playbooks under `/home/student/ansible/`
- Use FQCN modules (`ansible.builtin.set_fact`, etc.) — exam best practice
- Every task ends in a **verifiable deliverable**: a file at a specific path
  OR a `debug` message with a specific string. Both are graded.
- Each task includes a "**EX294 connection**" note showing the real exam
  scenario it prepares you for

---

## Tasks

### Task 01 — Memory in GB with 2 decimals (5 pts)

Create `mem-report.yml` that runs on **all managed nodes** and writes to
`/tmp/mem-report.txt` a single line per host:

```
node1.example.com: 1.84 GB
node2.example.com: 1.84 GB
```

**Required filter chain:** `ansible_memtotal_mb / 1024 | round(2)` — must
produce 2-decimal output. Use the `template` module with a `.j2` file.

**EX294 connection:** Every "hardware report" task on the real exam needs
this exact pattern. Memory always comes from `ansible_memtotal_mb`
(megabytes), but the deliverable is always asked in GB.

---

### Task 02 — Default filter for missing facts (5 pts)

Create `safe-report.yml` that writes `/tmp/safe-report.txt` per host:

```
node1.example.com  cpu=2  arch=x86_64  serial=NONE
```

Use `ansible_processor_vcpus`, `ansible_architecture`, and
`ansible_product_serial`. **Every fact lookup must use `| default('NONE')`**
so the template renders even if the fact is missing (which is what happens
on VMs that don't expose serial numbers, like the lab).

**EX294 connection:** The real exam often gives you inventories where some
hosts don't have all facts. The `default('NONE')` (or `default(omit)`)
pattern is THE way to write template tasks that don't blow up on partial
data. Costs 2 points to forget in most exam rubrics.

---

### Task 03 — Build /etc/hosts from inventory (10 pts)

Create `etc-hosts.yml` that generates `/etc/hosts` entries on every
managed node, ONE LINE per host in `groups['all']`, like:

```
10.0.1.10  control.example.com control
10.0.2.11  node1.example.com node1
10.0.2.12  node2.example.com node2
```

Use a template that loops over `groups['all']` and pulls each IP from
`hostvars[host].ansible_default_ipv4.address`. The first play must
`gather_facts: true` on every host so `hostvars` is fully populated.

**EX294 connection:** Building `/etc/hosts` from inventory has been a
recurring exam task for years. The pattern (gather facts on `all`, loop
`groups[]`, read `hostvars[]`) is reused in firewall rules, balancer
configs, monitoring lists, and `known_hosts` generation.

---

### Task 04 — Count hosts in groups (5 pts)

Create `host-counts.yml` that uses `debug:` to print a message like:

```
TOTAL: 3 hosts. MANAGED: 2 hosts. CONTROL: 1 host.
```

Use `groups['all'] | length`, `groups['managed'] | length`, and
`groups['control'] | length`. Output the result with a single
`debug: msg:` line.

**EX294 connection:** Calculating "how many" appears in capacity-planning
tasks (e.g. "set `forks` to 2× the number of managed nodes") and in
templated reports (e.g. "Cluster has N nodes"). `| length` works on any
list, group, or dict.

---

### Task 05 — Extract kernel major.minor (5 pts)

Create `kernel-version.yml` that uses `set_fact` to derive a variable
`kernel_short` from `ansible_kernel` containing only `major.minor`. For
example, if `ansible_kernel` is `5.14.0-362.el9.x86_64`, the value of
`kernel_short` must be `5.14`.

Then `debug: msg: "{{ inventory_hostname }}: kernel {{ kernel_short }}"`.

**Required filter chain:** `ansible_kernel.split('.')[:2] | join('.')`

**EX294 connection:** Conditional execution based on kernel version
(`when: kernel_short is version('5.14', '>=')`) appears in tasks where
you patch only old kernels or enable features that need new ones.

---

### Task 06 — Filter mounts above 80% usage (12 pts)

Create `mount-alert.yml` that writes `/tmp/full-mounts.txt` listing
ONLY mountpoints where used space ≥ 80% of total. Use
`ansible_mounts` (a list of dicts). Output format per line:

```
node1: /         used=4.1GB of 9.5GB (43%)
node1: /var      used=8.7GB of 10.0GB (87%)  ⚠
```

The `⚠` symbol must appear ONLY on lines ≥80%.

**Required filter chain:** `ansible_mounts | selectattr('size_total',
'gt', 0) | selectattr('size_total', '...', ...)` combined with math on
`size_total - size_available`.

**EX294 connection:** Monitoring/alerting tasks ask you to act on
filesystems crossing thresholds. The `selectattr` + math combo is the
standard pattern. Also tests your understanding that `ansible_mounts` is
a list of dicts, not a dict of dicts.

---

### Task 07 — Extract CPU model name (10 pts)

Create `cpu-model.yml` that uses `set_fact` to extract just the CPU
model name from `ansible_processor[2]`. Example transformation:

- Input: `Intel(R) Xeon(R) Platinum 8259CL CPU @ 2.50GHz`
- Output stored in `cpu_short`: `Xeon(R) Platinum 8259CL`

Strip the manufacturer prefix (`Intel(R) `) and the trailing speed info
(` CPU @ 2.50GHz`). Use `replace`, `regex_replace`, or `split` — your
choice; only the result matters. Write the result to
`/tmp/cpu-models.txt`, one host per line.

**EX294 connection:** Normalizing facts so they're useful for reports,
templates, and conditionals. Real exam example: "report the CPU model
without the marketing fluff".

---

### Task 08 — Map filter on a list of dicts (12 pts)

Define this variable at the top of `users-csv.yml`:

```yaml
users:
  - { name: alice, uid: 2001, shell: /bin/bash }
  - { name: bob,   uid: 2002, shell: /bin/zsh }
  - { name: cleo,  uid: 2003, shell: /bin/bash }
```

Use `map(attribute='name')` to extract only the user names. Then `join`
them as CSV. Write the result to `/tmp/usernames.csv`:

```
alice,bob,cleo
```

Bonus (no extra points but real exam pattern): generate ALSO
`/tmp/usernames-sorted.csv` with the names alphabetically sorted.

**EX294 connection:** Every "loop over a list of users/packages/services"
task on the real exam has a follow-up "generate a report listing them".
`map(attribute='name') | sort | join(',')` is the canonical 3-filter chain.

---

### Task 09 — Combine defaults with overrides (12 pts)

Define two dicts in `combine-config.yml`:

```yaml
defaults:
  port: 8080
  workers: 4
  log_level: info
  ssl: false

custom:
  port: 9090
  ssl: true
```

Use `set_fact` with `defaults | combine(custom)` to produce a merged
config. Write the result to `/tmp/app-config.json` with
`to_nice_json`. Expected content:

```json
{
    "log_level": "info",
    "port": 9090,
    "ssl": true,
    "workers": 4
}
```

**EX294 connection:** Role variable precedence in real exam tasks: "use
defaults but allow per-host overrides". The `combine` filter is the
mechanism. The recursive version (`combine(custom, recursive=true)`)
shows up when configs are nested dicts.

---

### Task 10 — Format multi-line YAML output (10 pts)

Create `inventory-snapshot.yml` that builds this structure in `set_fact`:

```yaml
cluster:
  total_hosts: 2
  total_ram_mb: 3680
  hosts:
    - name: node1.example.com
      ip: 10.0.2.11
      os: Rocky Linux 9.3
    - name: node2.example.com
      ip: 10.0.2.12
      os: Rocky Linux 9.3
```

Source data from `groups['managed']` + `hostvars`. Build the structure
in `set_fact` (use a `loop` over the group). Write it to
`/tmp/cluster-snapshot.yml` using `to_nice_yaml`.

**EX294 connection:** The exam asks for YAML or JSON deliverables in
multiple tasks (mostly in templated config files for monitoring tools or
inventory exporters). `to_nice_yaml` and `to_nice_json` are the filters
that produce human-readable output (vs `to_yaml` which is single-line).

---

### Task 11 — System report combining math + facts + filters (15 pts)

Create `system-report.yml` that writes a per-host file
`/tmp/system-{{ inventory_hostname_short }}.txt`:

```
SYSTEM REPORT — node1
─────────────────────
Hostname:     node1.example.com
IP:           10.0.2.11
OS:           Rocky Linux 9.3
Kernel:       5.14 (full: 5.14.0-362.el9.x86_64)
Architecture: x86_64
CPUs:         2
RAM:          1.84 GB
Uptime:       2.3 hours
Generated:    2026-05-12T15:00:00Z
```

Required transformations:
- Memory: `ansible_memtotal_mb / 1024 | round(2)` → `1.84 GB`
- Uptime: `ansible_uptime_seconds / 3600 | round(1)` → `2.3 hours`
- Kernel short: as in Task 05
- Generated: `ansible_date_time.iso8601`

Use the `template` module + a `.j2` file. Every field MUST use
`| default('NONE')` per Task 02.

**EX294 connection:** This is THE classic EX294 hardware-report task.
We've seen it in our `exam-04` Task 10 already (custom facts + report).
Here you drill the data-shaping part without the custom-fact ceremony.

---

### Task 12 — Filter IPs across the whole inventory (15 pts)

Create `all-ips.yml` that writes `/tmp/cluster-ips.txt`, one IP per line,
listing **every non-loopback IPv4 address from every managed host**,
sorted ascending.

You'll need:
- `hostvars` to access remote facts
- `ansible_all_ipv4_addresses` (list of strings per host)
- `reject('match', '^127\\.')` (or `selectattr` equivalent) to drop
  loopbacks
- A nested `map` or `flatten` to collapse the list-of-lists into a single
  list
- `sort | unique` to produce a clean output

**EX294 connection:** Generating a flat list of IPs to feed a firewall
ruleset, an allowlist, or a `known_hosts` file. The `hostvars + map +
flatten + reject + sort` chain is bread-and-butter for cluster config
templates.

---

### Task 13 — json_query for nested data extraction (15 pts)

Create `query-mounts.yml` that uses `community.general.json_query` to
extract just the mount paths and sizes from `ansible_mounts`, producing
a clean list:

```yaml
- mount: /
  size_gb: 9.5
- mount: /boot
  size_gb: 1.0
```

Required: use the JMESPath expression
`[*].{mount: mount, size_gb: size_total}` (then divide by 1073741824 in
a separate `set_fact` step to get GB). Write to
`/tmp/mounts-query.yml` with `to_nice_yaml`.

**EX294 connection:** `json_query` (from `community.general`) is on the
EX294 v9 syllabus. When you have heavily nested JSON (e.g. response from
a `uri` call, output of `kubectl get -o json`), JMESPath is faster and
more readable than chains of `selectattr | map`.

---

### Task 14 — Sort + truncate to top N (12 pts)

Create `top-talkers.yml` that builds a list of all managed hosts sorted
by **RAM descending**, then keeps only the top 1 (the host with the most
RAM). Write the result to `/tmp/biggest-host.txt`:

```
biggest=node2.example.com ram=1.85GB
```

Required: combine `groups['managed']` + `hostvars` into a list of dicts
with `{name, ram}`, then `sort(attribute='ram', reverse=true) | first`,
then format the output string.

**EX294 connection:** "Pick the most powerful host to be the leader" or
"deploy the heavy workload only to the largest node" tasks. The pattern
also reappears in `loop_control: label:` when you want to show host info
in the output.

---

### Task 15 — Generate sortable CSV report (15 pts)

Create `csv-report.yml` that produces `/tmp/cluster.csv` containing one
header row + one row per host in `groups['managed']`:

```
hostname,ip,os,kernel,cpus,ram_gb,uptime_hours
node1.example.com,10.0.2.11,Rocky Linux 9.3,5.14.0-362.el9.x86_64,2,1.84,2.3
node2.example.com,10.0.2.12,Rocky Linux 9.3,5.14.0-362.el9.x86_64,2,1.84,2.3
```

Required:
- Use a `.j2` template with the header line + a `{% for %}` loop
- Each row must apply `| default('NONE')` to every field
- Memory and uptime computed as in Task 11
- The play must `gather_facts: true` on `managed` BEFORE rendering on
  control (the template runs on control via `delegate_to`)
- File ownership: `root:root`, mode `0644`

**EX294 connection:** Final-style task that combines everything: facts,
hostvars, filters, math, template, and a CSV deliverable. Real exam
deliverables often ARE CSVs (inventory exports, audit reports). This is
the longest task; budget 15 minutes.

---

## Scoring

| Task | Topic | Pts |
|------|-------|-----|
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
| 12 | hostvars + reject + flatten | 15 |
| 13 | json_query / JMESPath | 15 |
| 14 | sort attribute + first | 12 |
| 15 | CSV via template (full integration) | 15 |
| **Total** | | **158** |

**Passing score: 70% (111/158 points)**

---

## When you finish

```bash
bash /home/student/exams/thematic/data-manipulation-and-filters/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

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

**Explanation:**
- `ansible_memtotal_mb` is always a number (megabytes). Divide by 1024,
  round to 2 decimals.
- The play structure gathers facts on `managed` first, then renders on
  control so we have full `hostvars` access.
- `round(2)` is the Jinja2 filter; do NOT use Python `round()` syntax.

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
      run_once: false
```

**Explanation:**
- `ansible_product_serial` is missing on most VMs. Without `default()`
  the template fails with `'ansible_product_serial' is undefined`.
- `| default('NONE')` returns 'NONE' when the variable is undefined OR
  empty. Use `| default('NONE', true)` to also handle empty strings.
- This is the #1 reason templates blow up on the real exam.

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

**Explanation:**
- Two plays: first to populate `hostvars` for every host (`gather_facts:
  true` on `all`), then to deploy.
- `host.split('.')[0]` produces the short hostname (`node1` from
  `node1.example.com`).
- Always preserve the loopback lines at the top — clobbering them breaks
  DNS resolution.

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

**Explanation:**
- `groups` is a magic variable: a dict where keys are group names and
  values are lists of host names. `| length` works on any list.
- Running on `localhost` avoids per-host repetition (you only need the
  count once).
- Could also use `play_hosts | length` for "hosts in current play".

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

**Explanation:**
- `.split('.')` is the Jinja2/Python method (no filter prefix because
  it's a method on the string object, not a filter).
- `[:2]` is Python-style slice (first 2 elements).
- `| join('.')` is the filter that re-joins with dots.
- The exam-relevant follow-up: `when: kernel_short is version('5.14',
  '>=')` for conditional execution.

---

## Solution 06 — Filter mounts above 80% usage

**Playbook: mount-alert.yml**
```yaml
---
- name: Mount alerts
  hosts: managed
  gather_facts: true
  tasks:
    - name: Compute mount usage
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

**Explanation:**
- `ansible_mounts` is a list of dicts. Each has `mount`, `size_total`,
  `size_available` (in bytes).
- `selectattr` with a math comparison is tricky — we precompute the
  percentage in a `{% set %}` loop, then conditionally append the `⚠`.
- The "real exam shortcut" uses `selectattr('size_available', 'lt',
  m.size_total * 0.2)` but the math gets harder. The set/if approach is
  more readable.

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

**Explanation:**
- `regex_replace` runs sequentially: strip prefix, then strip suffix.
- The regex `^Intel\(R\) ` requires escaping parens because they're meta
  in regex. In YAML strings, the backslash itself needs no escaping but
  it gets cleaner with single-quoted strings.
- For AMD CPUs, swap the regex to `^AMD ` (or use `regex_replace`'s
  alternation: `^(Intel\(R\)|AMD) `).

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
    - name: Write CSV (insertion order)
      ansible.builtin.copy:
        content: "{{ users | map(attribute='name') | join(',') }}\n"
        dest: /tmp/usernames.csv
        mode: '0644'

    - name: Write sorted CSV (bonus)
      ansible.builtin.copy:
        content: "{{ users | map(attribute='name') | sort | join(',') }}\n"
        dest: /tmp/usernames-sorted.csv
        mode: '0644'
```

**Explanation:**
- `map(attribute='name')` returns a generator; `| join(',')` materializes it.
- `sort` works on strings by default (lexicographic). For numeric sort:
  `sort(attribute='uid')`.
- This 3-filter chain (map → sort → join) is the most common pattern in
  EX294 list-to-string transformations.

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

**Explanation:**
- `combine` MERGES keys: anything in `custom` overrides `defaults`.
  Anything missing from `custom` stays from `defaults`.
- For nested dicts, use `combine(custom, recursive=true)` to merge at
  every level (otherwise the entire nested key gets replaced).
- `to_nice_json` is 4-space indented; `to_json` is single-line.
- Real role pattern: `vars: my_config: "{{ role_defaults | combine(role_vars
  | default({})) }}"` — flexible per-host override.

---

## Solution 10 — Format multi-line YAML output

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

**Explanation:**
- The `set_fact + loop` pattern accumulates a list across iterations.
  `default([])` makes the variable safe on the first iteration.
- `map('extract', hostvars, 'fact_name')` is the canonical way to pull
  the same fact from every host in a group, then `| sum` aggregates.
- `to_nice_yaml` produces multi-line, indented YAML; `to_yaml` is
  flow-style (one-liner).

---

## Solution 11 — System report combining math + facts + filters

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

**Explanation:**
- Pre-compute derived facts with `set_fact` instead of doing arithmetic
  inside the template — keeps the template readable.
- The `delegate_to: control.example.com` runs the template task on the
  control node but uses the facts of the host being iterated. Each host
  generates its own file.
- Every field has `| default('NONE')` — drilled in Task 02 for a reason.

---

## Solution 12 — Filter IPs across the whole inventory

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

**Explanation:**
- `map('extract', hostvars, 'fact')` builds a list-of-lists (each host
  contributes its own list of IPs).
- `flatten` collapses to a single list.
- `reject('match', '^127\\.')` drops loopback addresses. Double backslash
  because YAML processes the string before the regex engine sees it.
- `unique | sort` cleans duplicates and sorts alphabetically.

---

## Solution 13 — json_query for nested data extraction

**Playbook: query-mounts.yml**
```yaml
---
- name: JMESPath query on mounts
  hosts: managed
  gather_facts: true
  tasks:
    - name: Install community.general if missing
      ansible.builtin.command:
        cmd: ansible-galaxy collection install community.general
      delegate_to: localhost
      run_once: true
      changed_when: false

    - name: Project mounts via JMESPath
      ansible.builtin.set_fact:
        mounts_raw: "{{ ansible_mounts | community.general.json_query('[*].{mount: mount, size_gb_raw: size_total}') }}"

    - name: Convert size_gb_raw bytes to GB rounded
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

**Explanation:**
- `json_query` lives in `community.general` (must be in the EE on real
  exam — already in the lab's bootstrap).
- JMESPath syntax: `[*]` iterates the list, `.{key1: source1, key2:
  source2}` projects.
- JMESPath alone can't divide numbers — we post-process with a
  `loop` + `set_fact`.

---

## Solution 14 — Sort + truncate to top N

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

    - name: Sort desc and take first
      ansible.builtin.set_fact:
        biggest: "{{ (host_ram_list | sort(attribute='ram_mb', reverse=true)) | first }}"

    - name: Write result
      ansible.builtin.copy:
        content: "biggest={{ biggest.name }} ram={{ (biggest.ram_mb / 1024) | round(2) }}GB\n"
        dest: /tmp/biggest-host.txt
        mode: '0644'
```

**Explanation:**
- `sort(attribute='ram_mb', reverse=true)` orders descending.
- `| first` is shorter than `[0]` and reads better.
- For top-N (N>1), use `[:N]` slice after the sort.

---

## Solution 15 — Generate sortable CSV report

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

**Explanation:**
- The template is one long Jinja line per host. Long, but predictable.
- Every `hostvars[host].X` lookup uses `| default('NONE')` to survive
  partial fact gathering.
- The play structure (gather on `managed` → render on `localhost`) gives
  `localhost` access to the gathered facts via `hostvars`.

---

## Tips for the real EX294

1. **Pre-compute with `set_fact`.** When a math expression appears 2+
   times, set a fact for it. Cleaner templates, faster debugging.
2. **`| default('NONE')` EVERYWHERE.** Every fact lookup that COULD
   be missing should have it. Cheap insurance.
3. **`gather_facts: true` on `all` early.** Many tasks need cross-host
   data via `hostvars`. Failing to gather is the #1 reason templates
   show `undefined` errors.
4. **`to_nice_yaml` / `to_nice_json` for files, `to_yaml` / `to_json`
   for inline.** The "nice" versions add indentation and newlines.
5. **`map(attribute='X')` + `selectattr('X', op, val)`** is THE list-of-
   dicts pattern. Memorize it. The exam reuses it constantly.
6. **`json_query` only works if `community.general` is installed.** In
   the lab it's pre-installed; on a fresh control node you need to
   `ansible-galaxy collection install community.general` first.

---

Good luck! 🚀

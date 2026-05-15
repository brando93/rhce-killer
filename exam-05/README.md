# RHCE Killer — Exam 05: Troubleshooting and Advanced Techniques

**Duration:** 4 hours  
**Passing Score:** 70% (105/150 points)  
**Focus:** Debugging, Troubleshooting, Optimization, and Best Practices

---

## ⚠️ IMPORTANT INSTRUCTIONS

1. **Work Directory:** All work must be done in `/home/student/ansible/`
2. **Inventory:** Use the existing inventory at `/home/student/ansible/inventory`
3. **Ansible Config:** Use `/home/student/ansible/ansible.cfg`
4. **Test Your Work:** Run `bash ~/exams/exam-05/grade.sh` to check your progress
5. **Time Management:** You have 4 hours. This is the most challenging exam.
6. **Read Carefully:** Some tasks contain intentional errors that you must fix.

---

## 📋 EXAM TASKS

### Task 01: Debug Broken Playbook - Syntax Errors (15 points)

Fix the broken playbook at `/home/student/ansible/broken_syntax.yml`.

**Requirements:**
- Fix all syntax errors
- Playbook should install nginx on web servers
- Configure custom index page
- Ensure nginx is running
- Pass syntax check and execute successfully

**Verification:**
```bash
ansible-playbook broken_syntax.yml --syntax-check
ansible-playbook broken_syntax.yml
```

---

### Task 02: Fix Logic Errors (20 points)

The playbook at `/home/student/ansible/broken_logic.yml` runs without
syntax errors but produces wrong behavior. Diagnose and fix the logic
without changing the overall structure.

**Expected behavior:**
- User accounts (`appuser`, `dbuser`) are created ONLY on hosts whose
  `inventory_hostname` contains the substring `prod`
- Developer toolchain (`gcc`, `make`, `git`) is installed ONLY on hosts
  whose `inventory_hostname` contains `dev`
- Firewall: `https` service is opened on `web*` hosts, `mysql` service on
  `db*` hosts. Production hosts additionally get `ssh-rate-limit`.
- The variable `app_version` must be sourced from the host_vars file at
  the playbook's level, NOT from the group_vars `all/` directory

**Common pitfalls:**
- Mixing up `inventory_hostname` (FQDN) with `ansible_hostname` (short)
- Using `==` when the requirement is "contains" (use `in` or regex)
- Variable precedence: `host_vars/host` overrides `group_vars/all`,
  but `playbook vars:` is even higher — read the docs if unsure

**Verification:**
```bash
ansible-playbook broken_logic.yml --check --diff
ansible all -m shell -a "id appuser 2>/dev/null; getent passwd dbuser"
ansible all -m shell -a "rpm -q gcc make git 2>&1 | head -3"
```

---

### Task 03: Advanced Host Patterns (15 points)

Create `host_patterns.yml` that runs each of the following plays with the
correct host pattern. All plays should be in the same playbook file.

**Plays required:**

1. **Webservers except node1:** target `webservers` group **excluding**
   `node1.example.com`. Pattern: `webservers:!node1.example.com`. The
   play should run `ansible.builtin.debug: msg="trimmed web set"`.

2. **Intersection web ∩ db:** target hosts that are members of BOTH
   `webservers` AND `databases`. Pattern: `webservers:&databases`. Debug
   message: `"co-located web+db"`.

3. **Union app ∪ db:** target the combined set of `app` and `databases`
   groups. Pattern: `app:databases`. Debug message: `"backend tier"`.

4. **Regex on hostname:** target hosts whose `inventory_hostname` starts
   with `node`. Pattern: `~node.*`. Debug message: `"matched by regex"`.

5. **Delegated probe:** target `all`, but run a single `delegate_to:
   localhost` task with `run_once: true` that logs the total host count
   to `/tmp/host_count.txt`.

**Verification:**
```bash
ansible-playbook host_patterns.yml --list-hosts
cat /tmp/host_count.txt   # should contain the integer count
```

---

### Task 04: Dynamic Includes vs Static Imports (20 points)

Create `includes_demo.yml` plus a `tasks/` subdirectory that demonstrates
the runtime differences between `import_*` and `include_*`.

**Files to create:**

- `tasks/setup.yml` — 2 tasks tagged `setup` that print which phase
- `tasks/configure.yml` — 2 tasks tagged `config` that print phase
- `tasks/deploy.yml` — 2 tasks tagged `deploy` that print phase
- `includes_demo.yml` — main playbook that:
  - Uses `import_tasks: tasks/setup.yml` (static, tags resolve at parse)
  - Uses `include_tasks: tasks/configure.yml` (dynamic, tags resolve at runtime)
  - Uses `import_tasks: tasks/deploy.yml` with a conditional `when:`

**Tag-behavior demonstration required:**
- Running `--list-tasks` must list ALL tasks from `import_tasks` files but
  ONLY the include placeholder from `include_tasks`
- Running `--tags config` must execute config tasks even though they're
  included dynamically

**Variable-scope demonstration required:**
- Pass `phase_name: "alpha"` to `tasks/configure.yml` via `vars:` on the
  `include_tasks` directive
- That variable must NOT leak into `tasks/deploy.yml` afterwards

**Verification:**
```bash
ansible-playbook includes_demo.yml --list-tasks
ansible-playbook includes_demo.yml --tags config --check
```

---

### Task 05: Advanced Tagging Strategy (15 points)

Create `tagged_deployment.yml` with the following tag hierarchy:

**Required tags:**

| Tag | Behavior | Required tasks |
|---|---|---|
| `always` | Runs on every invocation | Print start banner |
| `never` | Skipped unless explicitly named | Destructive cleanup |
| `setup` | Initial provisioning | Install packages |
| `config` | Configuration push | Templates, lineinfile |
| `deploy` | Application deploy | Service restart |
| `verify` | Post-checks | URI/uri module, asserts |
| `frontend` | Web-tier tasks | Apache config |
| `backend` | DB-tier tasks | MariaDB config |

**Required behavior:**
- `ansible-playbook tagged_deployment.yml` runs `always` + `setup` +
  `config` + `deploy` + `verify` (default execution)
- `ansible-playbook tagged_deployment.yml --tags frontend` runs only the
  web-tier tasks PLUS `always`
- `ansible-playbook tagged_deployment.yml --tags never` runs ONLY the
  destructive cleanup
- `ansible-playbook tagged_deployment.yml --skip-tags deploy` runs
  everything except `deploy`

**Verification:**
```bash
ansible-playbook tagged_deployment.yml --list-tags
ansible-playbook tagged_deployment.yml --tags frontend --check
```

---

### Task 06: Task Delegation (15 points)

Create `delegation.yml` that demonstrates all 5 delegation patterns.
Target host group: `all` (so the play iterates over every managed node).

**Required patterns:**

1. **`delegate_to: localhost`** — Run a task on the control node (e.g.
   write `/tmp/run-{{ inventory_hostname }}.log` from localhost).

2. **`local_action`** — Use the shorthand syntax to execute `date` on the
   control node and `register` the result.

3. **`run_once: true`** combined with `delegate_to`: gather facts from
   a single host (node1) and reuse them across the whole play.

4. **`serial: 1`** — Process hosts one at a time (rolling update). Add a
   task that restarts httpd (use `service:` even if not installed; the
   point is the serial syntax). Wrap in `ignore_errors: true` so the
   play continues regardless of httpd state.

5. **`throttle: 2`** — On a specific task, limit concurrent executions to
   2 even though `forks` may allow more.

**Verification:**
```bash
ansible-playbook delegation.yml -v
ls /tmp/run-node*.log  # one file per managed node, written by localhost
```

---

### Task 07: Magic Variables (15 points)

Create `magic_vars.yml` that exercises Ansible's "magic" variables. Run
on `all` managed nodes. For each pattern below, include one task that
uses the variable and emits a debug message.

**Patterns required:**

1. **`hostvars['node1.example.com']['ansible_default_ipv4']['address']`** —
   from any host, print node1's IP. Requires fact-gathering on node1.

2. **`groups['webservers']`** — print a comma-joined list of all members.

3. **`group_names`** — on each host, print the list of groups that host
   belongs to.

4. **`inventory_hostname` vs `ansible_hostname`** — print both side by
   side to highlight the difference (inventory key vs facts `hostname`).

5. **`omit`** — create a user with `comment: "{{ user_comment | default(omit) }}"`;
   if `user_comment` is undefined, the comment field is dropped entirely.

6. **`lookup` / `query` plugins** — use `lookup('env', 'HOME')` and
   `query('inventory_hostnames', 'webservers')` and print the results.

**Verification:**
```bash
ansible-playbook magic_vars.yml | grep -E "node1|group_names|omit"
```

---

### Task 08: Ansible-lint and Best Practices (15 points)

Create `best_practices.yml` that scores **clean** on `ansible-lint`
(0 warnings, 0 errors at production profile).

**Required practices:**

- FQCN for every module (`ansible.builtin.copy` instead of `copy`)
- Every task has a descriptive `name:` (no anonymous tasks)
- Loop variables use `loop:` instead of deprecated `with_items:`
- No use of `command` or `shell` when a real module exists
- `changed_when: false` on read-only commands (e.g. checks)
- `failed_when:` customized when the default 0/non-0 isn't right
- `no_log: true` on tasks that emit secrets (e.g. user creation with password)
- Variables in `snake_case`, no leading underscores
- `become: true` only at task or play scope when needed (not globally)

**Verification:**
```bash
ansible-lint best_practices.yml          # must be clean
ansible-lint --profile production best_practices.yml
```

---

### Task 09: Performance Optimization (20 points)

Create `optimized.yml` and a custom `ansible.cfg.optimized` that together
demonstrate every optimization technique below.

**`ansible.cfg.optimized` required directives:**
```ini
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 3600
forks = 10
strategy = free

[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

**Required playbook behavior:**

1. **Skip fact gathering** on plays that don't need facts
   (`gather_facts: false`).
2. **Async + poll** — Long-running task (sleep 30) must execute with
   `async: 60, poll: 5`, registered, and its `finished` status checked
   in a follow-up task.
3. **Strategy: free** — At play level, set `strategy: free` so each host
   advances independently.
4. **Pipelining** verification — run with `-vvv` and confirm "PIPELINED"
   appears in the verbose output.
5. **Fact cache** verification — run the play twice; the second run
   should NOT re-gather facts because they're cached.

**Verification:**
```bash
ANSIBLE_CONFIG=ansible.cfg.optimized ansible-playbook optimized.yml
ls /tmp/ansible_facts/   # cache files should exist
```

---

### Task 10: Comprehensive Integration (25 points)

The capstone. Create `final_integration.yml` that exercises every concept
from this exam in a single coherent deployment. Worth 25 pts — partial
credit IS given (5 pts per major area below).

**Required architecture:**

```
final_integration.yml
├── Play 1: pre_tasks  (always tag)   — banner + facts gather
├── Play 2: roles      (frontend tag) — apache role, web hosts
├── Play 3: roles      (backend  tag) — mariadb role, db hosts
└── Play 4: post_tasks (verify tag)   — uri + asserts
```

**Required techniques (5 pts each):**

1. **Roles** — Use at least 2 roles (e.g. `webserver`, `database`), each
   with `defaults/`, `vars/`, `tasks/`, `handlers/`, `templates/`.

2. **Error handling** — Block/rescue/always somewhere in a role's tasks;
   `rescue:` must include a debug message AND a non-fatal `fail:`.

3. **Conditionals + loops** — At least one task uses `when:` + `loop:`
   with `loop_control: label:`.

4. **Delegation + magic variables** — One task with `delegate_to:
   localhost`, `run_once: true`, using `hostvars[...]` to access another
   host's facts.

5. **Tags + pre/post_tasks** — Plays use `pre_tasks:` and `post_tasks:`.
   Tags from Task 05 are reused. `--tags frontend` and `--tags backend`
   must each execute the corresponding play independently.

**Verification:**
```bash
ansible-playbook final_integration.yml --list-tags
ansible-playbook final_integration.yml --tags frontend --check
ansible-playbook final_integration.yml --tags verify
```

---

## 📚 DEBUGGING COMMANDS

```bash
# Syntax checking
ansible-playbook playbook.yml --syntax-check
ansible-lint playbook.yml

# Verbose output
ansible-playbook playbook.yml -v    # verbose
ansible-playbook playbook.yml -vvv  # very verbose

# Dry run
ansible-playbook playbook.yml --check
ansible-playbook playbook.yml --diff

# Task control
ansible-playbook playbook.yml --list-tasks
ansible-playbook playbook.yml --list-tags
ansible-playbook playbook.yml --start-at-task "Task name"
ansible-playbook playbook.yml --step
```

---

## ⚠️ SOLUTIONS BELOW ⚠️

<br><br><br><br><br><br><br><br><br><br>

---

# 🔓 SOLUTIONS

## Task 01: Fix Syntax Errors

**File:** `broken_syntax.yml`
```yaml
---
- name: Install and configure nginx
  hosts: web
  become: true
  
  vars:
    nginx_port: 8080
    server_name: "{{ ansible_hostname }}"
  
  tasks:
    - name: Install nginx
      ansible.builtin.dnf:
        name: nginx
        state: present
    
    - name: Create index page
      ansible.builtin.copy:
        content: "Welcome to {{ server_name }}"
        dest: /var/www/html/index.html
        owner: nginx
        group: nginx
        mode: '0644'
      notify:
        - restart nginx
    
    - name: Ensure nginx is running
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true
  
  handlers:
    - name: restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
```

**Errors Fixed:**
1. Missing colon after play name
2. Missing colon after `vars`
3. Missing quotes around variable
4. Missing FQCN for modules
5. Incorrect indentation

---

## Task 02: Fix Logic Errors

**File:** `broken_logic.yml`
```yaml
---
- name: Configure servers based on environment
  hosts: all
  become: true
  vars:
    env_type: "{{ 'production' if 'prod' in ansible_hostname else 'development' }}"
  
  tasks:
    - name: Create production users
      ansible.builtin.user:
        name: "{{ item }}"
        state: present
      loop:
        - produser1
        - produser2
      when: "'prod' in ansible_hostname"
    
    - name: Install development tools
      ansible.builtin.dnf:
        name:
          - gcc
          - make
          - git
        state: present
      when: env_type == 'development'
    
    - name: Configure production firewall
      ansible.posix.firewalld:
        port: "{{ item }}"
        permanent: true
        state: enabled
        immediate: true
      loop:
        - 80/tcp
        - 443/tcp
      when: "'prod' in ansible_hostname"
```

---

## Task 03: Advanced Host Patterns

**File:** `host_patterns.yml`
```yaml
---
- name: Advanced host patterns
  hosts: all
  gather_facts: true
  
  tasks:
    - name: Web servers except node1
      ansible.builtin.debug:
        msg: "Running on {{ inventory_hostname }}"
      when: 
        - inventory_hostname in groups['web']
        - inventory_hostname != 'node1'
    
    - name: Delegate to control node
      ansible.builtin.command: echo "Delegated"
      delegate_to: localhost
      run_once: true
      changed_when: false
    
    - name: Run once across all hosts
      ansible.builtin.debug:
        msg: "This runs only once"
      run_once: true
```

---

## Task 04: Includes vs Imports

**File:** `includes_imports.yml`
```yaml
---
- name: Includes vs imports
  hosts: all
  become: true
  
  tasks:
    # Static import
    - name: Import tasks (static)
      ansible.builtin.import_tasks: tasks/common.yml
      tags: common
    
    # Dynamic include
    - name: Include tasks (dynamic)
      ansible.builtin.include_tasks: tasks/web.yml
      when: inventory_hostname in groups['web']
      tags: web
```

---

## Task 05: Tagging Strategy

**File:** `tagged_deployment.yml`
```yaml
---
- name: Tagged deployment
  hosts: all
  become: true
  
  tasks:
    - name: Always runs
      ansible.builtin.ping:
      tags: always
    
    - name: Never runs
      ansible.builtin.debug:
        msg: "Dangerous"
      tags: never
    
    - name: Setup task
      ansible.builtin.file:
        path: /opt/app
        state: directory
        mode: '0755'
      tags:
        - setup
        - frontend
    
    - name: Deploy task
      ansible.builtin.copy:
        content: "App"
        dest: /opt/app/app.txt
        mode: '0644'
      tags:
        - deploy
        - frontend
```

---

## Task 06: Delegation

**File:** `delegation.yml`
```yaml
---
- name: Task delegation
  hosts: all
  become: true
  serial: 2
  
  tasks:
    - name: Delegate to localhost
      ansible.builtin.command: echo "Backup"
      delegate_to: localhost
      run_once: true
      changed_when: false
    
    - name: Local action
      local_action:
        module: ansible.builtin.copy
        content: "Report for {{ inventory_hostname }}"
        dest: "/tmp/report_{{ inventory_hostname }}.txt"
        mode: '0644'
    
    - name: Rolling update
      ansible.builtin.debug:
        msg: "Updating {{ inventory_hostname }}"
```

---

## Task 07: Magic Variables

**File:** `magic_vars.yml`
```yaml
---
- name: Magic variables
  hosts: all
  gather_facts: true
  
  tasks:
    - name: Show hostnames
      ansible.builtin.debug:
        msg: |
          Inventory: {{ inventory_hostname }}
          Ansible: {{ ansible_hostname }}
    
    - name: Show groups
      ansible.builtin.debug:
        msg: "Groups: {{ group_names }}"
    
    - name: Access other hosts
      ansible.builtin.debug:
        msg: "Node1 IP: {{ hostvars['node1']['ansible_default_ipv4']['address'] }}"
      run_once: true
      when: "'node1' in groups['all']"
    
    - name: Use omit
      ansible.builtin.user:
        name: testuser
        group: "{{ user_group | default(omit) }}"
        state: present
```

---

## Task 08: Best Practices

**File:** `best_practices.yml`
```yaml
---
- name: Ansible best practices
  hosts: all
  become: true
  
  tasks:
    - name: Install packages with FQCN
      ansible.builtin.dnf:
        name:
          - nginx
          - python3
        state: present
    
    - name: Command with changed_when
      ansible.builtin.command: cat /etc/hostname
      register: hostname
      changed_when: false
    
    - name: Block for error handling
      block:
        - name: Copy file
          ansible.builtin.copy:
            src: file.txt
            dest: /tmp/file.txt
            mode: '0644'
      rescue:
        - name: Handle error
          ansible.builtin.debug:
            msg: "Copy failed"
      always:
        - name: Cleanup
          ansible.builtin.file:
            path: /tmp/temp
            state: absent
    
    - name: Sensitive data
      ansible.builtin.lineinfile:
        path: /etc/config
        line: "password={{ secret }}"
        create: true
        mode: '0600'
      no_log: true
      when: secret is defined
```

---

## Task 09: Performance Optimization

**File:** `optimized.yml`
```yaml
---
- name: Optimized playbook
  hosts: all
  gather_facts: false
  strategy: free
  
  tasks:
    - name: Gather minimal facts
      ansible.builtin.setup:
        gather_subset:
          - '!all'
          - network
    
    - name: Async task
      ansible.builtin.dnf:
        name: '*'
        state: latest
      async: 300
      poll: 0
      register: update_job
    
    - name: Other tasks
      ansible.builtin.dnf:
        name: nginx
        state: present
    
    - name: Check async
      ansible.builtin.async_status:
        jid: "{{ update_job.ansible_job_id }}"
      register: result
      until: result.finished
      retries: 30
      delay: 10
      when: update_job.ansible_job_id is defined
```

---

## Task 10: Final Integration

**File:** `final_integration.yml`
```yaml
---
- name: Pre-flight checks
  hosts: localhost
  gather_facts: false
  tags: always
  
  tasks:
    - name: Verify Ansible version
      ansible.builtin.assert:
        that:
          - ansible_version.full is version('2.9', '>=')

- name: Database tier
  hosts: database
  become: true
  tags:
    - database
    - backend
  
  roles:
    - database
  
  tasks:
    - name: Verify database
      ansible.builtin.service:
        name: mariadb
        state: started

- name: Web tier
  hosts: web
  become: true
  tags:
    - web
    - frontend
  
  roles:
    - webserver
  
  tasks:
    - name: Configure nginx
      ansible.builtin.template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        mode: '0644'
      notify: Reload nginx
  
  handlers:
    - name: Reload nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded

- name: Verification
  hosts: all
  gather_facts: false
  tags:
    - verify
    - always
  
  tasks:
    - name: Check services
      ansible.builtin.service_facts:
    
    - name: Display status
      ansible.builtin.debug:
        msg: "Services running"
```

---

## 🎓 EXAM TIPS

1. **Debugging:** Use `-vvv` for detailed output
2. **Syntax:** Always run `--syntax-check` first
3. **Testing:** Use `--check` mode before applying
4. **Tags:** Use tags for selective execution
5. **Performance:** Enable fact caching and pipelining
6. **Best Practices:** Use FQCN and descriptive names
7. **Error Handling:** Use block/rescue/always
8. **Documentation:** Comment complex logic
9. **Idempotency:** Ensure tasks can run multiple times
10. **Verification:** Test thoroughly before submitting

---

**Good luck with your final exam! 🚀**
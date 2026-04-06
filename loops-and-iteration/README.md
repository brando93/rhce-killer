# RHCE Killer — Loops and Iteration
## EX294: Mastering Ansible Loops

---

> **Intermediate Exam: Loop Mastery**
> This exam teaches you how to iterate over data in Ansible.
> Master loop, with_items, loop_control, and nested loops.
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
- Use proper loop syntax
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, conditionals-and-when

You should know:
- How to write playbooks
- How to use variables
- How to use conditionals
- Basic module usage

---

## Tasks

### Task 01 — Basic Loop with Simple List (10 pts)

Create a playbook `/home/student/ansible/loop-basic.yml` that:
- Runs on **all managed nodes**
- Creates three users: `alice`, `bob`, `charlie`
- Uses a `loop` to iterate over the list
- Uses `become: true`

**Requirements:**
- Use `loop` keyword
- Use `user` module
- Create all three users
- Single task with loop

---

### Task 02 — Loop with Package Installation (12 pts)

Create a playbook `/home/student/ansible/loop-packages.yml` that:
- Runs on **all managed nodes**
- Installs multiple packages: `httpd`, `firewalld`, `vim-enhanced`
- Uses a `loop` to iterate over the packages
- Uses `become: true`

**Requirements:**
- Use `loop` keyword
- Use `dnf` module
- Install all packages in one task
- Use `state: present`

---

### Task 03 — Loop with File Creation (12 pts)

Create a playbook `/home/student/ansible/loop-files.yml` that:
- Runs on **all managed nodes**
- Creates three directories:
  - `/opt/app1`
  - `/opt/app2`
  - `/opt/app3`
- Uses a `loop` to iterate over the paths
- Sets mode to `0755`
- Uses `become: true`

**Requirements:**
- Use `loop` keyword
- Use `file` module
- Create all directories
- Set proper permissions

---

### Task 04 — Loop with Dictionary (15 pts)

Create a playbook `/home/student/ansible/loop-dict.yml` that:
- Runs on **all managed nodes**
- Creates users with specific UIDs:
  - `developer` with UID `2001`
  - `tester` with UID `2002`
  - `admin` with UID `2003`
- Uses a loop with dictionary items
- Uses `become: true`

**Requirements:**
- Use `loop` keyword
- Define list of dictionaries in vars
- Each dict has `name` and `uid` keys
- Use `{{ item.name }}` and `{{ item.uid }}`

---

### Task 05 — Loop with Conditional (15 pts)

Create a playbook `/home/student/ansible/loop-when.yml` that:
- Runs on **all managed nodes**
- Defines a list of packages: `httpd`, `nginx`, `mariadb-server`
- Installs only packages that contain "http" or "nginx" in their name
- Uses `loop` with `when` condition
- Uses `become: true`

**Requirements:**
- Use `loop` keyword
- Use `when` with `in` operator
- Use `item` variable in condition
- Only httpd and nginx should be installed

---

### Task 06 — Loop with Register (15 pts)

Create a playbook `/home/student/ansible/loop-register.yml` that:
- Runs on **all managed nodes**
- Checks if three users exist: `root`, `student`, `nobody`
- Uses `getent` module with loop
- Registers the results
- Displays the registered results

**Requirements:**
- Use `loop` keyword
- Use `getent` module with `database: passwd`
- Use `register` keyword
- Use `debug` to display results

---

### Task 07 — Loop Control - Label (12 pts)

Create a playbook `/home/student/ansible/loop-label.yml` that:
- Runs on **all managed nodes**
- Creates users with full details:
  - `dev1`: UID 3001, comment "Developer 1"
  - `dev2`: UID 3002, comment "Developer 2"
- Uses `loop_control` with `label` to show only username
- Uses `become: true`

**Requirements:**
- Use `loop` with dictionaries
- Use `loop_control` with `label`
- Label should show only `{{ item.name }}`
- Cleaner output than showing full dict

---

### Task 08 — Loop Control - Index (12 pts)

Create a playbook `/home/student/ansible/loop-index.yml` that:
- Runs on **all managed nodes**
- Creates files `/tmp/file-0.txt`, `/tmp/file-1.txt`, `/tmp/file-2.txt`
- Uses `loop_control` with `index_var` to get loop index
- File content should be "This is file number X"
- Uses loop over list: `['first', 'second', 'third']`

**Requirements:**
- Use `loop` keyword
- Use `loop_control` with `index_var: idx`
- Use `{{ idx }}` in filename
- Use `copy` module with `content`

---

### Task 09 — Loop Control - Pause (10 pts)

Create a playbook `/home/student/ansible/loop-pause.yml` that:
- Runs on **all managed nodes**
- Displays three messages: "Message 1", "Message 2", "Message 3"
- Pauses 2 seconds between each message
- Uses `loop_control` with `pause`

**Requirements:**
- Use `loop` keyword
- Use `loop_control` with `pause: 2`
- Use `debug` module
- Observable delay between messages

---

### Task 10 — Nested Loop (18 pts)

Create a playbook `/home/student/ansible/loop-nested.yml` that:
- Runs on **all managed nodes**
- Creates directories for each user and each app:
  - Users: `alice`, `bob`
  - Apps: `app1`, `app2`
  - Result: `/home/alice/app1`, `/home/alice/app2`, `/home/bob/app1`, `/home/bob/app2`
- Uses nested loops
- Uses `become: true`

**Requirements:**
- Use `loop` with nested list
- Use `{{ item.0 }}` and `{{ item.1 }}`
- Create all 4 directories
- Set mode to `0755`

---

### Task 11 — Loop with Subelements (18 pts)

Create a playbook `/home/student/ansible/loop-subelements.yml` that:
- Runs on **all managed nodes**
- Defines users with their SSH keys:
  ```yaml
  users:
    - name: alice
      keys:
        - "ssh-rsa AAAAB3... alice@example.com"
        - "ssh-rsa AAAAB4... alice@laptop"
    - name: bob
      keys:
        - "ssh-rsa AAAAB5... bob@example.com"
  ```
- Creates each user
- Adds all their SSH keys to authorized_keys
- Uses `subelements` lookup

**Requirements:**
- Use `loop: "{{ users | subelements('keys') }}"`
- Use `user` module to create users
- Use `authorized_key` module for keys
- Use `become: true`

---

### Task 12 — Loop with dict2items (15 pts)

Create a playbook `/home/student/ansible/loop-dict2items.yml` that:
- Runs on **all managed nodes**
- Defines a dictionary of services and their ports:
  ```yaml
  services:
    http: 80
    https: 443
    ssh: 22
  ```
- Creates a file `/tmp/services.txt` with content:
  ```
  http: 80
  https: 443
  ssh: 22
  ```
- Uses `dict2items` filter

**Requirements:**
- Use `loop: "{{ services | dict2items }}"`
- Use `{{ item.key }}` and `{{ item.value }}`
- Use `lineinfile` module
- Create all three lines

---

### Task 13 — Loop with items2dict (15 pts)

Create a playbook `/home/student/ansible/loop-items2dict.yml` that:
- Runs on **all managed nodes**
- Defines a list of user/group pairs:
  ```yaml
  user_groups:
    - user: alice
      group: developers
    - user: bob
      group: testers
  ```
- Creates each group
- Creates each user with their primary group
- Uses loop twice (once for groups, once for users)
- Uses `become: true`

**Requirements:**
- First loop creates groups
- Second loop creates users with `group` parameter
- Use `group` and `user` modules
- Two separate tasks

---

### Task 14 — Loop with until (18 pts)

Create a playbook `/home/student/ansible/loop-until.yml` that:
- Runs on **all managed nodes**
- Checks if `httpd` service is active
- Retries up to 5 times with 3 second delay
- Uses `until` keyword
- Starts httpd first if not running

**Requirements:**
- First task: ensure httpd is started
- Second task: check status with `systemctl is-active httpd`
- Use `register` to capture result
- Use `until: result.stdout == "active"`
- Use `retries: 5` and `delay: 3`
- Use `become: true`

---

### Task 15 — Complex Loop with Multiple Conditions (20 pts)

Create a playbook `/home/student/ansible/loop-complex.yml` that:
- Runs on **all managed nodes**
- Defines a list of packages with conditions:
  ```yaml
  packages:
    - name: httpd
      install: true
      service: true
    - name: nginx
      install: false
      service: false
    - name: firewalld
      install: true
      service: true
  ```
- Installs packages where `install: true`
- Starts and enables services where `service: true`
- Uses loops with conditionals
- Uses `become: true`

**Requirements:**
- First task: install packages with `when: item.install`
- Second task: start services with `when: item.service`
- Use `loop` keyword
- Use `dnf` and `service` modules

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Basic Loop | 10 |
| 02 | Loop with Packages | 12 |
| 03 | Loop with Files | 12 |
| 04 | Loop with Dictionary | 15 |
| 05 | Loop with Conditional | 15 |
| 06 | Loop with Register | 15 |
| 07 | Loop Control - Label | 12 |
| 08 | Loop Control - Index | 12 |
| 09 | Loop Control - Pause | 10 |
| 10 | Nested Loop | 18 |
| 11 | Loop with Subelements | 18 |
| 12 | Loop with dict2items | 15 |
| 13 | Loop with items2dict | 15 |
| 14 | Loop with until | 18 |
| 15 | Complex Loop | 20 |
| **Total** | | **207** |

**Passing score: 70% (145/207 points)**

---

## When you finish

```bash
bash /home/student/exams/loops-and-iteration/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Basic Loop with Simple List

```yaml
---
- name: Basic loop example
  hosts: all
  become: true
  
  tasks:
    - name: Create multiple users
      ansible.builtin.user:
        name: "{{ item }}"
        state: present
      loop:
        - alice
        - bob
        - charlie
```

**Explanation:**
- `loop` keyword replaces old `with_items`
- `item` variable contains current loop value
- Task runs once for each item in list
- Cleaner than writing three separate tasks
- List can be inline or in vars section

**Verification:**
```bash
ansible all -m command -a "id alice"
ansible all -m command -a "id bob"
ansible all -m command -a "id charlie"
```

---

## Solution 02 — Loop with Package Installation

```yaml
---
- name: Install multiple packages
  hosts: all
  become: true
  
  tasks:
    - name: Install packages with loop
      ansible.builtin.dnf:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - firewalld
        - vim-enhanced
```

**Explanation:**
- Same pattern as user creation
- `dnf` module can also take list directly
- Loop approach is more explicit
- Each package installed separately
- Better error messages per package

**Alternative (without loop):**
```yaml
- name: Install packages
  ansible.builtin.dnf:
    name:
      - httpd
      - firewalld
      - vim-enhanced
    state: present
```

---

## Solution 03 — Loop with File Creation

```yaml
---
- name: Create multiple directories
  hosts: all
  become: true
  
  tasks:
    - name: Create app directories
      ansible.builtin.file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
      loop:
        - /opt/app1
        - /opt/app2
        - /opt/app3
```

**Explanation:**
- Loop over directory paths
- `file` module with `state: directory`
- Mode applies to all directories
- Creates parent directories if needed
- Idempotent operation

**Verification:**
```bash
ansible all -m command -a "ls -ld /opt/app*"
```

---

## Solution 04 — Loop with Dictionary

```yaml
---
- name: Loop with dictionary items
  hosts: all
  become: true
  
  vars:
    users:
      - name: developer
        uid: 2001
      - name: tester
        uid: 2002
      - name: admin
        uid: 2003
  
  tasks:
    - name: Create users with specific UIDs
      ansible.builtin.user:
        name: "{{ item.name }}"
        uid: "{{ item.uid }}"
        state: present
      loop: "{{ users }}"
```

**Explanation:**
- List of dictionaries in vars
- Access dict values with `item.key`
- More structured than simple lists
- Can include multiple attributes
- Scalable approach

**Verification:**
```bash
ansible all -m command -a "id developer"
ansible all -m command -a "id tester"
```

---

## Solution 05 — Loop with Conditional

```yaml
---
- name: Loop with conditional
  hosts: all
  become: true
  
  vars:
    packages:
      - httpd
      - nginx
      - mariadb-server
  
  tasks:
    - name: Install only web server packages
      ansible.builtin.dnf:
        name: "{{ item }}"
        state: present
      loop: "{{ packages }}"
      when: "'http' in item or 'nginx' in item"
```

**Explanation:**
- `when` evaluates for each loop iteration
- Task skipped if condition false
- `in` operator checks substring
- `or` allows multiple conditions
- Only httpd and nginx installed

**Verification:**
```bash
ansible all -m command -a "rpm -q httpd nginx mariadb-server"
```

---

## Solution 06 — Loop with Register

```yaml
---
- name: Loop with register
  hosts: all
  
  tasks:
    - name: Check if users exist
      ansible.builtin.getent:
        database: passwd
        key: "{{ item }}"
      loop:
        - root
        - student
        - nobody
      register: user_check
      failed_when: false
    
    - name: Display results
      ansible.builtin.debug:
        var: user_check
```

**Explanation:**
- `register` captures all loop results
- Results stored in `results` list
- Each iteration creates one result item
- `failed_when: false` prevents failures
- Useful for checking multiple items

**Alternative - show specific info:**
```yaml
- name: Display user info
  ansible.builtin.debug:
    msg: "User {{ item.item }} exists: {{ item.failed == false }}"
  loop: "{{ user_check.results }}"
```

---

## Solution 07 — Loop Control - Label

```yaml
---
- name: Loop control with label
  hosts: all
  become: true
  
  vars:
    users:
      - name: dev1
        uid: 3001
        comment: "Developer 1"
      - name: dev2
        uid: 3002
        comment: "Developer 2"
  
  tasks:
    - name: Create users with clean output
      ansible.builtin.user:
        name: "{{ item.name }}"
        uid: "{{ item.uid }}"
        comment: "{{ item.comment }}"
        state: present
      loop: "{{ users }}"
      loop_control:
        label: "{{ item.name }}"
```

**Explanation:**
- `loop_control` customizes loop behavior
- `label` controls what's displayed in output
- Shows only username instead of full dict
- Cleaner, more readable output
- Doesn't affect functionality

**Without label output:**
```
TASK [Create users] ***
ok: [node1] => (item={'name': 'dev1', 'uid': 3001, 'comment': 'Developer 1'})
```

**With label output:**
```
TASK [Create users] ***
ok: [node1] => (item=dev1)
```

---

## Solution 08 — Loop Control - Index

```yaml
---
- name: Loop control with index
  hosts: all
  
  vars:
    items:
      - first
      - second
      - third
  
  tasks:
    - name: Create numbered files
      ansible.builtin.copy:
        content: "This is file number {{ idx }}\n"
        dest: "/tmp/file-{{ idx }}.txt"
        mode: '0644'
      loop: "{{ items }}"
      loop_control:
        index_var: idx
```

**Explanation:**
- `index_var` creates variable with loop index
- Index starts at 0
- Useful for numbering or ordering
- Can use any variable name
- Access with `{{ idx }}`

**Verification:**
```bash
ansible all -m command -a "cat /tmp/file-0.txt"
ansible all -m command -a "cat /tmp/file-1.txt"
```

---

## Solution 09 — Loop Control - Pause

```yaml
---
- name: Loop control with pause
  hosts: all
  
  tasks:
    - name: Display messages with delay
      ansible.builtin.debug:
        msg: "{{ item }}"
      loop:
        - "Message 1"
        - "Message 2"
        - "Message 3"
      loop_control:
        pause: 2
```

**Explanation:**
- `pause` adds delay between iterations
- Value in seconds
- Useful for rate limiting
- Prevents overwhelming services
- Observable in playbook execution

**Use cases:**
- API rate limiting
- Service startup delays
- Database connection pooling
- Avoiding resource exhaustion

---

## Solution 10 — Nested Loop

```yaml
---
- name: Nested loops
  hosts: all
  become: true
  
  vars:
    users:
      - alice
      - bob
    apps:
      - app1
      - app2
  
  tasks:
    - name: Create user app directories
      ansible.builtin.file:
        path: "/home/{{ item.0 }}/{{ item.1 }}"
        state: directory
        mode: '0755'
        owner: "{{ item.0 }}"
      loop: "{{ users | product(apps) | list }}"
```

**Explanation:**
- `product` filter creates cartesian product
- `item.0` is first list item (user)
- `item.1` is second list item (app)
- Creates all combinations
- 2 users × 2 apps = 4 directories

**Alternative syntax:**
```yaml
loop: "{{ users | product(apps) }}"
# or
loop: "{{ query('nested', users, apps) }}"
```

---

## Solution 11 — Loop with Subelements

```yaml
---
- name: Loop with subelements
  hosts: all
  become: true
  
  vars:
    users:
      - name: alice
        keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... alice@example.com"
          - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD... alice@laptop"
      - name: bob
        keys:
          - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQE... bob@example.com"
  
  tasks:
    - name: Create users
      ansible.builtin.user:
        name: "{{ item.name }}"
        state: present
      loop: "{{ users }}"
    
    - name: Add SSH keys
      ansible.posix.authorized_key:
        user: "{{ item.0.name }}"
        key: "{{ item.1 }}"
        state: present
      loop: "{{ users | subelements('keys') }}"
```

**Explanation:**
- `subelements` iterates over nested lists
- `item.0` is parent item (user dict)
- `item.1` is subelement (individual key)
- Flattens nested structure
- Perfect for one-to-many relationships

**How it works:**
```
users[0] + keys[0] → alice + key1
users[0] + keys[1] → alice + key2
users[1] + keys[0] → bob + key1
```

---

## Solution 12 — Loop with dict2items

```yaml
---
- name: Loop with dict2items
  hosts: all
  
  vars:
    services:
      http: 80
      https: 443
      ssh: 22
  
  tasks:
    - name: Create services file
      ansible.builtin.lineinfile:
        path: /tmp/services.txt
        line: "{{ item.key }}: {{ item.value }}"
        create: true
        mode: '0644'
      loop: "{{ services | dict2items }}"
```

**Explanation:**
- `dict2items` converts dict to list
- Each item has `key` and `value`
- Allows looping over dictionaries
- `lineinfile` adds each line
- Creates file if doesn't exist

**dict2items transformation:**
```yaml
# Input:
services:
  http: 80
  https: 443

# Output:
- key: http
  value: 80
- key: https
  value: 443
```

---

## Solution 13 — Loop with items2dict

```yaml
---
- name: Loop with items2dict concept
  hosts: all
  become: true
  
  vars:
    user_groups:
      - user: alice
        group: developers
      - user: bob
        group: testers
  
  tasks:
    - name: Create groups
      ansible.builtin.group:
        name: "{{ item.group }}"
        state: present
      loop: "{{ user_groups }}"
    
    - name: Create users with groups
      ansible.builtin.user:
        name: "{{ item.user }}"
        group: "{{ item.group }}"
        state: present
      loop: "{{ user_groups }}"
```

**Explanation:**
- First loop creates all groups
- Second loop creates users with groups
- Each user assigned to their group
- Two-pass approach ensures groups exist
- Common pattern for dependencies

**Verification:**
```bash
ansible all -m command -a "id alice"
ansible all -m command -a "id bob"
```

---

## Solution 14 — Loop with until

```yaml
---
- name: Loop with until
  hosts: all
  become: true
  
  tasks:
    - name: Ensure httpd is started
      ansible.builtin.service:
        name: httpd
        state: started
    
    - name: Wait for httpd to be active
      ansible.builtin.command: systemctl is-active httpd
      register: result
      until: result.stdout == "active"
      retries: 5
      delay: 3
      changed_when: false
```

**Explanation:**
- `until` repeats task until condition true
- `retries` sets maximum attempts
- `delay` sets seconds between attempts
- Fails if condition not met after retries
- Useful for waiting on services

**How it works:**
1. Run command
2. Check if stdout == "active"
3. If false, wait 3 seconds
4. Retry (up to 5 times)
5. Fail if never true

---

## Solution 15 — Complex Loop with Multiple Conditions

```yaml
---
- name: Complex loop with conditions
  hosts: all
  become: true
  
  vars:
    packages:
      - name: httpd
        install: true
        service: true
      - name: nginx
        install: false
        service: false
      - name: firewalld
        install: true
        service: true
  
  tasks:
    - name: Install selected packages
      ansible.builtin.dnf:
        name: "{{ item.name }}"
        state: present
      loop: "{{ packages }}"
      when: item.install
    
    - name: Start and enable selected services
      ansible.builtin.service:
        name: "{{ item.name }}"
        state: started
        enabled: true
      loop: "{{ packages }}"
      when: item.service
```

**Explanation:**
- Data-driven approach
- Each package has metadata
- First task: install if `install: true`
- Second task: start if `service: true`
- Flexible and maintainable
- Easy to add/remove packages

---

## Quick Reference: Loop Syntax

### Basic Loop
```yaml
loop:
  - item1
  - item2
  - item3
```

### Loop with Variable
```yaml
vars:
  my_list:
    - item1
    - item2

tasks:
  - name: Task
    module:
      param: "{{ item }}"
    loop: "{{ my_list }}"
```

### Loop with Dictionary
```yaml
vars:
  users:
    - name: alice
      uid: 1001
    - name: bob
      uid: 1002

tasks:
  - name: Create users
    user:
      name: "{{ item.name }}"
      uid: "{{ item.uid }}"
    loop: "{{ users }}"
```

### Loop with Conditional
```yaml
loop: "{{ my_list }}"
when: item != "skip_this"
```

### Loop with Register
```yaml
- command: "{{ item }}"
  loop:
    - cmd1
    - cmd2
  register: results

- debug:
    var: results
```

---

## Loop Control Options

### Label
```yaml
loop_control:
  label: "{{ item.name }}"
```

### Index Variable
```yaml
loop_control:
  index_var: idx
```

### Pause Between Iterations
```yaml
loop_control:
  pause: 3
```

### Extended Loop Variable
```yaml
loop_control:
  extended: true
# Provides: ansible_loop.index, ansible_loop.first, ansible_loop.last
```

---

## Loop Filters and Lookups

### product (Cartesian Product)
```yaml
loop: "{{ list1 | product(list2) | list }}"
# Creates all combinations
```

### dict2items
```yaml
loop: "{{ my_dict | dict2items }}"
# Converts dict to list with key/value
```

### subelements
```yaml
loop: "{{ users | subelements('keys') }}"
# Flattens nested lists
```

### flatten
```yaml
loop: "{{ nested_list | flatten }}"
# Flattens multi-level lists
```

### zip
```yaml
loop: "{{ list1 | zip(list2) | list }}"
# Pairs items from two lists
```

---

## Common Patterns

### Install Multiple Packages
```yaml
- dnf:
    name: "{{ item }}"
    state: present
  loop:
    - httpd
    - nginx
    - firewalld
```

### Create Multiple Users
```yaml
- user:
    name: "{{ item.name }}"
    uid: "{{ item.uid }}"
    state: present
  loop:
    - {name: alice, uid: 1001}
    - {name: bob, uid: 1002}
```

### Copy Multiple Files
```yaml
- copy:
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
  loop:
    - {src: file1.txt, dest: /tmp/file1.txt}
    - {src: file2.txt, dest: /tmp/file2.txt}
```

### Service Management
```yaml
- service:
    name: "{{ item }}"
    state: started
    enabled: true
  loop:
    - httpd
    - firewalld
```

---

## Best Practices

1. **Use loop instead of with_items:**
   ```yaml
   # Modern
   loop: "{{ items }}"
   
   # Deprecated
   with_items: "{{ items }}"
   ```

2. **Use loop_control for cleaner output:**
   ```yaml
   loop_control:
     label: "{{ item.name }}"
   ```

3. **Use meaningful variable names:**
   ```yaml
   loop_control:
     loop_var: user  # Instead of 'item'
   ```

4. **Combine with conditionals:**
   ```yaml
   loop: "{{ packages }}"
   when: item.install
   ```

5. **Use register for complex logic:**
   ```yaml
   register: results
   # Then process results.results
   ```

6. **Flatten nested structures:**
   ```yaml
   loop: "{{ nested | flatten }}"
   ```

7. **Use until for retries:**
   ```yaml
   until: result.rc == 0
   retries: 5
   delay: 3
   ```

---

## Tips for RHCE Exam

1. **Test loop syntax:**
   ```bash
   ansible-playbook playbook.yml --syntax-check
   ```

2. **Debug loop items:**
   ```yaml
   - debug:
       var: item
     loop: "{{ my_list }}"
   ```

3. **Check registered results:**
   ```yaml
   - debug:
       var: results.results
   ```

4. **Common mistakes:**
   - Forgetting quotes: `loop: {{ items }}` ❌
   - Correct: `loop: "{{ items }}"` ✅
   - Using old syntax: `with_items` ❌
   - Using new syntax: `loop` ✅

5. **Verify loop execution:**
   ```bash
   ansible-playbook playbook.yml -v
   ```

6. **Test with small lists first:**
   - Start with 2-3 items
   - Verify logic works
   - Then scale up

---

Good luck with your RHCE exam preparation! 🚀

Master these loop patterns - they're essential for efficient, scalable playbooks.
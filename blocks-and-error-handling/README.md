# RHCE Killer — Blocks and Error Handling
## EX294: Mastering Ansible Error Recovery

---

> **Intermediate Exam: Error Handling Mastery**
> This exam teaches you how to handle errors gracefully in Ansible.
> Master block/rescue/always, assertions, and error recovery.
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
- Use proper error handling syntax
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** conditionals-and-when, loops-and-iteration

You should know:
- How to write playbooks
- How to use conditionals
- How to use loops
- How to use register

---

## Tasks

### Task 01 — Basic Block Structure (10 pts)

Create a playbook `/home/student/ansible/block-basic.yml` that:
- Runs on **all managed nodes**
- Uses a `block` to group two tasks:
  - Create directory `/opt/app`
  - Create file `/opt/app/config.txt` with content "Configuration"
- Uses `become: true`

**Requirements:**
- Use `block` keyword
- Two tasks inside block
- Both tasks should succeed
- Use `file` and `copy` modules

---

### Task 02 — Block with Rescue (15 pts)

Create a playbook `/home/student/ansible/block-rescue.yml` that:
- Runs on **all managed nodes**
- Has a `block` that tries to:
  - Install a non-existent package `fake-package-xyz`
- Has a `rescue` section that:
  - Displays message "Package installation failed, installing alternative"
  - Installs `httpd` instead
- Uses `become: true`

**Requirements:**
- Use `block` and `rescue` keywords
- Block task should fail
- Rescue should execute
- Use `dnf` module

---

### Task 03 — Block with Always (15 pts)

Create a playbook `/home/student/ansible/block-always.yml` that:
- Runs on **all managed nodes**
- Has a `block` that:
  - Starts `httpd` service
- Has an `always` section that:
  - Displays message "This always runs"
- Uses `become: true`

**Requirements:**
- Use `block` and `always` keywords
- Always section runs regardless of success/failure
- Use `service` and `debug` modules

---

### Task 04 — Complete Block/Rescue/Always (18 pts)

Create a playbook `/home/student/ansible/block-complete.yml` that:
- Runs on **all managed nodes**
- Has a `block` that tries to:
  - Copy file `/tmp/source.txt` to `/tmp/dest.txt` (file doesn't exist)
- Has a `rescue` section that:
  - Creates `/tmp/source.txt` with content "Created by rescue"
  - Copies it to `/tmp/dest.txt`
- Has an `always` section that:
  - Displays "Cleanup completed"

**Requirements:**
- Use `block`, `rescue`, and `always`
- Block fails, rescue fixes it
- Always runs at the end
- Use `copy` and `debug` modules

---

### Task 05 — Ignore Errors (12 pts)

Create a playbook `/home/student/ansible/ignore-errors.yml` that:
- Runs on **all managed nodes**
- Has a task that tries to stop `fake-service` (doesn't exist)
- Uses `ignore_errors: true`
- Has another task that displays "Continuing despite error"
- Uses `become: true`

**Requirements:**
- Use `ignore_errors: true`
- First task fails but doesn't stop playbook
- Second task executes
- Use `service` and `debug` modules

---

### Task 06 — Force Handlers (15 pts)

Create a playbook `/home/student/ansible/force-handlers.yml` that:
- Runs on **all managed nodes**
- Has `force_handlers: true` at play level
- Has a task that:
  - Copies file to `/tmp/test.txt`
  - Notifies handler "display message"
- Has a task that fails (command `/bin/false`)
- Has a handler that displays "Handler executed despite failure"
- Uses `become: true`

**Requirements:**
- Use `force_handlers: true`
- Handler runs even though task fails
- Use `copy`, `command`, and `debug` modules

---

### Task 07 — Assert Module (15 pts)

Create a playbook `/home/student/ansible/assert-basic.yml` that:
- Runs on **all managed nodes**
- Checks that:
  - System has more than 1GB of RAM
  - System is running Rocky Linux
- Uses `assert` module
- Fails if conditions not met

**Requirements:**
- Use `assert` module
- Use `that` parameter with list of conditions
- Use `ansible_memtotal_mb` and `ansible_distribution` facts
- Custom failure message

---

### Task 08 — Assert with Custom Message (12 pts)

Create a playbook `/home/student/ansible/assert-message.yml` that:
- Runs on **all managed nodes**
- Asserts that hostname contains "node"
- Uses custom success and failure messages
- Uses `assert` module

**Requirements:**
- Use `assert` module
- Use `success_msg` parameter
- Use `fail_msg` parameter
- Use `inventory_hostname` variable

---

### Task 09 — Fail Module (12 pts)

Create a playbook `/home/student/ansible/fail-module.yml` that:
- Runs on **all managed nodes**
- Checks if file `/etc/important.conf` exists
- If file doesn't exist, fails with message "Critical file missing"
- Uses `stat` and `fail` modules

**Requirements:**
- Use `stat` module to check file
- Use `register` to capture result
- Use `fail` module with `when` condition
- Custom failure message

---

### Task 10 — Any Errors Fatal (15 pts)

Create a playbook `/home/student/ansible/any-errors-fatal.yml` that:
- Runs on **all managed nodes**
- Has `any_errors_fatal: true` at play level
- Has a task that fails on node1 (use `when: inventory_hostname == "node1.example.com"`)
- Has another task that should not run on any host
- Uses `fail` module

**Requirements:**
- Use `any_errors_fatal: true`
- Playbook stops on all hosts when one fails
- Second task never executes
- Use `fail` and `debug` modules

---

### Task 11 — Max Fail Percentage (15 pts)

Create a playbook `/home/student/ansible/max-fail-percentage.yml` that:
- Runs on **all managed nodes**
- Has `max_fail_percentage: 50` at play level
- Has a task that fails on node1 only
- Has another task that runs on remaining hosts
- Uses `become: true`

**Requirements:**
- Use `max_fail_percentage: 50`
- Playbook continues if less than 50% fail
- Use `fail` module with condition
- Second task executes on node2

---

### Task 12 — Block with Loop (18 pts)

Create a playbook `/home/student/ansible/block-loop.yml` that:
- Runs on **all managed nodes**
- Loops over list: `['app1', 'app2', 'app3']`
- For each item, uses a block to:
  - Create directory `/opt/{{ item }}`
  - Create file `/opt/{{ item }}/config.txt`
- Has rescue that displays "Failed to setup {{ item }}"
- Uses `become: true`

**Requirements:**
- Use `block` with `loop`
- Use `rescue` for error handling
- Use `{{ item }}` in paths
- Use `file` and `copy` modules

---

### Task 13 — Nested Blocks (18 pts)

Create a playbook `/home/student/ansible/block-nested.yml` that:
- Runs on **all managed nodes**
- Has outer block that:
  - Installs `httpd`
  - Has inner block that:
    - Starts `httpd`
    - Enables `httpd`
  - Inner rescue displays "Service setup failed"
- Outer rescue displays "Installation failed"
- Uses `become: true`

**Requirements:**
- Use nested `block` structures
- Each block has its own rescue
- Use `dnf` and `service` modules
- Proper error handling at each level

---

### Task 14 — Changed When with Block (15 pts)

Create a playbook `/home/student/ansible/block-changed.yml` that:
- Runs on **all managed nodes**
- Has a block that:
  - Runs command `echo "test"`
  - Runs command `cat /etc/hostname`
- Uses `changed_when: false` on both tasks
- Has always section that displays "Commands executed"

**Requirements:**
- Use `block` and `always`
- Use `changed_when: false`
- Tasks show as "ok" not "changed"
- Use `command` and `debug` modules

---

### Task 15 — Complex Error Recovery (20 pts)

Create a playbook `/home/student/ansible/block-recovery.yml` that:
- Runs on **all managed nodes**
- Has a block that tries to:
  - Check if `nginx` is installed
  - Start `nginx` service
- Has rescue that:
  - Installs `nginx`
  - Starts `nginx`
- Has always that:
  - Verifies `nginx` is running
  - Displays "Nginx is operational"
- Uses `become: true`

**Requirements:**
- Use `block`, `rescue`, and `always`
- Use `command` to check package
- Use `dnf` and `service` modules
- Complete error recovery workflow
- Use `register` and conditionals

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Basic Block | 10 |
| 02 | Block with Rescue | 15 |
| 03 | Block with Always | 15 |
| 04 | Complete Block/Rescue/Always | 18 |
| 05 | Ignore Errors | 12 |
| 06 | Force Handlers | 15 |
| 07 | Assert Module | 15 |
| 08 | Assert with Messages | 12 |
| 09 | Fail Module | 12 |
| 10 | Any Errors Fatal | 15 |
| 11 | Max Fail Percentage | 15 |
| 12 | Block with Loop | 18 |
| 13 | Nested Blocks | 18 |
| 14 | Changed When with Block | 15 |
| 15 | Complex Error Recovery | 20 |
| **Total** | | **215** |

**Passing score: 70% (151/215 points)**

---

## When you finish

```bash
bash /home/student/exams/blocks-and-error-handling/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**
> 
> These solutions are provided for learning after you complete the exam.
> Try to solve each task on your own first to maximize learning.

---

## Solution 01 — Basic Block Structure

```yaml
---
- name: Basic block structure
  hosts: all
  become: true
  
  tasks:
    - name: Setup application
      block:
        - name: Create app directory
          ansible.builtin.file:
            path: /opt/app
            state: directory
            mode: '0755'
        
        - name: Create config file
          ansible.builtin.copy:
            content: "Configuration\n"
            dest: /opt/app/config.txt
            mode: '0644'
```

**Explanation:**
- `block` groups related tasks
- Tasks execute in order
- All tasks share block-level attributes
- Cleaner organization
- Easier error handling

**Verification:**
```bash
ansible all -m command -a "ls -la /opt/app"
ansible all -m command -a "cat /opt/app/config.txt"
```

---

## Solution 02 — Block with Rescue

```yaml
---
- name: Block with rescue
  hosts: all
  become: true
  
  tasks:
    - name: Try to install package
      block:
        - name: Install fake package
          ansible.builtin.dnf:
            name: fake-package-xyz
            state: present
      
      rescue:
        - name: Display failure message
          ansible.builtin.debug:
            msg: "Package installation failed, installing alternative"
        
        - name: Install httpd instead
          ansible.builtin.dnf:
            name: httpd
            state: present
```

**Explanation:**
- `rescue` runs only if block fails
- Like try/catch in programming
- Allows graceful error recovery
- Playbook continues after rescue
- Useful for fallback logic

**Verification:**
```bash
ansible all -m command -a "rpm -q httpd"
```

---

## Solution 03 — Block with Always

```yaml
---
- name: Block with always
  hosts: all
  become: true
  
  tasks:
    - name: Service management
      block:
        - name: Start httpd service
          ansible.builtin.service:
            name: httpd
            state: started
      
      always:
        - name: Display message
          ansible.builtin.debug:
            msg: "This always runs"
```

**Explanation:**
- `always` runs regardless of success/failure
- Like finally in programming
- Perfect for cleanup tasks
- Runs after block or rescue
- Guaranteed execution

**Use cases:**
- Cleanup temporary files
- Close connections
- Log completion
- Reset state

---

## Solution 04 — Complete Block/Rescue/Always

```yaml
---
- name: Complete block structure
  hosts: all
  
  tasks:
    - name: File operations with error handling
      block:
        - name: Copy non-existent file
          ansible.builtin.copy:
            src: /tmp/source.txt
            dest: /tmp/dest.txt
            mode: '0644'
      
      rescue:
        - name: Create source file
          ansible.builtin.copy:
            content: "Created by rescue\n"
            dest: /tmp/source.txt
            mode: '0644'
        
        - name: Copy file again
          ansible.builtin.copy:
            src: /tmp/source.txt
            dest: /tmp/dest.txt
            remote_src: true
            mode: '0644'
      
      always:
        - name: Display cleanup message
          ansible.builtin.debug:
            msg: "Cleanup completed"
```

**Explanation:**
- Complete error handling workflow
- Block attempts operation
- Rescue fixes the problem
- Always runs cleanup
- Robust error recovery

**Execution flow:**
1. Block fails (file doesn't exist)
2. Rescue creates file and retries
3. Always displays message
4. Playbook succeeds

---

## Solution 05 — Ignore Errors

```yaml
---
- name: Ignore errors example
  hosts: all
  become: true
  
  tasks:
    - name: Try to stop non-existent service
      ansible.builtin.service:
        name: fake-service
        state: stopped
      ignore_errors: true
    
    - name: Continue execution
      ansible.builtin.debug:
        msg: "Continuing despite error"
```

**Explanation:**
- `ignore_errors: true` prevents task failure from stopping playbook
- Task marked as "failed" but playbook continues
- Useful for optional operations
- Different from rescue (no recovery logic)
- Simple error suppression

**When to use:**
- Optional cleanup tasks
- Best-effort operations
- Non-critical tasks

---

## Solution 06 — Force Handlers

```yaml
---
- name: Force handlers example
  hosts: all
  become: true
  force_handlers: true
  
  tasks:
    - name: Copy test file
      ansible.builtin.copy:
        content: "Test content\n"
        dest: /tmp/test.txt
        mode: '0644'
      notify: display message
    
    - name: Intentional failure
      ansible.builtin.command: /bin/false
      ignore_errors: true
  
  handlers:
    - name: display message
      ansible.builtin.debug:
        msg: "Handler executed despite failure"
```

**Explanation:**
- `force_handlers: true` runs notified handlers even if play fails
- Normally handlers don't run if play fails
- Useful for cleanup handlers
- Ensures critical handlers execute
- Play-level setting

**Without force_handlers:**
- Handler wouldn't run after failure

**With force_handlers:**
- Handler runs even after failure

---

## Solution 07 — Assert Module

```yaml
---
- name: Assert basic conditions
  hosts: all
  
  tasks:
    - name: Verify system requirements
      ansible.builtin.assert:
        that:
          - ansible_memtotal_mb > 1024
          - ansible_distribution == "Rocky"
        fail_msg: "System does not meet requirements"
        success_msg: "System requirements verified"
```

**Explanation:**
- `assert` validates conditions
- Fails if any condition false
- All conditions must be true
- Custom messages for clarity
- Better than manual fail checks

**Verification:**
```bash
ansible all -m setup -a "filter=ansible_memtotal_mb"
ansible all -m setup -a "filter=ansible_distribution"
```

---

## Solution 08 — Assert with Custom Message

```yaml
---
- name: Assert with custom messages
  hosts: all
  
  tasks:
    - name: Verify hostname
      ansible.builtin.assert:
        that:
          - "'node' in inventory_hostname"
        success_msg: "Hostname {{ inventory_hostname }} is valid"
        fail_msg: "Hostname {{ inventory_hostname }} does not contain 'node'"
```

**Explanation:**
- Custom messages provide context
- `success_msg` shown when assertion passes
- `fail_msg` shown when assertion fails
- Can use variables in messages
- Helpful for debugging

---

## Solution 09 — Fail Module

```yaml
---
- name: Fail module example
  hosts: all
  
  tasks:
    - name: Check if critical file exists
      ansible.builtin.stat:
        path: /etc/important.conf
      register: file_check
    
    - name: Fail if file missing
      ansible.builtin.fail:
        msg: "Critical file missing"
      when: not file_check.stat.exists
```

**Explanation:**
- `fail` module explicitly fails task
- Use with `when` for conditional failure
- Custom error messages
- More control than assert
- Useful for complex validation

**Alternative with assert:**
```yaml
- assert:
    that: file_check.stat.exists
    fail_msg: "Critical file missing"
```

---

## Solution 10 — Any Errors Fatal

```yaml
---
- name: Any errors fatal example
  hosts: all
  any_errors_fatal: true
  
  tasks:
    - name: Task that fails on node1
      ansible.builtin.fail:
        msg: "Intentional failure"
      when: inventory_hostname == "node1.example.com"
    
    - name: This task never runs
      ansible.builtin.debug:
        msg: "This should not appear"
```

**Explanation:**
- `any_errors_fatal: true` stops all hosts if any host fails
- Normally Ansible continues on other hosts
- Useful for coordinated operations
- All-or-nothing approach
- Play-level setting

**Behavior:**
- Without: node2 continues after node1 fails
- With: all hosts stop when node1 fails

---

## Solution 11 — Max Fail Percentage

```yaml
---
- name: Max fail percentage example
  hosts: all
  max_fail_percentage: 50
  
  tasks:
    - name: Task that fails on node1
      ansible.builtin.fail:
        msg: "Intentional failure"
      when: inventory_hostname == "node1.example.com"
    
    - name: This runs on remaining hosts
      ansible.builtin.debug:
        msg: "Continuing on {{ inventory_hostname }}"
```

**Explanation:**
- `max_fail_percentage` sets failure threshold
- Playbook continues if failures below threshold
- 50% means playbook stops if more than half fail
- Useful for rolling updates
- Prevents cascading failures

**With 2 hosts:**
- 1 failure = 50% (at threshold, continues)
- 2 failures = 100% (stops)

---

## Solution 12 — Block with Loop

```yaml
---
- name: Block with loop
  hosts: all
  become: true
  
  tasks:
    - name: Setup applications
      block:
        - name: Create app directory
          ansible.builtin.file:
            path: "/opt/{{ item }}"
            state: directory
            mode: '0755'
        
        - name: Create config file
          ansible.builtin.copy:
            content: "Config for {{ item }}\n"
            dest: "/opt/{{ item }}/config.txt"
            mode: '0644'
      
      rescue:
        - name: Display failure
          ansible.builtin.debug:
            msg: "Failed to setup {{ item }}"
      
      loop:
        - app1
        - app2
        - app3
```

**Explanation:**
- Block can have loop
- Each iteration has its own block/rescue
- `{{ item }}` available in block and rescue
- Error in one iteration doesn't affect others
- Powerful combination

**Execution:**
- Loop iteration 1: block → rescue if fails
- Loop iteration 2: block → rescue if fails
- Loop iteration 3: block → rescue if fails

---

## Solution 13 — Nested Blocks

```yaml
---
- name: Nested blocks
  hosts: all
  become: true
  
  tasks:
    - name: Setup web server
      block:
        - name: Install httpd
          ansible.builtin.dnf:
            name: httpd
            state: present
        
        - name: Configure service
          block:
            - name: Start httpd
              ansible.builtin.service:
                name: httpd
                state: started
            
            - name: Enable httpd
              ansible.builtin.service:
                name: httpd
                enabled: true
          
          rescue:
            - name: Service setup failed
              ansible.builtin.debug:
                msg: "Service setup failed"
      
      rescue:
        - name: Installation failed
          ansible.builtin.debug:
            msg: "Installation failed"
```

**Explanation:**
- Blocks can be nested
- Each level has its own error handling
- Inner rescue handles inner failures
- Outer rescue handles outer failures
- Hierarchical error handling

**Error flow:**
- Inner block fails → inner rescue
- Outer block fails → outer rescue
- Granular error control

---

## Solution 14 — Changed When with Block

```yaml
---
- name: Block with changed_when
  hosts: all
  
  tasks:
    - name: Run commands
      block:
        - name: Echo test
          ansible.builtin.command: echo "test"
          changed_when: false
        
        - name: Read hostname
          ansible.builtin.command: cat /etc/hostname
          changed_when: false
      
      always:
        - name: Display completion
          ansible.builtin.debug:
            msg: "Commands executed"
```

**Explanation:**
- `changed_when: false` prevents "changed" status
- Useful for read-only operations
- Cleaner playbook output
- Better idempotency reporting
- Can be used with blocks

---

## Solution 15 — Complex Error Recovery

```yaml
---
- name: Complex error recovery
  hosts: all
  become: true
  
  tasks:
    - name: Ensure nginx is operational
      block:
        - name: Check if nginx is installed
          ansible.builtin.command: rpm -q nginx
          register: nginx_check
          failed_when: false
          changed_when: false
        
        - name: Start nginx
          ansible.builtin.service:
            name: nginx
            state: started
          when: nginx_check.rc == 0
      
      rescue:
        - name: Install nginx
          ansible.builtin.dnf:
            name: nginx
            state: present
        
        - name: Start nginx after installation
          ansible.builtin.service:
            name: nginx
            state: started
      
      always:
        - name: Verify nginx is running
          ansible.builtin.command: systemctl is-active nginx
          register: nginx_status
          changed_when: false
        
        - name: Display status
          ansible.builtin.debug:
            msg: "Nginx is operational"
          when: nginx_status.stdout == "active"
```

**Explanation:**
- Complete error recovery workflow
- Check → Try → Rescue → Verify
- Handles missing package scenario
- Ensures service is running
- Production-ready pattern

**Workflow:**
1. Check if installed
2. Try to start
3. If fails, install and start
4. Always verify status
5. Display confirmation

---

## Quick Reference: Error Handling

### Block Structure
```yaml
block:
  - task1
  - task2
rescue:
  - recovery_task
always:
  - cleanup_task
```

### Ignore Errors
```yaml
- task:
    module: params
  ignore_errors: true
```

### Assert
```yaml
- assert:
    that:
      - condition1
      - condition2
    fail_msg: "Failure message"
    success_msg: "Success message"
```

### Fail
```yaml
- fail:
    msg: "Error message"
  when: condition
```

### Force Handlers
```yaml
- name: Play
  hosts: all
  force_handlers: true
```

### Any Errors Fatal
```yaml
- name: Play
  hosts: all
  any_errors_fatal: true
```

### Max Fail Percentage
```yaml
- name: Play
  hosts: all
  max_fail_percentage: 25
```

---

## Common Patterns

### Try-Catch Pattern
```yaml
block:
  - name: Try operation
    module: params
rescue:
  - name: Handle error
    module: params
```

### Try-Finally Pattern
```yaml
block:
  - name: Main operation
    module: params
always:
  - name: Cleanup
    module: params
```

### Complete Pattern
```yaml
block:
  - name: Try operation
    module: params
rescue:
  - name: Handle error
    module: params
always:
  - name: Cleanup
    module: params
```

### Validation Pattern
```yaml
- stat:
    path: /path/to/file
  register: result

- assert:
    that: result.stat.exists
    fail_msg: "File missing"
```

---

## Best Practices

1. **Use blocks for related tasks:**
   ```yaml
   block:
     - install_task
     - configure_task
     - start_task
   ```

2. **Always have rescue for critical operations:**
   ```yaml
   block:
     - critical_task
   rescue:
     - recovery_task
   ```

3. **Use always for cleanup:**
   ```yaml
   always:
     - cleanup_temp_files
     - close_connections
   ```

4. **Prefer assert over manual checks:**
   ```yaml
   # Good
   - assert:
       that: condition
   
   # Less clear
   - fail:
       msg: "Failed"
     when: not condition
   ```

5. **Use meaningful error messages:**
   ```yaml
   fail_msg: "Database connection failed: {{ error_details }}"
   ```

6. **Combine with conditionals:**
   ```yaml
   block:
     - task
   rescue:
     - recovery
   when: should_run
   ```

---

## Tips for RHCE Exam

1. **Test error paths:**
   ```bash
   # Intentionally cause errors to test rescue
   ansible-playbook playbook.yml
   ```

2. **Verify always runs:**
   - Check that always section executes
   - Even when block succeeds
   - Even when rescue runs

3. **Common mistakes:**
   - Forgetting `rescue` keyword
   - Wrong indentation
   - Using `rescue` without `block`
   - Not testing error scenarios

4. **Debug error handling:**
   ```yaml
   - debug:
       var: ansible_failed_task
     when: ansible_failed_task is defined
   ```

5. **Check handler execution:**
   ```bash
   ansible-playbook playbook.yml -v
   # Look for "RUNNING HANDLER" messages
   ```

6. **Verify assertions:**
   ```bash
   ansible all -m setup -a "filter=ansible_*"
   # Check facts before asserting
   ```

---

Good luck with your RHCE exam preparation! 🚀

Master error handling - it's essential for writing robust, production-ready playbooks.
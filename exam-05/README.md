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

Fix logic errors in `/home/student/ansible/broken_logic.yml`.

**Expected Behavior:**
- Create users only on production servers (hostname contains 'prod')
- Install dev tools only on development servers
- Configure firewall based on environment
- Use correct variable precedence

---

### Task 03: Advanced Host Patterns (15 points)

Create `host_patterns.yml` demonstrating advanced patterns:
- All web servers except node1
- Intersection of web and database groups
- Union of app and database groups
- Regex pattern matching
- Use `delegate_to` and `run_once`

---

### Task 04: Dynamic Includes vs Static Imports (20 points)

Create comprehensive example showing difference between `include_*` and `import_*`:
- Create task files in `tasks/` directory
- Use `import_tasks` for static inclusion
- Use `include_tasks` for dynamic inclusion
- Show variable scope differences
- Demonstrate tag behavior differences

---

### Task 05: Advanced Tagging Strategy (15 points)

Create `tagged_deployment.yml` with hierarchical tags:
- `always` - runs always
- `never` - never runs unless explicitly called
- `setup`, `deploy`, `config`, `verify`
- Tag combinations: `frontend+deploy`, `backend+config`

---

### Task 06: Task Delegation (15 points)

Create `delegation.yml` demonstrating:
- `delegate_to` for specific hosts
- `local_action` for control node
- `run_once` for single execution
- `serial` for rolling updates
- `throttle` for rate limiting

---

### Task 07: Magic Variables (15 points)

Create `magic_vars.yml` using:
- `hostvars` to access other host variables
- `groups` to iterate inventory groups
- `group_names` to check host's groups
- `inventory_hostname` vs `ansible_hostname`
- `omit` for conditional parameters
- `lookup` and `query` plugins

---

### Task 08: Ansible-lint and Best Practices (15 points)

Create `best_practices.yml` that:
- Passes `ansible-lint` with no errors
- Uses FQCN for all modules
- Has descriptive task names
- Implements idempotency
- Uses `changed_when` and `failed_when`
- Avoids `command`/`shell` when possible
- Uses `no_log` for sensitive data

---

### Task 09: Performance Optimization (20 points)

Create `optimized.yml` with performance best practices:
- Enable fact caching (JSON file)
- Use `gather_facts: false` where appropriate
- Implement `async` and `poll`
- Use `strategy: free`
- Configure pipelining
- Optimize connection reuse

**ansible.cfg:**
```ini
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 3600
pipelining = True
forks = 10
```

---

### Task 10: Comprehensive Integration (25 points)

Create `final_integration.yml` integrating everything:
- Multiple plays for different host groups
- Use roles, includes, and imports
- Proper error handling with block/rescue
- Advanced conditionals and loops
- Delegation and local actions
- Magic variables
- Follow all best practices
- Comprehensive tagging
- Pre_tasks and post_tasks

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
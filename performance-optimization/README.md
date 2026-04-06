# RHCE Killer — Performance Optimization
## EX294: Optimizing Ansible Performance

---

> **Advanced Exam: Performance Mastery**
> This exam teaches you how to optimize Ansible playbook performance.
> Master async, serial, forks, caching, and optimization techniques.
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
- Focus on performance optimization
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** playbooks-fundamentals, roles-basics

You should know:
- How to write playbooks
- Basic module usage
- How to use roles
- Command line basics

---

## Tasks

### Task 01 — Async Task Execution (15 pts)

Create playbook `async-basic.yml` that:
- Runs long command asynchronously
- Uses `async: 300` (5 minutes timeout)
- Uses `poll: 0` (fire and forget)
- Checks status later

**Requirements:**
- Use `async` parameter
- Use `poll` parameter
- Task runs in background
- Status checkable

---

### Task 02 — Async with Polling (18 pts)

Create playbook `async-poll.yml` that:
- Runs async task with `async: 60`
- Polls every 5 seconds with `poll: 5`
- Waits for completion
- Shows progress

**Requirements:**
- Use `async` and `poll`
- Task completes
- Shows polling
- Proper timeout

---

### Task 03 — Async Status Check (18 pts)

Create playbook `async-status.yml` that:
- Starts async task
- Registers job ID
- Uses `async_status` to check
- Waits for completion

**Requirements:**
- Use `async` with `poll: 0`
- Register result
- Use `async_status` module
- Check until finished

---

### Task 04 — Serial Execution (15 pts)

Create playbook `serial-basic.yml` that:
- Runs on all hosts
- Uses `serial: 1` to run one at a time
- Shows sequential execution

**Requirements:**
- Use `serial` keyword
- One host at a time
- Sequential execution
- All hosts processed

---

### Task 05 — Serial with Percentage (15 pts)

Create playbook `serial-percent.yml` that:
- Uses `serial: "50%"`
- Processes half hosts at a time
- Shows batched execution

**Requirements:**
- Use percentage format
- Batched processing
- Proper calculation
- All hosts processed

---

### Task 06 — Serial with List (18 pts)

Create playbook `serial-list.yml` that:
- Uses `serial: [1, 2, 5]`
- First batch: 1 host
- Second batch: 2 hosts
- Third batch: 5 hosts

**Requirements:**
- Use list format
- Multiple batch sizes
- Progressive scaling
- All hosts processed

---

### Task 07 — Configure Forks (15 pts)

Modify `ansible.cfg` to:
- Set `forks = 10`
- Increase parallel execution
- Test with playbook

**Requirements:**
- Modify ansible.cfg
- Set forks value
- Verify setting
- Faster execution

---

### Task 08 — Strategy: Free (18 pts)

Create playbook `strategy-free.yml` that:
- Uses `strategy: free`
- Hosts don't wait for each other
- Fastest execution
- Shows independent progress

**Requirements:**
- Use `strategy: free`
- Hosts run independently
- No synchronization
- Faster completion

---

### Task 09 — Strategy: Linear (12 pts)

Create playbook `strategy-linear.yml` that:
- Uses `strategy: linear` (default)
- All hosts wait at each task
- Synchronized execution

**Requirements:**
- Use `strategy: linear`
- Synchronized execution
- All hosts together
- Default behavior

---

### Task 10 — Fact Caching (20 pts)

Configure fact caching in `ansible.cfg`:
- Enable JSON file caching
- Set cache timeout
- Set cache directory
- Test caching

**Requirements:**
- Configure in ansible.cfg
- Use jsonfile plugin
- Set timeout
- Verify caching works

---

### Task 11 — Disable Fact Gathering (12 pts)

Create playbook `no-facts.yml` that:
- Disables fact gathering with `gather_facts: false`
- Runs faster
- No facts available

**Requirements:**
- Set `gather_facts: false`
- Faster execution
- No fact collection
- Tasks run without facts

---

### Task 12 — Selective Fact Gathering (18 pts)

Create playbook `selective-facts.yml` that:
- Gathers only specific facts
- Uses `gather_subset`
- Reduces collection time

**Requirements:**
- Use `gather_subset`
- Specify subsets
- Faster than full gather
- Only needed facts

---

### Task 13 — Pipelining (15 pts)

Enable pipelining in `ansible.cfg`:
- Set `pipelining = True`
- Reduces SSH operations
- Faster execution

**Requirements:**
- Enable in ansible.cfg
- SSH pipelining active
- Fewer connections
- Faster playbooks

---

### Task 14 — ControlMaster (15 pts)

Configure SSH ControlMaster in `ansible.cfg`:
- Enable connection multiplexing
- Set ControlPersist
- Reuse connections

**Requirements:**
- Configure ssh_args
- Enable ControlMaster
- Set persistence time
- Faster connections

---

### Task 15 — Mitogen Strategy (20 pts)

Install and configure Mitogen:
- Install mitogen
- Configure in ansible.cfg
- Use mitogen_linear strategy
- Significant speedup

**Requirements:**
- Install mitogen
- Configure strategy
- Test performance
- Verify improvement

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | Async Basic | 15 |
| 02 | Async with Polling | 18 |
| 03 | Async Status Check | 18 |
| 04 | Serial Execution | 15 |
| 05 | Serial Percentage | 15 |
| 06 | Serial List | 18 |
| 07 | Configure Forks | 15 |
| 08 | Strategy Free | 18 |
| 09 | Strategy Linear | 12 |
| 10 | Fact Caching | 20 |
| 11 | Disable Facts | 12 |
| 12 | Selective Facts | 18 |
| 13 | Pipelining | 15 |
| 14 | ControlMaster | 15 |
| 15 | Mitogen Strategy | 20 |
| **Total** | | **244** |

**Passing score: 70% (171/244 points)**

---

## When you finish

```bash
bash /home/student/exams/performance-optimization/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

---

## Solution 01 — Async Task Execution

**Playbook: async-basic.yml**
```yaml
---
- name: Async execution
  hosts: all
  
  tasks:
    - name: Run long task asynchronously
      ansible.builtin.command: sleep 30
      async: 300
      poll: 0
      register: long_task
    
    - name: Display job ID
      ansible.builtin.debug:
        msg: "Job ID: {{ long_task.ansible_job_id }}"
```

**Explanation:**
- `async: 300` - Maximum time (seconds)
- `poll: 0` - Don't wait (fire and forget)
- Task runs in background
- Returns immediately

---

## Solution 02 — Async with Polling

**Playbook: async-poll.yml**
```yaml
---
- name: Async with polling
  hosts: all
  
  tasks:
    - name: Run task with polling
      ansible.builtin.command: sleep 20
      async: 60
      poll: 5
      register: polled_task
    
    - name: Display result
      ansible.builtin.debug:
        msg: "Task completed"
```

**Explanation:**
- `async: 60` - Timeout
- `poll: 5` - Check every 5 seconds
- Waits for completion
- Shows progress

---

## Solution 03 — Async Status Check

**Playbook: async-status.yml**
```yaml
---
- name: Async status check
  hosts: all
  
  tasks:
    - name: Start async task
      ansible.builtin.command: sleep 30
      async: 300
      poll: 0
      register: async_result
    
    - name: Wait for task completion
      ansible.builtin.async_status:
        jid: "{{ async_result.ansible_job_id }}"
      register: job_result
      until: job_result.finished
      retries: 30
      delay: 5
    
    - name: Display final status
      ansible.builtin.debug:
        var: job_result
```

**Explanation:**
- Start task with `poll: 0`
- Register job ID
- Use `async_status` to check
- Loop until finished

---

## Solution 04 — Serial Execution

**Playbook: serial-basic.yml**
```yaml
---
- name: Serial execution
  hosts: all
  serial: 1
  
  tasks:
    - name: Display hostname
      ansible.builtin.debug:
        msg: "Processing {{ inventory_hostname }}"
    
    - name: Simulate work
      ansible.builtin.command: sleep 5
      changed_when: false
```

**Explanation:**
- `serial: 1` - One host at a time
- Sequential execution
- Useful for rolling updates
- Controlled deployment

---

## Solution 05 — Serial with Percentage

**Playbook: serial-percent.yml**
```yaml
---
- name: Serial with percentage
  hosts: all
  serial: "50%"
  
  tasks:
    - name: Display batch info
      ansible.builtin.debug:
        msg: "Processing {{ inventory_hostname }} in batch"
    
    - name: Simulate deployment
      ansible.builtin.command: sleep 3
      changed_when: false
```

**Explanation:**
- `serial: "50%"` - Half hosts at a time
- Percentage of total hosts
- Scales with inventory size
- Balanced approach

---

## Solution 06 — Serial with List

**Playbook: serial-list.yml**
```yaml
---
- name: Serial with list
  hosts: all
  serial:
    - 1
    - 2
    - 5
  
  tasks:
    - name: Display batch
      ansible.builtin.debug:
        msg: "Batch processing {{ inventory_hostname }}"
    
    - name: Deploy application
      ansible.builtin.command: echo "Deploying"
      changed_when: false
```

**Explanation:**
- First batch: 1 host
- Second batch: 2 hosts
- Third batch: 5 hosts
- Progressive scaling

---

## Solution 07 — Configure Forks

**Modify ansible.cfg:**
```ini
[defaults]
inventory = inventory
remote_user = student
forks = 10
```

**Test playbook:**
```yaml
---
- name: Test forks
  hosts: all
  
  tasks:
    - name: Parallel execution
      ansible.builtin.ping:
```

**Explanation:**
- `forks = 10` - 10 parallel processes
- Default is 5
- More forks = more parallelism
- Limited by system resources

**Verify:**
```bash
ansible-config dump | grep forks
```

---

## Solution 08 — Strategy: Free

**Playbook: strategy-free.yml**
```yaml
---
- name: Free strategy
  hosts: all
  strategy: free
  
  tasks:
    - name: Task 1
      ansible.builtin.command: sleep {{ 10 | random }}
      changed_when: false
    
    - name: Task 2
      ansible.builtin.debug:
        msg: "{{ inventory_hostname }} finished task 1"
    
    - name: Task 3
      ansible.builtin.command: sleep {{ 5 | random }}
      changed_when: false
```

**Explanation:**
- `strategy: free` - No synchronization
- Hosts run independently
- Fastest hosts finish first
- Maximum parallelism

---

## Solution 09 — Strategy: Linear

**Playbook: strategy-linear.yml**
```yaml
---
- name: Linear strategy
  hosts: all
  strategy: linear
  
  tasks:
    - name: Task 1
      ansible.builtin.debug:
        msg: "All hosts wait here"
    
    - name: Task 2
      ansible.builtin.debug:
        msg: "All hosts together"
    
    - name: Task 3
      ansible.builtin.debug:
        msg: "Synchronized execution"
```

**Explanation:**
- `strategy: linear` - Default
- All hosts wait at each task
- Synchronized execution
- Predictable order

---

## Solution 10 — Fact Caching

**Modify ansible.cfg:**
```ini
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400

[inventory]
cache = yes
cache_plugin = jsonfile
cache_timeout = 3600
cache_connection = /tmp/ansible_cache
```

**Test playbook:**
```yaml
---
- name: Test fact caching
  hosts: all
  
  tasks:
    - name: Display cached fact
      ansible.builtin.debug:
        var: ansible_distribution
```

**Explanation:**
- Facts cached to JSON files
- Timeout: 86400 seconds (24 hours)
- Subsequent runs use cache
- Much faster

**Verify:**
```bash
ls -la /tmp/ansible_facts/
```

---

## Solution 11 — Disable Fact Gathering

**Playbook: no-facts.yml**
```yaml
---
- name: No fact gathering
  hosts: all
  gather_facts: false
  
  tasks:
    - name: Task without facts
      ansible.builtin.debug:
        msg: "Running without facts"
    
    - name: Install package
      ansible.builtin.dnf:
        name: vim-enhanced
        state: present
      become: true
```

**Explanation:**
- `gather_facts: false` - Skip gathering
- Faster playbook start
- Use when facts not needed
- Significant time savings

---

## Solution 12 — Selective Fact Gathering

**Playbook: selective-facts.yml**
```yaml
---
- name: Selective fact gathering
  hosts: all
  gather_facts: true
  gather_subset:
    - '!all'
    - '!min'
    - network
    - hardware
  
  tasks:
    - name: Display network facts
      ansible.builtin.debug:
        var: ansible_default_ipv4
    
    - name: Display hardware facts
      ansible.builtin.debug:
        var: ansible_memtotal_mb
```

**Explanation:**
- `gather_subset` - Specify what to gather
- `!all` - Exclude all
- `network` - Include network facts
- `hardware` - Include hardware facts
- Faster than full gather

**Available subsets:**
- `all` - All facts
- `min` - Minimum facts
- `hardware` - Hardware facts
- `network` - Network facts
- `virtual` - Virtualization facts
- `ohai` - Ohai facts
- `facter` - Facter facts

---

## Solution 13 — Pipelining

**Modify ansible.cfg:**
```ini
[defaults]
inventory = inventory
remote_user = student

[ssh_connection]
pipelining = True
```

**Explanation:**
- Reduces SSH operations
- Sends commands through existing connection
- Requires `requiretty` disabled in sudoers
- Significant performance improvement

**Verify:**
```bash
ansible-config dump | grep pipelining
```

**Note:** Requires sudo without requiretty:
```bash
# /etc/sudoers.d/ansible
Defaults:student !requiretty
```

---

## Solution 14 — ControlMaster

**Modify ansible.cfg:**
```ini
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
```

**Explanation:**
- `ControlMaster=auto` - Enable multiplexing
- `ControlPersist=60s` - Keep connection 60 seconds
- Reuses SSH connections
- Faster subsequent connections

**Test:**
```bash
time ansible all -m ping
# Run again - should be faster
time ansible all -m ping
```

---

## Solution 15 — Mitogen Strategy

**Install Mitogen:**
```bash
pip3 install mitogen
```

**Modify ansible.cfg:**
```ini
[defaults]
strategy_plugins = /usr/local/lib/python3.9/site-packages/ansible_mitogen/plugins/strategy
strategy = mitogen_linear

[ssh_connection]
pipelining = True
```

**Test playbook:**
```yaml
---
- name: Test mitogen
  hosts: all
  
  tasks:
    - name: Ping test
      ansible.builtin.ping:
```

**Explanation:**
- Mitogen significantly faster
- Reduces Python startup overhead
- Persistent connections
- Can be 2-10x faster

**Benchmark:**
```bash
# Without mitogen
time ansible-playbook test.yml

# With mitogen
time ansible-playbook test.yml
```

---

## Quick Reference: Performance Settings

### ansible.cfg Optimizations
```ini
[defaults]
forks = 20
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400

[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

### Playbook Optimizations
```yaml
---
- name: Optimized playbook
  hosts: all
  gather_facts: false  # Or selective
  strategy: free       # Or mitogen_linear
  serial: "25%"        # If needed
  
  tasks:
    - name: Async task
      command: long_command
      async: 300
      poll: 0
```

---

## Quick Reference: Async Patterns

### Fire and Forget
```yaml
- command: long_task
  async: 300
  poll: 0
```

### Wait with Polling
```yaml
- command: long_task
  async: 300
  poll: 5
```

### Check Status Later
```yaml
- command: long_task
  async: 300
  poll: 0
  register: job

- async_status:
    jid: "{{ job.ansible_job_id }}"
  register: result
  until: result.finished
  retries: 30
```

---

## Quick Reference: Serial Patterns

### Fixed Number
```yaml
serial: 1      # One at a time
serial: 5      # Five at a time
```

### Percentage
```yaml
serial: "25%"  # Quarter at a time
serial: "50%"  # Half at a time
```

### Progressive
```yaml
serial:
  - 1
  - 2
  - 5
  - "25%"
```

---

## Best Practices

1. **Use fact caching:**
   ```ini
   fact_caching = jsonfile
   fact_caching_timeout = 86400
   ```

2. **Disable facts when not needed:**
   ```yaml
   gather_facts: false
   ```

3. **Use selective fact gathering:**
   ```yaml
   gather_subset:
     - '!all'
     - network
   ```

4. **Enable pipelining:**
   ```ini
   pipelining = True
   ```

5. **Use ControlMaster:**
   ```ini
   ssh_args = -o ControlMaster=auto -o ControlPersist=60s
   ```

6. **Increase forks:**
   ```ini
   forks = 20
   ```

7. **Use async for long tasks:**
   ```yaml
   async: 300
   poll: 0
   ```

8. **Use free strategy when possible:**
   ```yaml
   strategy: free
   ```

---

## Performance Comparison

### Typical Improvements

| Optimization | Speed Improvement |
|--------------|-------------------|
| Fact caching | 2-5x faster |
| Disable facts | 2-3x faster |
| Pipelining | 1.5-2x faster |
| ControlMaster | 1.5-2x faster |
| Mitogen | 2-10x faster |
| Async tasks | Depends on task |
| Free strategy | 1.5-3x faster |

---

## Tips for RHCE Exam

1. **Know async syntax:**
   ```yaml
   async: 300
   poll: 0
   ```

2. **Know serial options:**
   ```yaml
   serial: 1
   serial: "50%"
   serial: [1, 2, 5]
   ```

3. **Configure ansible.cfg:**
   ```ini
   forks = 10
   pipelining = True
   ```

4. **Disable facts when not needed:**
   ```yaml
   gather_facts: false
   ```

5. **Common mistakes:**
   - Forgetting to register async jobs
   - Wrong async_status syntax
   - Not setting forks high enough
   - Gathering facts unnecessarily

6. **Test performance:**
   ```bash
   time ansible-playbook playbook.yml
   ```

---

Good luck with your RHCE exam preparation! 🚀

Master performance optimization - it's essential for efficient, scalable automation.
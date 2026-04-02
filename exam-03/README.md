# RHCE Killer — Exam 03: Roles and Collections

**Duration:** 4 hours  
**Passing Score:** 70% (84/120 points)  
**Focus:** Ansible Roles, Collections, and Galaxy

---

## ⚠️ IMPORTANT INSTRUCTIONS

1. **Work Directory:** All work must be done in `/home/student/ansible/`
2. **Inventory:** Use the existing inventory at `/home/student/ansible/inventory`
3. **Ansible Config:** Use `/home/student/ansible/ansible.cfg`
4. **Test Your Work:** Run `bash ~/exams/exam-03/grade.sh` to check your progress
5. **Time Management:** You have 4 hours. Budget your time wisely.
6. **Read Carefully:** Each task specifies exact requirements. Follow them precisely.

---

## 📋 EXAM TASKS

### Task 01: Create a Custom Role from Scratch (15 points)

Create a role named `webserver` using `ansible-galaxy init` that:
- Installs and configures Apache (httpd)
- Creates a custom index.html page
- Ensures the service is running and enabled
- Opens firewall port 80

**Requirements:**
- Role location: `/home/student/ansible/roles/webserver`
- Must use proper role structure (tasks, handlers, templates, defaults)
- Create a playbook `site.yml` that applies this role to the `web` group
- The index.html should display "Welcome to {{ ansible_hostname }}"

**Verification:**
```bash
curl http://node1
curl http://node2
```

---

### Task 02: Role with Variables (defaults and vars) (10 points)

Create a role named `appserver` that demonstrates proper variable precedence:
- Role location: `/home/student/ansible/roles/appserver`
- Define default variables in `defaults/main.yml`:
  - `app_port: 8080`
  - `app_user: appuser`
  - `app_dir: /opt/app`
- Define role variables in `vars/main.yml`:
  - `app_name: myapp`
  - `app_version: 1.0`
- Create tasks that:
  - Create the app user
  - Create the app directory with proper ownership
  - Create a config file at `/etc/myapp.conf` with all variables

**Requirements:**
- Create playbook `appserver.yml` that uses this role on `app` group
- Override `app_port` to `9090` in the playbook
- The config file should contain all variable values

---

### Task 03: Role with Templates and Handlers (15 points)

Create a role named `database` that:
- Installs MariaDB (mariadb-server)
- Uses a Jinja2 template for `/etc/my.cnf.d/custom.cnf`
- Configures the following in the template:
  - `max_connections` based on available RAM (< 2GB: 50, 2-4GB: 100, > 4GB: 200)
  - `port` from variable (default: 3306)
  - `bind-address` from variable (default: 0.0.0.0)
- Implements handlers to restart MariaDB when config changes
- Ensures MariaDB is running and enabled

**Requirements:**
- Role location: `/home/student/ansible/roles/database`
- Template location: `roles/database/templates/custom.cnf.j2`
- Handler name: `restart mariadb`
- Create playbook `database.yml` for `database` group
- Use conditionals in template based on `ansible_memtotal_mb`

---

### Task 04: Role Dependencies (10 points)

Create a role named `wordpress` that depends on other roles:
- Role location: `/home/student/ansible/roles/wordpress`
- Add dependencies in `meta/main.yml`:
  - Depends on `webserver` role
  - Depends on `database` role
- The wordpress role should:
  - Install PHP and required modules
  - Create a simple PHP info page at `/var/www/html/info.php`

**Requirements:**
- Properly configure `meta/main.yml` with dependencies
- Create playbook `wordpress.yml` that only calls the wordpress role
- Dependencies should execute automatically
- Apply to `web` group

---

### Task 05: Install Collections from Galaxy (10 points)

Install the following collections from Ansible Galaxy:
- `community.general`
- `ansible.posix`
- `community.mysql`

**Requirements:**
- Install to the default collections path
- Verify installation with `ansible-galaxy collection list`
- Document the installed versions in `/home/student/ansible/collections.txt`

---

### Task 06: Use Collection Modules (10 points)

Create a playbook `posix_demo.yml` that uses modules from `ansible.posix` collection:
- Use `ansible.posix.firewalld` to configure firewall rules on all nodes:
  - Allow SSH (permanent)
  - Allow HTTP (permanent)
  - Reload firewalld
- Use `ansible.posix.selinux` to ensure SELinux is in enforcing mode
- Use `ansible.posix.sysctl` to set `net.ipv4.ip_forward=1`

**Requirements:**
- Use FQCN (Fully Qualified Collection Names) for all modules
- Apply to `all` hosts
- All changes should be permanent

---

### Task 07: Collections Requirements File (10 points)

Create a collections requirements file that automates collection installation:
- File location: `/home/student/ansible/requirements.yml`
- Include the following collections with specific versions:
  - `community.general` version `>=8.0.0`
  - `ansible.posix` version `>=1.5.0`
  - `community.mysql` version `>=3.0.0`
- Add a role requirement:
  - Role: `geerlingguy.apache` from Galaxy

**Requirements:**
- Proper YAML format
- Include both collections and roles sections
- Test installation: `ansible-galaxy install -r requirements.yml`

---

### Task 08: Use External Roles from Galaxy (15 points)

Use an external role from Ansible Galaxy:
- Install role `geerlingguy.nginx` from Galaxy
- Create playbook `nginx.yml` that:
  - Uses the geerlingguy.nginx role
  - Configures nginx on `web` group
  - Overrides the following variables:
    - `nginx_vhosts`: Configure a virtual host for port 8080
    - `nginx_remove_default_vhost: true`
- Ensure nginx is running and accessible

**Requirements:**
- Install role to `/home/student/ansible/roles/`
- Create proper playbook with variable overrides
- Verify nginx is listening on port 8080

---

### Task 09: System Roles (RHEL System Roles) (15 points)

Use RHEL System Roles to configure system settings:
- Install the `rhel-system-roles` package (if not already installed)
- Create playbook `system_config.yml` that uses system roles:
  - Use `rhel-system-roles.timesync` to configure NTP:
    - NTP servers: `0.pool.ntp.org`, `1.pool.ntp.org`
  - Use `rhel-system-roles.selinux` to ensure SELinux is enforcing
  - Use `rhel-system-roles.firewall` to configure firewall rules

**Requirements:**
- Apply to `all` hosts
- Use proper role names from rhel-system-roles
- Configure all required variables for each role
- Verify services are running

---

### Task 10: Complex Role with Multiple Plays (10 points)

Create a comprehensive playbook `deploy_stack.yml` that:
- Uses multiple roles in a specific order
- Has separate plays for different host groups
- Implements tags for selective execution

**Requirements:**
- Play 1: Configure database servers
  - Hosts: `database` group
  - Roles: `database`
  - Tags: `database`, `backend`
- Play 2: Configure application servers
  - Hosts: `app` group
  - Roles: `appserver`
  - Tags: `app`, `backend`
- Play 3: Configure web servers
  - Hosts: `web` group
  - Roles: `webserver`, `wordpress`
  - Tags: `web`, `frontend`
- Add pre_tasks and post_tasks:
  - Pre: Display message "Starting deployment"
  - Post: Display message "Deployment complete"

**Verification:**
```bash
ansible-playbook deploy_stack.yml --tags database
ansible-playbook deploy_stack.yml --tags frontend
ansible-playbook deploy_stack.yml
```

---

## 🎯 GRADING

Run the grading script to check your work:
```bash
bash ~/exams/exam-03/grade.sh
```

The script will verify:
- ✓ Role structures and files
- ✓ Proper use of variables, templates, and handlers
- ✓ Collection installations and usage
- ✓ External role integration
- ✓ System roles configuration
- ✓ Playbook syntax and execution

---

## 📚 USEFUL COMMANDS

### Role Management
```bash
# Create a new role
ansible-galaxy init <role_name>

# List installed roles
ansible-galaxy role list

# Install role from Galaxy
ansible-galaxy role install <author.role_name>

# Remove a role
ansible-galaxy role remove <role_name>
```

### Collection Management
```bash
# Install a collection
ansible-galaxy collection install <namespace.collection>

# List installed collections
ansible-galaxy collection list

# Install from requirements file
ansible-galaxy install -r requirements.yml

# Install collections to specific path
ansible-galaxy collection install <namespace.collection> -p ./collections
```

### Testing Roles
```bash
# Check role syntax
ansible-playbook <playbook.yml> --syntax-check

# Run in check mode
ansible-playbook <playbook.yml> --check

# List tasks
ansible-playbook <playbook.yml> --list-tasks

# List tags
ansible-playbook <playbook.yml> --list-tags

# Run specific tags
ansible-playbook <playbook.yml> --tags "web,database"

# Skip specific tags
ansible-playbook <playbook.yml> --skip-tags "database"
```

### Role Structure
```
roles/
└── role_name/
    ├── defaults/
    │   └── main.yml          # Default variables (lowest precedence)
    ├── vars/
    │   └── main.yml          # Role variables (high precedence)
    ├── tasks/
    │   └── main.yml          # Main task list
    ├── handlers/
    │   └── main.yml          # Handlers
    ├── templates/
    │   └── template.j2       # Jinja2 templates
    ├── files/
    │   └── file.txt          # Static files
    ├── meta/
    │   └── main.yml          # Role metadata and dependencies
    └── README.md             # Role documentation
```

---

## ⚠️ SOLUTIONS BELOW - DO NOT SCROLL UNLESS YOU WANT SPOILERS! ⚠️

<br><br><br><br><br><br><br><br><br><br>
<br><br><br><br><br><br><br><br><br><br>
<br><br><br><br><br><br><br><br><br><br>

---

# 🔓 SOLUTIONS

## Task 01: Create a Custom Role from Scratch

### Step 1: Create the role structure
```bash
cd /home/student/ansible
ansible-galaxy init roles/webserver
```

### Step 2: Define default variables
**File:** `roles/webserver/defaults/main.yml`
```yaml
---
# defaults file for webserver
http_port: 80
server_name: "{{ ansible_hostname }}"
```

### Step 3: Create tasks
**File:** `roles/webserver/tasks/main.yml`
```yaml
---
# tasks file for webserver
- name: Install Apache
  ansible.builtin.dnf:
    name: httpd
    state: present

- name: Create custom index.html from template
  ansible.builtin.template:
    src: index.html.j2
    dest: /var/www/html/index.html
    owner: apache
    group: apache
    mode: '0644'
  notify: restart apache

- name: Ensure Apache is started and enabled
  ansible.builtin.service:
    name: httpd
    state: started
    enabled: true

- name: Configure firewall for HTTP
  ansible.posix.firewalld:
    service: http
    permanent: true
    state: enabled
    immediate: true
```

### Step 4: Create template
**File:** `roles/webserver/templates/index.html.j2`
```html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
</head>
<body>
    <h1>Welcome to {{ ansible_hostname }}</h1>
    <p>Server: {{ server_name }}</p>
    <p>Port: {{ http_port }}</p>
</body>
</html>
```

### Step 5: Create handlers
**File:** `roles/webserver/handlers/main.yml`
```yaml
---
# handlers file for webserver
- name: restart apache
  ansible.builtin.service:
    name: httpd
    state: restarted
```

### Step 6: Create site playbook
**File:** `site.yml`
```yaml
---
- name: Configure web servers
  hosts: web
  become: true
  roles:
    - webserver
```

### Step 7: Run the playbook
```bash
ansible-playbook site.yml
```

### Step 8: Verify
```bash
curl http://node1
curl http://node2
```

---

## Task 02: Role with Variables (defaults and vars)

### Step 1: Create the role
```bash
ansible-galaxy init roles/appserver
```

### Step 2: Define default variables
**File:** `roles/appserver/defaults/main.yml`
```yaml
---
# defaults file for appserver
app_port: 8080
app_user: appuser
app_dir: /opt/app
```

### Step 3: Define role variables
**File:** `roles/appserver/vars/main.yml`
```yaml
---
# vars file for appserver
app_name: myapp
app_version: 1.0
```

### Step 4: Create tasks
**File:** `roles/appserver/tasks/main.yml`
```yaml
---
# tasks file for appserver
- name: Create application user
  ansible.builtin.user:
    name: "{{ app_user }}"
    system: true
    create_home: false
    shell: /sbin/nologin

- name: Create application directory
  ansible.builtin.file:
    path: "{{ app_dir }}"
    state: directory
    owner: "{{ app_user }}"
    group: "{{ app_user }}"
    mode: '0755'

- name: Create application config file
  ansible.builtin.template:
    src: myapp.conf.j2
    dest: /etc/myapp.conf
    owner: root
    group: root
    mode: '0644'
```

### Step 5: Create template
**File:** `roles/appserver/templates/myapp.conf.j2`
```ini
# Application Configuration
[application]
name = {{ app_name }}
version = {{ app_version }}
port = {{ app_port }}
user = {{ app_user }}
directory = {{ app_dir }}

[server]
hostname = {{ ansible_hostname }}
ip_address = {{ ansible_default_ipv4.address }}
```

### Step 6: Create playbook
**File:** `appserver.yml`
```yaml
---
- name: Configure application servers
  hosts: app
  become: true
  roles:
    - role: appserver
      app_port: 9090
```

### Step 7: Run the playbook
```bash
ansible-playbook appserver.yml
```

### Step 8: Verify
```bash
ansible app -m shell -a "cat /etc/myapp.conf"
ansible app -m shell -a "id appuser"
ansible app -m shell -a "ls -ld /opt/app"
```

---

## Task 03: Role with Templates and Handlers

### Step 1: Create the role
```bash
ansible-galaxy init roles/database
```

### Step 2: Define default variables
**File:** `roles/database/defaults/main.yml`
```yaml
---
# defaults file for database
db_port: 3306
db_bind_address: 0.0.0.0
```

### Step 3: Create tasks
**File:** `roles/database/tasks/main.yml`
```yaml
---
# tasks file for database
- name: Install MariaDB
  ansible.builtin.dnf:
    name:
      - mariadb-server
      - python3-PyMySQL
    state: present

- name: Create custom MariaDB configuration
  ansible.builtin.template:
    src: custom.cnf.j2
    dest: /etc/my.cnf.d/custom.cnf
    owner: root
    group: root
    mode: '0644'
  notify: restart mariadb

- name: Ensure MariaDB is started and enabled
  ansible.builtin.service:
    name: mariadb
    state: started
    enabled: true

- name: Configure firewall for MySQL
  ansible.posix.firewalld:
    port: "{{ db_port }}/tcp"
    permanent: true
    state: enabled
    immediate: true
```

### Step 4: Create template
**File:** `roles/database/templates/custom.cnf.j2`
```ini
[mysqld]
# Port configuration
port = {{ db_port }}

# Bind address
bind-address = {{ db_bind_address }}

# Max connections based on available RAM
{% if ansible_memtotal_mb < 2048 %}
max_connections = 50
{% elif ansible_memtotal_mb >= 2048 and ansible_memtotal_mb <= 4096 %}
max_connections = 100
{% else %}
max_connections = 200
{% endif %}

# Performance settings
{% if ansible_memtotal_mb >= 4096 %}
innodb_buffer_pool_size = 1G
{% else %}
innodb_buffer_pool_size = 256M
{% endif %}

# Server identification
server-id = {{ ansible_default_ipv4.address.split('.')[-1] }}
```

### Step 5: Create handlers
**File:** `roles/database/handlers/main.yml`
```yaml
---
# handlers file for database
- name: restart mariadb
  ansible.builtin.service:
    name: mariadb
    state: restarted
```

### Step 6: Create playbook
**File:** `database.yml`
```yaml
---
- name: Configure database servers
  hosts: database
  become: true
  roles:
    - database
```

### Step 7: Run the playbook
```bash
ansible-playbook database.yml
```

### Step 8: Verify
```bash
ansible database -m shell -a "systemctl status mariadb"
ansible database -m shell -a "cat /etc/my.cnf.d/custom.cnf"
```

---

## Task 04: Role Dependencies

### Step 1: Create the role
```bash
ansible-galaxy init roles/wordpress
```

### Step 2: Configure dependencies
**File:** `roles/wordpress/meta/main.yml`
```yaml
---
dependencies:
  - role: webserver
  - role: database

galaxy_info:
  author: student
  description: WordPress installation role
  company: RHCE Killer
  license: MIT
  min_ansible_version: 2.9
  platforms:
    - name: EL
      versions:
        - 8
        - 9
  galaxy_tags:
    - wordpress
    - web
```

### Step 3: Define variables
**File:** `roles/wordpress/defaults/main.yml`
```yaml
---
# defaults file for wordpress
php_packages:
  - php
  - php-mysqlnd
  - php-fpm
  - php-json
  - php-gd
```

### Step 4: Create tasks
**File:** `roles/wordpress/tasks/main.yml`
```yaml
---
# tasks file for wordpress
- name: Install PHP and required modules
  ansible.builtin.dnf:
    name: "{{ php_packages }}"
    state: present

- name: Create PHP info page
  ansible.builtin.copy:
    content: |
      <?php
      phpinfo();
      ?>
    dest: /var/www/html/info.php
    owner: apache
    group: apache
    mode: '0644'

- name: Ensure PHP-FPM is started and enabled
  ansible.builtin.service:
    name: php-fpm
    state: started
    enabled: true

- name: Restart Apache to load PHP module
  ansible.builtin.service:
    name: httpd
    state: restarted
```

### Step 5: Create playbook
**File:** `wordpress.yml`
```yaml
---
- name: Deploy WordPress stack
  hosts: web
  become: true
  roles:
    - wordpress
```

### Step 6: Run the playbook
```bash
ansible-playbook wordpress.yml
```

### Step 7: Verify
```bash
curl http://node1/info.php
ansible web -m shell -a "rpm -q php"
```

---

## Task 05: Install Collections from Galaxy

### Step 1: Install collections
```bash
cd /home/student/ansible
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.mysql
```

### Step 2: Verify installation
```bash
ansible-galaxy collection list
```

### Step 3: Document versions
```bash
ansible-galaxy collection list | grep -E "community.general|ansible.posix|community.mysql" > collections.txt
```

**File:** `collections.txt`
```
community.general    X.X.X
ansible.posix        X.X.X
community.mysql      X.X.X
```

---

## Task 06: Use Collection Modules

### Create the playbook
**File:** `posix_demo.yml`
```yaml
---
- name: Demonstrate ansible.posix collection usage
  hosts: all
  become: true
  tasks:
    - name: Configure firewall - Allow SSH
      ansible.posix.firewalld:
        service: ssh
        permanent: true
        state: enabled
        immediate: true

    - name: Configure firewall - Allow HTTP
      ansible.posix.firewalld:
        service: http
        permanent: true
        state: enabled
        immediate: true

    - name: Reload firewalld
      ansible.builtin.service:
        name: firewalld
        state: reloaded

    - name: Ensure SELinux is in enforcing mode
      ansible.posix.selinux:
        policy: targeted
        state: enforcing

    - name: Enable IP forwarding
      ansible.posix.sysctl:
        name: net.ipv4.ip_forward
        value: '1'
        state: present
        reload: true
        sysctl_set: true

    - name: Verify sysctl setting
      ansible.builtin.command: sysctl net.ipv4.ip_forward
      register: sysctl_result
      changed_when: false

    - name: Display sysctl result
      ansible.builtin.debug:
        var: sysctl_result.stdout
```

### Run the playbook
```bash
ansible-playbook posix_demo.yml
```

### Verify
```bash
ansible all -m shell -a "firewall-cmd --list-services"
ansible all -m shell -a "getenforce"
ansible all -m shell -a "sysctl net.ipv4.ip_forward"
```

---

## Task 07: Collections Requirements File

### Create requirements file
**File:** `requirements.yml`
```yaml
---
collections:
  - name: community.general
    version: ">=8.0.0"
  
  - name: ansible.posix
    version: ">=1.5.0"
  
  - name: community.mysql
    version: ">=3.0.0"

roles:
  - name: geerlingguy.apache
    src: geerlingguy.apache
```

### Install from requirements
```bash
ansible-galaxy install -r requirements.yml
```

### Verify installation
```bash
ansible-galaxy collection list
ansible-galaxy role list
```

---

## Task 08: Use External Roles from Galaxy

### Step 1: Install the role
```bash
ansible-galaxy role install geerlingguy.nginx -p /home/student/ansible/roles/
```

### Step 2: Create playbook
**File:** `nginx.yml`
```yaml
---
- name: Configure Nginx web servers
  hosts: web
  become: true
  vars:
    nginx_remove_default_vhost: true
    nginx_vhosts:
      - listen: "8080"
        server_name: "{{ ansible_hostname }}"
        root: "/var/www/html"
        index: "index.html index.htm"
        locations:
          - path: "/"
            try_files: "$uri $uri/ =404"
  roles:
    - geerlingguy.nginx
```

### Step 3: Run the playbook
```bash
ansible-playbook nginx.yml
```

### Step 4: Verify
```bash
ansible web -m shell -a "systemctl status nginx"
ansible web -m shell -a "ss -tlnp | grep 8080"
curl http://node1:8080
```

---

## Task 09: System Roles (RHEL System Roles)

### Step 1: Install system roles (if needed)
```bash
sudo dnf install rhel-system-roles -y
```

### Step 2: Create playbook
**File:** `system_config.yml`
```yaml
---
- name: Configure system settings using RHEL System Roles
  hosts: all
  become: true
  vars:
    # Timesync role variables
    timesync_ntp_servers:
      - hostname: 0.pool.ntp.org
        iburst: true
      - hostname: 1.pool.ntp.org
        iburst: true
    
    # SELinux role variables
    selinux_policy: targeted
    selinux_state: enforcing
    
    # Firewall role variables
    firewall:
      - service: ssh
        state: enabled
      - service: http
        state: enabled
      - service: https
        state: enabled
  
  roles:
    - role: rhel-system-roles.timesync
    - role: rhel-system-roles.selinux
    - role: rhel-system-roles.firewall
```

### Step 3: Run the playbook
```bash
ansible-playbook system_config.yml
```

### Step 4: Verify
```bash
ansible all -m shell -a "systemctl status chronyd"
ansible all -m shell -a "getenforce"
ansible all -m shell -a "firewall-cmd --list-services"
ansible all -m shell -a "chronyc sources"
```

---

## Task 10: Complex Role with Multiple Plays

### Create comprehensive playbook
**File:** `deploy_stack.yml`
```yaml
---
- name: Deploy Database Tier
  hosts: database
  become: true
  tags:
    - database
    - backend
  
  pre_tasks:
    - name: Display deployment start message
      ansible.builtin.debug:
        msg: "Starting deployment on {{ inventory_hostname }}"
  
  roles:
    - database
  
  post_tasks:
    - name: Display deployment complete message
      ansible.builtin.debug:
        msg: "Deployment complete on {{ inventory_hostname }}"

- name: Deploy Application Tier
  hosts: app
  become: true
  tags:
    - app
    - backend
  
  pre_tasks:
    - name: Display deployment start message
      ansible.builtin.debug:
        msg: "Starting deployment on {{ inventory_hostname }}"
  
  roles:
    - appserver
  
  post_tasks:
    - name: Display deployment complete message
      ansible.builtin.debug:
        msg: "Deployment complete on {{ inventory_hostname }}"

- name: Deploy Web Tier
  hosts: web
  become: true
  tags:
    - web
    - frontend
  
  pre_tasks:
    - name: Display deployment start message
      ansible.builtin.debug:
        msg: "Starting deployment on {{ inventory_hostname }}"
  
  roles:
    - webserver
    - wordpress
  
  post_tasks:
    - name: Display deployment complete message
      ansible.builtin.debug:
        msg: "Deployment complete on {{ inventory_hostname }}"

- name: Final verification
  hosts: all
  become: true
  tags:
    - always
  
  tasks:
    - name: Gather service facts
      ansible.builtin.service_facts:
    
    - name: Display running services
      ansible.builtin.debug:
        msg: "{{ ansible_facts.services.keys() | select('match', '(httpd|mariadb|nginx)') | list }}"
```

### Run with different tags
```bash
# Run only database tier
ansible-playbook deploy_stack.yml --tags database

# Run only frontend tier
ansible-playbook deploy_stack.yml --tags frontend

# Run backend tiers
ansible-playbook deploy_stack.yml --tags backend

# Run everything
ansible-playbook deploy_stack.yml

# List all tags
ansible-playbook deploy_stack.yml --list-tags

# List all tasks
ansible-playbook deploy_stack.yml --list-tasks
```

### Verify
```bash
ansible all -m shell -a "systemctl list-units --type=service --state=running | grep -E '(httpd|mariadb|nginx)'"
```

---

## 🎓 EXAM TIPS

1. **Role Structure:** Always use `ansible-galaxy init` to create proper role structure
2. **Variable Precedence:** Remember: defaults < vars < playbook vars < command line
3. **FQCN:** Use Fully Qualified Collection Names in production playbooks
4. **Dependencies:** Test roles individually before adding dependencies
5. **Tags:** Use tags for selective execution and testing
6. **Documentation:** Read role README files and collection documentation
7. **Testing:** Always test with `--check` and `--syntax-check` first
8. **Galaxy:** Use `ansible-galaxy` for both roles and collections
9. **System Roles:** RHEL System Roles are pre-tested and production-ready
10. **Handlers:** Use handlers for service restarts to avoid unnecessary restarts

---

## 📖 ADDITIONAL RESOURCES

- Ansible Galaxy: https://galaxy.ansible.com
- Collection Index: https://docs.ansible.com/ansible/latest/collections/index.html
- Role Development: https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html
- RHEL System Roles: https://access.redhat.com/articles/3050101

---

**Good luck with your exam! 🚀**
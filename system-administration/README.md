# RHCE Killer — System Administration
## EX294: Complete System Administration with Ansible

---

> **Advanced Exam: Real-World System Administration**
> This exam combines all skills for complete system administration.
> Master users, packages, services, storage, networking, and security.
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
- All playbooks must be created under `/home/student/ansible/`
- Use all Ansible skills learned
- Each task specifies its point value — partial credit is **not** given

---

## Prerequisites

**Required:** All previous exams

You should know:
- Playbooks, roles, templates
- Variables, facts, conditionals
- Loops, blocks, error handling
- Vault, SSH, debugging
- Performance optimization

---

## Tasks

### Task 01 — Complete User Management (20 pts)

Create playbook `users-complete.yml` that:
- Creates users from list with UIDs
- Sets passwords (encrypted with vault)
- Adds SSH keys
- Sets shell and home directory
- Creates groups first

**Requirements:**
- Multiple users
- Encrypted passwords
- SSH key management
- Group membership
- Proper permissions

---

### Task 02 — Package Management Suite (18 pts)

Create playbook `packages-suite.yml` that:
- Installs base packages
- Installs role-specific packages
- Removes unwanted packages
- Updates all packages
- Uses conditionals for OS

**Requirements:**
- Multiple package operations
- OS-specific logic
- Package groups
- Update cache
- Error handling

---

### Task 03 — Service Management (18 pts)

Create playbook `services-mgmt.yml` that:
- Starts and enables services
- Stops and disables services
- Restarts services on config change
- Uses handlers
- Checks service status

**Requirements:**
- Multiple services
- Handlers for restarts
- Enable/disable
- Start/stop
- Status verification

---

### Task 04 — Firewall Configuration (20 pts)

Create playbook `firewall-config.yml` that:
- Installs and enables firewalld
- Opens specific ports
- Adds services to zones
- Sets default zone
- Makes changes permanent

**Requirements:**
- Install firewalld
- Configure zones
- Open ports
- Add services
- Permanent rules

---

### Task 05 — SELinux Management (18 pts)

Create playbook `selinux-mgmt.yml` that:
- Sets SELinux mode
- Sets file contexts
- Restores contexts
- Manages booleans
- Verifies status

**Requirements:**
- Set enforcing/permissive
- File context management
- Boolean management
- Context restoration
- Status check

---

### Task 06 — Storage Management (22 pts)

Create playbook `storage-mgmt.yml` that:
- Creates logical volumes
- Formats filesystems
- Mounts filesystems
- Updates /etc/fstab
- Sets permissions

**Requirements:**
- LVM operations
- Filesystem creation
- Mount management
- Persistent mounts
- Proper permissions

---

### Task 07 — Network Configuration (20 pts)

Create playbook `network-config.yml` that:
- Configures static IP (if needed)
- Sets hostname
- Manages /etc/hosts
- Configures DNS
- Tests connectivity

**Requirements:**
- Hostname management
- Hosts file
- DNS configuration
- Network testing
- Idempotent

---

### Task 08 — Cron Job Management (15 pts)

Create playbook `cron-mgmt.yml` that:
- Creates cron jobs
- Sets schedule
- Manages user crontabs
- Creates system cron files
- Proper permissions

**Requirements:**
- User cron jobs
- System cron jobs
- Various schedules
- Proper syntax
- File permissions

---

### Task 09 — Log Management (18 pts)

Create playbook `log-mgmt.yml` that:
- Configures rsyslog
- Sets log rotation
- Creates custom logs
- Sets permissions
- Tests logging

**Requirements:**
- Rsyslog configuration
- Logrotate setup
- Custom log files
- Proper permissions
- Verification

---

### Task 10 — Time Synchronization (15 pts)

Create playbook `time-sync.yml` that:
- Installs chrony
- Configures NTP servers
- Enables and starts service
- Sets timezone
- Verifies sync

**Requirements:**
- Install chrony
- Configure servers
- Service management
- Timezone setting
- Status check

---

### Task 11 — SSH Hardening (20 pts)

Create playbook `ssh-harden.yml` that:
- Disables root login
- Disables password auth
- Changes SSH port (optional)
- Sets key-only auth
- Restarts sshd

**Requirements:**
- Modify sshd_config
- Security settings
- Backup original
- Restart service
- Verify changes

---

### Task 12 — System Updates (18 pts)

Create playbook `system-update.yml` that:
- Updates all packages
- Reboots if needed
- Waits for system
- Verifies services
- Sends notification

**Requirements:**
- Package updates
- Conditional reboot
- Wait for boot
- Service verification
- Notification

---

### Task 13 — Backup Configuration (22 pts)

Create playbook `backup-config.yml` that:
- Backs up config files
- Creates archive
- Stores remotely
- Sets retention
- Verifies backup

**Requirements:**
- File collection
- Archive creation
- Remote storage
- Retention policy
- Verification

---

### Task 14 — Monitoring Setup (20 pts)

Create playbook `monitoring-setup.yml` that:
- Installs monitoring agent
- Configures metrics
- Sets up alerts
- Creates dashboards
- Tests monitoring

**Requirements:**
- Agent installation
- Configuration
- Alert setup
- Dashboard creation
- Testing

---

### Task 15 — Complete Web Server Stack (25 pts)

Create playbook `webserver-stack.yml` that:
- Installs Apache/Nginx
- Installs PHP
- Installs MariaDB
- Configures virtual hosts
- Deploys application
- Sets up SSL
- Configures firewall

**Requirements:**
- Full LAMP/LEMP stack
- Virtual host config
- Database setup
- Application deployment
- SSL certificates
- Firewall rules
- All services running

---

## Scoring

| Task | Topic | Points |
|------|-------|--------|
| 01 | User Management | 20 |
| 02 | Package Management | 18 |
| 03 | Service Management | 18 |
| 04 | Firewall Configuration | 20 |
| 05 | SELinux Management | 18 |
| 06 | Storage Management | 22 |
| 07 | Network Configuration | 20 |
| 08 | Cron Job Management | 15 |
| 09 | Log Management | 18 |
| 10 | Time Synchronization | 15 |
| 11 | SSH Hardening | 20 |
| 12 | System Updates | 18 |
| 13 | Backup Configuration | 22 |
| 14 | Monitoring Setup | 20 |
| 15 | Web Server Stack | 25 |
| **Total** | | **289** |

**Passing score: 70% (202/289 points)**

---

## When you finish

```bash
bash /home/student/exams/system-administration/grade.sh
```

---
---

# 📚 SOLUTIONS

> **⚠️ WARNING: Do not look at solutions until you've attempted the exam!**

---

## Solution 01 — Complete User Management

**Playbook: users-complete.yml**
```yaml
---
- name: Complete user management
  hosts: all
  become: true
  
  vars:
    user_list:
      - name: alice
        uid: 2001
        groups: wheel
        shell: /bin/bash
        password: "{{ vault_alice_password }}"
        ssh_key: "ssh-rsa AAAAB3... alice@example.com"
      
      - name: bob
        uid: 2002
        groups: developers
        shell: /bin/bash
        password: "{{ vault_bob_password }}"
        ssh_key: "ssh-rsa AAAAB4... bob@example.com"
  
  tasks:
    - name: Create groups
      ansible.builtin.group:
        name: "{{ item }}"
        state: present
      loop:
        - wheel
        - developers
    
    - name: Create users
      ansible.builtin.user:
        name: "{{ item.name }}"
        uid: "{{ item.uid }}"
        groups: "{{ item.groups }}"
        shell: "{{ item.shell }}"
        password: "{{ item.password | password_hash('sha512') }}"
        state: present
      loop: "{{ user_list }}"
      no_log: true
    
    - name: Add SSH keys
      ansible.posix.authorized_key:
        user: "{{ item.name }}"
        key: "{{ item.ssh_key }}"
        state: present
      loop: "{{ user_list }}"
```

---

## Solution 02 — Package Management Suite

**Playbook: packages-suite.yml**
```yaml
---
- name: Package management
  hosts: all
  become: true
  
  tasks:
    - name: Install base packages
      ansible.builtin.dnf:
        name:
          - vim-enhanced
          - git
          - wget
          - curl
          - htop
        state: present
    
    - name: Install web server packages
      ansible.builtin.dnf:
        name:
          - httpd
          - mod_ssl
        state: present
      when: "'webservers' in group_names"
    
    - name: Install database packages
      ansible.builtin.dnf:
        name:
          - mariadb-server
          - python3-PyMySQL
        state: present
      when: "'databases' in group_names"
    
    - name: Remove unwanted packages
      ansible.builtin.dnf:
        name:
          - telnet
          - rsh
        state: absent
    
    - name: Update all packages
      ansible.builtin.dnf:
        name: '*'
        state: latest
        update_cache: true
```

---

## Solution 03 — Service Management

**Playbook: services-mgmt.yml**
```yaml
---
- name: Service management
  hosts: all
  become: true
  
  tasks:
    - name: Start and enable services
      ansible.builtin.service:
        name: "{{ item }}"
        state: started
        enabled: true
      loop:
        - firewalld
        - chronyd
    
    - name: Copy httpd config
      ansible.builtin.copy:
        src: httpd.conf
        dest: /etc/httpd/conf/httpd.conf
        mode: '0644'
      notify: restart httpd
      when: "'webservers' in group_names"
    
    - name: Verify service status
      ansible.builtin.service_facts:
    
    - name: Display service status
      ansible.builtin.debug:
        msg: "Firewalld is {{ ansible_facts.services['firewalld.service'].state }}"
  
  handlers:
    - name: restart httpd
      ansible.builtin.service:
        name: httpd
        state: restarted
```

---

## Solution 04 — Firewall Configuration

**Playbook: firewall-config.yml**
```yaml
---
- name: Firewall configuration
  hosts: all
  become: true
  
  tasks:
    - name: Install firewalld
      ansible.builtin.dnf:
        name: firewalld
        state: present
    
    - name: Start and enable firewalld
      ansible.builtin.service:
        name: firewalld
        state: started
        enabled: true
    
    - name: Set default zone
      ansible.posix.firewalld:
        zone: public
        state: enabled
        permanent: true
        immediate: true
    
    - name: Open HTTP port
      ansible.posix.firewalld:
        service: http
        zone: public
        permanent: true
        immediate: true
        state: enabled
    
    - name: Open HTTPS port
      ansible.posix.firewalld:
        service: https
        zone: public
        permanent: true
        immediate: true
        state: enabled
    
    - name: Open custom port
      ansible.posix.firewalld:
        port: 8080/tcp
        zone: public
        permanent: true
        immediate: true
        state: enabled
```

---

## Solution 05 — SELinux Management

**Playbook: selinux-mgmt.yml**
```yaml
---
- name: SELinux management
  hosts: all
  become: true
  
  tasks:
    - name: Set SELinux to enforcing
      ansible.posix.selinux:
        policy: targeted
        state: enforcing
    
    - name: Set file context
      community.general.sefcontext:
        target: '/opt/webapp(/.*)?'
        setype: httpd_sys_content_t
        state: present
    
    - name: Apply file context
      ansible.builtin.command: restorecon -Rv /opt/webapp
      when: false  # Only if directory exists
    
    - name: Set SELinux boolean
      ansible.posix.seboolean:
        name: httpd_can_network_connect
        state: true
        persistent: true
    
    - name: Verify SELinux status
      ansible.builtin.command: getenforce
      register: selinux_status
      changed_when: false
    
    - name: Display SELinux status
      ansible.builtin.debug:
        var: selinux_status.stdout
```

---

## Solution 06 — Storage Management

**Playbook: storage-mgmt.yml**
```yaml
---
- name: Storage management
  hosts: all
  become: true
  
  tasks:
    - name: Create volume group
      community.general.lvg:
        vg: vg_data
        pvs: /dev/sdb
        state: present
      when: false  # Only if /dev/sdb exists
    
    - name: Create logical volume
      community.general.lvol:
        vg: vg_data
        lv: lv_app
        size: 10G
        state: present
      when: false
    
    - name: Create filesystem
      community.general.filesystem:
        fstype: xfs
        dev: /dev/vg_data/lv_app
      when: false
    
    - name: Create mount point
      ansible.builtin.file:
        path: /mnt/app_data
        state: directory
        mode: '0755'
    
    - name: Mount filesystem
      ansible.posix.mount:
        path: /mnt/app_data
        src: /dev/vg_data/lv_app
        fstype: xfs
        state: mounted
      when: false
    
    - name: Set permissions
      ansible.builtin.file:
        path: /mnt/app_data
        owner: apache
        group: apache
        mode: '0755'
      when: false
```

---

## Solution 07 — Network Configuration

**Playbook: network-config.yml**
```yaml
---
- name: Network configuration
  hosts: all
  become: true
  
  tasks:
    - name: Set hostname
      ansible.builtin.hostname:
        name: "{{ inventory_hostname }}"
    
    - name: Update /etc/hosts
      ansible.builtin.lineinfile:
        path: /etc/hosts
        line: "{{ ansible_default_ipv4.address }} {{ inventory_hostname }} {{ inventory_hostname_short }}"
        state: present
    
    - name: Configure DNS
      ansible.builtin.copy:
        content: |
          nameserver 8.8.8.8
          nameserver 8.8.4.4
        dest: /etc/resolv.conf
        mode: '0644'
    
    - name: Test connectivity
      ansible.builtin.ping:
    
    - name: Test DNS resolution
      ansible.builtin.command: nslookup google.com
      register: dns_test
      changed_when: false
      failed_when: dns_test.rc != 0
```

---

## Solution 08 — Cron Job Management

**Playbook: cron-mgmt.yml**
```yaml
---
- name: Cron job management
  hosts: all
  become: true
  
  tasks:
    - name: Create user cron job
      ansible.builtin.cron:
        name: "Backup user data"
        minute: "0"
        hour: "2"
        job: "/usr/local/bin/backup.sh"
        user: student
        state: present
    
    - name: Create system cron job
      ansible.builtin.copy:
        content: |
          0 3 * * * root /usr/local/bin/system-backup.sh
        dest: /etc/cron.d/system-backup
        mode: '0644'
    
    - name: Create hourly cron job
      ansible.builtin.cron:
        name: "Check disk space"
        special_time: hourly
        job: "df -h > /var/log/diskspace.log"
        user: root
        state: present
```

---

## Solution 09 — Log Management

**Playbook: log-mgmt.yml**
```yaml
---
- name: Log management
  hosts: all
  become: true
  
  tasks:
    - name: Configure rsyslog
      ansible.builtin.lineinfile:
        path: /etc/rsyslog.conf
        line: "local0.* /var/log/myapp.log"
        state: present
      notify: restart rsyslog
    
    - name: Create log file
      ansible.builtin.file:
        path: /var/log/myapp.log
        state: touch
        mode: '0644'
        modification_time: preserve
        access_time: preserve
    
    - name: Configure logrotate
      ansible.builtin.copy:
        content: |
          /var/log/myapp.log {
              daily
              rotate 7
              compress
              delaycompress
              missingok
              notifempty
              create 0644 root root
          }
        dest: /etc/logrotate.d/myapp
        mode: '0644'
  
  handlers:
    - name: restart rsyslog
      ansible.builtin.service:
        name: rsyslog
        state: restarted
```

---

## Solution 10 — Time Synchronization

**Playbook: time-sync.yml**
```yaml
---
- name: Time synchronization
  hosts: all
  become: true
  
  tasks:
    - name: Install chrony
      ansible.builtin.dnf:
        name: chrony
        state: present
    
    - name: Configure NTP servers
      ansible.builtin.lineinfile:
        path: /etc/chrony.conf
        regexp: '^server '
        line: 'server {{ item }}'
        state: present
      loop:
        - 0.pool.ntp.org
        - 1.pool.ntp.org
      notify: restart chronyd
    
    - name: Start and enable chronyd
      ansible.builtin.service:
        name: chronyd
        state: started
        enabled: true
    
    - name: Set timezone
      community.general.timezone:
        name: America/New_York
    
    - name: Verify time sync
      ansible.builtin.command: chronyc tracking
      register: chrony_status
      changed_when: false
    
    - name: Display sync status
      ansible.builtin.debug:
        var: chrony_status.stdout_lines
  
  handlers:
    - name: restart chronyd
      ansible.builtin.service:
        name: chronyd
        state: restarted
```

---

## Solution 15 — Complete Web Server Stack

**Playbook: webserver-stack.yml**
```yaml
---
- name: Complete web server stack
  hosts: webservers
  become: true
  
  vars:
    domain_name: example.com
    db_name: webapp
    db_user: webappuser
    db_password: "{{ vault_db_password }}"
  
  tasks:
    # Install packages
    - name: Install web server
      ansible.builtin.dnf:
        name:
          - httpd
          - mod_ssl
          - php
          - php-mysqlnd
          - php-fpm
        state: present
    
    - name: Install database
      ansible.builtin.dnf:
        name:
          - mariadb-server
          - python3-PyMySQL
        state: present
    
    # Configure Apache
    - name: Create virtual host config
      ansible.builtin.template:
        src: vhost.conf.j2
        dest: "/etc/httpd/conf.d/{{ domain_name }}.conf"
        mode: '0644'
      notify: restart httpd
    
    - name: Create document root
      ansible.builtin.file:
        path: "/var/www/{{ domain_name }}"
        state: directory
        owner: apache
        group: apache
        mode: '0755'
    
    # Deploy application
    - name: Deploy index.php
      ansible.builtin.copy:
        content: |
          <?php
          phpinfo();
          ?>
        dest: "/var/www/{{ domain_name }}/index.php"
        owner: apache
        group: apache
        mode: '0644'
    
    # Configure database
    - name: Start MariaDB
      ansible.builtin.service:
        name: mariadb
        state: started
        enabled: true
    
    - name: Create database
      community.mysql.mysql_db:
        name: "{{ db_name }}"
        state: present
        login_unix_socket: /var/lib/mysql/mysql.sock
    
    - name: Create database user
      community.mysql.mysql_user:
        name: "{{ db_user }}"
        password: "{{ db_password }}"
        priv: "{{ db_name }}.*:ALL"
        state: present
        login_unix_socket: /var/lib/mysql/mysql.sock
      no_log: true
    
    # Configure SSL
    - name: Generate self-signed certificate
      ansible.builtin.command: >
        openssl req -new -x509 -days 365 -nodes
        -out /etc/pki/tls/certs/{{ domain_name }}.crt
        -keyout /etc/pki/tls/private/{{ domain_name }}.key
        -subj "/CN={{ domain_name }}"
      args:
        creates: "/etc/pki/tls/certs/{{ domain_name }}.crt"
    
    # Configure firewall
    - name: Open HTTP/HTTPS ports
      ansible.posix.firewalld:
        service: "{{ item }}"
        permanent: true
        immediate: true
        state: enabled
      loop:
        - http
        - https
    
    # Start services
    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
    
    # Verify
    - name: Test web server
      ansible.builtin.uri:
        url: "http://localhost"
        return_content: true
      register: web_test
    
    - name: Display test result
      ansible.builtin.debug:
        msg: "Web server is responding"
      when: web_test.status == 200
  
  handlers:
    - name: restart httpd
      ansible.builtin.service:
        name: httpd
        state: restarted
```

**Template: vhost.conf.j2**
```apache
<VirtualHost *:80>
    ServerName {{ domain_name }}
    DocumentRoot /var/www/{{ domain_name }}
    
    <Directory /var/www/{{ domain_name }}>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog /var/log/httpd/{{ domain_name }}-error.log
    CustomLog /var/log/httpd/{{ domain_name }}-access.log combined
</VirtualHost>

<VirtualHost *:443>
    ServerName {{ domain_name }}
    DocumentRoot /var/www/{{ domain_name }}
    
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/{{ domain_name }}.crt
    SSLCertificateKeyFile /etc/pki/tls/private/{{ domain_name }}.key
    
    <Directory /var/www/{{ domain_name }}>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog /var/log/httpd/{{ domain_name }}-ssl-error.log
    CustomLog /var/log/httpd/{{ domain_name }}-ssl-access.log combined
</VirtualHost>
```

---

## Best Practices Summary

1. **Always use become for system tasks**
2. **Use handlers for service restarts**
3. **Encrypt sensitive data with vault**
4. **Use templates for config files**
5. **Test changes with --check first**
6. **Use tags for selective execution**
7. **Document complex playbooks**
8. **Use roles for reusability**
9. **Implement error handling**
10. **Verify changes after execution**

---

## Tips for RHCE Exam

1. **Read requirements carefully**
2. **Test incrementally**
3. **Use --syntax-check**
4. **Use --check mode**
5. **Verify with ad-hoc commands**
6. **Keep playbooks organized**
7. **Use meaningful names**
8. **Comment complex logic**
9. **Test error scenarios**
10. **Manage time wisely**

---

Good luck with your RHCE exam preparation! 🚀

You've completed all 16 thematic exams. You're ready for the real RHCE EX294 exam!
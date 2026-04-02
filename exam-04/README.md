# RHCE Killer — Exam 04: Linux Administration with Ansible

**Duration:** 4 hours  
**Passing Score:** 70% (84/120 points)  
**Focus:** System Administration Tasks using Ansible

---

## ⚠️ IMPORTANT INSTRUCTIONS

1. **Work Directory:** All work must be done in `/home/student/ansible/`
2. **Inventory:** Use the existing inventory at `/home/student/ansible/inventory`
3. **Ansible Config:** Use `/home/student/ansible/ansible.cfg`
4. **Test Your Work:** Run `bash ~/exams/exam-04/grade.sh` to check your progress
5. **Time Management:** You have 4 hours. Budget your time wisely.
6. **Read Carefully:** Each task specifies exact requirements. Follow them precisely.

---

## 📋 EXAM TASKS

### Task 01: User and Group Management (10 points)

Create a playbook `users.yml` that manages users and groups across all nodes:

**Requirements:**
- Create groups:
  - `developers` (GID: 3000)
  - `operators` (GID: 3001)
  - `admins` (GID: 3002)
- Create users with specific attributes:
  - `alice`: UID 3001, primary group `developers`, secondary group `admins`
  - `bob`: UID 3002, primary group `operators`
  - `charlie`: UID 3003, primary group `developers`
  - `david`: UID 3004, primary group `admins`, shell `/bin/bash`
- Set password for `alice`: `redhat123` (use ansible-vault)
- Ensure user `testuser` is absent from all systems
- All users should have home directories created

**Verification:**
```bash
ansible all -m shell -a "id alice"
ansible all -m shell -a "groups alice bob charlie david"
```

---

### Task 02: SSH Key Management (10 points)

Create a playbook `ssh_keys.yml` that manages SSH keys:

**Requirements:**
- Generate SSH key pair for user `alice` on control node
- Distribute alice's public key to all managed nodes
- Add the following public key to `bob`'s authorized_keys on all nodes:
  ```
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDExample bob@example.com
  ```
- Ensure SSH directory permissions are correct (700 for .ssh, 600 for authorized_keys)
- Remove any existing keys for user `olduser`

**Verification:**
```bash
ansible all -m shell -a "ls -la /home/alice/.ssh/"
ansible all -m shell -a "cat /home/bob/.ssh/authorized_keys"
```

---

### Task 03: Sudo Configuration (10 points)

Create a playbook `sudo.yml` that configures sudo access:

**Requirements:**
- Create sudoers file `/etc/sudoers.d/custom_sudo`
- Configure the following sudo rules:
  - Group `admins`: Full sudo access without password (NOPASSWD: ALL)
  - Group `operators`: Can restart services without password
  - User `alice`: Can run yum/dnf commands without password
  - User `bob`: Can run systemctl commands for httpd service only
- Validate sudoers syntax before applying
- Set proper permissions (440) on sudoers files

**Verification:**
```bash
ansible all -m shell -a "cat /etc/sudoers.d/custom_sudo"
ansible all -m shell -a "sudo -l -U alice"
```

---

### Task 04: Scheduled Tasks (Cron and At) (15 points)

Create a playbook `scheduled_tasks.yml` that manages scheduled tasks:

**Requirements:**
- Create cron jobs:
  - Daily backup script at 2:00 AM: `/usr/local/bin/backup.sh`
  - Hourly log rotation: `/usr/local/bin/rotate_logs.sh`
  - Weekly system update check (Sundays at 3:00 AM)
  - Monthly cleanup (1st day of month at 4:00 AM)
- Create the backup script `/usr/local/bin/backup.sh`:
  - Backs up `/etc` to `/backup/etc-$(date +%Y%m%d).tar.gz`
  - Keeps only last 7 backups
- Create the log rotation script `/usr/local/bin/rotate_logs.sh`:
  - Rotates logs in `/var/log/myapp/`
- Ensure cron service is running and enabled
- Set proper permissions on scripts (755)

**Verification:**
```bash
ansible all -m shell -a "crontab -l"
ansible all -m shell -a "ls -l /usr/local/bin/backup.sh"
```

---

### Task 05: Storage Management with LVM (20 points)

Create a playbook `storage.yml` that manages storage using the `storage` system role:

**Requirements:**
- Create a volume group `vg_data` using available disk space
- Create logical volumes:
  - `lv_app`: 2GB, mounted at `/mnt/app`, ext4 filesystem
  - `lv_logs`: 1GB, mounted at `/mnt/logs`, xfs filesystem
  - `lv_backup`: 3GB, mounted at `/mnt/backup`, ext4 filesystem
- Ensure all filesystems are mounted persistently (in /etc/fstab)
- Set proper mount options:
  - `/mnt/app`: defaults,noatime
  - `/mnt/logs`: defaults,noatime,nodev
  - `/mnt/backup`: defaults,noexec
- Create directories with proper permissions:
  - `/mnt/app`: 755, owner: alice, group: developers
  - `/mnt/logs`: 775, owner: root, group: operators
  - `/mnt/backup`: 700, owner: root, group: root

**Note:** This task uses the RHEL System Role for storage management.

**Verification:**
```bash
ansible all -m shell -a "lvs"
ansible all -m shell -a "df -h | grep /mnt"
ansible all -m shell -a "cat /etc/fstab | grep /mnt"
```

---

### Task 06: Filesystem Management (15 points)

Create a playbook `filesystems.yml` that manages filesystems and mount points:

**Requirements:**
- Create directories:
  - `/data/shared`: 2775, owner: root, group: developers, setgid bit set
  - `/data/private`: 700, owner: alice, group: admins
  - `/data/public`: 755, owner: root, group: root
- Create NFS mount (if NFS server available):
  - Mount `nfs-server:/exports/shared` to `/mnt/nfs`
  - Use options: `defaults,_netdev`
- Create symbolic links:
  - `/opt/app` → `/data/shared/app`
  - `/var/app-logs` → `/mnt/logs`
- Set ACLs on `/data/shared`:
  - User `bob`: read and write access
  - Group `operators`: read access
  - Default ACL for new files: group `developers` gets rw

**Verification:**
```bash
ansible all -m shell -a "ls -ld /data/*"
ansible all -m shell -a "getfacl /data/shared"
ansible all -m shell -a "mount | grep /mnt"
```

---

### Task 07: Network Configuration (15 points)

Create a playbook `network.yml` that configures network settings using system roles:

**Requirements:**
- Use `rhel-system-roles.network` to configure:
  - Set static IP addresses (if not already configured)
  - Configure DNS servers: 8.8.8.8, 8.8.4.4
  - Set search domain: `example.com`
  - Configure hostname based on inventory
- Configure `/etc/hosts` file:
  - Add entries for all nodes in inventory
  - Add custom entry: `192.168.1.100 app.example.com`
- Configure network bonding (if multiple interfaces available):
  - Bond name: `bond0`
  - Mode: `active-backup`
  - Slaves: `eth1`, `eth2`
- Ensure NetworkManager is running and enabled

**Verification:**
```bash
ansible all -m shell -a "ip addr show"
ansible all -m shell -a "cat /etc/resolv.conf"
ansible all -m shell -a "cat /etc/hosts"
```

---

### Task 08: Firewall Configuration (10 points)

Create a playbook `firewall.yml` that manages firewall rules:

**Requirements:**
- Configure firewalld on all nodes:
  - Default zone: `public`
  - Allow services: `ssh`, `http`, `https`
  - Allow custom ports:
    - 8080/tcp (application port)
    - 3306/tcp (database port) - only on database group
    - 9090/tcp (monitoring port)
  - Block port 23/tcp (telnet)
  - Enable masquerading on web servers
- Create custom firewall zone `internal`:
  - Allow all traffic from 192.168.1.0/24 network
  - Assign to internal interface (if available)
- Configure rich rules:
  - Rate limit SSH connections (max 3 per minute)
  - Log dropped packets
- Ensure firewalld is running and enabled
- Make all changes permanent

**Verification:**
```bash
ansible all -m shell -a "firewall-cmd --list-all"
ansible all -m shell -a "firewall-cmd --list-ports"
ansible database -m shell -a "firewall-cmd --list-ports | grep 3306"
```

---

### Task 09: SELinux Configuration (10 points)

Create a playbook `selinux.yml` that manages SELinux:

**Requirements:**
- Ensure SELinux is in enforcing mode with targeted policy
- Configure SELinux contexts:
  - Set context for `/data/shared`: `httpd_sys_content_t`
  - Set context for `/mnt/app`: `httpd_sys_rw_content_t`
  - Set context for custom port 8080: `http_port_t`
- Configure SELinux booleans:
  - `httpd_can_network_connect`: on
  - `httpd_can_network_connect_db`: on
  - `httpd_enable_homedirs`: off
- Create custom SELinux policy module (if needed):
  - Allow httpd to connect to custom port 9090
- Restore default contexts on `/var/www/html`
- Ensure all changes persist across reboots

**Verification:**
```bash
ansible all -m shell -a "getenforce"
ansible all -m shell -a "ls -Z /data/shared"
ansible all -m shell -a "getsebool httpd_can_network_connect"
ansible all -m shell -a "semanage port -l | grep http_port_t"
```

---

### Task 10: System Facts and Custom Facts (15 points)

Create a playbook `facts.yml` that works with system facts:

**Requirements:**
- Create custom facts directory: `/etc/ansible/facts.d/`
- Create custom fact script `/etc/ansible/facts.d/system_info.fact`:
  - Return JSON with:
    - `environment`: "production" or "development" based on hostname
    - `datacenter`: "dc1" or "dc2" based on IP address
    - `backup_enabled`: true/false based on presence of /backup directory
    - `last_patched`: date from /var/log/last_patch.txt or "never"
- Create playbook that uses facts to:
  - Display all custom facts
  - Create report file `/var/log/system_report.txt` with:
    - Hostname
    - IP address
    - OS version
    - Total memory
    - Total disk space
    - Custom facts
  - Set MOTD based on environment (production vs development)
  - Configure monitoring based on datacenter
- Use fact caching to improve performance

**Verification:**
```bash
ansible all -m setup -a "filter=ansible_local"
ansible all -m shell -a "cat /var/log/system_report.txt"
ansible all -m shell -a "cat /etc/motd"
```

---

## 🎯 GRADING

Run the grading script to check your work:
```bash
bash ~/exams/exam-04/grade.sh
```

The script will verify:
- ✓ User and group configurations
- ✓ SSH key deployments
- ✓ Sudo configurations
- ✓ Scheduled tasks (cron jobs)
- ✓ Storage and filesystem configurations
- ✓ Network settings
- ✓ Firewall rules
- ✓ SELinux contexts and booleans
- ✓ Custom facts and reports

---

## 📚 USEFUL COMMANDS

### User Management
```bash
# Create user
ansible all -m user -a "name=alice uid=3001 groups=developers,admins"

# Set password (encrypted)
ansible all -m user -a "name=alice password={{ 'redhat123' | password_hash('sha512') }}"

# Remove user
ansible all -m user -a "name=testuser state=absent remove=yes"

# List users
ansible all -m shell -a "getent passwd | grep -E '(alice|bob|charlie)'"
```

### SSH Keys
```bash
# Generate SSH key
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""

# Add authorized key
ansible all -m authorized_key -a "user=alice key='{{ lookup('file', '~/.ssh/id_rsa.pub') }}'"

# Check SSH directory permissions
ansible all -m file -a "path=/home/alice/.ssh mode=0700 owner=alice"
```

### Sudo Configuration
```bash
# Validate sudoers file
visudo -c -f /etc/sudoers.d/custom_sudo

# Test sudo access
sudo -l -U alice
```

### Cron Jobs
```bash
# Add cron job
ansible all -m cron -a "name='daily backup' hour=2 minute=0 job='/usr/local/bin/backup.sh'"

# List cron jobs
crontab -l

# Remove cron job
ansible all -m cron -a "name='daily backup' state=absent"
```

### Storage Management
```bash
# List volume groups
vgs

# List logical volumes
lvs

# Check filesystem
df -h

# Check fstab
cat /etc/fstab
```

### Firewall
```bash
# List all rules
firewall-cmd --list-all

# Add service
firewall-cmd --add-service=http --permanent

# Add port
firewall-cmd --add-port=8080/tcp --permanent

# Reload firewall
firewall-cmd --reload
```

### SELinux
```bash
# Check SELinux status
getenforce

# Set SELinux context
semanage fcontext -a -t httpd_sys_content_t "/data/shared(/.*)?"
restorecon -Rv /data/shared

# Set SELinux boolean
setsebool -P httpd_can_network_connect on

# List SELinux booleans
getsebool -a | grep httpd
```

---

## ⚠️ SOLUTIONS BELOW - DO NOT SCROLL UNLESS YOU WANT SPOILERS! ⚠️

<br><br><br><br><br><br><br><br><br><br>
<br><br><br><br><br><br><br><br><br><br>
<br><br><br><br><br><br><br><br><br><br>

---

# 🔓 SOLUTIONS

## Task 01: User and Group Management

### Create the playbook
**File:** `users.yml`
```yaml
---
- name: Manage users and groups
  hosts: all
  become: true
  vars_files:
    - vault_passwords.yml
  
  tasks:
    - name: Create groups
      ansible.builtin.group:
        name: "{{ item.name }}"
        gid: "{{ item.gid }}"
        state: present
      loop:
        - { name: 'developers', gid: 3000 }
        - { name: 'operators', gid: 3001 }
        - { name: 'admins', gid: 3002 }

    - name: Create user alice
      ansible.builtin.user:
        name: alice
        uid: 3001
        group: developers
        groups: admins
        append: true
        create_home: true
        password: "{{ alice_password | password_hash('sha512') }}"
        state: present

    - name: Create user bob
      ansible.builtin.user:
        name: bob
        uid: 3002
        group: operators
        create_home: true
        state: present

    - name: Create user charlie
      ansible.builtin.user:
        name: charlie
        uid: 3003
        group: developers
        create_home: true
        state: present

    - name: Create user david
      ansible.builtin.user:
        name: david
        uid: 3004
        group: admins
        create_home: true
        shell: /bin/bash
        state: present

    - name: Ensure testuser is absent
      ansible.builtin.user:
        name: testuser
        state: absent
        remove: true
```

### Create vault file for passwords
```bash
# Create vault password file
echo "redhat123" > vault_passwords.yml

# Encrypt the file
ansible-vault encrypt vault_passwords.yml

# Edit to add password variable
ansible-vault edit vault_passwords.yml
```

**Content of vault_passwords.yml:**
```yaml
---
alice_password: "redhat123"
```

### Run the playbook
```bash
ansible-playbook users.yml --ask-vault-pass
```

### Verify
```bash
ansible all -m shell -a "id alice"
ansible all -m shell -a "id bob"
ansible all -m shell -a "groups alice bob charlie david"
ansible all -m shell -a "getent group developers operators admins"
```

---

## Task 02: SSH Key Management

### Create the playbook
**File:** `ssh_keys.yml`
```yaml
---
- name: Manage SSH keys
  hosts: all
  become: true
  
  tasks:
    - name: Ensure .ssh directory exists for alice
      ansible.builtin.file:
        path: /home/alice/.ssh
        state: directory
        owner: alice
        group: alice
        mode: '0700'

    - name: Generate SSH key for alice on control node
      ansible.builtin.user:
        name: alice
        generate_ssh_key: true
        ssh_key_bits: 2048
        ssh_key_file: /home/alice/.ssh/id_rsa
      delegate_to: localhost
      run_once: true

    - name: Distribute alice's public key to all nodes
      ansible.posix.authorized_key:
        user: alice
        key: "{{ lookup('file', '/home/alice/.ssh/id_rsa.pub') }}"
        state: present

    - name: Ensure .ssh directory exists for bob
      ansible.builtin.file:
        path: /home/bob/.ssh
        state: directory
        owner: bob
        group: bob
        mode: '0700'

    - name: Add public key to bob's authorized_keys
      ansible.posix.authorized_key:
        user: bob
        key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDExample bob@example.com"
        state: present

    - name: Set correct permissions on authorized_keys
      ansible.builtin.file:
        path: "/home/{{ item }}/.ssh/authorized_keys"
        owner: "{{ item }}"
        group: "{{ item }}"
        mode: '0600'
      loop:
        - alice
        - bob

    - name: Remove SSH keys for olduser
      ansible.builtin.file:
        path: /home/olduser/.ssh
        state: absent
      ignore_errors: true
```

### Run the playbook
```bash
ansible-playbook ssh_keys.yml
```

### Verify
```bash
ansible all -m shell -a "ls -la /home/alice/.ssh/"
ansible all -m shell -a "cat /home/bob/.ssh/authorized_keys"
```

---

## Task 03: Sudo Configuration

### Create the playbook
**File:** `sudo.yml`
```yaml
---
- name: Configure sudo access
  hosts: all
  become: true
  
  tasks:
    - name: Create custom sudoers file
      ansible.builtin.copy:
        content: |
          # Custom sudo rules
          # Group admins - full access without password
          %admins ALL=(ALL) NOPASSWD: ALL
          
          # Group operators - can restart services
          %operators ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart *
          
          # User alice - can run yum/dnf without password
          alice ALL=(ALL) NOPASSWD: /usr/bin/yum, /usr/bin/dnf
          
          # User bob - can manage httpd service only
          bob ALL=(ALL) NOPASSWD: /usr/bin/systemctl * httpd
        dest: /etc/sudoers.d/custom_sudo
        owner: root
        group: root
        mode: '0440'
        validate: '/usr/sbin/visudo -cf %s'
```

### Run the playbook
```bash
ansible-playbook sudo.yml
```

### Verify
```bash
ansible all -m shell -a "cat /etc/sudoers.d/custom_sudo"
ansible all -m shell -a "sudo -l -U alice" -b
ansible all -m shell -a "sudo -l -U bob" -b
```

---

## Task 04: Scheduled Tasks (Cron and At)

### Create the playbook
**File:** `scheduled_tasks.yml`
```yaml
---
- name: Manage scheduled tasks
  hosts: all
  become: true
  
  tasks:
    - name: Create backup directory
      ansible.builtin.file:
        path: /backup
        state: directory
        mode: '0755'

    - name: Create backup script
      ansible.builtin.copy:
        content: |
          #!/bin/bash
          # Backup script
          BACKUP_DIR="/backup"
          DATE=$(date +%Y%m%d)
          
          # Create backup
          tar -czf ${BACKUP_DIR}/etc-${DATE}.tar.gz /etc 2>/dev/null
          
          # Keep only last 7 backups
          cd ${BACKUP_DIR}
          ls -t etc-*.tar.gz | tail -n +8 | xargs -r rm
        dest: /usr/local/bin/backup.sh
        owner: root
        group: root
        mode: '0755'

    - name: Create log rotation script
      ansible.builtin.copy:
        content: |
          #!/bin/bash
          # Log rotation script
          LOG_DIR="/var/log/myapp"
          
          if [ -d "$LOG_DIR" ]; then
            find $LOG_DIR -name "*.log" -mtime +7 -exec gzip {} \;
            find $LOG_DIR -name "*.gz" -mtime +30 -delete
          fi
        dest: /usr/local/bin/rotate_logs.sh
        owner: root
        group: root
        mode: '0755'

    - name: Create myapp log directory
      ansible.builtin.file:
        path: /var/log/myapp
        state: directory
        mode: '0755'

    - name: Schedule daily backup at 2:00 AM
      ansible.builtin.cron:
        name: "Daily backup"
        minute: "0"
        hour: "2"
        job: "/usr/local/bin/backup.sh"
        user: root

    - name: Schedule hourly log rotation
      ansible.builtin.cron:
        name: "Hourly log rotation"
        minute: "0"
        job: "/usr/local/bin/rotate_logs.sh"
        user: root

    - name: Schedule weekly system update check
      ansible.builtin.cron:
        name: "Weekly update check"
        minute: "0"
        hour: "3"
        weekday: "0"
        job: "/usr/bin/dnf check-update > /var/log/update_check.log 2>&1"
        user: root

    - name: Schedule monthly cleanup
      ansible.builtin.cron:
        name: "Monthly cleanup"
        minute: "0"
        hour: "4"
        day: "1"
        job: "/usr/bin/find /tmp -type f -mtime +30 -delete"
        user: root

    - name: Ensure cron service is running
      ansible.builtin.service:
        name: crond
        state: started
        enabled: true
```

### Run the playbook
```bash
ansible-playbook scheduled_tasks.yml
```

### Verify
```bash
ansible all -m shell -a "crontab -l"
ansible all -m shell -a "ls -l /usr/local/bin/backup.sh /usr/local/bin/rotate_logs.sh"
ansible all -m shell -a "systemctl status crond"
```

---

## Task 05: Storage Management with LVM

### Create the playbook
**File:** `storage.yml`
```yaml
---
- name: Manage storage with LVM
  hosts: all
  become: true
  vars:
    storage_pools:
      - name: vg_data
        disks:
          - /dev/sdb
        volumes:
          - name: lv_app
            size: 2g
            fs_type: ext4
            mount_point: /mnt/app
            mount_options: defaults,noatime
          - name: lv_logs
            size: 1g
            fs_type: xfs
            mount_point: /mnt/logs
            mount_options: defaults,noatime,nodev
          - name: lv_backup
            size: 3g
            fs_type: ext4
            mount_point: /mnt/backup
            mount_options: defaults,noexec
  
  roles:
    - role: rhel-system-roles.storage
  
  post_tasks:
    - name: Set ownership and permissions on /mnt/app
      ansible.builtin.file:
        path: /mnt/app
        state: directory
        owner: alice
        group: developers
        mode: '0755'

    - name: Set ownership and permissions on /mnt/logs
      ansible.builtin.file:
        path: /mnt/logs
        state: directory
        owner: root
        group: operators
        mode: '0775'

    - name: Set ownership and permissions on /mnt/backup
      ansible.builtin.file:
        path: /mnt/backup
        state: directory
        owner: root
        group: root
        mode: '0700'
```

### Run the playbook
```bash
ansible-playbook storage.yml
```

### Verify
```bash
ansible all -m shell -a "vgs"
ansible all -m shell -a "lvs"
ansible all -m shell -a "df -h | grep /mnt"
ansible all -m shell -a "cat /etc/fstab | grep /mnt"
ansible all -m shell -a "ls -ld /mnt/app /mnt/logs /mnt/backup"
```

---

## Task 06: Filesystem Management

### Create the playbook
**File:** `filesystems.yml`
```yaml
---
- name: Manage filesystems and mount points
  hosts: all
  become: true
  
  tasks:
    - name: Create /data directory
      ansible.builtin.file:
        path: /data
        state: directory
        mode: '0755'

    - name: Create /data/shared with setgid
      ansible.builtin.file:
        path: /data/shared
        state: directory
        owner: root
        group: developers
        mode: '2775'

    - name: Create /data/private
      ansible.builtin.file:
        path: /data/private
        state: directory
        owner: alice
        group: admins
        mode: '0700'

    - name: Create /data/public
      ansible.builtin.file:
        path: /data/public
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Create /data/shared/app directory
      ansible.builtin.file:
        path: /data/shared/app
        state: directory
        owner: root
        group: developers
        mode: '2775'

    - name: Create symbolic link /opt/app
      ansible.builtin.file:
        src: /data/shared/app
        dest: /opt/app
        state: link

    - name: Create symbolic link /var/app-logs
      ansible.builtin.file:
        src: /mnt/logs
        dest: /var/app-logs
        state: link

    - name: Install ACL package
      ansible.builtin.dnf:
        name: acl
        state: present

    - name: Set ACL for user bob on /data/shared
      ansible.posix.acl:
        path: /data/shared
        entity: bob
        etype: user
        permissions: rw
        state: present

    - name: Set ACL for group operators on /data/shared
      ansible.posix.acl:
        path: /data/shared
        entity: operators
        etype: group
        permissions: r
        state: present

    - name: Set default ACL for group developers on /data/shared
      ansible.posix.acl:
        path: /data/shared
        entity: developers
        etype: group
        permissions: rw
        default: true
        state: present
```

### Run the playbook
```bash
ansible-playbook filesystems.yml
```

### Verify
```bash
ansible all -m shell -a "ls -ld /data/*"
ansible all -m shell -a "getfacl /data/shared"
ansible all -m shell -a "ls -l /opt/app /var/app-logs"
```

---

## Task 07: Network Configuration

### Create the playbook
**File:** `network.yml`
```yaml
---
- name: Configure network settings
  hosts: all
  become: true
  
  tasks:
    - name: Configure /etc/hosts
      ansible.builtin.lineinfile:
        path: /etc/hosts
        line: "{{ hostvars[item].ansible_default_ipv4.address }} {{ item }}"
        state: present
      loop: "{{ groups['all'] }}"

    - name: Add custom host entry
      ansible.builtin.lineinfile:
        path: /etc/hosts
        line: "192.168.1.100 app.example.com"
        state: present

    - name: Configure DNS servers
      ansible.builtin.lineinfile:
        path: /etc/resolv.conf
        line: "nameserver {{ item }}"
        state: present
      loop:
        - 8.8.8.8
        - 8.8.4.4

    - name: Set search domain
      ansible.builtin.lineinfile:
        path: /etc/resolv.conf
        line: "search example.com"
        insertbefore: BOF
        state: present

    - name: Set hostname
      ansible.builtin.hostname:
        name: "{{ inventory_hostname }}"

    - name: Ensure NetworkManager is running
      ansible.builtin.service:
        name: NetworkManager
        state: started
        enabled: true
```

### Run the playbook
```bash
ansible-playbook network.yml
```

### Verify
```bash
ansible all -m shell -a "cat /etc/hosts"
ansible all -m shell -a "cat /etc/resolv.conf"
ansible all -m shell -a "hostname"
```

---

## Task 08: Firewall Configuration

### Create the playbook
**File:** `firewall.yml`
```yaml
---
- name: Configure firewall
  hosts: all
  become: true
  
  tasks:
    - name: Ensure firewalld is installed
      ansible.builtin.dnf:
        name: firewalld
        state: present

    - name: Ensure firewalld is running
      ansible.builtin.service:
        name: firewalld
        state: started
        enabled: true

    - name: Set default zone to public
      ansible.posix.firewalld:
        zone: public
        state: enabled
        permanent: true
        immediate: true

    - name: Allow services in firewall
      ansible.posix.firewalld:
        service: "{{ item }}"
        permanent: true
        state: enabled
        immediate: true
      loop:
        - ssh
        - http
        - https

    - name: Allow custom ports
      ansible.posix.firewalld:
        port: "{{ item }}"
        permanent: true
        state: enabled
        immediate: true
      loop:
        - 8080/tcp
        - 9090/tcp

    - name: Block telnet port
      ansible.posix.firewalld:
        port: 23/tcp
        permanent: true
        state: disabled
        immediate: true

    - name: Configure rich rule for SSH rate limiting
      ansible.posix.firewalld:
        rich_rule: 'rule service name="ssh" limit value="3/m" accept'
        permanent: true
        state: enabled
        immediate: true

    - name: Enable logging for dropped packets
      ansible.posix.firewalld:
        rich_rule: 'rule log prefix="DROPPED: " level="info" limit value="5/m"'
        permanent: true
        state: enabled
        immediate: true

- name: Configure database firewall
  hosts: database
  become: true
  
  tasks:
    - name: Allow MySQL port on database servers
      ansible.posix.firewalld:
        port: 3306/tcp
        permanent: true
        state: enabled
        immediate: true

- name: Configure web server firewall
  hosts: web
  become: true
  
  tasks:
    - name: Enable masquerading on web servers
      ansible.posix.firewalld:
        masquerade: true
        permanent: true
        state: enabled
        immediate: true
```

### Run the playbook
```bash
ansible-playbook firewall.yml
```

### Verify
```bash
ansible all -m shell -a "firewall-cmd --list-all"
ansible all -m shell -a "firewall-cmd --list-ports"
ansible database -m shell -a "firewall-cmd --list-ports | grep 3306"
ansible web -m shell -a "firewall-cmd --query-masquerade"
```

---

## Task 09: SELinux Configuration

### Create the playbook
**File:** `selinux.yml`
```yaml
---
- name: Configure SELinux
  hosts: all
  become: true
  
  tasks:
    - name: Ensure SELinux is in enforcing mode
      ansible.posix.selinux:
        policy: targeted
        state: enforcing

    - name: Install SELinux management tools
      ansible.builtin.dnf:
        name:
          - policycoreutils-python-utils
          - setools-console
        state: present

    - name: Set SELinux context for /data/shared
      community.general.sefcontext:
        target: '/data/shared(/.*)?'
        setype: httpd_sys_content_t
        state: present

    - name: Apply SELinux context to /data/shared
      ansible.builtin.command:
        cmd: restorecon -Rv /data/shared
      changed_when: false

    - name: Set SELinux context for /mnt/app
      community.general.sefcontext:
        target: '/mnt/app(/.*)?'
        setype: httpd_sys_rw_content_t
        state: present

    - name: Apply SELinux context to /mnt/app
      ansible.builtin.command:
        cmd: restorecon -Rv /mnt/app
      changed_when: false

    - name: Add SELinux port for custom port 8080
      community.general.seport:
        ports: 8080
        proto: tcp
        setype: http_port_t
        state: present

    - name: Set SELinux boolean httpd_can_network_connect
      ansible.posix.seboolean:
        name: httpd_can_network_connect
        state: true
        persistent: true

    - name: Set SELinux boolean httpd_can_network_connect_db
      ansible.posix.seboolean:
        name: httpd_can_network_connect_db
        state: true
        persistent: true

    - name: Set SELinux boolean httpd_enable_homedirs
      ansible.posix.seboolean:
        name: httpd_enable_homedirs
        state: false
        persistent: true

    - name: Restore default contexts on /var/www/html
      ansible.builtin.command:
        cmd: restorecon -Rv /var/www/html
      changed_when: false
```

### Run the playbook
```bash
ansible-playbook selinux.yml
```

### Verify
```bash
ansible all -m shell -a "getenforce"
ansible all -m shell -a "ls -Z /data/shared"
ansible all -m shell -a "ls -Z /mnt/app"
ansible all -m shell -a "getsebool httpd_can_network_connect"
ansible all -m shell -a "semanage port -l | grep http_port_t | grep 8080"
```

---

## Task 10: System Facts and Custom Facts

### Create custom fact script
**File:** `files/system_info.fact`
```bash
#!/bin/bash
# Custom fact script

# Determine environment based on hostname
if [[ $(hostname) =~ prod ]]; then
    ENVIRONMENT="production"
else
    ENVIRONMENT="development"
fi

# Determine datacenter based on IP
IP=$(hostname -I | awk '{print $1}')
if [[ $IP =~ ^192\.168\.1\. ]]; then
    DATACENTER="dc1"
else
    DATACENTER="dc2"
fi

# Check if backup is enabled
if [ -d /backup ]; then
    BACKUP_ENABLED=true
else
    BACKUP_ENABLED=false
fi

# Get last patched date
if [ -f /var/log/last_patch.txt ]; then
    LAST_PATCHED=$(cat /var/log/last_patch.txt)
else
    LAST_PATCHED="never"
fi

# Output JSON
cat <<EOF
{
    "environment": "$ENVIRONMENT",
    "datacenter": "$DATACENTER",
    "backup_enabled": $BACKUP_ENABLED,
    "last_patched": "$LAST_PATCHED"
}
EOF
```

### Create the playbook
**File:** `facts.yml`
```yaml
---
- name: Manage system facts
  hosts: all
  become: true
  
  tasks:
    - name: Create custom facts directory
      ansible.builtin.file:
        path: /etc/ansible/facts.d
        state: directory
        mode: '0755'

    - name: Deploy custom fact script
      ansible.builtin.copy:
        src: files/system_info.fact
        dest: /etc/ansible/facts.d/system_info.fact
        owner: root
        group: root
        mode: '0755'

    - name: Reload facts
      ansible.builtin.setup:

    - name: Display custom facts
      ansible.builtin.debug:
        var: ansible_local.system_info

    - name: Create system report
      ansible.builtin.template:
        src: templates/system_report.j2
        dest: /var/log/system_report.txt
        owner: root
        group: root
        mode: '0644'

    - name: Set MOTD based on environment
      ansible.builtin.copy:
        content: |
          ╔══════════════════════════════════════════════════════════╗
          ║  {{ ansible_hostname | upper }}
          ║  Environment: {{ ansible_local.system_info.environment | upper }}
          ║  Datacenter: {{ ansible_local.system_info.datacenter | upper }}
          ║  IP Address: {{ ansible_default_ipv4.address }}
          ╚══════════════════════════════════════════════════════════╝
        dest: /etc/motd
        owner: root
        group: root
        mode: '0644'
```

### Create report template
**File:** `templates/system_report.j2`
```jinja2
SYSTEM REPORT
=============
Generated: {{ ansible_date_time.iso8601 }}

BASIC INFORMATION
-----------------
Hostname: {{ ansible_hostname }}
FQDN: {{ ansible_fqdn }}
IP Address: {{ ansible_default_ipv4.address }}
OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
Kernel: {{ ansible_kernel }}

HARDWARE INFORMATION
--------------------
Architecture: {{ ansible_architecture }}
Processor: {{ ansible_processor[2] }}
CPU Cores: {{ ansible_processor_cores }}
Total Memory: {{ ansible_memtotal_mb }} MB
Total Disk: {{ ansible_devices.sda.size }}

CUSTOM FACTS
------------
Environment: {{ ansible_local.system_info.environment }}
Datacenter: {{ ansible_local.system_info.datacenter }}
Backup Enabled: {{ ansible_local.system_info.backup_enabled }}
Last Patched: {{ ansible_local.system_info.last_patched }}

NETWORK INTERFACES
------------------
{% for interface in ansible_interfaces %}
{{ interface }}: {{ ansible_facts[interface].get('ipv4', {}).get('address', 'N/A') }}
{% endfor %}
```

### Run the playbook
```bash
ansible-playbook facts.yml
```

### Verify
```bash
ansible all -m setup -a "filter=ansible_local"
ansible all -m shell -a "cat /var/log/system_report.txt"
ansible all -m shell -a "cat /etc/motd"
ansible all -m shell -a "cat /etc/ansible/facts.d/system_info.fact"
```

---

## 🎓 EXAM TIPS

1. **User Management:** Always verify UIDs and GIDs match requirements
2. **SSH Keys:** Check permissions (700 for .ssh, 600 for authorized_keys)
3. **Sudo:** Always validate sudoers files before applying
4. **Cron:** Use proper time format and test scripts before scheduling
5. **Storage:** Use system roles for complex storage configurations
6. **Firewall:** Make changes permanent and reload firewalld
7. **SELinux:** Always restore contexts after setting them
8. **Facts:** Custom facts must be executable and return valid JSON
9. **Testing:** Use --check mode to test before applying
10. **Documentation:** Read man pages for modules you're unsure about

---

**Good luck with your exam! 🚀**
#!/bin/bash

# RHCE Killer - System Administration Grading Script
# Exam: Complete System Administration with Ansible
# Total Points: 289
# Passing Score: 70% (202/289)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_POINTS=0
MAX_POINTS=289
TASK_COUNT=0
PASSED_TASKS=0

# Base directory
ANSIBLE_DIR="/home/student/ansible"

# Helper function to check conditions
check() {
    local DESC="$1"
    local POINTS=$2
    local CMD="$3"
    local HINT="$4"
    
    TASK_COUNT=$((TASK_COUNT + 1))
    echo -e "\n${CYAN}Task $TASK_COUNT: $DESC${NC}"
    
    if eval "$CMD" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC} (+$POINTS points)"
        TOTAL_POINTS=$((TOTAL_POINTS + POINTS))
        PASSED_TASKS=$((PASSED_TASKS + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (0 points)"
        if [ -n "$HINT" ]; then
            echo -e "${YELLOW}Hint: $HINT${NC}"
        fi
        return 1
    fi
}

# Helper function for ansible checks
ansible_check() {
    local DESC="$1"
    local POINTS=$2
    local HOST="$3"
    local MODULE="$4"
    local ARGS="$5"
    local GREP="$6"
    local HINT="$7"
    
    TASK_COUNT=$((TASK_COUNT + 1))
    echo -e "\n${CYAN}Task $TASK_COUNT: $DESC${NC}"
    
    local OUTPUT=$(ansible "$HOST" -m "$MODULE" -a "$ARGS" 2>/dev/null)
    
    if echo "$OUTPUT" | grep -q "$GREP"; then
        echo -e "${GREEN}✓ PASS${NC} (+$POINTS points)"
        TOTAL_POINTS=$((TOTAL_POINTS + POINTS))
        PASSED_TASKS=$((PASSED_TASKS + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (0 points)"
        if [ -n "$HINT" ]; then
            echo -e "${YELLOW}Hint: $HINT${NC}"
        fi
        return 1
    fi
}

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                            ║${NC}"
echo -e "${CYAN}║         RHCE KILLER - SYSTEM ADMINISTRATION EXAM           ║${NC}"
echo -e "${CYAN}║                                                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Grading Complete System Administration with Ansible...${NC}"
echo -e "${YELLOW}Total possible points: $MAX_POINTS${NC}"
echo -e "${YELLOW}Passing score: 70% (202 points)${NC}"
echo ""

# Change to ansible directory
cd "$ANSIBLE_DIR" || {
    echo -e "${RED}Error: Cannot access $ANSIBLE_DIR${NC}"
    exit 1
}

# ============================================================================
# TASK 01 - Complete User Management (20 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 01: Complete User Management (20 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook users-complete.yml exists" 2 \
    "test -f users-complete.yml" \
    "Create playbook: users-complete.yml"

check "Playbook has valid YAML syntax" 2 \
    "ansible-playbook users-complete.yml --syntax-check" \
    "Fix YAML syntax errors"

check "Playbook targets all hosts" 2 \
    "grep -q 'hosts:.*all' users-complete.yml" \
    "Set hosts: all in playbook"

check "Playbook uses become" 1 \
    "grep -q 'become:.*true' users-complete.yml" \
    "Add become: true for privilege escalation"

ansible_check "Groups created on nodes" 3 \
    "all" "shell" "getent group | grep -E '(wheel|developers)'" "wheel\|developers" \
    "Create groups before users"

ansible_check "Users created with UIDs" 3 \
    "all" "shell" "id alice 2>/dev/null && id bob 2>/dev/null" "uid=" \
    "Create users with specified UIDs"

ansible_check "User alice has correct UID" 2 \
    "all" "shell" "id -u alice" "2001" \
    "Set alice UID to 2001"

ansible_check "User bob has correct UID" 2 \
    "all" "shell" "id -u bob" "2002" \
    "Set bob UID to 2002"

ansible_check "SSH keys configured" 3 \
    "all" "shell" "test -f /home/alice/.ssh/authorized_keys && test -f /home/bob/.ssh/authorized_keys" "rc=0" \
    "Add SSH keys to authorized_keys"

# ============================================================================
# TASK 02 - Package Management Suite (18 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 02: Package Management Suite (18 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook packages-suite.yml exists" 2 \
    "test -f packages-suite.yml" \
    "Create playbook: packages-suite.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook packages-suite.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Base packages installed" 4 \
    "all" "shell" "rpm -q vim-enhanced git wget curl htop" "vim-enhanced" \
    "Install base packages: vim-enhanced, git, wget, curl, htop"

ansible_check "Git package installed" 2 \
    "all" "shell" "rpm -q git" "git-" \
    "Install git package"

ansible_check "Wget package installed" 2 \
    "all" "shell" "rpm -q wget" "wget-" \
    "Install wget package"

ansible_check "Unwanted packages removed" 3 \
    "all" "shell" "! rpm -q telnet 2>/dev/null && ! rpm -q rsh 2>/dev/null" "rc=0" \
    "Remove telnet and rsh packages"

check "Uses conditionals for groups" 3 \
    "grep -q \"when:.*group_names\" packages-suite.yml" \
    "Use conditionals based on group_names"

# ============================================================================
# TASK 03 - Service Management (18 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 03: Service Management (18 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook services-mgmt.yml exists" 2 \
    "test -f services-mgmt.yml" \
    "Create playbook: services-mgmt.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook services-mgmt.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Firewalld service running" 3 \
    "all" "shell" "systemctl is-active firewalld" "active" \
    "Start firewalld service"

ansible_check "Firewalld service enabled" 3 \
    "all" "shell" "systemctl is-enabled firewalld" "enabled" \
    "Enable firewalld service"

ansible_check "Chronyd service running" 2 \
    "all" "shell" "systemctl is-active chronyd" "active" \
    "Start chronyd service"

ansible_check "Chronyd service enabled" 2 \
    "all" "shell" "systemctl is-enabled chronyd" "enabled" \
    "Enable chronyd service"

check "Uses handlers for restarts" 4 \
    "grep -q 'handlers:' services-mgmt.yml && grep -q 'notify:' services-mgmt.yml" \
    "Use handlers for service restarts"

# ============================================================================
# TASK 04 - Firewall Configuration (20 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 04: Firewall Configuration (20 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook firewall-config.yml exists" 2 \
    "test -f firewall-config.yml" \
    "Create playbook: firewall-config.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook firewall-config.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Firewalld installed" 2 \
    "all" "shell" "rpm -q firewalld" "firewalld-" \
    "Install firewalld package"

ansible_check "HTTP service allowed" 4 \
    "all" "shell" "firewall-cmd --list-services | grep http" "http" \
    "Allow http service in firewall"

ansible_check "HTTPS service allowed" 4 \
    "all" "shell" "firewall-cmd --list-services | grep https" "https" \
    "Allow https service in firewall"

ansible_check "Custom port 8080 open" 3 \
    "all" "shell" "firewall-cmd --list-ports | grep 8080" "8080/tcp" \
    "Open port 8080/tcp"

check "Uses permanent and immediate flags" 3 \
    "grep -q 'permanent:.*true' firewall-config.yml && grep -q 'immediate:.*true' firewall-config.yml" \
    "Set permanent: true and immediate: true"

# ============================================================================
# TASK 05 - SELinux Management (18 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 05: SELinux Management (18 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook selinux-mgmt.yml exists" 2 \
    "test -f selinux-mgmt.yml" \
    "Create playbook: selinux-mgmt.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook selinux-mgmt.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "SELinux is enforcing" 4 \
    "all" "shell" "getenforce" "Enforcing" \
    "Set SELinux to enforcing mode"

ansible_check "SELinux boolean set" 4 \
    "all" "shell" "getsebool httpd_can_network_connect" "on" \
    "Set httpd_can_network_connect boolean to on"

check "Uses selinux module" 3 \
    "grep -q 'ansible.posix.selinux' selinux-mgmt.yml" \
    "Use ansible.posix.selinux module"

check "Uses seboolean module" 3 \
    "grep -q 'ansible.posix.seboolean' selinux-mgmt.yml" \
    "Use ansible.posix.seboolean module"

# ============================================================================
# TASK 06 - Storage Management (22 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 06: Storage Management (22 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook storage-mgmt.yml exists" 3 \
    "test -f storage-mgmt.yml" \
    "Create playbook: storage-mgmt.yml"

check "Playbook has valid syntax" 3 \
    "ansible-playbook storage-mgmt.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Mount point directory exists" 4 \
    "all" "shell" "test -d /mnt/app_data" "rc=0" \
    "Create /mnt/app_data directory"

check "Uses lvg module for volume groups" 3 \
    "grep -q 'community.general.lvg' storage-mgmt.yml" \
    "Use community.general.lvg module"

check "Uses lvol module for logical volumes" 3 \
    "grep -q 'community.general.lvol' storage-mgmt.yml" \
    "Use community.general.lvol module"

check "Uses filesystem module" 3 \
    "grep -q 'community.general.filesystem' storage-mgmt.yml" \
    "Use community.general.filesystem module"

check "Uses mount module" 3 \
    "grep -q 'ansible.posix.mount' storage-mgmt.yml" \
    "Use ansible.posix.mount module"

# ============================================================================
# TASK 07 - Network Configuration (20 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 07: Network Configuration (20 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook network-config.yml exists" 2 \
    "test -f network-config.yml" \
    "Create playbook: network-config.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook network-config.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Hostname set correctly on node1" 4 \
    "node1" "shell" "hostname" "node1.example.com" \
    "Set hostname to node1.example.com"

ansible_check "Hostname set correctly on node2" 4 \
    "node2" "shell" "hostname" "node2.example.com" \
    "Set hostname to node2.example.com"

ansible_check "/etc/hosts configured" 4 \
    "all" "shell" "grep -E 'node[12].example.com' /etc/hosts" "node" \
    "Add entries to /etc/hosts"

check "Uses hostname module" 2 \
    "grep -q 'ansible.builtin.hostname' network-config.yml" \
    "Use ansible.builtin.hostname module"

check "Tests connectivity" 2 \
    "grep -q 'ansible.builtin.ping' network-config.yml" \
    "Use ping module to test connectivity"

# ============================================================================
# TASK 08 - Cron Job Management (15 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 08: Cron Job Management (15 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook cron-mgmt.yml exists" 2 \
    "test -f cron-mgmt.yml" \
    "Create playbook: cron-mgmt.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook cron-mgmt.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "User cron job created" 4 \
    "all" "shell" "crontab -l -u student | grep -i backup" "backup" \
    "Create cron job for user student"

ansible_check "System cron file exists" 4 \
    "all" "shell" "test -f /etc/cron.d/system-backup" "rc=0" \
    "Create system cron file in /etc/cron.d/"

check "Uses cron module" 3 \
    "grep -q 'ansible.builtin.cron' cron-mgmt.yml" \
    "Use ansible.builtin.cron module"

# ============================================================================
# TASK 09 - Log Management (18 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 09: Log Management (18 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook log-mgmt.yml exists" 2 \
    "test -f log-mgmt.yml" \
    "Create playbook: log-mgmt.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook log-mgmt.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Custom log file exists" 3 \
    "all" "shell" "test -f /var/log/myapp.log" "rc=0" \
    "Create /var/log/myapp.log file"

ansible_check "Rsyslog configured" 4 \
    "all" "shell" "grep 'myapp.log' /etc/rsyslog.conf" "myapp.log" \
    "Configure rsyslog for custom log"

ansible_check "Logrotate configured" 4 \
    "all" "shell" "test -f /etc/logrotate.d/myapp" "rc=0" \
    "Create logrotate config in /etc/logrotate.d/myapp"

check "Uses handlers for rsyslog restart" 3 \
    "grep -q 'restart rsyslog' log-mgmt.yml" \
    "Add handler to restart rsyslog"

# ============================================================================
# TASK 10 - Time Synchronization (15 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 10: Time Synchronization (15 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook time-sync.yml exists" 2 \
    "test -f time-sync.yml" \
    "Create playbook: time-sync.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook time-sync.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Chrony package installed" 3 \
    "all" "shell" "rpm -q chrony" "chrony-" \
    "Install chrony package"

ansible_check "Chronyd service running" 3 \
    "all" "shell" "systemctl is-active chronyd" "active" \
    "Start chronyd service"

ansible_check "NTP servers configured" 3 \
    "all" "shell" "grep 'pool.ntp.org' /etc/chrony.conf" "pool.ntp.org" \
    "Configure NTP servers in /etc/chrony.conf"

check "Uses timezone module" 2 \
    "grep -q 'community.general.timezone' time-sync.yml" \
    "Use community.general.timezone module"

# ============================================================================
# TASK 11 - SSH Hardening (20 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 11: SSH Hardening (20 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook ssh-harden.yml exists" 2 \
    "test -f ssh-harden.yml" \
    "Create playbook: ssh-harden.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook ssh-harden.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Root login disabled" 4 \
    "all" "shell" "grep '^PermitRootLogin no' /etc/ssh/sshd_config" "PermitRootLogin no" \
    "Set PermitRootLogin no in sshd_config"

ansible_check "Password auth disabled" 4 \
    "all" "shell" "grep '^PasswordAuthentication no' /etc/ssh/sshd_config" "PasswordAuthentication no" \
    "Set PasswordAuthentication no in sshd_config"

check "Backs up original config" 4 \
    "grep -q 'backup:.*yes' ssh-harden.yml" \
    "Use backup: yes when modifying sshd_config"

check "Uses lineinfile module" 4 \
    "grep -q 'ansible.builtin.lineinfile' ssh-harden.yml" \
    "Use lineinfile module to modify sshd_config"

# ============================================================================
# TASK 12 - System Updates (18 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 12: System Updates (18 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook system-update.yml exists" 2 \
    "test -f system-update.yml" \
    "Create playbook: system-update.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook system-update.yml --syntax-check" \
    "Fix YAML syntax"

check "Updates all packages" 4 \
    "grep -q \"name:.*'\\*'\" system-update.yml && grep -q 'state:.*latest' system-update.yml" \
    "Update all packages with name: '*' and state: latest"

check "Uses reboot module" 3 \
    "grep -q 'ansible.builtin.reboot' system-update.yml" \
    "Use ansible.builtin.reboot module"

check "Waits for system" 3 \
    "grep -q 'ansible.builtin.wait_for_connection' system-update.yml" \
    "Use wait_for_connection after reboot"

check "Uses conditionals for reboot" 4 \
    "grep -q 'when:' system-update.yml" \
    "Use conditionals to reboot only when needed"

# ============================================================================
# TASK 13 - Backup Configuration (22 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 13: Backup Configuration (22 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook backup-config.yml exists" 3 \
    "test -f backup-config.yml" \
    "Create playbook: backup-config.yml"

check "Playbook has valid syntax" 3 \
    "ansible-playbook backup-config.yml --syntax-check" \
    "Fix YAML syntax"

check "Uses fetch module" 4 \
    "grep -q 'ansible.builtin.fetch' backup-config.yml" \
    "Use fetch module to retrieve files"

check "Uses archive module" 4 \
    "grep -q 'community.general.archive' backup-config.yml" \
    "Use archive module to create backup"

check "Uses find module" 4 \
    "grep -q 'ansible.builtin.find' backup-config.yml" \
    "Use find module to locate files"

check "Implements retention policy" 4 \
    "grep -q 'age:' backup-config.yml || grep -q 'mtime:' backup-config.yml" \
    "Implement retention policy with age or mtime"

# ============================================================================
# TASK 14 - Monitoring Setup (20 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 14: Monitoring Setup (20 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook monitoring-setup.yml exists" 3 \
    "test -f monitoring-setup.yml" \
    "Create playbook: monitoring-setup.yml"

check "Playbook has valid syntax" 3 \
    "ansible-playbook monitoring-setup.yml --syntax-check" \
    "Fix YAML syntax"

check "Installs monitoring packages" 4 \
    "grep -q 'ansible.builtin.dnf' monitoring-setup.yml || grep -q 'ansible.builtin.package' monitoring-setup.yml" \
    "Install monitoring agent packages"

check "Configures monitoring" 4 \
    "grep -q 'ansible.builtin.template' monitoring-setup.yml || grep -q 'ansible.builtin.copy' monitoring-setup.yml" \
    "Configure monitoring with template or copy"

check "Manages monitoring service" 3 \
    "grep -q 'ansible.builtin.service' monitoring-setup.yml" \
    "Start and enable monitoring service"

check "Tests monitoring" 3 \
    "grep -q 'ansible.builtin.uri' monitoring-setup.yml || grep -q 'ansible.builtin.wait_for' monitoring-setup.yml" \
    "Test monitoring endpoint or port"

# ============================================================================
# TASK 15 - Complete Web Server Stack (25 pts)
# ============================================================================
echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}TASK 15: Complete Web Server Stack (25 points)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

check "Playbook webserver-stack.yml exists" 2 \
    "test -f webserver-stack.yml" \
    "Create playbook: webserver-stack.yml"

check "Playbook has valid syntax" 2 \
    "ansible-playbook webserver-stack.yml --syntax-check" \
    "Fix YAML syntax"

ansible_check "Apache/httpd installed" 3 \
    "all" "shell" "rpm -q httpd" "httpd-" \
    "Install httpd package"

ansible_check "PHP installed" 3 \
    "all" "shell" "rpm -q php" "php-" \
    "Install php package"

ansible_check "MariaDB installed" 3 \
    "all" "shell" "rpm -q mariadb-server" "mariadb-server-" \
    "Install mariadb-server package"

ansible_check "Httpd service running" 3 \
    "all" "shell" "systemctl is-active httpd" "active" \
    "Start httpd service"

ansible_check "MariaDB service running" 3 \
    "all" "shell" "systemctl is-active mariadb" "active" \
    "Start mariadb service"

check "Creates virtual host config" 3 \
    "grep -q 'ansible.builtin.template' webserver-stack.yml || grep -q 'ansible.builtin.copy' webserver-stack.yml" \
    "Create virtual host configuration"

check "Configures SSL" 3 \
    "grep -q 'openssl' webserver-stack.yml || grep -q 'mod_ssl' webserver-stack.yml" \
    "Configure SSL certificates"

# ============================================================================
# FINAL RESULTS
# ============================================================================
echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                      FINAL RESULTS                         ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

PERCENTAGE=$((TOTAL_POINTS * 100 / MAX_POINTS))

echo -e "Tasks Passed: ${GREEN}$PASSED_TASKS${NC} / $TASK_COUNT"
echo -e "Points Earned: ${GREEN}$TOTAL_POINTS${NC} / $MAX_POINTS"
echo -e "Percentage: ${GREEN}$PERCENTAGE%${NC}"
echo ""

if [ $TOTAL_POINTS -ge 202 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║                    ★ EXAM PASSED! ★                        ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║          Congratulations! You've completed the             ║${NC}"
    echo -e "${GREEN}║          System Administration exam!                       ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║          You've mastered all 16 thematic exams!            ║${NC}"
    echo -e "${GREEN}║          You're ready for the RHCE EX294 exam!             ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                            ║${NC}"
    echo -e "${RED}║                    ✗ EXAM FAILED ✗                         ║${NC}"
    echo -e "${RED}║                                                            ║${NC}"
    echo -e "${RED}║          You need 202 points to pass (70%)                 ║${NC}"
    echo -e "${RED}║          Current score: $TOTAL_POINTS points ($PERCENTAGE%)                      ║${NC}"
    echo -e "${RED}║                                                            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Review the failed tasks above and try again.${NC}"
    echo -e "${YELLOW}Focus on:${NC}"
    echo -e "${YELLOW}- Complete user management with vault${NC}"
    echo -e "${YELLOW}- Package management with conditionals${NC}"
    echo -e "${YELLOW}- Service management with handlers${NC}"
    echo -e "${YELLOW}- Firewall and SELinux configuration${NC}"
    echo -e "${YELLOW}- Storage, network, and system administration${NC}"
    echo -e "${YELLOW}- Complete web server stack deployment${NC}"
    echo ""
    exit 1
fi

# Made with Bob

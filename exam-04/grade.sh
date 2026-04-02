#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# RHCE Killer — Exam 04 Grading Script
# Validates Linux Administration tasks with Ansible
# ═══════════════════════════════════════════════════════════════════════════

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Scoring
TOTAL_SCORE=0
MAX_SCORE=120
FAILED_TASKS=()

# Helper function to check conditions
check() {
    local description="$1"
    local command="$2"
    local points="$3"
    local hint="$4"
    
    echo -ne "${CYAN}Checking:${NC} $description... "
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC} (+${points} pts)"
        TOTAL_SCORE=$((TOTAL_SCORE + points))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (0 pts)"
        if [ -n "$hint" ]; then
            echo -e "  ${YELLOW}💡 Hint:${NC} $hint"
        fi
        FAILED_TASKS+=("$description")
        return 1
    fi
}

# Helper to check file exists
file_exists() {
    [ -f "$1" ]
}

# Helper to check directory exists
dir_exists() {
    [ -d "$1" ]
}

clear
echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                  RHCE KILLER — Exam 04 Grading                         ║"
echo "║              Linux Administration with Ansible                         ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 01: User and Group Management (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 01: User and Group Management (10 pts) ━━━${NC}"

check "Playbook users.yml exists" \
    "file_exists /home/student/ansible/users.yml" \
    1 \
    "Create /home/student/ansible/users.yml playbook"

check "Group developers exists (GID 3000)" \
    "ansible all -m shell -a 'getent group developers' 2>/dev/null | grep -q '3000'" \
    1 \
    "Create group developers with GID 3000"

check "Group operators exists (GID 3001)" \
    "ansible all -m shell -a 'getent group operators' 2>/dev/null | grep -q '3001'" \
    1 \
    "Create group operators with GID 3001"

check "Group admins exists (GID 3002)" \
    "ansible all -m shell -a 'getent group admins' 2>/dev/null | grep -q '3002'" \
    1 \
    "Create group admins with GID 3002"

check "User alice exists (UID 3001)" \
    "ansible all -m shell -a 'id alice' 2>/dev/null | grep -q 'uid=3001'" \
    1 \
    "Create user alice with UID 3001"

check "User alice in correct groups" \
    "ansible all -m shell -a 'groups alice' 2>/dev/null | grep -q 'developers' && ansible all -m shell -a 'groups alice' 2>/dev/null | grep -q 'admins'" \
    2 \
    "Add alice to developers (primary) and admins (secondary) groups"

check "User bob exists (UID 3002)" \
    "ansible all -m shell -a 'id bob' 2>/dev/null | grep -q 'uid=3002'" \
    1 \
    "Create user bob with UID 3002 in operators group"

check "User charlie exists (UID 3003)" \
    "ansible all -m shell -a 'id charlie' 2>/dev/null | grep -q 'uid=3003'" \
    1 \
    "Create user charlie with UID 3003 in developers group"

check "User testuser is absent" \
    "! ansible all -m shell -a 'id testuser' 2>/dev/null | grep -q 'uid='" \
    1 \
    "Remove user testuser from all systems"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 02: SSH Key Management (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 02: SSH Key Management (10 pts) ━━━${NC}"

check "Playbook ssh_keys.yml exists" \
    "file_exists /home/student/ansible/ssh_keys.yml" \
    2 \
    "Create /home/student/ansible/ssh_keys.yml playbook"

check "Alice's .ssh directory exists" \
    "ansible all -m shell -a 'test -d /home/alice/.ssh' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create .ssh directory for alice with correct permissions (700)"

check "Alice's .ssh directory has correct permissions" \
    "ansible all -m shell -a 'stat -c %a /home/alice/.ssh' 2>/dev/null | grep -q '700'" \
    2 \
    "Set permissions 700 on /home/alice/.ssh"

check "Bob's authorized_keys exists" \
    "ansible all -m shell -a 'test -f /home/bob/.ssh/authorized_keys' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create authorized_keys file for bob"

check "Authorized_keys has correct permissions" \
    "ansible all -m shell -a 'stat -c %a /home/bob/.ssh/authorized_keys' 2>/dev/null | grep -q '600'" \
    2 \
    "Set permissions 600 on authorized_keys files"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 03: Sudo Configuration (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 03: Sudo Configuration (10 pts) ━━━${NC}"

check "Playbook sudo.yml exists" \
    "file_exists /home/student/ansible/sudo.yml" \
    2 \
    "Create /home/student/ansible/sudo.yml playbook"

check "Sudoers file exists" \
    "ansible all -m shell -a 'test -f /etc/sudoers.d/custom_sudo' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create /etc/sudoers.d/custom_sudo file"

check "Sudoers file has correct permissions" \
    "ansible all -m shell -a 'stat -c %a /etc/sudoers.d/custom_sudo' 2>/dev/null | grep -q '440'" \
    2 \
    "Set permissions 440 on sudoers file"

check "Admins group has NOPASSWD access" \
    "ansible all -m shell -a 'grep -q \"^%admins.*NOPASSWD.*ALL\" /etc/sudoers.d/custom_sudo' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Configure admins group with NOPASSWD: ALL"

check "Alice has sudo for yum/dnf" \
    "ansible all -m shell -a 'grep -q \"^alice.*NOPASSWD.*yum\\|dnf\" /etc/sudoers.d/custom_sudo' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Configure alice to run yum/dnf without password"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 04: Scheduled Tasks (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 04: Scheduled Tasks (15 pts) ━━━${NC}"

check "Playbook scheduled_tasks.yml exists" \
    "file_exists /home/student/ansible/scheduled_tasks.yml" \
    2 \
    "Create /home/student/ansible/scheduled_tasks.yml playbook"

check "Backup script exists" \
    "ansible all -m shell -a 'test -f /usr/local/bin/backup.sh' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create /usr/local/bin/backup.sh script"

check "Backup script is executable" \
    "ansible all -m shell -a 'test -x /usr/local/bin/backup.sh' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    1 \
    "Set execute permissions on backup.sh"

check "Log rotation script exists" \
    "ansible all -m shell -a 'test -f /usr/local/bin/rotate_logs.sh' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create /usr/local/bin/rotate_logs.sh script"

check "Daily backup cron job exists" \
    "ansible all -m shell -a 'crontab -l | grep backup.sh' 2>/dev/null | grep -c 'backup.sh' | grep -q '[3-9]'" \
    3 \
    "Create cron job for daily backup at 2:00 AM"

check "Hourly log rotation cron job exists" \
    "ansible all -m shell -a 'crontab -l | grep rotate_logs.sh' 2>/dev/null | grep -c 'rotate_logs.sh' | grep -q '[3-9]'" \
    2 \
    "Create cron job for hourly log rotation"

check "Cron service is running" \
    "ansible all -m shell -a 'systemctl is-active crond' 2>/dev/null | grep -c 'active' | grep -q '3'" \
    3 \
    "Ensure crond service is running and enabled"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 05: Storage Management (20 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 05: Storage Management (20 pts) ━━━${NC}"

check "Playbook storage.yml exists" \
    "file_exists /home/student/ansible/storage.yml" \
    2 \
    "Create /home/student/ansible/storage.yml playbook"

check "Volume group vg_data exists" \
    "ansible all -m shell -a 'vgs vg_data' 2>/dev/null | grep -q 'vg_data'" \
    3 \
    "Create volume group vg_data"

check "Logical volume lv_app exists (2GB)" \
    "ansible all -m shell -a 'lvs vg_data/lv_app' 2>/dev/null | grep -q 'lv_app'" \
    3 \
    "Create logical volume lv_app (2GB)"

check "Logical volume lv_logs exists (1GB)" \
    "ansible all -m shell -a 'lvs vg_data/lv_logs' 2>/dev/null | grep -q 'lv_logs'" \
    2 \
    "Create logical volume lv_logs (1GB)"

check "/mnt/app is mounted" \
    "ansible all -m shell -a 'df -h | grep /mnt/app' 2>/dev/null | grep -q '/mnt/app'" \
    3 \
    "Mount lv_app at /mnt/app"

check "/mnt/logs is mounted" \
    "ansible all -m shell -a 'df -h | grep /mnt/logs' 2>/dev/null | grep -q '/mnt/logs'" \
    2 \
    "Mount lv_logs at /mnt/logs"

check "Mounts are in /etc/fstab" \
    "ansible all -m shell -a 'grep -E \"/mnt/(app|logs)\" /etc/fstab' 2>/dev/null | grep -c '/mnt' | grep -q '[6-9]'" \
    3 \
    "Add mount points to /etc/fstab for persistence"

check "/mnt/app has correct ownership" \
    "ansible all -m shell -a 'stat -c \"%U:%G\" /mnt/app' 2>/dev/null | grep -q 'alice:developers'" \
    2 \
    "Set ownership of /mnt/app to alice:developers"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 06: Filesystem Management (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 06: Filesystem Management (15 pts) ━━━${NC}"

check "Playbook filesystems.yml exists" \
    "file_exists /home/student/ansible/filesystems.yml" \
    2 \
    "Create /home/student/ansible/filesystems.yml playbook"

check "/data/shared directory exists" \
    "ansible all -m shell -a 'test -d /data/shared' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create /data/shared directory"

check "/data/shared has setgid bit" \
    "ansible all -m shell -a 'stat -c %a /data/shared' 2>/dev/null | grep -q '2775'" \
    2 \
    "Set permissions 2775 (with setgid) on /data/shared"

check "/data/private directory exists" \
    "ansible all -m shell -a 'test -d /data/private' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create /data/private directory with permissions 700"

check "Symbolic link /opt/app exists" \
    "ansible all -m shell -a 'test -L /opt/app' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create symbolic link /opt/app → /data/shared/app"

check "ACL package installed" \
    "ansible all -m shell -a 'rpm -q acl' 2>/dev/null | grep -q 'acl'" \
    2 \
    "Install acl package"

check "ACLs set on /data/shared" \
    "ansible all -m shell -a 'getfacl /data/shared | grep -E \"user:bob|group:operators\"' 2>/dev/null | grep -c 'bob\\|operators' | grep -q '[3-9]'" \
    3 \
    "Set ACLs for bob and operators group on /data/shared"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 07: Network Configuration (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 07: Network Configuration (15 pts) ━━━${NC}"

check "Playbook network.yml exists" \
    "file_exists /home/student/ansible/network.yml" \
    2 \
    "Create /home/student/ansible/network.yml playbook"

check "/etc/hosts has inventory entries" \
    "ansible all -m shell -a 'grep -E \"(node1|node2|node3)\" /etc/hosts' 2>/dev/null | grep -c 'node' | grep -q '[6-9]'" \
    3 \
    "Add all inventory hosts to /etc/hosts"

check "/etc/hosts has custom entry" \
    "ansible all -m shell -a 'grep -q \"192.168.1.100.*app.example.com\" /etc/hosts' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Add custom entry 192.168.1.100 app.example.com to /etc/hosts"

check "DNS servers configured" \
    "ansible all -m shell -a 'grep -E \"(8.8.8.8|8.8.4.4)\" /etc/resolv.conf' 2>/dev/null | grep -c '8.8' | grep -q '[3-9]'" \
    3 \
    "Configure DNS servers 8.8.8.8 and 8.8.4.4"

check "Search domain configured" \
    "ansible all -m shell -a 'grep -q \"search example.com\" /etc/resolv.conf' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Set search domain to example.com"

check "NetworkManager is running" \
    "ansible all -m shell -a 'systemctl is-active NetworkManager' 2>/dev/null | grep -c 'active' | grep -q '3'" \
    3 \
    "Ensure NetworkManager is running and enabled"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 08: Firewall Configuration (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 08: Firewall Configuration (10 pts) ━━━${NC}"

check "Playbook firewall.yml exists" \
    "file_exists /home/student/ansible/firewall.yml" \
    1 \
    "Create /home/student/ansible/firewall.yml playbook"

check "Firewalld is running" \
    "ansible all -m shell -a 'systemctl is-active firewalld' 2>/dev/null | grep -c 'active' | grep -q '3'" \
    1 \
    "Ensure firewalld is running and enabled"

check "HTTP service allowed" \
    "ansible all -m shell -a 'firewall-cmd --list-services' 2>/dev/null | grep -c 'http' | grep -q '[3-9]'" \
    1 \
    "Allow http service in firewall"

check "HTTPS service allowed" \
    "ansible all -m shell -a 'firewall-cmd --list-services' 2>/dev/null | grep -c 'https' | grep -q '[3-9]'" \
    1 \
    "Allow https service in firewall"

check "Port 8080 allowed" \
    "ansible all -m shell -a 'firewall-cmd --list-ports' 2>/dev/null | grep -c '8080' | grep -q '[3-9]'" \
    2 \
    "Allow port 8080/tcp in firewall"

check "Port 9090 allowed" \
    "ansible all -m shell -a 'firewall-cmd --list-ports' 2>/dev/null | grep -c '9090' | grep -q '[3-9]'" \
    2 \
    "Allow port 9090/tcp in firewall"

check "MySQL port on database servers" \
    "ansible database -m shell -a 'firewall-cmd --list-ports' 2>/dev/null | grep -q '3306'" \
    2 \
    "Allow port 3306/tcp on database group only"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 09: SELinux Configuration (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 09: SELinux Configuration (10 pts) ━━━${NC}"

check "Playbook selinux.yml exists" \
    "file_exists /home/student/ansible/selinux.yml" \
    1 \
    "Create /home/student/ansible/selinux.yml playbook"

check "SELinux is in enforcing mode" \
    "ansible all -m shell -a 'getenforce' 2>/dev/null | grep -c 'Enforcing' | grep -q '3'" \
    2 \
    "Set SELinux to enforcing mode"

check "SELinux context on /data/shared" \
    "ansible all -m shell -a 'ls -Zd /data/shared' 2>/dev/null | grep -q 'httpd_sys_content_t'" \
    2 \
    "Set SELinux context httpd_sys_content_t on /data/shared"

check "Boolean httpd_can_network_connect enabled" \
    "ansible all -m shell -a 'getsebool httpd_can_network_connect' 2>/dev/null | grep -c 'on' | grep -q '3'" \
    2 \
    "Enable SELinux boolean httpd_can_network_connect"

check "Boolean httpd_can_network_connect_db enabled" \
    "ansible all -m shell -a 'getsebool httpd_can_network_connect_db' 2>/dev/null | grep -c 'on' | grep -q '3'" \
    2 \
    "Enable SELinux boolean httpd_can_network_connect_db"

check "Port 8080 has http_port_t context" \
    "ansible all -m shell -a 'semanage port -l | grep http_port_t | grep 8080' 2>/dev/null | grep -q '8080'" \
    1 \
    "Add SELinux port context for 8080/tcp"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 10: System Facts and Custom Facts (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 10: System Facts and Custom Facts (15 pts) ━━━${NC}"

check "Playbook facts.yml exists" \
    "file_exists /home/student/ansible/facts.yml" \
    2 \
    "Create /home/student/ansible/facts.yml playbook"

check "Custom facts directory exists" \
    "ansible all -m shell -a 'test -d /etc/ansible/facts.d' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Create /etc/ansible/facts.d directory"

check "Custom fact script exists" \
    "ansible all -m shell -a 'test -f /etc/ansible/facts.d/system_info.fact' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Create custom fact script system_info.fact"

check "Custom fact script is executable" \
    "ansible all -m shell -a 'test -x /etc/ansible/facts.d/system_info.fact' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    2 \
    "Set execute permissions on custom fact script"

check "System report file exists" \
    "ansible all -m shell -a 'test -f /var/log/system_report.txt' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Create system report at /var/log/system_report.txt"

check "MOTD file configured" \
    "ansible all -m shell -a 'test -f /etc/motd' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Configure /etc/motd with system information"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# FINAL REPORT
# ═══════════════════════════════════════════════════════════════════════════
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                           FINAL SCORE                                  ║"
echo "╠════════════════════════════════════════════════════════════════════════╣"

PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))

if [ $PERCENTAGE -ge 70 ]; then
    COLOR=$GREEN
    STATUS="✓ PASS"
elif [ $PERCENTAGE -ge 50 ]; then
    COLOR=$YELLOW
    STATUS="⚠ NEEDS IMPROVEMENT"
else
    COLOR=$RED
    STATUS="✗ FAIL"
fi

printf "║  Score: ${COLOR}%3d / %3d points (%3d%%)${NC}                                 ║\n" $TOTAL_SCORE $MAX_SCORE $PERCENTAGE
printf "║  Status: ${COLOR}%-20s${NC}                                       ║\n" "$STATUS"
echo "╚════════════════════════════════════════════════════════════════════════╝"

# Show failed tasks if any
if [ ${#FAILED_TASKS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Failed Tasks:${NC}"
    for task in "${FAILED_TASKS[@]}"; do
        echo -e "  ${RED}✗${NC} $task"
    done
    echo ""
    echo -e "${CYAN}💡 Tips:${NC}"
    echo "  • Review the hints above for each failed check"
    echo "  • Verify user/group configurations: id <username>"
    echo "  • Check file permissions: ls -l <file>"
    echo "  • Verify cron jobs: crontab -l"
    echo "  • Check storage: lvs, vgs, df -h"
    echo "  • Verify firewall: firewall-cmd --list-all"
    echo "  • Check SELinux: getenforce, getsebool -a"
    echo "  • View solutions: cat ~/exams/exam-04/README.md | less"
fi

echo ""

# Exit with appropriate code
if [ $PERCENTAGE -ge 70 ]; then
    exit 0
else
    exit 1
fi

# Made with Bob

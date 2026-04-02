#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# RHCE Killer — Exam 02 Grading Script
# Validates intermediate Ansible tasks
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

# Helper to check user exists
user_exists() {
    id "$1" &>/dev/null
}

# Helper to check group exists
group_exists() {
    getent group "$1" &>/dev/null
}

# Helper to check service status
service_active() {
    ansible all -m shell -a "systemctl is-active $1" 2>/dev/null | grep -q "active"
}

# Helper to check service enabled
service_enabled() {
    ansible all -m shell -a "systemctl is-enabled $1" 2>/dev/null | grep -q "enabled"
}

clear
echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                  RHCE KILLER — Exam 02 Grading                         ║"
echo "║                    Intermediate Ansible Tasks                          ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 01: Advanced Loops with Dictionaries (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 01: Advanced Loops with Dictionaries (10 pts) ━━━${NC}"

check "Playbook users.yml exists" \
    "file_exists /home/student/ansible/users.yml" \
    1 \
    "Create /home/student/ansible/users.yml playbook"

check "User alice exists on all nodes" \
    "ansible all -m shell -a 'id alice' 2>/dev/null | grep -q 'uid=2001'" \
    2 \
    "Create user alice with UID 2001 using loop with dictionary"

check "User bob exists on all nodes" \
    "ansible all -m shell -a 'id bob' 2>/dev/null | grep -q 'uid=2002'" \
    2 \
    "Create user bob with UID 2002 using loop with dictionary"

check "User charlie exists on all nodes" \
    "ansible all -m shell -a 'id charlie' 2>/dev/null | grep -q 'uid=2003'" \
    2 \
    "Create user charlie with UID 2003 using loop with dictionary"

check "Group developers exists" \
    "ansible all -m shell -a 'getent group developers' 2>/dev/null | grep -q 'developers'" \
    1 \
    "Create group 'developers' and assign users to it"

check "Users are in developers group" \
    "ansible all -m shell -a 'groups alice bob charlie' 2>/dev/null | grep -q 'developers'" \
    2 \
    "Add alice, bob, and charlie to developers group"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 02: Complex Conditionals with Facts (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 02: Complex Conditionals with Facts (10 pts) ━━━${NC}"

check "Playbook system_classify.yml exists" \
    "file_exists /home/student/ansible/system_classify.yml" \
    2 \
    "Create /home/student/ansible/system_classify.yml playbook"

check "Classification file exists on nodes" \
    "ansible all -m shell -a 'test -f /etc/system_class.txt' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Create /etc/system_class.txt on all nodes based on RAM"

check "Classification content is correct" \
    "ansible all -m shell -a 'cat /etc/system_class.txt' 2>/dev/null | grep -E '(small|medium|large)'" \
    3 \
    "File should contain 'small', 'medium', or 'large' based on RAM (< 2GB, 2-4GB, > 4GB)"

check "Uses ansible_memtotal_mb fact" \
    "grep -q 'ansible_memtotal_mb' /home/student/ansible/system_classify.yml" \
    2 \
    "Use ansible_memtotal_mb fact in conditionals"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 03: Multiple Handlers (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 03: Multiple Handlers (10 pts) ━━━${NC}"

check "Playbook webserver.yml exists" \
    "file_exists /home/student/ansible/webserver.yml" \
    1 \
    "Create /home/student/ansible/webserver.yml playbook"

check "Apache is installed on web group" \
    "ansible web -m shell -a 'rpm -q httpd' 2>/dev/null | grep -q 'httpd'" \
    2 \
    "Install httpd package on web group"

check "Apache config file exists" \
    "ansible web -m shell -a 'test -f /etc/httpd/conf.d/custom.conf' 2>/dev/null | grep -q 'SUCCESS'" \
    2 \
    "Create /etc/httpd/conf.d/custom.conf configuration file"

check "Apache service is running" \
    "service_active httpd" \
    2 \
    "Ensure httpd service is started and enabled"

check "Firewall allows HTTP" \
    "ansible web -m shell -a 'firewall-cmd --list-services' 2>/dev/null | grep -q 'http'" \
    2 \
    "Add http service to firewall using firewalld module"

check "Handlers section exists in playbook" \
    "grep -q 'handlers:' /home/student/ansible/webserver.yml" \
    1 \
    "Define handlers section with restart and reload handlers"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 04: Block/Rescue/Always (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 04: Block/Rescue/Always (15 pts) ━━━${NC}"

check "Playbook backup.yml exists" \
    "file_exists /home/student/ansible/backup.yml" \
    2 \
    "Create /home/student/ansible/backup.yml playbook"

check "Uses block/rescue/always structure" \
    "grep -q 'block:' /home/student/ansible/backup.yml && grep -q 'rescue:' /home/student/ansible/backup.yml && grep -q 'always:' /home/student/ansible/backup.yml" \
    4 \
    "Use block/rescue/always structure in playbook"

check "Backup directory exists" \
    "ansible all -m shell -a 'test -d /backup' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Create /backup directory in block section"

check "Log file exists" \
    "ansible all -m shell -a 'test -f /var/log/backup.log' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Create /var/log/backup.log in always section"

check "Error handling is implemented" \
    "grep -q 'rescue:' /home/student/ansible/backup.yml" \
    3 \
    "Implement error handling in rescue section"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 05: Register Variables and Debug (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 05: Register Variables and Debug (10 pts) ━━━${NC}"

check "Playbook disk_check.yml exists" \
    "file_exists /home/student/ansible/disk_check.yml" \
    2 \
    "Create /home/student/ansible/disk_check.yml playbook"

check "Uses register keyword" \
    "grep -q 'register:' /home/student/ansible/disk_check.yml" \
    2 \
    "Use register to capture command output"

check "Uses debug module" \
    "grep -q 'debug:' /home/student/ansible/disk_check.yml" \
    2 \
    "Use debug module to display registered variable"

check "Checks disk usage with df command" \
    "grep -q 'df' /home/student/ansible/disk_check.yml" \
    2 \
    "Use df command to check disk usage"

check "Uses when condition with register" \
    "grep -q 'when:' /home/student/ansible/disk_check.yml" \
    2 \
    "Use when condition to check disk usage threshold"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 06: Advanced Jinja2 Templates (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 06: Advanced Jinja2 Templates (15 pts) ━━━${NC}"

check "Playbook deploy_config.yml exists" \
    "file_exists /home/student/ansible/deploy_config.yml" \
    2 \
    "Create /home/student/ansible/deploy_config.yml playbook"

check "Template file system_info.j2 exists" \
    "file_exists /home/student/ansible/templates/system_info.j2" \
    2 \
    "Create templates/system_info.j2 template file"

check "Template uses loops" \
    "grep -q 'for' /home/student/ansible/templates/system_info.j2" \
    3 \
    "Use Jinja2 for loops in template"

check "Template uses conditionals" \
    "grep -q 'if' /home/student/ansible/templates/system_info.j2" \
    3 \
    "Use Jinja2 if conditionals in template"

check "Config file deployed to nodes" \
    "ansible all -m shell -a 'test -f /etc/system_info.conf' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Deploy template to /etc/system_info.conf on all nodes"

check "Template contains facts" \
    "grep -q 'ansible_' /home/student/ansible/templates/system_info.j2" \
    2 \
    "Use Ansible facts in template (ansible_hostname, ansible_distribution, etc.)"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 07: File Modules (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 07: File Modules (15 pts) ━━━${NC}"

check "Playbook file_ops.yml exists" \
    "file_exists /home/student/ansible/file_ops.yml" \
    1 \
    "Create /home/student/ansible/file_ops.yml playbook"

check "Source file copied to nodes" \
    "ansible all -m shell -a 'test -f /opt/app/config.txt' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Use copy module to copy files/config.txt to /opt/app/config.txt"

check "Line added to file" \
    "ansible all -m shell -a 'grep -q \"Environment=production\" /opt/app/config.txt' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Use lineinfile to add 'Environment=production' to config.txt"

check "Block added to file" \
    "ansible all -m shell -a 'grep -q \"# Monitoring Configuration\" /opt/app/config.txt' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Use blockinfile to add monitoring configuration block"

check "File fetched from nodes" \
    "test -f /home/student/ansible/fetched_configs/node1/opt/app/config.txt || test -f /home/student/ansible/fetched_configs/node2/opt/app/config.txt" \
    3 \
    "Use fetch module to retrieve config.txt from nodes"

check "Uses multiple file modules" \
    "grep -q 'copy:' /home/student/ansible/file_ops.yml && grep -q 'lineinfile:' /home/student/ansible/file_ops.yml && grep -q 'blockinfile:' /home/student/ansible/file_ops.yml && grep -q 'fetch:' /home/student/ansible/file_ops.yml" \
    2 \
    "Use copy, lineinfile, blockinfile, and fetch modules"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 08: OS-Specific Package Management (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 08: OS-Specific Package Management (10 pts) ━━━${NC}"

check "Playbook packages.yml exists" \
    "file_exists /home/student/ansible/packages.yml" \
    2 \
    "Create /home/student/ansible/packages.yml playbook"

check "Uses ansible_distribution fact" \
    "grep -q 'ansible_distribution' /home/student/ansible/packages.yml || grep -q 'ansible_os_family' /home/student/ansible/packages.yml" \
    2 \
    "Use ansible_distribution or ansible_os_family fact"

check "Packages installed on all nodes" \
    "ansible all -m shell -a 'rpm -q wget curl' 2>/dev/null | grep -c 'wget\\|curl' | grep -q '[6-9]'" \
    3 \
    "Install wget and curl packages on all nodes"

check "Uses conditional package installation" \
    "grep -q 'when:' /home/student/ansible/packages.yml" \
    2 \
    "Use when condition for OS-specific package installation"

check "Uses package or dnf module" \
    "grep -q 'package:\\|dnf:' /home/student/ansible/packages.yml" \
    1 \
    "Use package or dnf module for installation"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 09: Service Management (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 09: Service Management (10 pts) ━━━${NC}"

check "Playbook services.yml exists" \
    "file_exists /home/student/ansible/services.yml" \
    2 \
    "Create /home/student/ansible/services.yml playbook"

check "Chronyd package installed" \
    "ansible all -m shell -a 'rpm -q chrony' 2>/dev/null | grep -q 'chrony'" \
    2 \
    "Install chrony package on all nodes"

check "Chronyd service is running" \
    "service_active chronyd" \
    3 \
    "Ensure chronyd service is started"

check "Chronyd service is enabled" \
    "service_enabled chronyd" \
    2 \
    "Ensure chronyd service is enabled at boot"

check "Uses service or systemd module" \
    "grep -q 'service:\\|systemd:' /home/student/ansible/services.yml" \
    1 \
    "Use service or systemd module for service management"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 10: Multi-File Ansible Vault (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 10: Multi-File Ansible Vault (15 pts) ━━━${NC}"

check "Playbook vault_demo.yml exists" \
    "file_exists /home/student/ansible/vault_demo.yml" \
    2 \
    "Create /home/student/ansible/vault_demo.yml playbook"

check "Vault password file exists" \
    "file_exists /home/student/ansible/vault_pass.txt" \
    2 \
    "Create vault_pass.txt password file"

check "Encrypted vars file exists" \
    "file_exists /home/student/ansible/group_vars/all/vault.yml" \
    2 \
    "Create encrypted group_vars/all/vault.yml file"

check "Vault file is encrypted" \
    "head -1 /home/student/ansible/group_vars/all/vault.yml | grep -q '\$ANSIBLE_VAULT'" \
    3 \
    "Encrypt vault.yml with ansible-vault"

check "Secret file created on nodes" \
    "ansible all -m shell -a 'test -f /etc/secret.conf' 2>/dev/null | grep -c 'SUCCESS' | grep -q '3'" \
    3 \
    "Create /etc/secret.conf using vault variables"

check "Uses vault variables in playbook" \
    "grep -q 'vault_' /home/student/ansible/vault_demo.yml || grep -q 'secret_' /home/student/ansible/vault_demo.yml" \
    3 \
    "Reference vault variables in playbook"

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
    echo "  • Check playbook syntax: ansible-playbook --syntax-check <playbook>"
    echo "  • Test playbooks: ansible-playbook <playbook> --check"
    echo "  • View solutions: cat ~/exams/exam-02/README.md | less"
    echo "  • Check Ansible docs: ansible-doc <module_name>"
fi

echo ""

# Exit with appropriate code
if [ $PERCENTAGE -ge 70 ]; then
    exit 0
else
    exit 1
fi

# Made with Bob

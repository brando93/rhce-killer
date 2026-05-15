#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# RHCE Killer — Exam 02 Grading Script
# Validates intermediate Ansible tasks
# ═══════════════════════════════════════════════════════════════════════════

# ───── shared helpers (color codes, check(), counters, print_summary) ─
# Probe standard locations: local repo and ~/exams/lib on the control node.
for _LIB in \
    "$(dirname "$0")/../../lib/grade-helpers.sh" \
    "$(dirname "$0")/../scripts/lib/grade-helpers.sh" \
    "$(dirname "$0")/../lib/grade-helpers.sh"; do
    [ -f "$_LIB" ] && { source "$_LIB"; break; }
done
unset _LIB


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
    1 \
    "file_exists /home/student/ansible/users.yml" \
    "Create /home/student/ansible/users.yml playbook"

check "User alice exists on all nodes" \
    2 \
    "ansible all -m shell -a 'id alice' 2>/dev/null | grep -q 'uid=2001'" \
    "Create user alice with UID 2001 using loop with dictionary"

check "User bob exists on all nodes" \
    2 \
    "ansible all -m shell -a 'id bob' 2>/dev/null | grep -q 'uid=2002'" \
    "Create user bob with UID 2002 using loop with dictionary"

check "User charlie exists on all nodes" \
    2 \
    "ansible all -m shell -a 'id charlie' 2>/dev/null | grep -q 'uid=2003'" \
    "Create user charlie with UID 2003 using loop with dictionary"

check "Group developers exists" \
    1 \
    "ansible all -m shell -a 'getent group developers' 2>/dev/null | grep -q 'developers'" \
    "Create group 'developers' and assign users to it"

check "Users are in developers group" \
    2 \
    "ansible all -m shell -a 'groups alice bob charlie' 2>/dev/null | grep -q 'developers'" \
    "Add alice, bob, and charlie to developers group"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 02: Complex Conditionals with Facts (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 02: Complex Conditionals with Facts (10 pts) ━━━${NC}"

check "Playbook system_classify.yml exists" \
    2 \
    "file_exists /home/student/ansible/system_classify.yml" \
    "Create /home/student/ansible/system_classify.yml playbook"

check "Classification file exists on nodes" \
    3 \
    "ansible all -m shell -a 'test -f /etc/system_class.txt' &>/dev/null" \
    "Create /etc/system_class.txt on all nodes based on RAM"

check "Classification content is correct" \
    3 \
    "ansible all -m shell -a 'cat /etc/system_class.txt' 2>/dev/null | grep -E '(small|medium|large)'" \
    "File should contain 'small', 'medium', or 'large' based on RAM (< 2GB, 2-4GB, > 4GB)"

check "Uses ansible_memtotal_mb fact" \
    2 \
    "grep -q 'ansible_memtotal_mb' /home/student/ansible/system_classify.yml" \
    "Use ansible_memtotal_mb fact in conditionals"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 03: Multiple Handlers (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 03: Multiple Handlers (10 pts) ━━━${NC}"

check "Playbook webserver.yml exists" \
    1 \
    "file_exists /home/student/ansible/webserver.yml" \
    "Create /home/student/ansible/webserver.yml playbook"

check "Apache is installed on web group" \
    2 \
    "ansible web -m shell -a 'rpm -q httpd' 2>/dev/null | grep -q 'httpd'" \
    "Install httpd package on web group"

check "Apache config file exists" \
    2 \
    "ansible web -m shell -a 'test -f /etc/httpd/conf.d/custom.conf' 2>/dev/null | grep -q 'SUCCESS'" \
    "Create /etc/httpd/conf.d/custom.conf configuration file"

check "Apache service is running" \
    2 \
    "service_active httpd" \
    "Ensure httpd service is started and enabled"

check "Firewall allows HTTP" \
    2 \
    "ansible web -m shell -a 'firewall-cmd --list-services' 2>/dev/null | grep -q 'http'" \
    "Add http service to firewall using firewalld module"

check "Handlers section exists in playbook" \
    1 \
    "grep -q 'handlers:' /home/student/ansible/webserver.yml" \
    "Define handlers section with restart and reload handlers"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 04: Block/Rescue/Always (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 04: Block/Rescue/Always (15 pts) ━━━${NC}"

check "Playbook backup.yml exists" \
    2 \
    "file_exists /home/student/ansible/backup.yml" \
    "Create /home/student/ansible/backup.yml playbook"

check "Uses block/rescue/always structure" \
    4 \
    "grep -q 'block:' /home/student/ansible/backup.yml && grep -q 'rescue:' /home/student/ansible/backup.yml && grep -q 'always:' /home/student/ansible/backup.yml" \
    "Use block/rescue/always structure in playbook"

check "Backup directory exists" \
    3 \
    "ansible all -m shell -a 'test -d /backup' &>/dev/null" \
    "Create /backup directory in block section"

check "Log file exists" \
    3 \
    "ansible all -m shell -a 'test -f /var/log/backup.log' &>/dev/null" \
    "Create /var/log/backup.log in always section"

check "Error handling is implemented" \
    3 \
    "grep -q 'rescue:' /home/student/ansible/backup.yml" \
    "Implement error handling in rescue section"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 05: Register Variables and Debug (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 05: Register Variables and Debug (10 pts) ━━━${NC}"

check "Playbook disk_check.yml exists" \
    2 \
    "file_exists /home/student/ansible/disk_check.yml" \
    "Create /home/student/ansible/disk_check.yml playbook"

check "Uses register keyword" \
    2 \
    "grep -q 'register:' /home/student/ansible/disk_check.yml" \
    "Use register to capture command output"

check "Uses debug module" \
    2 \
    "grep -q 'debug:' /home/student/ansible/disk_check.yml" \
    "Use debug module to display registered variable"

check "Checks disk usage with df command" \
    2 \
    "grep -q 'df' /home/student/ansible/disk_check.yml" \
    "Use df command to check disk usage"

check "Uses when condition with register" \
    2 \
    "grep -q 'when:' /home/student/ansible/disk_check.yml" \
    "Use when condition to check disk usage threshold"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 06: Advanced Jinja2 Templates (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 06: Advanced Jinja2 Templates (15 pts) ━━━${NC}"

check "Playbook deploy_config.yml exists" \
    2 \
    "file_exists /home/student/ansible/deploy_config.yml" \
    "Create /home/student/ansible/deploy_config.yml playbook"

check "Template file system_info.j2 exists" \
    2 \
    "file_exists /home/student/ansible/templates/system_info.j2" \
    "Create templates/system_info.j2 template file"

check "Template uses loops" \
    3 \
    "grep -q 'for' /home/student/ansible/templates/system_info.j2" \
    "Use Jinja2 for loops in template"

check "Template uses conditionals" \
    3 \
    "grep -q 'if' /home/student/ansible/templates/system_info.j2" \
    "Use Jinja2 if conditionals in template"

check "Config file deployed to nodes" \
    3 \
    "ansible all -m shell -a 'test -f /etc/system_info.conf' &>/dev/null" \
    "Deploy template to /etc/system_info.conf on all nodes"

check "Template contains facts" \
    2 \
    "grep -q 'ansible_' /home/student/ansible/templates/system_info.j2" \
    "Use Ansible facts in template (ansible_hostname, ansible_distribution, etc.)"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 07: File Modules (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 07: File Modules (15 pts) ━━━${NC}"

check "Playbook file_ops.yml exists" \
    1 \
    "file_exists /home/student/ansible/file_ops.yml" \
    "Create /home/student/ansible/file_ops.yml playbook"

check "Source file copied to nodes" \
    3 \
    "ansible all -m shell -a 'test -f /opt/app/config.txt' &>/dev/null" \
    "Use copy module to copy files/config.txt to /opt/app/config.txt"

check "Line added to file" \
    3 \
    "ansible all -m shell -a 'grep -q \"Environment=production\" /opt/app/config.txt' &>/dev/null" \
    "Use lineinfile to add 'Environment=production' to config.txt"

check "Block added to file" \
    3 \
    "ansible all -m shell -a 'grep -q \"# Monitoring Configuration\" /opt/app/config.txt' &>/dev/null" \
    "Use blockinfile to add monitoring configuration block"

check "File fetched from nodes" \
    3 \
    "test -f /home/student/ansible/fetched_configs/node1/opt/app/config.txt || test -f /home/student/ansible/fetched_configs/node2/opt/app/config.txt" \
    "Use fetch module to retrieve config.txt from nodes"

check "Uses multiple file modules" \
    2 \
    "grep -q 'copy:' /home/student/ansible/file_ops.yml && grep -q 'lineinfile:' /home/student/ansible/file_ops.yml && grep -q 'blockinfile:' /home/student/ansible/file_ops.yml && grep -q 'fetch:' /home/student/ansible/file_ops.yml" \
    "Use copy, lineinfile, blockinfile, and fetch modules"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 08: OS-Specific Package Management (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 08: OS-Specific Package Management (10 pts) ━━━${NC}"

check "Playbook packages.yml exists" \
    2 \
    "file_exists /home/student/ansible/packages.yml" \
    "Create /home/student/ansible/packages.yml playbook"

check "Uses ansible_distribution fact" \
    2 \
    "grep -q 'ansible_distribution' /home/student/ansible/packages.yml || grep -q 'ansible_os_family' /home/student/ansible/packages.yml" \
    "Use ansible_distribution or ansible_os_family fact"

check "Packages installed on all nodes" \
    3 \
    "ansible all -m shell -a 'rpm -q wget curl' 2>/dev/null | grep -c 'wget\\|curl' | grep -q '[6-9]'" \
    "Install wget and curl packages on all nodes"

check "Uses conditional package installation" \
    2 \
    "grep -q 'when:' /home/student/ansible/packages.yml" \
    "Use when condition for OS-specific package installation"

check "Uses package or dnf module" \
    1 \
    "grep -q 'package:\\|dnf:' /home/student/ansible/packages.yml" \
    "Use package or dnf module for installation"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 09: Service Management (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 09: Service Management (10 pts) ━━━${NC}"

check "Playbook services.yml exists" \
    2 \
    "file_exists /home/student/ansible/services.yml" \
    "Create /home/student/ansible/services.yml playbook"

check "Chronyd package installed" \
    2 \
    "ansible all -m shell -a 'rpm -q chrony' 2>/dev/null | grep -q 'chrony'" \
    "Install chrony package on all nodes"

check "Chronyd service is running" \
    3 \
    "service_active chronyd" \
    "Ensure chronyd service is started"

check "Chronyd service is enabled" \
    2 \
    "service_enabled chronyd" \
    "Ensure chronyd service is enabled at boot"

check "Uses service or systemd module" \
    1 \
    "grep -q 'service:\\|systemd:' /home/student/ansible/services.yml" \
    "Use service or systemd module for service management"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 10: Multi-File Ansible Vault (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 10: Multi-File Ansible Vault (15 pts) ━━━${NC}"

check "Playbook vault_demo.yml exists" \
    2 \
    "file_exists /home/student/ansible/vault_demo.yml" \
    "Create /home/student/ansible/vault_demo.yml playbook"

check "Vault password file exists" \
    2 \
    "file_exists /home/student/ansible/vault_pass.txt" \
    "Create vault_pass.txt password file"

check "Encrypted vars file exists" \
    2 \
    "file_exists /home/student/ansible/group_vars/all/vault.yml" \
    "Create encrypted group_vars/all/vault.yml file"

check "Vault file is encrypted" \
    3 \
    "head -1 /home/student/ansible/group_vars/all/vault.yml | grep -q '\$ANSIBLE_VAULT'" \
    "Encrypt vault.yml with ansible-vault"

check "Secret file created on nodes" \
    3 \
    "ansible all -m shell -a 'test -f /etc/secret.conf' &>/dev/null" \
    "Create /etc/secret.conf using vault variables"

check "Uses vault variables in playbook" \
    3 \
    "grep -q 'vault_' /home/student/ansible/vault_demo.yml || grep -q 'secret_' /home/student/ansible/vault_demo.yml" \
    "Reference vault variables in playbook"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 11: Cluster Inventory Report from hostvars (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 11: Cluster Inventory Report from hostvars (15 pts) ━━━${NC}"

check "Playbook cluster-report.yml exists" \
    2 \
    "file_exists /home/student/ansible/cluster-report.yml" \
    "Create /home/student/ansible/cluster-report.yml"

check "Template cluster-info.j2 exists" \
    2 \
    "file_exists /home/student/ansible/templates/cluster-info.j2" \
    "Create templates/cluster-info.j2 that loops over groups['all']"

check "Template loops over groups['all']" \
    3 \
    "grep -E \"for[[:space:]]+\\w+[[:space:]]+in[[:space:]]+groups\\\\['all'\\\\]\" /home/student/ansible/templates/cluster-info.j2" \
    "Use {% for host in groups['all'] %} ... {% endfor %} inside the template"

check "Template reads from hostvars" \
    2 \
    "grep -q 'hostvars\\[' /home/student/ansible/templates/cluster-info.j2" \
    "Pull every value via hostvars[host].<fact>"

check "Template uses default('NONE') filter" \
    1 \
    "grep -q \"default('NONE')\" /home/student/ansible/templates/cluster-info.j2" \
    "Defend every fact lookup with | default('NONE')"

check "/etc/cluster-info.txt deployed to every node" \
    3 \
    "ansible all -b -m shell -a 'test -f /etc/cluster-info.txt' 2>/dev/null | grep -c 'SUCCESS' | grep -qE '^[23]$'" \
    "Use ansible.builtin.template to write /etc/cluster-info.txt on every host"

check "/etc/cluster-info.txt lists every host" \
    2 \
    "ansible node1.example.com -b -m shell -a 'grep -c node /etc/cluster-info.txt' 2>/dev/null | grep -qE '[2-9]'" \
    "The file must contain a line per host in groups['all']"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# FINAL REPORT
# ═══════════════════════════════════════════════════════════════════════════
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                           FINAL SCORE                                  ║"
echo "╠════════════════════════════════════════════════════════════════════════╣"

PERCENTAGE=$((PASS * 100 / TOTAL))

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

printf "║  Score: ${COLOR}%3d / %3d points (%3d%%)${NC}                                 ║\n" $PASS $TOTAL $PERCENTAGE
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

#!/bin/bash

# RHCE Killer - SSH and Privilege Escalation Grading Script
# Exam: SSH and Privilege (15 tasks, 215 points)
# Passing score: 70% (151 points)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_POINTS=0
MAX_POINTS=215
TASKS_PASSED=0
TASKS_FAILED=0
TOTAL_TASKS=15

# Ansible directory
ANSIBLE_DIR="/home/student/ansible"

# Arrays to store results
declare -a FAILED_TASKS
declare -a FAILED_HINTS

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}RHCE Killer - SSH and Privilege Grading${NC}"
echo -e "${CYAN}========================================${NC}\n"

# Function to check a condition
check() {
    local description="$1"
    local points="$2"
    local command="$3"
    local hint="$4"
    
    echo -n "Checking: $description... "
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}PASS${NC} (+${points} pts)"
        ((TOTAL_POINTS += points))
        ((TASKS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC} (0 pts)"
        ((TASKS_FAILED++))
        FAILED_TASKS+=("$description")
        FAILED_HINTS+=("$hint")
        return 1
    fi
}

# Function to check ansible ad-hoc command result
ansible_check() {
    local description="$1"
    local points="$2"
    local host="$3"
    local module="$4"
    local args="$5"
    local grep_pattern="$6"
    local hint="$7"
    
    echo -n "Checking: $description... "
    
    local result=$(ansible "$host" -m "$module" -a "$args" 2>/dev/null)
    
    if echo "$result" | grep -q "$grep_pattern"; then
        echo -e "${GREEN}PASS${NC} (+${points} pts)"
        ((TOTAL_POINTS += points))
        ((TASKS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC} (0 pts)"
        ((TASKS_FAILED++))
        FAILED_TASKS+=("$description")
        FAILED_HINTS+=("$hint")
        return 1
    fi
}

echo -e "${YELLOW}Task 01: Basic Become (10 pts)${NC}"
check "playbook become-basic.yml exists" 3 \
    "test -f $ANSIBLE_DIR/become-basic.yml" \
    "Create: $ANSIBLE_DIR/become-basic.yml"

check "playbook uses become at play level" 3 \
    "grep -q 'become: true' $ANSIBLE_DIR/become-basic.yml" \
    "Add: become: true at play level"

check "playbook installs httpd" 2 \
    "grep -q 'httpd' $ANSIBLE_DIR/become-basic.yml" \
    "Install: httpd package"

ansible_check "httpd installed on nodes" 2 \
    "node1.example.com" "command" "rpm -q httpd" "httpd-" \
    "Package should be installed"

echo ""
echo -e "${YELLOW}Task 02: Become at Task Level (12 pts)${NC}"
check "playbook become-task.yml exists" 3 \
    "test -f $ANSIBLE_DIR/become-task.yml" \
    "Create: $ANSIBLE_DIR/become-task.yml"

check "playbook has task without become" 3 \
    "grep -q '/tmp/user-file.txt' $ANSIBLE_DIR/become-task.yml" \
    "Create /tmp/user-file.txt without become"

check "playbook has task with become" 3 \
    "grep -q '/opt/root-file.txt' $ANSIBLE_DIR/become-task.yml" \
    "Create /opt/root-file.txt with become: true"

ansible_check "both files created" 3 \
    "node1.example.com" "stat" "path=/tmp/user-file.txt" "exists.*True" \
    "Files should be created on nodes"

echo ""
echo -e "${YELLOW}Task 03: Become User (15 pts)${NC}"
check "playbook become-user.yml exists" 3 \
    "test -f $ANSIBLE_DIR/become-user.yml" \
    "Create: $ANSIBLE_DIR/become-user.yml"

check "playbook creates appuser" 3 \
    "grep -q 'appuser' $ANSIBLE_DIR/become-user.yml" \
    "Create user: appuser"

check "playbook uses become_user" 4 \
    "grep -q 'become_user:' $ANSIBLE_DIR/become-user.yml" \
    "Use: become_user: appuser"

ansible_check "appuser exists on nodes" 3 \
    "node1.example.com" "command" "id appuser" "uid=" \
    "User appuser should exist"

ansible_check "file created as appuser" 2 \
    "node1.example.com" "stat" "path=/home/appuser/app.txt" "exists.*True" \
    "File /home/appuser/app.txt should exist"

echo ""
echo -e "${YELLOW}Task 04: Become Method (12 pts)${NC}"
check "playbook become-method.yml exists" 3 \
    "test -f $ANSIBLE_DIR/become-method.yml" \
    "Create: $ANSIBLE_DIR/become-method.yml"

check "playbook uses become_method" 4 \
    "grep -q 'become_method:' $ANSIBLE_DIR/become-method.yml" \
    "Use: become_method: sudo"

check "playbook installs firewalld" 2 \
    "grep -q 'firewalld' $ANSIBLE_DIR/become-method.yml" \
    "Install: firewalld package"

ansible_check "firewalld installed" 3 \
    "node1.example.com" "command" "rpm -q firewalld" "firewalld-" \
    "Package should be installed"

echo ""
echo -e "${YELLOW}Task 05: Ansible Config Become (15 pts)${NC}"
check "ansible.cfg has become settings" 5 \
    "grep -q 'become.*True' $ANSIBLE_DIR/ansible.cfg" \
    "Add to ansible.cfg: become = True"

check "ansible.cfg has become_user" 3 \
    "grep -q 'become_user.*root' $ANSIBLE_DIR/ansible.cfg" \
    "Add to ansible.cfg: become_user = root"

check "playbook become-config.yml exists" 3 \
    "test -f $ANSIBLE_DIR/become-config.yml" \
    "Create: $ANSIBLE_DIR/become-config.yml"

check "playbook installs vim-enhanced" 2 \
    "grep -q 'vim-enhanced' $ANSIBLE_DIR/become-config.yml" \
    "Install: vim-enhanced package"

ansible_check "vim-enhanced installed" 2 \
    "node1.example.com" "command" "rpm -q vim-enhanced" "vim-enhanced-" \
    "Package should be installed"

echo ""
echo -e "${YELLOW}Task 06: Inventory Become Variables (15 pts)${NC}"
check "inventory has ansible_become for webservers" 5 \
    "grep -A 5 '\[webservers\]' $ANSIBLE_DIR/inventory | grep -q 'ansible_become'" \
    "Add to inventory: ansible_become=true for webservers"

check "inventory has ansible_become_user" 5 \
    "grep -A 5 '\[webservers\]' $ANSIBLE_DIR/inventory | grep -q 'ansible_become_user'" \
    "Add to inventory: ansible_become_user=root"

check "playbook for webservers exists" 3 \
    "ls $ANSIBLE_DIR/*.yml | xargs grep -l 'webservers' | head -1 | xargs test -f" \
    "Create playbook that targets webservers"

ansible_check "nginx can be installed" 2 \
    "node1.example.com" "command" "rpm -q nginx || echo 'not installed'" "nginx\\|not installed" \
    "Playbook should install nginx on webservers"

echo ""
echo -e "${YELLOW}Task 07: SSH Connection Variables (15 pts)${NC}"
check "playbook ssh-vars.yml exists" 4 \
    "test -f $ANSIBLE_DIR/ssh-vars.yml" \
    "Create: $ANSIBLE_DIR/ssh-vars.yml"

check "playbook sets ansible_connection" 4 \
    "grep -q 'ansible_connection:' $ANSIBLE_DIR/ssh-vars.yml" \
    "Set: ansible_connection: ssh"

check "playbook sets ansible_port" 3 \
    "grep -q 'ansible_port:' $ANSIBLE_DIR/ssh-vars.yml" \
    "Set: ansible_port: 22"

check "playbook sets ansible_user" 4 \
    "grep -q 'ansible_user:' $ANSIBLE_DIR/ssh-vars.yml" \
    "Set: ansible_user: student"

echo ""
echo -e "${YELLOW}Task 08: SSH Key Authentication (18 pts)${NC}"
check "SSH key exists" 5 \
    "test -f /home/student/.ssh/ansible_key" \
    "Generate: ssh-keygen -t rsa -f ~/.ssh/ansible_key -N ''"

check "SSH public key exists" 3 \
    "test -f /home/student/.ssh/ansible_key.pub" \
    "Public key should be generated"

check "ansible.cfg references private key" 5 \
    "grep -q 'private_key_file' $ANSIBLE_DIR/ansible.cfg" \
    "Add to ansible.cfg: private_key_file = ~/.ssh/ansible_key"

check "SSH key has correct permissions" 5 \
    "test \$(stat -c %a /home/student/.ssh/ansible_key 2>/dev/null) = '600'" \
    "Set permissions: chmod 600 ~/.ssh/ansible_key"

echo ""
echo -e "${YELLOW}Task 09: Inventory SSH Variables (15 pts)${NC}"
check "inventory has ansible_ssh_private_key_file" 8 \
    "grep -q 'ansible_ssh_private_key_file' $ANSIBLE_DIR/inventory" \
    "Add to inventory: ansible_ssh_private_key_file=/home/student/.ssh/ansible_key"

check "inventory sets key for node1" 7 \
    "grep 'node1.example.com' $ANSIBLE_DIR/inventory | grep -q 'ansible_ssh_private_key_file'" \
    "Set SSH key for node1 in inventory"

echo ""
echo -e "${YELLOW}Task 10: Become Password (18 pts)${NC}"
check "sudouser exists or playbook creates it" 5 \
    "grep -q 'sudouser' $ANSIBLE_DIR/*.yml 2>/dev/null || ansible node1.example.com -m command -a 'id sudouser' 2>/dev/null | grep -q 'uid='" \
    "Create user: sudouser with sudo access"

check "playbook uses ansible_become_password" 8 \
    "grep -q 'ansible_become_password' $ANSIBLE_DIR/*.yml 2>/dev/null || grep -q 'ansible_become_password' $ANSIBLE_DIR/group_vars/* 2>/dev/null || grep -q 'ansible_become_password' $ANSIBLE_DIR/host_vars/* 2>/dev/null" \
    "Set: ansible_become_password variable"

check "password stored in vault" 5 \
    "find $ANSIBLE_DIR -name '*.yml' -exec grep -l 'ANSIBLE_VAULT' {} \\; | head -1 | xargs test -f" \
    "Encrypt password with ansible-vault"

echo ""
echo -e "${YELLOW}Task 11: Connection Timeout (12 pts)${NC}"
check "playbook ssh-timeout.yml exists" 4 \
    "test -f $ANSIBLE_DIR/ssh-timeout.yml" \
    "Create: $ANSIBLE_DIR/ssh-timeout.yml"

check "playbook sets ansible_ssh_timeout" 5 \
    "grep -q 'ansible_ssh_timeout:' $ANSIBLE_DIR/ssh-timeout.yml" \
    "Set: ansible_ssh_timeout: 30"

check "playbook runs on all hosts" 3 \
    "grep -q 'hosts: all' $ANSIBLE_DIR/ssh-timeout.yml" \
    "Set: hosts: all"

echo ""
echo -e "${YELLOW}Task 12: SSH Common Args (15 pts)${NC}"
check "ansible.cfg has ssh_connection section" 5 \
    "grep -q '\[ssh_connection\]' $ANSIBLE_DIR/ansible.cfg" \
    "Add section: [ssh_connection]"

check "ansible.cfg has ssh_args" 5 \
    "grep -q 'ssh_args' $ANSIBLE_DIR/ansible.cfg" \
    "Add: ssh_args = -o ControlMaster=auto -o ControlPersist=60s"

check "ssh_args includes ControlMaster" 5 \
    "grep 'ssh_args' $ANSIBLE_DIR/ansible.cfg | grep -q 'ControlMaster'" \
    "Include: ControlMaster=auto in ssh_args"

echo ""
echo -e "${YELLOW}Task 13: Pipelining (15 pts)${NC}"
check "ansible.cfg has pipelining enabled" 8 \
    "grep -q 'pipelining.*True' $ANSIBLE_DIR/ansible.cfg" \
    "Add to [ssh_connection]: pipelining = True"

check "pipelining in ssh_connection section" 7 \
    "grep -A 10 '\[ssh_connection\]' $ANSIBLE_DIR/ansible.cfg | grep -q 'pipelining'" \
    "Pipelining should be in [ssh_connection] section"

echo ""
echo -e "${YELLOW}Task 14: Privilege Escalation Flags (18 pts)${NC}"
check "playbook become-flags.yml exists" 5 \
    "test -f $ANSIBLE_DIR/become-flags.yml" \
    "Create: $ANSIBLE_DIR/become-flags.yml"

check "playbook uses become_flags" 8 \
    "grep -q 'become_flags:' $ANSIBLE_DIR/become-flags.yml" \
    "Use: become_flags: '-H -S -n'"

check "playbook has become enabled" 5 \
    "grep -q 'become: true' $ANSIBLE_DIR/become-flags.yml" \
    "Add: become: true"

echo ""
echo -e "${YELLOW}Task 15: Complex Privilege Scenario (20 pts)${NC}"
check "playbook privilege-complex.yml exists" 4 \
    "test -f $ANSIBLE_DIR/privilege-complex.yml" \
    "Create: $ANSIBLE_DIR/privilege-complex.yml"

check "playbook creates webadmin user" 4 \
    "grep -q 'webadmin' $ANSIBLE_DIR/privilege-complex.yml" \
    "Create user: webadmin"

check "playbook creates /opt/webapp directory" 4 \
    "grep -q '/opt/webapp' $ANSIBLE_DIR/privilege-complex.yml" \
    "Create directory: /opt/webapp"

check "playbook uses multiple become scenarios" 4 \
    "grep -c 'become' $ANSIBLE_DIR/privilege-complex.yml | grep -q '[3-9]'" \
    "Use become in multiple tasks"

ansible_check "webadmin user exists" 4 \
    "node1.example.com" "command" "id webadmin" "uid=" \
    "User webadmin should be created"

# Summary
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}GRADING SUMMARY${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "Total Points: ${GREEN}$TOTAL_POINTS${NC} / $MAX_POINTS"
echo -e "Tasks Passed: ${GREEN}$TASKS_PASSED${NC}"
echo -e "Tasks Failed: ${RED}$TASKS_FAILED${NC}"
echo -e "Total Tasks:  $TOTAL_TASKS"

PERCENTAGE=$((TOTAL_POINTS * 100 / MAX_POINTS))
echo -e "Percentage:   ${GREEN}$PERCENTAGE%${NC}"

if [ $PERCENTAGE -ge 70 ]; then
    echo -e "\n${GREEN}★ ★ ★ CONGRATULATIONS! YOU PASSED! ★ ★ ★${NC}"
    echo -e "${GREEN}You achieved $PERCENTAGE% (passing score: 70%)${NC}\n"
else
    echo -e "\n${RED}✗ NOT PASSED${NC}"
    echo -e "${RED}You achieved $PERCENTAGE% (passing score: 70%)${NC}"
    echo -e "${YELLOW}You need $((151 - TOTAL_POINTS)) more points to pass.${NC}\n"
fi

# Show failed tasks if any
if [ ${#FAILED_TASKS[@]} -gt 0 ]; then
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}FAILED TASKS SUMMARY${NC}"
    echo -e "${CYAN}========================================${NC}"
    for i in "${!FAILED_TASKS[@]}"; do
        echo -e "${RED}✗${NC} ${FAILED_TASKS[$i]}"
        echo -e "  ${YELLOW}Hint:${NC} ${FAILED_HINTS[$i]}\n"
    done
fi

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}NEXT STEPS${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "1. Review failed tasks above"
echo -e "2. Check playbooks in: $ANSIBLE_DIR"
echo -e "3. Check ansible.cfg and inventory"
echo -e "4. Test SSH: ${YELLOW}ssh -i ~/.ssh/ansible_key student@node1${NC}"
echo -e "5. Re-run: ${YELLOW}~/exams/thematic/ssh-and-privilege/grade.sh${NC}\n"

exit 0

# Made with Bob

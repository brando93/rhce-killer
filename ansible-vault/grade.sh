#!/bin/bash

# RHCE Killer - Ansible Vault Grading Script
# Exam: Ansible Vault (15 tasks, 213 points)
# Passing score: 70% (149 points)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_POINTS=0
MAX_POINTS=213
TASKS_PASSED=0
TASKS_FAILED=0
TOTAL_TASKS=15

# Ansible directory
ANSIBLE_DIR="/home/student/ansible"

# Arrays to store results
declare -a FAILED_TASKS
declare -a FAILED_HINTS

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}RHCE Killer - Ansible Vault Grading${NC}"
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

echo -e "${YELLOW}Task 01: Create Vault Password File (10 pts)${NC}"
check "vault password file exists" 3 \
    "test -f $ANSIBLE_DIR/.vault_pass" \
    "Create: echo 'ansible123' > $ANSIBLE_DIR/.vault_pass"

check "vault password file has correct permissions" 3 \
    "test \$(stat -c %a $ANSIBLE_DIR/.vault_pass 2>/dev/null) = '600'" \
    "Set permissions: chmod 0600 $ANSIBLE_DIR/.vault_pass"

check "vault password file contains correct password" 2 \
    "grep -q 'ansible123' $ANSIBLE_DIR/.vault_pass" \
    "Password should be: ansible123"

check "ansible.cfg references vault password file" 2 \
    "grep -q 'vault_password_file' $ANSIBLE_DIR/ansible.cfg" \
    "Add to ansible.cfg: vault_password_file = .vault_pass"

echo ""
echo -e "${YELLOW}Task 02: Encrypt a String (12 pts)${NC}"
check "playbook vault-string.yml exists" 3 \
    "test -f $ANSIBLE_DIR/vault-string.yml" \
    "Create: $ANSIBLE_DIR/vault-string.yml"

check "playbook contains encrypted variable" 3 \
    "grep -q '!vault' $ANSIBLE_DIR/vault-string.yml" \
    "Use: ansible-vault encrypt_string 'SecretPass123' --name 'db_password'"

check "playbook defines db_password variable" 3 \
    "grep -q 'db_password:' $ANSIBLE_DIR/vault-string.yml" \
    "Variable name should be: db_password"

check "playbook has debug task" 3 \
    "grep -q 'debug:' $ANSIBLE_DIR/vault-string.yml" \
    "Add debug task to display password"

echo ""
echo -e "${YELLOW}Task 03: Create Encrypted File (15 pts)${NC}"
check "secrets.yml file exists" 3 \
    "test -f $ANSIBLE_DIR/secrets.yml" \
    "Create: ansible-vault create secrets.yml"

check "secrets.yml is encrypted" 5 \
    "head -n 1 $ANSIBLE_DIR/secrets.yml | grep -q 'ANSIBLE_VAULT'" \
    "File should start with \$ANSIBLE_VAULT header"

check "secrets.yml can be viewed with vault" 4 \
    "ansible-vault view $ANSIBLE_DIR/secrets.yml 2>/dev/null | grep -q 'api_key'" \
    "File should contain: api_key, db_password, admin_password"

check "secrets.yml contains all required variables" 3 \
    "ansible-vault view $ANSIBLE_DIR/secrets.yml 2>/dev/null | grep -q 'db_password' && ansible-vault view $ANSIBLE_DIR/secrets.yml 2>/dev/null | grep -q 'admin_password'" \
    "Include: api_key, db_password, admin_password"

echo ""
echo -e "${YELLOW}Task 04: Use Encrypted Variables (15 pts)${NC}"
check "playbook vault-use.yml exists" 3 \
    "test -f $ANSIBLE_DIR/vault-use.yml" \
    "Create: $ANSIBLE_DIR/vault-use.yml"

check "playbook loads secrets.yml" 4 \
    "grep -q 'vars_files:' $ANSIBLE_DIR/vault-use.yml && grep -q 'secrets.yml' $ANSIBLE_DIR/vault-use.yml" \
    "Use: vars_files: - secrets.yml"

check "playbook uses api_key variable" 3 \
    "grep -q 'api_key' $ANSIBLE_DIR/vault-use.yml" \
    "Use: {{ api_key }} in task"

ansible_check "file deployed with API key" 5 \
    "node1.example.com" "stat" "path=/tmp/api-config.txt" "exists.*True" \
    "Deploy to /tmp/api-config.txt with API key content"

echo ""
echo -e "${YELLOW}Task 05: Encrypt Existing File (12 pts)${NC}"
check "credentials.yml file exists" 3 \
    "test -f $ANSIBLE_DIR/credentials.yml" \
    "Create plain file first, then encrypt it"

check "credentials.yml is encrypted" 5 \
    "head -n 1 $ANSIBLE_DIR/credentials.yml | grep -q 'ANSIBLE_VAULT'" \
    "Use: ansible-vault encrypt credentials.yml"

check "credentials.yml contains username and password" 4 \
    "ansible-vault view $ANSIBLE_DIR/credentials.yml 2>/dev/null | grep -q 'username' && ansible-vault view $ANSIBLE_DIR/credentials.yml 2>/dev/null | grep -q 'password'" \
    "File should contain: username and password"

echo ""
echo -e "${YELLOW}Task 06: Decrypt File (10 pts)${NC}"
check "credentials.yml can be decrypted" 5 \
    "test -f $ANSIBLE_DIR/credentials.yml" \
    "Use: ansible-vault decrypt credentials.yml"

check "credentials.yml is readable after decrypt" 5 \
    "grep -q 'username' $ANSIBLE_DIR/credentials.yml 2>/dev/null || ansible-vault view $ANSIBLE_DIR/credentials.yml 2>/dev/null | grep -q 'username'" \
    "File should be plain text or still encrypted"

echo ""
echo -e "${YELLOW}Task 07: View Encrypted File (10 pts)${NC}"
check "secrets.yml still exists" 5 \
    "test -f $ANSIBLE_DIR/secrets.yml" \
    "File should exist: secrets.yml"

check "secrets.yml remains encrypted" 5 \
    "head -n 1 $ANSIBLE_DIR/secrets.yml | grep -q 'ANSIBLE_VAULT'" \
    "Use: ansible-vault view secrets.yml (doesn't modify file)"

echo ""
echo -e "${YELLOW}Task 08: Edit Encrypted File (15 pts)${NC}"
check "secrets.yml contains smtp_password" 8 \
    "ansible-vault view $ANSIBLE_DIR/secrets.yml 2>/dev/null | grep -q 'smtp_password'" \
    "Use: ansible-vault edit secrets.yml, add smtp_password"

check "secrets.yml still encrypted after edit" 7 \
    "head -n 1 $ANSIBLE_DIR/secrets.yml | grep -q 'ANSIBLE_VAULT'" \
    "File should remain encrypted after edit"

echo ""
echo -e "${YELLOW}Task 09: Rekey Encrypted File (15 pts)${NC}"
check "secrets.yml exists for rekey" 5 \
    "test -f $ANSIBLE_DIR/secrets.yml" \
    "File should exist: secrets.yml"

check "secrets.yml is still encrypted" 5 \
    "head -n 1 $ANSIBLE_DIR/secrets.yml | grep -q 'ANSIBLE_VAULT'" \
    "File should be encrypted"

check "secrets.yml accessible (with old or new password)" 5 \
    "ansible-vault view $ANSIBLE_DIR/secrets.yml 2>/dev/null | grep -q 'api_key' || ansible-vault view $ANSIBLE_DIR/secrets.yml --vault-password-file <(echo 'newpass456') 2>/dev/null | grep -q 'api_key'" \
    "Use: ansible-vault rekey secrets.yml (old: ansible123, new: newpass456)"

echo ""
echo -e "${YELLOW}Task 10: Multiple Vault IDs (18 pts)${NC}"
check "dev-secrets.yml exists" 4 \
    "test -f $ANSIBLE_DIR/dev-secrets.yml" \
    "Create: ansible-vault create --vault-id dev@prompt dev-secrets.yml"

check "prod-secrets.yml exists" 4 \
    "test -f $ANSIBLE_DIR/prod-secrets.yml" \
    "Create: ansible-vault create --vault-id prod@prompt prod-secrets.yml"

check "dev-secrets.yml is encrypted" 5 \
    "head -n 1 $ANSIBLE_DIR/dev-secrets.yml | grep -q 'ANSIBLE_VAULT'" \
    "File should be encrypted with vault ID"

check "prod-secrets.yml is encrypted" 5 \
    "head -n 1 $ANSIBLE_DIR/prod-secrets.yml | grep -q 'ANSIBLE_VAULT'" \
    "File should be encrypted with vault ID"

echo ""
echo -e "${YELLOW}Task 11: Playbook with Multiple Vaults (20 pts)${NC}"
check "playbook vault-multi.yml exists" 5 \
    "test -f $ANSIBLE_DIR/vault-multi.yml" \
    "Create: $ANSIBLE_DIR/vault-multi.yml"

check "playbook loads dev-secrets.yml" 5 \
    "grep -q 'dev-secrets.yml' $ANSIBLE_DIR/vault-multi.yml" \
    "Use: vars_files with dev-secrets.yml"

check "playbook loads prod-secrets.yml" 5 \
    "grep -q 'prod-secrets.yml' $ANSIBLE_DIR/vault-multi.yml" \
    "Use: vars_files with prod-secrets.yml"

check "playbook has debug tasks" 5 \
    "grep -q 'debug:' $ANSIBLE_DIR/vault-multi.yml" \
    "Add debug tasks to display environment values"

echo ""
echo -e "${YELLOW}Task 12: Encrypt Specific Variables (15 pts)${NC}"
check "playbook vault-mixed.yml exists" 4 \
    "test -f $ANSIBLE_DIR/vault-mixed.yml" \
    "Create: $ANSIBLE_DIR/vault-mixed.yml"

check "playbook has plain variables" 4 \
    "grep -q 'app_name:' $ANSIBLE_DIR/vault-mixed.yml && grep -q 'app_port:' $ANSIBLE_DIR/vault-mixed.yml" \
    "Define: app_name and app_port as plain variables"

check "playbook has encrypted variable" 4 \
    "grep -q '!vault' $ANSIBLE_DIR/vault-mixed.yml" \
    "Use: !vault | for api_secret"

check "playbook runs on all hosts" 3 \
    "grep -q 'hosts: all' $ANSIBLE_DIR/vault-mixed.yml" \
    "Set: hosts: all"

echo ""
echo -e "${YELLOW}Task 13: Vault in Group Variables (18 pts)${NC}"
check "group_vars/all directory exists" 3 \
    "test -d $ANSIBLE_DIR/group_vars/all" \
    "Create: mkdir -p group_vars/all"

check "group_vars/all/vault.yml exists" 5 \
    "test -f $ANSIBLE_DIR/group_vars/all/vault.yml" \
    "Create: ansible-vault create group_vars/all/vault.yml"

check "group_vars vault.yml is encrypted" 5 \
    "head -n 1 $ANSIBLE_DIR/group_vars/all/vault.yml | grep -q 'ANSIBLE_VAULT'" \
    "File should be encrypted"

check "group_vars vault.yml contains required variables" 5 \
    "ansible-vault view $ANSIBLE_DIR/group_vars/all/vault.yml 2>/dev/null | grep -q 'vault_db_password' && ansible-vault view $ANSIBLE_DIR/group_vars/all/vault.yml 2>/dev/null | grep -q 'vault_api_key'" \
    "Include: vault_db_password and vault_api_key"

echo ""
echo -e "${YELLOW}Task 14: Vault in Host Variables (18 pts)${NC}"
check "host_vars/node1.example.com directory exists" 3 \
    "test -d $ANSIBLE_DIR/host_vars/node1.example.com" \
    "Create: mkdir -p host_vars/node1.example.com"

check "host_vars vault.yml exists" 5 \
    "test -f $ANSIBLE_DIR/host_vars/node1.example.com/vault.yml" \
    "Create: ansible-vault create host_vars/node1.example.com/vault.yml"

check "host_vars vault.yml is encrypted" 5 \
    "head -n 1 $ANSIBLE_DIR/host_vars/node1.example.com/vault.yml | grep -q 'ANSIBLE_VAULT'" \
    "File should be encrypted"

check "host_vars vault.yml contains vault_node_secret" 5 \
    "ansible-vault view $ANSIBLE_DIR/host_vars/node1.example.com/vault.yml 2>/dev/null | grep -q 'vault_node_secret'" \
    "Include: vault_node_secret variable"

echo ""
echo -e "${YELLOW}Task 15: Vault Password Script (20 pts)${NC}"
check "vault-pass.sh script exists" 5 \
    "test -f $ANSIBLE_DIR/vault-pass.sh" \
    "Create: $ANSIBLE_DIR/vault-pass.sh"

check "vault-pass.sh is executable" 5 \
    "test -x $ANSIBLE_DIR/vault-pass.sh" \
    "Set permissions: chmod 0700 vault-pass.sh"

check "vault-pass.sh has bash shebang" 3 \
    "head -n 1 $ANSIBLE_DIR/vault-pass.sh | grep -q '#!/bin/bash'" \
    "Add: #!/bin/bash as first line"

check "vault-pass.sh outputs password" 4 \
    "$ANSIBLE_DIR/vault-pass.sh 2>/dev/null | grep -q 'ansible123'" \
    "Script should echo 'ansible123'"

check "vault-pass.sh works with ansible-vault" 3 \
    "test -x $ANSIBLE_DIR/vault-pass.sh && $ANSIBLE_DIR/vault-pass.sh | grep -q 'ansible123'" \
    "Script should output password to stdout"

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
    echo -e "${YELLOW}You need $((149 - TOTAL_POINTS)) more points to pass.${NC}\n"
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
echo -e "2. Check files in: $ANSIBLE_DIR"
echo -e "3. Test vault commands: ${YELLOW}ansible-vault --help${NC}"
echo -e "4. View encrypted files: ${YELLOW}ansible-vault view <file>${NC}"
echo -e "5. Re-run: ${YELLOW}~/exams/thematic/ansible-vault/grade.sh${NC}\n"

exit 0

# Made with Bob

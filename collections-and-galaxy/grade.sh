#!/bin/bash

# RHCE Killer - Collections and Galaxy Grading Script
# Exam: Collections and Galaxy (15 tasks, 214 points)
# Passing score: 70% (150 points)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_POINTS=0
MAX_POINTS=214
TASKS_PASSED=0
TASKS_FAILED=0
TOTAL_TASKS=15

# Ansible directory
ANSIBLE_DIR="/home/student/ansible"
ROLES_PATH="$HOME/.ansible/roles"
COLLECTIONS_PATH="$HOME/.ansible/collections"

# Arrays to store results
declare -a FAILED_TASKS
declare -a FAILED_HINTS

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}RHCE Killer - Collections and Galaxy${NC}"
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

echo -e "${YELLOW}Task 01: Install Role from Galaxy (12 pts)${NC}"
check "geerlingguy.apache role installed" 8 \
    "ansible-galaxy list 2>/dev/null | grep -q 'geerlingguy.apache'" \
    "Install: ansible-galaxy install geerlingguy.apache"

check "role exists in roles path" 4 \
    "find ~/.ansible/roles -name 'geerlingguy.apache' -o -name 'apache' | grep -q '.'" \
    "Role should be in ~/.ansible/roles/"

echo ""
echo -e "${YELLOW}Task 02: Install Specific Role Version (15 pts)${NC}"
check "geerlingguy.mysql role installed" 10 \
    "ansible-galaxy list 2>/dev/null | grep -q 'geerlingguy.mysql'" \
    "Install: ansible-galaxy install geerlingguy.mysql,4.3.0"

check "mysql role version 4.3.0" 5 \
    "ansible-galaxy list 2>/dev/null | grep 'geerlingguy.mysql' | grep -q '4.3.0'" \
    "Specify version: ansible-galaxy install geerlingguy.mysql,4.3.0"

echo ""
echo -e "${YELLOW}Task 03: Install Role to Custom Path (15 pts)${NC}"
check "custom-roles directory exists" 5 \
    "test -d $ANSIBLE_DIR/custom-roles" \
    "Create: mkdir -p $ANSIBLE_DIR/custom-roles"

check "geerlingguy.nginx in custom path" 10 \
    "test -d $ANSIBLE_DIR/custom-roles/geerlingguy.nginx || test -d $ANSIBLE_DIR/custom-roles/nginx" \
    "Install: ansible-galaxy install geerlingguy.nginx -p $ANSIBLE_DIR/custom-roles/"

echo ""
echo -e "${YELLOW}Task 04: Create requirements.yml for Roles (18 pts)${NC}"
check "requirements.yml exists" 5 \
    "test -f $ANSIBLE_DIR/requirements.yml" \
    "Create: $ANSIBLE_DIR/requirements.yml"

check "requirements.yml has roles section" 5 \
    "grep -q 'roles:' $ANSIBLE_DIR/requirements.yml" \
    "Add: roles: section in requirements.yml"

check "requirements lists geerlingguy.apache" 3 \
    "grep -q 'geerlingguy.apache' $ANSIBLE_DIR/requirements.yml" \
    "List: geerlingguy.apache with version"

check "requirements lists geerlingguy.mysql" 3 \
    "grep -q 'geerlingguy.mysql' $ANSIBLE_DIR/requirements.yml" \
    "List: geerlingguy.mysql with version"

check "requirements lists geerlingguy.nginx" 2 \
    "grep -q 'geerlingguy.nginx' $ANSIBLE_DIR/requirements.yml" \
    "List: geerlingguy.nginx with version"

echo ""
echo -e "${YELLOW}Task 05: Install Collection from Galaxy (15 pts)${NC}"
check "community.general collection installed" 10 \
    "ansible-galaxy collection list 2>/dev/null | grep -q 'community.general'" \
    "Install: ansible-galaxy collection install community.general"

check "collection in collections path" 5 \
    "find ~/.ansible/collections -name 'community' -type d | grep -q '.'" \
    "Collection should be in ~/.ansible/collections/"

echo ""
echo -e "${YELLOW}Task 06: Install Specific Collection Version (15 pts)${NC}"
check "ansible.posix collection installed" 10 \
    "ansible-galaxy collection list 2>/dev/null | grep -q 'ansible.posix'" \
    "Install: ansible-galaxy collection install ansible.posix:1.4.0"

check "ansible.posix version 1.4.0" 5 \
    "ansible-galaxy collection list 2>/dev/null | grep 'ansible.posix' | grep -q '1.4.0'" \
    "Specify version: ansible-galaxy collection install ansible.posix:1.4.0"

echo ""
echo -e "${YELLOW}Task 07: Install Collection to Custom Path (15 pts)${NC}"
check "custom-collections directory exists" 5 \
    "test -d $ANSIBLE_DIR/custom-collections" \
    "Create: mkdir -p $ANSIBLE_DIR/custom-collections"

check "community.docker in custom path" 10 \
    "test -d $ANSIBLE_DIR/custom-collections/ansible_collections/community/docker" \
    "Install: ansible-galaxy collection install community.docker -p $ANSIBLE_DIR/custom-collections/"

echo ""
echo -e "${YELLOW}Task 08: Create requirements.yml for Collections (18 pts)${NC}"
check "requirements.yml has collections section" 6 \
    "grep -q 'collections:' $ANSIBLE_DIR/requirements.yml" \
    "Add: collections: section in requirements.yml"

check "requirements lists community.general" 4 \
    "grep -A 10 'collections:' $ANSIBLE_DIR/requirements.yml | grep -q 'community.general'" \
    "List: community.general with version"

check "requirements lists ansible.posix" 4 \
    "grep -A 10 'collections:' $ANSIBLE_DIR/requirements.yml | grep -q 'ansible.posix'" \
    "List: ansible.posix with version"

check "requirements lists community.docker" 4 \
    "grep -A 10 'collections:' $ANSIBLE_DIR/requirements.yml | grep -q 'community.docker'" \
    "List: community.docker with version"

echo ""
echo -e "${YELLOW}Task 09: Use Module from Collection (15 pts)${NC}"
check "playbook use-collection.yml exists" 5 \
    "test -f $ANSIBLE_DIR/use-collection.yml" \
    "Create: use-collection.yml playbook"

check "playbook uses FQCN format" 10 \
    "grep -q 'community\\.general\\.' $ANSIBLE_DIR/use-collection.yml" \
    "Use: FQCN format (community.general.module_name)"

echo ""
echo -e "${YELLOW}Task 10: List Installed Roles (10 pts)${NC}"
check "can list installed roles" 10 \
    "ansible-galaxy list 2>/dev/null | grep -q 'geerlingguy'" \
    "Run: ansible-galaxy list"

echo ""
echo -e "${YELLOW}Task 11: List Installed Collections (10 pts)${NC}"
check "can list installed collections" 10 \
    "ansible-galaxy collection list 2>/dev/null | grep -q 'community\\|ansible'" \
    "Run: ansible-galaxy collection list"

echo ""
echo -e "${YELLOW}Task 12: Remove Installed Role (12 pts)${NC}"
check "at least one role can be removed" 12 \
    "ansible-galaxy list 2>/dev/null | wc -l | grep -q '[0-9]'" \
    "Remove: ansible-galaxy remove <role_name>"

echo ""
echo -e "${YELLOW}Task 13: Search Galaxy for Roles (12 pts)${NC}"
check "can search galaxy" 12 \
    "ansible-galaxy search apache 2>/dev/null | grep -q 'geerlingguy\\|Found'" \
    "Search: ansible-galaxy search <keyword>"

echo ""
echo -e "${YELLOW}Task 14: View Role Information (12 pts)${NC}"
check "can view role info" 12 \
    "ansible-galaxy info geerlingguy.apache 2>/dev/null | grep -q 'description\\|author\\|Role:'" \
    "Info: ansible-galaxy info <role_name>"

echo ""
echo -e "${YELLOW}Task 15: Combined requirements.yml (20 pts)${NC}"
check "requirements.yml has both sections" 8 \
    "grep -q 'roles:' $ANSIBLE_DIR/requirements.yml && grep -q 'collections:' $ANSIBLE_DIR/requirements.yml" \
    "Include: both roles and collections sections"

check "requirements has multiple roles" 6 \
    "grep -A 20 'roles:' $ANSIBLE_DIR/requirements.yml | grep -c 'name:' | grep -q '[2-9]'" \
    "List: multiple roles with versions"

check "requirements has multiple collections" 6 \
    "grep -A 20 'collections:' $ANSIBLE_DIR/requirements.yml | grep -c 'name:' | grep -q '[2-9]'" \
    "List: multiple collections with versions"

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
    echo -e "${YELLOW}You need $((150 - TOTAL_POINTS)) more points to pass.${NC}\n"
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
echo -e "2. Install roles: ${YELLOW}ansible-galaxy install <role>${NC}"
echo -e "3. Install collections: ${YELLOW}ansible-galaxy collection install <collection>${NC}"
echo -e "4. Use requirements: ${YELLOW}ansible-galaxy install -r requirements.yml${NC}"
echo -e "5. Re-run: ${YELLOW}~/exams/thematic/collections-and-galaxy/grade.sh${NC}\n"

exit 0

# Made with Bob

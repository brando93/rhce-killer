#!/bin/bash

# RHCE Killer - Debugging and Troubleshooting Grading Script
# Exam: Debugging and Troubleshooting (20 tasks, 240 points)
# Passing score: 70% (168 points)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_POINTS=0
MAX_POINTS=240
TASKS_PASSED=0
TASKS_FAILED=0
TOTAL_TASKS=20

# Ansible directory
ANSIBLE_DIR="/home/student/ansible"

# Arrays to store results
declare -a FAILED_TASKS
declare -a FAILED_HINTS

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}RHCE Killer - Debugging & Troubleshooting${NC}"
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

echo -e "${YELLOW}Task 01: Basic Debug Module (10 pts)${NC}"
check "playbook debug-basic.yml exists" 3 \
    "test -f $ANSIBLE_DIR/debug-basic.yml" \
    "Create: debug-basic.yml playbook"

check "playbook uses debug module" 4 \
    "grep -q 'debug:' $ANSIBLE_DIR/debug-basic.yml" \
    "Use: debug module with msg"

check "debug displays inventory_hostname" 3 \
    "grep -q 'inventory_hostname' $ANSIBLE_DIR/debug-basic.yml" \
    "Display: {{ inventory_hostname }}"

echo ""
echo -e "${YELLOW}Task 02: Debug Variable (12 pts)${NC}"
check "playbook debug-var.yml exists" 3 \
    "test -f $ANSIBLE_DIR/debug-var.yml" \
    "Create: debug-var.yml playbook"

check "playbook defines app_version" 3 \
    "grep -q 'app_version:' $ANSIBLE_DIR/debug-var.yml" \
    "Define: app_version variable"

check "debug uses var parameter" 6 \
    "grep -q 'var:' $ANSIBLE_DIR/debug-var.yml" \
    "Use: debug with var parameter"

echo ""
echo -e "${YELLOW}Task 03: Debug with Verbosity (12 pts)${NC}"
check "playbook debug-verbosity.yml exists" 4 \
    "test -f $ANSIBLE_DIR/debug-verbosity.yml" \
    "Create: debug-verbosity.yml playbook"

check "debug uses verbosity parameter" 8 \
    "grep -q 'verbosity:' $ANSIBLE_DIR/debug-verbosity.yml" \
    "Use: verbosity: 2 in debug task"

echo ""
echo -e "${YELLOW}Task 04: Debug Registered Variable (15 pts)${NC}"
check "playbook debug-register.yml exists" 3 \
    "test -f $ANSIBLE_DIR/debug-register.yml" \
    "Create: debug-register.yml playbook"

check "playbook uses register" 5 \
    "grep -q 'register:' $ANSIBLE_DIR/debug-register.yml" \
    "Use: register to capture output"

check "debug displays registered variable" 7 \
    "grep -A 3 'debug:' $ANSIBLE_DIR/debug-register.yml | grep -q 'var:'" \
    "Debug: registered variable with var"

echo ""
echo -e "${YELLOW}Task 05: Debug Specific Registered Field (12 pts)${NC}"
check "playbook debug-field.yml exists" 4 \
    "test -f $ANSIBLE_DIR/debug-field.yml" \
    "Create: debug-field.yml playbook"

check "debug uses dot notation for field" 8 \
    "grep -q '\\.stdout' $ANSIBLE_DIR/debug-field.yml" \
    "Use: var: result.stdout"

echo ""
echo -e "${YELLOW}Task 06: Debug with Conditional (15 pts)${NC}"
check "playbook debug-when.yml exists" 5 \
    "test -f $ANSIBLE_DIR/debug-when.yml" \
    "Create: debug-when.yml playbook"

check "debug has when condition" 10 \
    "grep -A 3 'debug:' $ANSIBLE_DIR/debug-when.yml | grep -q 'when:'" \
    "Use: when condition with debug"

echo ""
echo -e "${YELLOW}Task 07: Debug Facts (12 pts)${NC}"
check "playbook debug-facts.yml exists" 3 \
    "test -f $ANSIBLE_DIR/debug-facts.yml" \
    "Create: debug-facts.yml playbook"

check "playbook debugs ansible_distribution" 3 \
    "grep -q 'ansible_distribution' $ANSIBLE_DIR/debug-facts.yml" \
    "Debug: ansible_distribution"

check "playbook debugs ansible_memtotal_mb" 3 \
    "grep -q 'ansible_memtotal_mb' $ANSIBLE_DIR/debug-facts.yml" \
    "Debug: ansible_memtotal_mb"

check "playbook debugs ansible_processor_vcpus" 3 \
    "grep -q 'ansible_processor_vcpus' $ANSIBLE_DIR/debug-facts.yml" \
    "Debug: ansible_processor_vcpus"

echo ""
echo -e "${YELLOW}Task 08: Debug with Loop (15 pts)${NC}"
check "playbook debug-loop.yml exists" 5 \
    "test -f $ANSIBLE_DIR/debug-loop.yml" \
    "Create: debug-loop.yml playbook"

check "playbook uses loop with debug" 10 \
    "grep -A 5 'debug:' $ANSIBLE_DIR/debug-loop.yml | grep -q 'loop:'" \
    "Use: loop with debug module"

echo ""
echo -e "${YELLOW}Task 09: Syntax Check (10 pts)${NC}"
check "playbook syntax-test.yml exists" 5 \
    "test -f $ANSIBLE_DIR/syntax-test.yml" \
    "Create: syntax-test.yml playbook"

check "playbook passes syntax check" 5 \
    "ansible-playbook $ANSIBLE_DIR/syntax-test.yml --syntax-check" \
    "Fix syntax errors, run: ansible-playbook --syntax-check"

echo ""
echo -e "${YELLOW}Task 10: Check Mode (Dry Run) (12 pts)${NC}"
check "playbook check-mode.yml exists" 6 \
    "test -f $ANSIBLE_DIR/check-mode.yml" \
    "Create: check-mode.yml playbook"

check "playbook has file creation task" 6 \
    "grep -q '/tmp/test.txt' $ANSIBLE_DIR/check-mode.yml" \
    "Add task to create /tmp/test.txt"

echo ""
echo -e "${YELLOW}Task 11: Diff Mode (15 pts)${NC}"
check "playbook diff-mode.yml exists" 8 \
    "test -f $ANSIBLE_DIR/diff-mode.yml" \
    "Create: diff-mode.yml playbook"

check "playbook modifies file content" 7 \
    "grep -q 'copy:\\|template:\\|lineinfile:' $ANSIBLE_DIR/diff-mode.yml" \
    "Add task that modifies file content"

echo ""
echo -e "${YELLOW}Task 12: Step Mode (12 pts)${NC}"
check "playbook step-mode.yml exists" 6 \
    "test -f $ANSIBLE_DIR/step-mode.yml" \
    "Create: step-mode.yml playbook"

check "playbook has multiple tasks" 6 \
    "grep -c 'name:' $ANSIBLE_DIR/step-mode.yml | grep -q '[3-9]'" \
    "Add: multiple tasks for step mode"

echo ""
echo -e "${YELLOW}Task 13: Start at Task (15 pts)${NC}"
check "playbook start-at.yml exists" 5 \
    "test -f $ANSIBLE_DIR/start-at.yml" \
    "Create: start-at.yml playbook"

check "playbook has 5+ tasks" 10 \
    "grep -c 'name:' $ANSIBLE_DIR/start-at.yml | grep -q '[5-9]'" \
    "Add: 5 or more tasks with names"

echo ""
echo -e "${YELLOW}Task 14: Limit Hosts (12 pts)${NC}"
check "playbook limit-hosts.yml exists" 6 \
    "test -f $ANSIBLE_DIR/limit-hosts.yml" \
    "Create: limit-hosts.yml playbook"

check "playbook targets all hosts" 6 \
    "grep -q 'hosts: all' $ANSIBLE_DIR/limit-hosts.yml" \
    "Set: hosts: all (use --limit at runtime)"

echo ""
echo -e "${YELLOW}Task 15: List Tasks (10 pts)${NC}"
check "playbook list-tasks.yml exists" 5 \
    "test -f $ANSIBLE_DIR/list-tasks.yml" \
    "Create: list-tasks.yml playbook"

check "playbook has tasks to list" 5 \
    "grep -c 'name:' $ANSIBLE_DIR/list-tasks.yml | grep -q '[2-9]'" \
    "Add: tasks with names"

echo ""
echo -e "${YELLOW}Task 16: List Tags (10 pts)${NC}"
check "playbook list-tags.yml exists" 5 \
    "test -f $ANSIBLE_DIR/list-tags.yml" \
    "Create: list-tags.yml playbook"

check "playbook has tagged tasks" 5 \
    "grep -q 'tags:' $ANSIBLE_DIR/list-tags.yml" \
    "Add: tags to tasks"

echo ""
echo -e "${YELLOW}Task 17: Verbose Output Levels (15 pts)${NC}"
check "playbook verbose-test.yml exists" 8 \
    "test -f $ANSIBLE_DIR/verbose-test.yml" \
    "Create: verbose-test.yml playbook"

check "playbook has tasks for verbose testing" 7 \
    "grep -c 'name:' $ANSIBLE_DIR/verbose-test.yml | grep -q '[2-9]'" \
    "Add: tasks to test with -v, -vv, -vvv, -vvvv"

echo ""
echo -e "${YELLOW}Task 18: Debug Ansible Configuration (12 pts)${NC}"
check "can run ansible-config list" 6 \
    "ansible-config list 2>/dev/null | grep -q 'DEFAULT'" \
    "Run: ansible-config list"

check "can run ansible-config dump" 6 \
    "ansible-config dump 2>/dev/null | grep -q '='" \
    "Run: ansible-config dump"

echo ""
echo -e "${YELLOW}Task 19: Debug Inventory (12 pts)${NC}"
check "can list inventory" 6 \
    "ansible-inventory --list 2>/dev/null | grep -q 'node1\\|node2'" \
    "Run: ansible-inventory --list"

check "can show host variables" 6 \
    "ansible-inventory --host node1.example.com 2>/dev/null | grep -q '{'" \
    "Run: ansible-inventory --host <hostname>"

echo ""
echo -e "${YELLOW}Task 20: Troubleshoot Failed Playbook (20 pts)${NC}"
check "broken.yml exists" 5 \
    "test -f $ANSIBLE_DIR/broken.yml" \
    "Create or fix: broken.yml playbook"

check "broken.yml passes syntax check" 8 \
    "ansible-playbook $ANSIBLE_DIR/broken.yml --syntax-check 2>/dev/null" \
    "Fix: syntax errors in broken.yml"

check "broken.yml has valid YAML" 7 \
    "python3 -c 'import yaml; yaml.safe_load(open(\"$ANSIBLE_DIR/broken.yml\"))' 2>/dev/null" \
    "Fix: YAML formatting errors"

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
    echo -e "${YELLOW}You need $((168 - TOTAL_POINTS)) more points to pass.${NC}\n"
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
echo -e "${CYAN}DEBUGGING COMMANDS${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "Syntax check: ${YELLOW}ansible-playbook --syntax-check <playbook>${NC}"
echo -e "Check mode: ${YELLOW}ansible-playbook --check <playbook>${NC}"
echo -e "Diff mode: ${YELLOW}ansible-playbook --diff <playbook>${NC}"
echo -e "Verbose: ${YELLOW}ansible-playbook -v/-vv/-vvv/-vvvv <playbook>${NC}"
echo -e "Step mode: ${YELLOW}ansible-playbook --step <playbook>${NC}"
echo -e "List tasks: ${YELLOW}ansible-playbook --list-tasks <playbook>${NC}"
echo -e "List tags: ${YELLOW}ansible-playbook --list-tags <playbook>${NC}"
echo -e "Limit hosts: ${YELLOW}ansible-playbook --limit <host> <playbook>${NC}"
echo -e "Start at: ${YELLOW}ansible-playbook --start-at-task '<task>' <playbook>${NC}"
echo -e "\nRe-run: ${YELLOW}~/exams/thematic/debugging-and-troubleshooting/grade.sh${NC}\n"

exit 0

# Made with Bob

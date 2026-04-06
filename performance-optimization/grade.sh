#!/bin/bash

# RHCE Killer - Performance Optimization Grading Script
# Exam: Performance Optimization (15 tasks, 244 points)
# Passing score: 70% (171 points)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_POINTS=0
MAX_POINTS=244
TASKS_PASSED=0
TASKS_FAILED=0
TOTAL_TASKS=15

# Ansible directory
ANSIBLE_DIR="/home/student/ansible"

# Arrays to store results
declare -a FAILED_TASKS
declare -a FAILED_HINTS

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}RHCE Killer - Performance Optimization${NC}"
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

echo -e "${YELLOW}Task 01: Async Task Execution (15 pts)${NC}"
check "playbook async-basic.yml exists" 5 \
    "test -f $ANSIBLE_DIR/async-basic.yml" \
    "Create: async-basic.yml playbook"

check "playbook uses async parameter" 5 \
    "grep -q 'async:' $ANSIBLE_DIR/async-basic.yml" \
    "Use: async: 300"

check "playbook uses poll parameter" 5 \
    "grep -q 'poll:' $ANSIBLE_DIR/async-basic.yml" \
    "Use: poll: 0 (fire and forget)"

echo ""
echo -e "${YELLOW}Task 02: Async with Polling (18 pts)${NC}"
check "playbook async-poll.yml exists" 6 \
    "test -f $ANSIBLE_DIR/async-poll.yml" \
    "Create: async-poll.yml playbook"

check "playbook uses async with timeout" 6 \
    "grep -q 'async:' $ANSIBLE_DIR/async-poll.yml" \
    "Use: async: 60"

check "playbook polls every 5 seconds" 6 \
    "grep 'poll:' $ANSIBLE_DIR/async-poll.yml | grep -q '5'" \
    "Use: poll: 5"

echo ""
echo -e "${YELLOW}Task 03: Async Status Check (18 pts)${NC}"
check "playbook async-status.yml exists" 6 \
    "test -f $ANSIBLE_DIR/async-status.yml" \
    "Create: async-status.yml playbook"

check "playbook uses async_status module" 6 \
    "grep -q 'async_status:' $ANSIBLE_DIR/async-status.yml" \
    "Use: async_status module"

check "playbook registers and checks job" 6 \
    "grep -q 'register:' $ANSIBLE_DIR/async-status.yml && grep -q 'jid:' $ANSIBLE_DIR/async-status.yml" \
    "Register job and check with jid"

echo ""
echo -e "${YELLOW}Task 04: Serial Execution (15 pts)${NC}"
check "playbook serial-basic.yml exists" 5 \
    "test -f $ANSIBLE_DIR/serial-basic.yml" \
    "Create: serial-basic.yml playbook"

check "playbook uses serial keyword" 10 \
    "grep -q 'serial:' $ANSIBLE_DIR/serial-basic.yml" \
    "Use: serial: 1"

echo ""
echo -e "${YELLOW}Task 05: Serial with Percentage (15 pts)${NC}"
check "playbook serial-percent.yml exists" 5 \
    "test -f $ANSIBLE_DIR/serial-percent.yml" \
    "Create: serial-percent.yml playbook"

check "playbook uses percentage format" 10 \
    "grep 'serial:' $ANSIBLE_DIR/serial-percent.yml | grep -q '%'" \
    "Use: serial: '50%'"

echo ""
echo -e "${YELLOW}Task 06: Serial with List (18 pts)${NC}"
check "playbook serial-list.yml exists" 6 \
    "test -f $ANSIBLE_DIR/serial-list.yml" \
    "Create: serial-list.yml playbook"

check "playbook uses list format" 12 \
    "grep 'serial:' $ANSIBLE_DIR/serial-list.yml | grep -q '\\['" \
    "Use: serial: [1, 2, 5]"

echo ""
echo -e "${YELLOW}Task 07: Configure Forks (15 pts)${NC}"
check "ansible.cfg has forks setting" 10 \
    "grep -q 'forks' $ANSIBLE_DIR/ansible.cfg" \
    "Add to ansible.cfg: forks = 10"

check "forks set to 10 or higher" 5 \
    "grep 'forks' $ANSIBLE_DIR/ansible.cfg | grep -q '1[0-9]\\|[2-9][0-9]'" \
    "Set: forks = 10 (or higher)"

echo ""
echo -e "${YELLOW}Task 08: Strategy: Free (18 pts)${NC}"
check "playbook strategy-free.yml exists" 6 \
    "test -f $ANSIBLE_DIR/strategy-free.yml" \
    "Create: strategy-free.yml playbook"

check "playbook uses strategy free" 12 \
    "grep -q 'strategy:.*free' $ANSIBLE_DIR/strategy-free.yml" \
    "Use: strategy: free"

echo ""
echo -e "${YELLOW}Task 09: Strategy: Linear (12 pts)${NC}"
check "playbook strategy-linear.yml exists" 6 \
    "test -f $ANSIBLE_DIR/strategy-linear.yml" \
    "Create: strategy-linear.yml playbook"

check "playbook uses strategy linear" 6 \
    "grep -q 'strategy:.*linear' $ANSIBLE_DIR/strategy-linear.yml" \
    "Use: strategy: linear"

echo ""
echo -e "${YELLOW}Task 10: Fact Caching (20 pts)${NC}"
check "ansible.cfg has fact_caching" 8 \
    "grep -q 'fact_caching' $ANSIBLE_DIR/ansible.cfg" \
    "Add to ansible.cfg: fact_caching = jsonfile"

check "ansible.cfg has fact_caching_connection" 6 \
    "grep -q 'fact_caching_connection' $ANSIBLE_DIR/ansible.cfg" \
    "Add: fact_caching_connection = /path/to/cache"

check "ansible.cfg has fact_caching_timeout" 6 \
    "grep -q 'fact_caching_timeout' $ANSIBLE_DIR/ansible.cfg" \
    "Add: fact_caching_timeout = 3600"

echo ""
echo -e "${YELLOW}Task 11: Disable Fact Gathering (12 pts)${NC}"
check "playbook no-facts.yml exists" 6 \
    "test -f $ANSIBLE_DIR/no-facts.yml" \
    "Create: no-facts.yml playbook"

check "playbook disables fact gathering" 6 \
    "grep -q 'gather_facts:.*false' $ANSIBLE_DIR/no-facts.yml" \
    "Use: gather_facts: false"

echo ""
echo -e "${YELLOW}Task 12: Selective Fact Gathering (18 pts)${NC}"
check "playbook selective-facts.yml exists" 6 \
    "test -f $ANSIBLE_DIR/selective-facts.yml" \
    "Create: selective-facts.yml playbook"

check "playbook uses gather_subset" 12 \
    "grep -q 'gather_subset:' $ANSIBLE_DIR/selective-facts.yml" \
    "Use: gather_subset to specify subsets"

echo ""
echo -e "${YELLOW}Task 13: Pipelining (15 pts)${NC}"
check "ansible.cfg has pipelining enabled" 15 \
    "grep -q 'pipelining.*True' $ANSIBLE_DIR/ansible.cfg" \
    "Add to [ssh_connection]: pipelining = True"

echo ""
echo -e "${YELLOW}Task 14: ControlMaster (15 pts)${NC}"
check "ansible.cfg has ssh_args" 8 \
    "grep -q 'ssh_args' $ANSIBLE_DIR/ansible.cfg" \
    "Add to [ssh_connection]: ssh_args"

check "ssh_args includes ControlMaster" 7 \
    "grep 'ssh_args' $ANSIBLE_DIR/ansible.cfg | grep -q 'ControlMaster'" \
    "Include: -o ControlMaster=auto -o ControlPersist=60s"

echo ""
echo -e "${YELLOW}Task 15: Mitogen Strategy (20 pts)${NC}"
check "mitogen installed or configured" 10 \
    "pip3 list 2>/dev/null | grep -q 'mitogen' || grep -q 'mitogen' $ANSIBLE_DIR/ansible.cfg" \
    "Install: pip3 install mitogen"

check "ansible.cfg references mitogen" 10 \
    "grep -q 'mitogen' $ANSIBLE_DIR/ansible.cfg || test -d ~/.ansible/plugins/strategy/" \
    "Configure: strategy_plugins or use mitogen_linear"

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
    echo -e "${YELLOW}You need $((171 - TOTAL_POINTS)) more points to pass.${NC}\n"
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
echo -e "${CYAN}PERFORMANCE TIPS${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "Async: ${YELLOW}async: 300, poll: 0${NC}"
echo -e "Serial: ${YELLOW}serial: 1 or serial: '50%' or serial: [1,2,5]${NC}"
echo -e "Forks: ${YELLOW}forks = 10${NC} in ansible.cfg"
echo -e "Strategy: ${YELLOW}strategy: free${NC} or ${YELLOW}strategy: linear${NC}"
echo -e "Facts: ${YELLOW}gather_facts: false${NC} or ${YELLOW}gather_subset${NC}"
echo -e "Caching: ${YELLOW}fact_caching = jsonfile${NC}"
echo -e "Pipelining: ${YELLOW}pipelining = True${NC}"
echo -e "SSH: ${YELLOW}ControlMaster=auto ControlPersist=60s${NC}"
echo -e "\nRe-run: ${YELLOW}~/exams/thematic/performance-optimization/grade.sh${NC}\n"

exit 0

# Made with Bob

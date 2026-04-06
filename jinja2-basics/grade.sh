#!/bin/bash

# RHCE Killer - Jinja2 Basics Grading Script
# Exam: Jinja2 Basics (20 tasks, 286 points)
# Passing score: 70% (200 points)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_POINTS=0
MAX_POINTS=286
TASKS_PASSED=0
TASKS_FAILED=0
TOTAL_TASKS=20

# Ansible directory
ANSIBLE_DIR="/home/student/ansible"
TEMPLATES_DIR="$ANSIBLE_DIR/templates"

# Arrays to store results
declare -a FAILED_TASKS
declare -a FAILED_HINTS

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}RHCE Killer - Jinja2 Basics Grading${NC}"
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

echo -e "${YELLOW}Task 01: Basic Variable Substitution (10 pts)${NC}"
check "playbook template-basic.yml exists" 2 \
    "test -f $ANSIBLE_DIR/template-basic.yml" \
    "Create: $ANSIBLE_DIR/template-basic.yml"

check "template basic.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/basic.j2" \
    "Create: $TEMPLATES_DIR/basic.j2"

check "template uses inventory_hostname" 2 \
    "grep -q 'inventory_hostname' $TEMPLATES_DIR/basic.j2" \
    "Use: {{ inventory_hostname }}"

check "template uses ansible_default_ipv4.address" 2 \
    "grep -q 'ansible_default_ipv4.address' $TEMPLATES_DIR/basic.j2" \
    "Use: {{ ansible_default_ipv4.address }}"

ansible_check "file deployed to /tmp/server-info.txt" 2 \
    "node1.example.com" "stat" "path=/tmp/server-info.txt" "exists.*True" \
    "Deploy template to /tmp/server-info.txt"

echo ""
echo -e "${YELLOW}Task 02: Template with Variables (12 pts)${NC}"
check "playbook template-vars.yml exists" 2 \
    "test -f $ANSIBLE_DIR/template-vars.yml" \
    "Create: $ANSIBLE_DIR/template-vars.yml"

check "template app-config.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/app-config.j2" \
    "Create: $TEMPLATES_DIR/app-config.j2"

check "playbook defines app_name variable" 2 \
    "grep -q 'app_name:' $ANSIBLE_DIR/template-vars.yml" \
    "Define: app_name: myapp"

check "playbook defines app_port variable" 2 \
    "grep -q 'app_port:' $ANSIBLE_DIR/template-vars.yml" \
    "Define: app_port: 8080"

check "template uses variables" 2 \
    "grep -q '{{ app_name }}' $TEMPLATES_DIR/app-config.j2 && grep -q '{{ app_port }}' $TEMPLATES_DIR/app-config.j2" \
    "Use: {{ app_name }}, {{ app_port }}, {{ app_env }}"

ansible_check "file deployed to /opt/app/config.txt" 2 \
    "node1.example.com" "stat" "path=/opt/app/config.txt" "exists.*True" \
    "Deploy template to /opt/app/config.txt"

echo ""
echo -e "${YELLOW}Task 03: Template with Facts (12 pts)${NC}"
check "playbook template-facts.yml exists" 2 \
    "test -f $ANSIBLE_DIR/template-facts.yml" \
    "Create: $ANSIBLE_DIR/template-facts.yml"

check "template system-info.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/system-info.j2" \
    "Create: $TEMPLATES_DIR/system-info.j2"

check "template uses ansible_hostname" 2 \
    "grep -q 'ansible_hostname' $TEMPLATES_DIR/system-info.j2" \
    "Use: {{ ansible_hostname }}"

check "template uses ansible_distribution" 2 \
    "grep -q 'ansible_distribution' $TEMPLATES_DIR/system-info.j2" \
    "Use: {{ ansible_distribution }}"

check "template uses ansible_memtotal_mb" 2 \
    "grep -q 'ansible_memtotal_mb' $TEMPLATES_DIR/system-info.j2" \
    "Use: {{ ansible_memtotal_mb }}"

ansible_check "file deployed to /tmp/system-info.txt" 2 \
    "node1.example.com" "stat" "path=/tmp/system-info.txt" "exists.*True" \
    "Deploy template to /tmp/system-info.txt"

echo ""
echo -e "${YELLOW}Task 04: Upper Filter (10 pts)${NC}"
check "playbook template-upper.yml exists" 2 \
    "test -f $ANSIBLE_DIR/template-upper.yml" \
    "Create: $ANSIBLE_DIR/template-upper.yml"

check "template uppercase.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/uppercase.j2" \
    "Create: $TEMPLATES_DIR/uppercase.j2"

check "template uses upper filter" 3 \
    "grep -q '| upper' $TEMPLATES_DIR/uppercase.j2" \
    "Use: {{ server_name | upper }}"

ansible_check "file contains WEBSERVER" 3 \
    "node1.example.com" "command" "cat /tmp/uppercase.txt" "WEBSERVER" \
    "Result should contain 'WEBSERVER'"

echo ""
echo -e "${YELLOW}Task 05: Lower Filter (10 pts)${NC}"
check "playbook template-lower.yml exists" 2 \
    "test -f $ANSIBLE_DIR/template-lower.yml" \
    "Create: $ANSIBLE_DIR/template-lower.yml"

check "template lowercase.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/lowercase.j2" \
    "Create: $TEMPLATES_DIR/lowercase.j2"

check "template uses lower filter" 3 \
    "grep -q '| lower' $TEMPLATES_DIR/lowercase.j2" \
    "Use: {{ company_name | lower }}"

ansible_check "file contains lowercase text" 3 \
    "node1.example.com" "command" "cat /tmp/lowercase.txt" "acme corp" \
    "Result should contain 'acme corp'"

echo ""
echo -e "${YELLOW}Task 06: Default Filter (15 pts)${NC}"
check "playbook template-default.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-default.yml" \
    "Create: $ANSIBLE_DIR/template-default.yml"

check "template default.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/default.j2" \
    "Create: $TEMPLATES_DIR/default.j2"

check "template uses default filter" 4 \
    "grep -q '| default' $TEMPLATES_DIR/default.j2" \
    "Use: {{ custom_port | default(80) }}"

check "playbook does not define custom_port" 2 \
    "! grep -q 'custom_port:' $ANSIBLE_DIR/template-default.yml" \
    "Do NOT define custom_port variable"

ansible_check "file contains default value 80" 3 \
    "node1.example.com" "command" "cat /tmp/default.txt" "80" \
    "Result should contain 'Port: 80'"

echo ""
echo -e "${YELLOW}Task 07: Replace Filter (12 pts)${NC}"
check "playbook template-replace.yml exists" 2 \
    "test -f $ANSIBLE_DIR/template-replace.yml" \
    "Create: $ANSIBLE_DIR/template-replace.yml"

check "template replace.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/replace.j2" \
    "Create: $TEMPLATES_DIR/replace.j2"

check "template uses replace filter" 4 \
    "grep -q '| replace' $TEMPLATES_DIR/replace.j2" \
    "Use: {{ message | replace('World', 'Ansible') }}"

ansible_check "file contains Hello Ansible" 4 \
    "node1.example.com" "command" "cat /tmp/replace.txt" "Hello Ansible" \
    "Result should contain 'Hello Ansible'"

echo ""
echo -e "${YELLOW}Task 08: Join Filter (15 pts)${NC}"
check "playbook template-join.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-join.yml" \
    "Create: $ANSIBLE_DIR/template-join.yml"

check "template join.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/join.j2" \
    "Create: $TEMPLATES_DIR/join.j2"

check "playbook defines packages list" 3 \
    "grep -q 'packages:' $ANSIBLE_DIR/template-join.yml" \
    "Define: packages list with httpd, nginx, firewalld"

check "template uses join filter" 3 \
    "grep -q '| join' $TEMPLATES_DIR/join.j2" \
    "Use: {{ packages | join(', ') }}"

ansible_check "file contains comma-separated packages" 3 \
    "node1.example.com" "command" "cat /tmp/packages.txt" "httpd.*nginx.*firewalld" \
    "Result should be comma-separated list"

echo ""
echo -e "${YELLOW}Task 09: Length Filter (12 pts)${NC}"
check "playbook template-length.yml exists" 2 \
    "test -f $ANSIBLE_DIR/template-length.yml" \
    "Create: $ANSIBLE_DIR/template-length.yml"

check "template length.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/length.j2" \
    "Create: $TEMPLATES_DIR/length.j2"

check "template uses length filter" 4 \
    "grep -q '| length' $TEMPLATES_DIR/length.j2" \
    "Use: {{ items | length }}"

ansible_check "file contains 'Total items: 5'" 4 \
    "node1.example.com" "command" "cat /tmp/length.txt" "5" \
    "Result should show 5 items"

echo ""
echo -e "${YELLOW}Task 10: Min and Max Filters (15 pts)${NC}"
check "playbook template-minmax.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-minmax.yml" \
    "Create: $ANSIBLE_DIR/template-minmax.yml"

check "template minmax.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/minmax.j2" \
    "Create: $TEMPLATES_DIR/minmax.j2"

check "template uses min filter" 3 \
    "grep -q '| min' $TEMPLATES_DIR/minmax.j2" \
    "Use: {{ numbers | min }}"

check "template uses max filter" 3 \
    "grep -q '| max' $TEMPLATES_DIR/minmax.j2" \
    "Use: {{ numbers | max }}"

ansible_check "file contains min and max values" 3 \
    "node1.example.com" "command" "cat /tmp/minmax.txt" "5.*30" \
    "Result should show min=5 and max=30"

echo ""
echo -e "${YELLOW}Task 11: Unique Filter (12 pts)${NC}"
check "playbook template-unique.yml exists" 2 \
    "test -f $ANSIBLE_DIR/template-unique.yml" \
    "Create: $ANSIBLE_DIR/template-unique.yml"

check "template unique.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/unique.j2" \
    "Create: $TEMPLATES_DIR/unique.j2"

check "template uses unique filter" 4 \
    "grep -q '| unique' $TEMPLATES_DIR/unique.j2" \
    "Use: {{ items | unique | join(', ') }}"

ansible_check "file contains unique items only" 4 \
    "node1.example.com" "command" "cat /tmp/unique.txt" "a.*b.*c" \
    "Result should have no duplicates"

echo ""
echo -e "${YELLOW}Task 12: Sort Filter (15 pts)${NC}"
check "playbook template-sort.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-sort.yml" \
    "Create: $ANSIBLE_DIR/template-sort.yml"

check "template sort.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/sort.j2" \
    "Create: $TEMPLATES_DIR/sort.j2"

check "template uses sort filter" 3 \
    "grep -q '| sort' $TEMPLATES_DIR/sort.j2" \
    "Use: {{ names | sort | join(', ') }}"

check "template uses reverse sort" 3 \
    "grep -q 'reverse=true' $TEMPLATES_DIR/sort.j2" \
    "Use: {{ names | sort(reverse=true) | join(', ') }}"

ansible_check "file contains sorted names" 3 \
    "node1.example.com" "command" "cat /tmp/sort.txt" "alice.*bob.*charlie" \
    "Result should show sorted and reverse sorted"

echo ""
echo -e "${YELLOW}Task 13: To JSON Filter (15 pts)${NC}"
check "playbook template-json.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-json.yml" \
    "Create: $ANSIBLE_DIR/template-json.yml"

check "template json.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/json.j2" \
    "Create: $TEMPLATES_DIR/json.j2"

check "template uses to_json filter" 4 \
    "grep -q '| to_json' $TEMPLATES_DIR/json.j2" \
    "Use: {{ config | to_json }}"

ansible_check "file is valid JSON" 5 \
    "node1.example.com" "command" "python3 -m json.tool /tmp/config.json" "host.*port.*debug" \
    "Result should be valid JSON with config data"

echo ""
echo -e "${YELLOW}Task 14: To YAML Filter (15 pts)${NC}"
check "playbook template-yaml.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-yaml.yml" \
    "Create: $ANSIBLE_DIR/template-yaml.yml"

check "template yaml.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/yaml.j2" \
    "Create: $TEMPLATES_DIR/yaml.j2"

check "template uses to_yaml filter" 4 \
    "grep -q '| to_yaml' $TEMPLATES_DIR/yaml.j2" \
    "Use: {{ settings | to_yaml }}"

ansible_check "file contains YAML data" 5 \
    "node1.example.com" "command" "cat /tmp/settings.yaml" "database.*cache.*queue" \
    "Result should be valid YAML with settings data"

echo ""
echo -e "${YELLOW}Task 15: Multiple Filters Chained (18 pts)${NC}"
check "playbook template-chain.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-chain.yml" \
    "Create: $ANSIBLE_DIR/template-chain.yml"

check "template chain.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/chain.j2" \
    "Create: $TEMPLATES_DIR/chain.j2"

check "template uses select filter" 3 \
    "grep -q 'select' $TEMPLATES_DIR/chain.j2" \
    "Use: | select('search', 'web')"

check "template chains multiple filters" 4 \
    "grep -q '|.*|.*|' $TEMPLATES_DIR/chain.j2" \
    "Chain filters: select | sort | upper | join"

ansible_check "file contains filtered result" 5 \
    "node1.example.com" "command" "cat /tmp/chain.txt" "WEB1.*WEB2.*WEB3" \
    "Result should be 'WEB1, WEB2, WEB3'"

echo ""
echo -e "${YELLOW}Task 16: Template with Math (15 pts)${NC}"
check "playbook template-math.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-math.yml" \
    "Create: $ANSIBLE_DIR/template-math.yml"

check "template math.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/math.j2" \
    "Create: $TEMPLATES_DIR/math.j2"

check "template uses division" 3 \
    "grep -q '/' $TEMPLATES_DIR/math.j2" \
    "Use: {{ (memory_mb / 1024) }}"

check "template uses round filter" 3 \
    "grep -q '| round' $TEMPLATES_DIR/math.j2" \
    "Use: | round(2) and | round(3)"

ansible_check "file contains calculated values" 3 \
    "node1.example.com" "command" "cat /tmp/math.txt" "2.0.*0.09" \
    "Result should show rounded calculations"

echo ""
echo -e "${YELLOW}Task 17: Template with Hostname Manipulation (15 pts)${NC}"
check "playbook template-hostname.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-hostname.yml" \
    "Create: $ANSIBLE_DIR/template-hostname.yml"

check "template hostname.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/hostname.j2" \
    "Create: $TEMPLATES_DIR/hostname.j2"

check "template uses split method" 3 \
    "grep -q '.split' $TEMPLATES_DIR/hostname.j2" \
    "Use: inventory_hostname.split('.')"

check "template uses list slicing" 3 \
    "grep -q '\[0\]' $TEMPLATES_DIR/hostname.j2 && grep -q '\[1:\]' $TEMPLATES_DIR/hostname.j2" \
    "Use: [0] for first element, [1:] for rest"

ansible_check "file contains hostname parts" 3 \
    "node1.example.com" "stat" "path=/tmp/hostname-parts.txt" "exists.*True" \
    "Deploy template to /tmp/hostname-parts.txt"

echo ""
echo -e "${YELLOW}Task 18: Template with Conditional Content (18 pts)${NC}"
check "playbook template-conditional.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-conditional.yml" \
    "Create: $ANSIBLE_DIR/template-conditional.yml"

check "template conditional.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/conditional.j2" \
    "Create: $TEMPLATES_DIR/conditional.j2"

check "template uses if statement" 4 \
    "grep -q '{% if' $TEMPLATES_DIR/conditional.j2" \
    "Use: {% if environment == 'production' %}"

check "template uses else clause" 4 \
    "grep -q '{% else %}' $TEMPLATES_DIR/conditional.j2" \
    "Use: {% else %}"

ansible_check "file contains production config" 4 \
    "node1.example.com" "command" "cat /tmp/conditional.txt" "Debug.*false.*error" \
    "Result should show production settings"

echo ""
echo -e "${YELLOW}Task 19: Template with Loop (20 pts)${NC}"
check "playbook template-loop.yml exists" 4 \
    "test -f $ANSIBLE_DIR/template-loop.yml" \
    "Create: $ANSIBLE_DIR/template-loop.yml"

check "template loop.j2 exists" 4 \
    "test -f $TEMPLATES_DIR/loop.j2" \
    "Create: $TEMPLATES_DIR/loop.j2"

check "template uses for loop" 4 \
    "grep -q '{% for' $TEMPLATES_DIR/loop.j2" \
    "Use: {% for user in users %}"

check "template uses endfor" 4 \
    "grep -q '{% endfor %}' $TEMPLATES_DIR/loop.j2" \
    "Use: {% endfor %}"

ansible_check "file contains user list" 4 \
    "node1.example.com" "command" "cat /tmp/users.txt" "alice.*bob.*charlie" \
    "Result should list all users"

echo ""
echo -e "${YELLOW}Task 20: Complex Template (25 pts)${NC}"
check "playbook template-complex.yml exists" 5 \
    "test -f $ANSIBLE_DIR/template-complex.yml" \
    "Create: $ANSIBLE_DIR/template-complex.yml"

check "template services.j2 exists" 5 \
    "test -f $TEMPLATES_DIR/services.j2" \
    "Create: $TEMPLATES_DIR/services.j2"

check "template uses for loop" 5 \
    "grep -q '{% for service in services %}' $TEMPLATES_DIR/services.j2" \
    "Use: {% for service in services %}"

check "template uses if inside loop" 5 \
    "grep -q '{% if service.enabled %}' $TEMPLATES_DIR/services.j2" \
    "Use: {% if service.enabled %}"

ansible_check "file contains only enabled services" 5 \
    "node1.example.com" "command" "cat /tmp/active-services.txt" "httpd.*80.*mysql.*3306" \
    "Result should show only httpd and mysql (enabled=true)"

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
    echo -e "${YELLOW}You need $((200 - TOTAL_POINTS)) more points to pass.${NC}\n"
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
echo -e "3. Check templates in: $TEMPLATES_DIR"
echo -e "4. Test with: ${YELLOW}ansible-playbook <playbook>.yml${NC}"
echo -e "5. Re-run: ${YELLOW}~/exams/thematic/jinja2-basics/grade.sh${NC}\n"

exit 0

# Made with Bob

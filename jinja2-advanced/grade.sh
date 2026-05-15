#!/bin/bash

# RHCE Killer - Jinja2 Advanced Grading Script
# Exam: Jinja2 Advanced (20 tasks, 366 points)
# Passing score: 70% (256 points)


TOTAL_POINTS=0
MAX_POINTS=388
# ───── shared helpers (color codes, check(), counters, print_summary) ─
# Probe standard locations: local repo and ~/exams/lib on the control node.
for _LIB in \
    "$(dirname "$0")/../../lib/grade-helpers.sh" \
    "$(dirname "$0")/../scripts/lib/grade-helpers.sh" \
    "$(dirname "$0")/../lib/grade-helpers.sh"; do
    [ -f "$_LIB" ] && { source "$_LIB"; break; }
done
unset _LIB
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
echo -e "${CYAN}RHCE Killer - Jinja2 Advanced Grading${NC}"
echo -e "${CYAN}========================================${NC}\n"

echo -e "${YELLOW}Task 01: Regex Replace Filter (15 pts)${NC}"
check "playbook template-regex.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-regex.yml" \
    "Create: $ANSIBLE_DIR/template-regex.yml"

check "template regex.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/regex.j2" \
    "Create: $TEMPLATES_DIR/regex.j2"

check "template uses regex_replace filter" 4 \
    "grep -q 'regex_replace' $TEMPLATES_DIR/regex.j2" \
    "Use: {{ ip_address | regex_replace('\\.', '-') }}"

check "playbook defines ip_address variable" 2 \
    "grep -q 'ip_address:' $ANSIBLE_DIR/template-regex.yml" \
    "Define: ip_address: 192.168.1.100"

ansible_check "file contains dashes instead of dots" 3 \
    "node1.example.com" "command" "cat /tmp/regex.txt" "192-168-1-100" \
    "Result should be '192-168-1-100'"

echo ""
echo -e "${YELLOW}Task 02: Regex Search Filter (15 pts)${NC}"
check "playbook template-search.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-search.yml" \
    "Create: $ANSIBLE_DIR/template-search.yml"

check "template search.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/search.j2" \
    "Create: $TEMPLATES_DIR/search.j2"

check "template uses select with match" 4 \
    "grep -q \"select.*match\" $TEMPLATES_DIR/search.j2 || grep -q \"regex_search\" $TEMPLATES_DIR/search.j2" \
    "Use: | select('match', 'ERROR.*')"

check "playbook defines logs list" 2 \
    "grep -q 'logs:' $ANSIBLE_DIR/template-search.yml" \
    "Define: logs list with ERROR and INFO entries"

ansible_check "file contains only ERROR lines" 3 \
    "node1.example.com" "command" "cat /tmp/errors.txt" "ERROR" \
    "Result should contain only ERROR messages"

echo ""
echo -e "${YELLOW}Task 03: Map Filter (18 pts)${NC}"
check "playbook template-map.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-map.yml" \
    "Create: $ANSIBLE_DIR/template-map.yml"

check "template map.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/map.j2" \
    "Create: $TEMPLATES_DIR/map.j2"

check "template uses map filter" 5 \
    "grep -q \"map.*attribute\" $TEMPLATES_DIR/map.j2" \
    "Use: | map(attribute='name')"

check "playbook defines users list" 3 \
    "grep -q 'users:' $ANSIBLE_DIR/template-map.yml" \
    "Define: users list with name and uid"

ansible_check "file contains extracted names" 4 \
    "node1.example.com" "command" "cat /tmp/names.txt" "alice.*bob" \
    "Result should be 'alice, bob'"

echo ""
echo -e "${YELLOW}Task 04: Selectattr Filter (18 pts)${NC}"
check "playbook template-selectattr.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-selectattr.yml" \
    "Create: $ANSIBLE_DIR/template-selectattr.yml"

check "template selectattr.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/selectattr.j2" \
    "Create: $TEMPLATES_DIR/selectattr.j2"

check "template uses selectattr filter" 5 \
    "grep -q 'selectattr' $TEMPLATES_DIR/selectattr.j2" \
    "Use: | selectattr('type', 'equalto', 'web')"

check "playbook defines servers list" 3 \
    "grep -q 'servers:' $ANSIBLE_DIR/template-selectattr.yml" \
    "Define: servers list with type and active attributes"

ansible_check "file contains only active web servers" 4 \
    "node1.example.com" "command" "cat /tmp/active-web.txt" "web1.*web2" \
    "Result should show web1 and web2 (active web servers)"

echo ""
echo -e "${YELLOW}Task 05: Rejectattr Filter (15 pts)${NC}"
check "playbook template-rejectattr.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-rejectattr.yml" \
    "Create: $ANSIBLE_DIR/template-rejectattr.yml"

check "template rejectattr.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/rejectattr.j2" \
    "Create: $TEMPLATES_DIR/rejectattr.j2"

check "template uses rejectattr filter" 4 \
    "grep -q 'rejectattr' $TEMPLATES_DIR/rejectattr.j2" \
    "Use: | rejectattr('active', 'equalto', false)"

ansible_check "file excludes inactive servers" 5 \
    "node1.example.com" "command" "cat /tmp/active-servers.txt" "web1.*web2" \
    "Result should show only active servers"

echo ""
echo -e "${YELLOW}Task 06: Groupby Filter (20 pts)${NC}"
check "playbook template-groupby.yml exists" 4 \
    "test -f $ANSIBLE_DIR/template-groupby.yml" \
    "Create: $ANSIBLE_DIR/template-groupby.yml"

check "template groupby.j2 exists" 4 \
    "test -f $TEMPLATES_DIR/groupby.j2" \
    "Create: $TEMPLATES_DIR/groupby.j2"

check "template uses groupby filter" 5 \
    "grep -q 'groupby' $TEMPLATES_DIR/groupby.j2" \
    "Use: | groupby('type')"

check "playbook defines servers list" 3 \
    "grep -q 'servers:' $ANSIBLE_DIR/template-groupby.yml" \
    "Define: servers list with type attribute"

ansible_check "file contains grouped servers" 4 \
    "node1.example.com" "command" "cat /tmp/grouped.txt" "web.*database" \
    "Result should show servers grouped by type"

echo ""
echo -e "${YELLOW}Task 07: Combine Filter (18 pts)${NC}"
check "playbook template-combine.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-combine.yml" \
    "Create: $ANSIBLE_DIR/template-combine.yml"

check "template combine.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/combine.j2" \
    "Create: $TEMPLATES_DIR/combine.j2"

check "template uses combine filter" 5 \
    "grep -q 'combine' $TEMPLATES_DIR/combine.j2" \
    "Use: | combine()"

check "playbook defines defaults and custom dicts" 3 \
    "grep -q 'defaults:' $ANSIBLE_DIR/template-combine.yml && grep -q 'custom:' $ANSIBLE_DIR/template-combine.yml" \
    "Define: defaults and custom dictionaries"

ansible_check "file shows merged configuration" 4 \
    "node1.example.com" "command" "cat /tmp/config.txt" "8080.*ssl" \
    "Result should show merged config with custom overrides"

echo ""
echo -e "${YELLOW}Task 08: Ternary Filter (15 pts)${NC}"
check "playbook template-ternary.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-ternary.yml" \
    "Create: $ANSIBLE_DIR/template-ternary.yml"

check "template ternary.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/ternary.j2" \
    "Create: $TEMPLATES_DIR/ternary.j2"

check "template uses ternary filter" 4 \
    "grep -q 'ternary' $TEMPLATES_DIR/ternary.j2" \
    "Use: | ternary('production', 'development')"

ansible_check "file contains production environment" 5 \
    "node1.example.com" "command" "cat /tmp/environment.txt" "production" \
    "Result should be 'production' when is_production is true"

echo ""
echo -e "${YELLOW}Task 09: Zip Filter (18 pts)${NC}"
check "playbook template-zip.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-zip.yml" \
    "Create: $ANSIBLE_DIR/template-zip.yml"

check "template zip.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/zip.j2" \
    "Create: $TEMPLATES_DIR/zip.j2"

check "template uses zip filter" 5 \
    "grep -q 'zip' $TEMPLATES_DIR/zip.j2" \
    "Use: | zip()"

check "playbook defines names and ages lists" 3 \
    "grep -q 'names:' $ANSIBLE_DIR/template-zip.yml && grep -q 'ages:' $ANSIBLE_DIR/template-zip.yml" \
    "Define: names and ages lists"

ansible_check "file contains paired data" 4 \
    "node1.example.com" "command" "cat /tmp/users-ages.txt" "alice.*25.*bob.*30" \
    "Result should pair names with ages"

echo ""
echo -e "${YELLOW}Task 10: Flatten Filter (15 pts)${NC}"
check "playbook template-flatten.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-flatten.yml" \
    "Create: $ANSIBLE_DIR/template-flatten.yml"

check "template flatten.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/flatten.j2" \
    "Create: $TEMPLATES_DIR/flatten.j2"

check "template uses flatten filter" 4 \
    "grep -q 'flatten' $TEMPLATES_DIR/flatten.j2" \
    "Use: | flatten"

ansible_check "file contains flattened list" 5 \
    "node1.example.com" "command" "cat /tmp/flat.txt" "1.*2.*3.*4.*5.*6" \
    "Result should be single flat list"

echo ""
echo -e "${YELLOW}Task 11: Batch Filter (18 pts)${NC}"
check "playbook template-batch.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-batch.yml" \
    "Create: $ANSIBLE_DIR/template-batch.yml"

check "template batch.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/batch.j2" \
    "Create: $TEMPLATES_DIR/batch.j2"

check "template uses batch filter" 5 \
    "grep -q 'batch' $TEMPLATES_DIR/batch.j2" \
    "Use: | batch(3)"

check "playbook defines items list" 3 \
    "grep -q 'items:' $ANSIBLE_DIR/template-batch.yml" \
    "Define: items list with 8 elements"

ansible_check "file contains batched items" 4 \
    "node1.example.com" "stat" "path=/tmp/batches.txt" "exists.*True" \
    "Deploy template to /tmp/batches.txt"

echo ""
echo -e "${YELLOW}Task 12: Slice Filter (18 pts)${NC}"
check "playbook template-slice.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-slice.yml" \
    "Create: $ANSIBLE_DIR/template-slice.yml"

check "template slice.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/slice.j2" \
    "Create: $TEMPLATES_DIR/slice.j2"

check "template uses slice filter" 5 \
    "grep -q 'slice' $TEMPLATES_DIR/slice.j2" \
    "Use: | slice(3)"

check "playbook defines servers list" 3 \
    "grep -q 'servers:' $ANSIBLE_DIR/template-slice.yml" \
    "Define: servers list with 6 elements"

ansible_check "file contains sliced groups" 4 \
    "node1.example.com" "stat" "path=/tmp/slices.txt" "exists.*True" \
    "Deploy template to /tmp/slices.txt"

echo ""
echo -e "${YELLOW}Task 13: Custom Tests (20 pts)${NC}"
check "playbook template-tests.yml exists" 4 \
    "test -f $ANSIBLE_DIR/template-tests.yml" \
    "Create: $ANSIBLE_DIR/template-tests.yml"

check "template tests.j2 exists" 4 \
    "test -f $TEMPLATES_DIR/tests.j2" \
    "Create: $TEMPLATES_DIR/tests.j2"

check "template uses 'is number' test" 4 \
    "grep -q 'is number' $TEMPLATES_DIR/tests.j2" \
    "Use: {% if port is number %}"

check "template uses 'is even' test" 4 \
    "grep -q 'is even' $TEMPLATES_DIR/tests.j2" \
    "Use: {% if port is even %}"

ansible_check "file contains test results" 4 \
    "node1.example.com" "command" "cat /tmp/tests.txt" "numeric.*even" \
    "Result should show port is numeric and even"

echo ""
echo -e "${YELLOW}Task 14: Set Variables in Template (20 pts)${NC}"
check "playbook template-set.yml exists" 4 \
    "test -f $ANSIBLE_DIR/template-set.yml" \
    "Create: $ANSIBLE_DIR/template-set.yml"

check "template set.j2 exists" 4 \
    "test -f $TEMPLATES_DIR/set.j2" \
    "Create: $TEMPLATES_DIR/set.j2"

check "template uses set statement" 5 \
    "grep -q '{% set' $TEMPLATES_DIR/set.j2" \
    "Use: {% set variable = value %}"

check "template reuses set variable" 3 \
    "grep -q '{{.*}}' $TEMPLATES_DIR/set.j2" \
    "Use set variable multiple times"

ansible_check "file contains calculated values" 4 \
    "node1.example.com" "stat" "path=/tmp/calculated.txt" "exists.*True" \
    "Deploy template to /tmp/calculated.txt"

echo ""
echo -e "${YELLOW}Task 15: Macro Definition (22 pts)${NC}"
check "playbook template-macro.yml exists" 4 \
    "test -f $ANSIBLE_DIR/template-macro.yml" \
    "Create: $ANSIBLE_DIR/template-macro.yml"

check "template macro.j2 exists" 4 \
    "test -f $TEMPLATES_DIR/macro.j2" \
    "Create: $TEMPLATES_DIR/macro.j2"

check "template defines macro" 5 \
    "grep -q '{% macro' $TEMPLATES_DIR/macro.j2" \
    "Use: {% macro user_info(name, uid) %}"

check "template ends macro" 4 \
    "grep -q '{% endmacro %}' $TEMPLATES_DIR/macro.j2" \
    "Use: {% endmacro %}"

ansible_check "file contains macro output" 5 \
    "node1.example.com" "command" "cat /tmp/macro.txt" "User.*UID" \
    "Result should show macro called with different arguments"

echo ""
echo -e "${YELLOW}Task 16: Include Template (20 pts)${NC}"
check "playbook template-include.yml exists" 4 \
    "test -f $ANSIBLE_DIR/template-include.yml" \
    "Create: $ANSIBLE_DIR/template-include.yml"

check "template header.j2 exists" 4 \
    "test -f $TEMPLATES_DIR/header.j2" \
    "Create: $TEMPLATES_DIR/header.j2"

check "template main-include.j2 exists" 4 \
    "test -f $TEMPLATES_DIR/main-include.j2" \
    "Create: $TEMPLATES_DIR/main-include.j2"

check "main template includes header" 4 \
    "grep -q \"{% include\" $TEMPLATES_DIR/main-include.j2" \
    "Use: {% include 'header.j2' %}"

ansible_check "file contains included content" 4 \
    "node1.example.com" "stat" "path=/tmp/included.txt" "exists.*True" \
    "Deploy template to /tmp/included.txt"

echo ""
echo -e "${YELLOW}Task 17: Loop with Index (18 pts)${NC}"
check "playbook template-loop-index.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-loop-index.yml" \
    "Create: $ANSIBLE_DIR/template-loop-index.yml"

check "template loop-index.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/loop-index.j2" \
    "Create: $TEMPLATES_DIR/loop-index.j2"

check "template uses loop.index" 5 \
    "grep -q 'loop.index' $TEMPLATES_DIR/loop-index.j2" \
    "Use: {{ loop.index }}"

check "template has for loop" 3 \
    "grep -q '{% for' $TEMPLATES_DIR/loop-index.j2" \
    "Use: {% for item in items %}"

ansible_check "file contains indexed items" 4 \
    "node1.example.com" "command" "cat /tmp/indexed.txt" "1.*first.*2.*second" \
    "Result should show index and item"

echo ""
echo -e "${YELLOW}Task 18: Loop with First/Last (18 pts)${NC}"
check "playbook template-loop-special.yml exists" 3 \
    "test -f $ANSIBLE_DIR/template-loop-special.yml" \
    "Create: $ANSIBLE_DIR/template-loop-special.yml"

check "template loop-special.j2 exists" 3 \
    "test -f $TEMPLATES_DIR/loop-special.j2" \
    "Create: $TEMPLATES_DIR/loop-special.j2"

check "template uses loop.first" 4 \
    "grep -q 'loop.first' $TEMPLATES_DIR/loop-special.j2" \
    "Use: {% if loop.first %}"

check "template uses loop.last" 4 \
    "grep -q 'loop.last' $TEMPLATES_DIR/loop-special.j2" \
    "Use: {% if loop.last %}"

ansible_check "file marks first and last items" 4 \
    "node1.example.com" "command" "cat /tmp/marked.txt" "START.*END" \
    "Result should mark first with START and last with END"

echo ""
echo -e "${YELLOW}Task 19: Whitespace Control (20 pts)${NC}"
check "playbook template-whitespace.yml exists" 4 \
    "test -f $ANSIBLE_DIR/template-whitespace.yml" \
    "Create: $ANSIBLE_DIR/template-whitespace.yml"

check "template whitespace.j2 exists" 4 \
    "test -f $TEMPLATES_DIR/whitespace.j2" \
    "Create: $TEMPLATES_DIR/whitespace.j2"

check "template uses whitespace control" 5 \
    "grep -q '{%-' $TEMPLATES_DIR/whitespace.j2 || grep -q '-%}' $TEMPLATES_DIR/whitespace.j2" \
    "Use: {%- and -%} for whitespace control"

check "playbook defines items list" 3 \
    "grep -q 'items:' $ANSIBLE_DIR/template-whitespace.yml" \
    "Define: items list"

ansible_check "file has compact output" 4 \
    "node1.example.com" "stat" "path=/tmp/compact.txt" "exists.*True" \
    "Deploy template to /tmp/compact.txt"

echo ""
echo -e "${YELLOW}Task 20: Complex Multi-Level Template (25 pts)${NC}"
check "playbook template-complex.yml exists" 5 \
    "test -f $ANSIBLE_DIR/template-complex.yml" \
    "Create: $ANSIBLE_DIR/template-complex.yml"

check "template complex.j2 exists" 5 \
    "test -f $TEMPLATES_DIR/complex.j2" \
    "Create: $TEMPLATES_DIR/complex.j2"

check "playbook defines infrastructure dict" 5 \
    "grep -q 'infrastructure:' $ANSIBLE_DIR/template-complex.yml" \
    "Define: infrastructure with nested structure"

check "template has nested loops" 5 \
    "grep -c '{% for' $TEMPLATES_DIR/complex.j2 | grep -q '[2-9]'" \
    "Use: nested for loops for environments, types, servers"

ansible_check "file contains structured output" 5 \
    "node1.example.com" "command" "cat /tmp/infrastructure.txt" "production.*web.*database.*staging" \
    "Result should show all environments and server types"

echo ""
echo -e "${YELLOW}Task 21: Cluster Inventory Report from hostvars (22 pts)${NC}"
check "playbook cluster-report.yml exists" 2 \
    "test -f $ANSIBLE_DIR/cluster-report.yml" \
    "Create: $ANSIBLE_DIR/cluster-report.yml"

check "template cluster-info.j2 exists" 2 \
    "test -f $TEMPLATES_DIR/cluster-info.j2" \
    "Create: $TEMPLATES_DIR/cluster-info.j2"

check "template loops over groups['all']" 4 \
    "grep -qE \"for[[:space:]]+\\w+[[:space:]]+in[[:space:]]+groups\\\\['all'\\\\]\" $TEMPLATES_DIR/cluster-info.j2" \
    "Use: {% for host in groups['all'] %} ... {% endfor %}"

check "template reads from hostvars[]" 3 \
    "grep -q 'hostvars\\[' $TEMPLATES_DIR/cluster-info.j2" \
    "Pull each fact via hostvars[host].<fact>"

check "template uses default('NONE') filter" 2 \
    "grep -q \"default('NONE')\" $TEMPLATES_DIR/cluster-info.j2" \
    "Guard every fact lookup with | default('NONE')"

check "playbook gathers facts" 2 \
    "grep -qE 'gather_facts:[[:space:]]*(true|yes)' $ANSIBLE_DIR/cluster-report.yml" \
    "First play needs gather_facts: true so hostvars[] is populated for all hosts"

ansible_check "/etc/cluster-info.txt deployed" 4 \
    "all" "shell" "test -f /etc/cluster-info.txt" "" \
    "Use ansible.builtin.template to write /etc/cluster-info.txt on every host"

ansible_check "cluster-info.txt lists every host" 3 \
    "node1.example.com" "shell" "grep -c node /etc/cluster-info.txt" "[2-9]" \
    "The file must contain a line per host in groups['all']"

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
    echo -e "${YELLOW}You need $((256 - TOTAL_POINTS)) more points to pass.${NC}\n"
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
echo -e "5. Re-run: ${YELLOW}~/exams/thematic/jinja2-advanced/grade.sh${NC}\n"

exit 0

# Made with Bob

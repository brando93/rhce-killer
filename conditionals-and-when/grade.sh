#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Conditionals and When Grader
# Run this after completing all tasks to see your score.
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

EXAM_NAME="conditionals-and-when"
EXAM_TITLE="Conditionals And When"
# ───── shared helpers (color codes, check(), counters, print_summary) ─
# Probe standard locations: local repo and ~/exams/lib on the control node.
for _LIB in \
    "$(dirname "$0")/../../lib/grade-helpers.sh" \
    "$(dirname "$0")/../scripts/lib/grade-helpers.sh" \
    "$(dirname "$0")/../lib/grade-helpers.sh"; do
    [ -f "$_LIB" ] && { source "$_LIB"; break; }
done
unset _LIB
TOTAL_POINTS=207


# ── Colors ──

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}   RHCE KILLER — ${EXAM_TITLE} Results${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# ─────────────────────────────────────────────
echo -e "${BOLD}Task 01 — Basic When Condition with Equality (10 pts)${NC}"
# ─────────────────────────────────────────────
check "when-basic.yml exists" 2 \
  "test -f $ANSIBLE_DIR/when-basic.yml" \
  "Create playbook: when-basic.yml"
check "playbook defines environment variable" 2 \
  "grep -q 'environment:.*production' $ANSIBLE_DIR/when-basic.yml" \
  "Define variable: environment: production"
check "playbook uses when with ==" 3 \
  "grep -q 'when:.*environment.*==.*production' $ANSIBLE_DIR/when-basic.yml" \
  "Use: when: environment == 'production'"
check "playbook uses when with !=" 2 \
  "grep -q 'when:.*environment.*!=' $ANSIBLE_DIR/when-basic.yml" \
  "Use: when: environment != 'production'"
check "playbook syntax is valid" 1 \
  "ansible-playbook --syntax-check $ANSIBLE_DIR/when-basic.yml" \
  "Check syntax with: ansible-playbook --syntax-check when-basic.yml"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — When with Facts - OS Detection (12 pts)${NC}"
# ─────────────────────────────────────────────
check "when-os.yml exists" 2 \
  "test -f $ANSIBLE_DIR/when-os.yml" \
  "Create playbook: when-os.yml"
check "playbook uses ansible_distribution fact" 3 \
  "grep -q 'ansible_distribution' $ANSIBLE_DIR/when-os.yml" \
  "Use fact: ansible_distribution"
check "playbook checks for Rocky" 2 \
  "grep -q 'Rocky' $ANSIBLE_DIR/when-os.yml" \
  "Check for: ansible_distribution == 'Rocky'"
check "playbook installs httpd" 2 \
  "grep -q 'httpd' $ANSIBLE_DIR/when-os.yml" \
  "Install httpd on Rocky Linux"
ansible_check "httpd installed on node1" 3 \
  "node1.example.com" "command" "rpm -q httpd" "httpd-" \
  "Run playbook to install httpd"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — When with Numeric Comparison (12 pts)${NC}"
# ─────────────────────────────────────────────
check "when-memory.yml exists" 2 \
  "test -f $ANSIBLE_DIR/when-memory.yml" \
  "Create playbook: when-memory.yml"
check "playbook uses ansible_memtotal_mb" 3 \
  "grep -q 'ansible_memtotal_mb' $ANSIBLE_DIR/when-memory.yml" \
  "Use fact: ansible_memtotal_mb"
check "playbook uses > operator" 2 \
  "grep -q '>' $ANSIBLE_DIR/when-memory.yml" \
  "Use numeric comparison: >"
check "playbook uses < operator" 2 \
  "grep -q '<' $ANSIBLE_DIR/when-memory.yml" \
  "Use numeric comparison: <"
check "playbook has three memory checks" 3 \
  "grep -c 'memory' $ANSIBLE_DIR/when-memory.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
  "Create three tasks for different memory ranges"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Multiple Conditions with AND (15 pts)${NC}"
# ─────────────────────────────────────────────
check "when-and.yml exists" 3 \
  "test -f $ANSIBLE_DIR/when-and.yml" \
  "Create playbook: when-and.yml"
check "playbook uses ansible_processor_vcpus" 3 \
  "grep -q 'ansible_processor_vcpus' $ANSIBLE_DIR/when-and.yml" \
  "Use fact: ansible_processor_vcpus"
check "playbook uses ansible_memtotal_mb" 2 \
  "grep -q 'ansible_memtotal_mb' $ANSIBLE_DIR/when-and.yml" \
  "Use fact: ansible_memtotal_mb"
check "playbook uses and operator" 3 \
  "grep -q 'and' $ANSIBLE_DIR/when-and.yml || grep -A1 'when:' $ANSIBLE_DIR/when-and.yml | grep -q '^  -'" \
  "Use 'and' operator or list format for multiple conditions"
ansible_check "firewalld installed on node1" 4 \
  "node1.example.com" "command" "rpm -q firewalld" "firewalld-" \
  "Run playbook to install firewalld"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Multiple Conditions with OR (12 pts)${NC}"
# ─────────────────────────────────────────────
check "when-or.yml exists" 3 \
  "test -f $ANSIBLE_DIR/when-or.yml" \
  "Create playbook: when-or.yml"
check "playbook uses or operator" 3 \
  "grep -q 'or' $ANSIBLE_DIR/when-or.yml" \
  "Use 'or' operator for multiple conditions"
check "playbook uses in operator" 3 \
  "grep -q 'in' $ANSIBLE_DIR/when-or.yml" \
  "Use 'in' operator for string matching"
check "playbook uses inventory_hostname or ansible_hostname" 3 \
  "grep -q 'inventory_hostname\|ansible_hostname' $ANSIBLE_DIR/when-or.yml" \
  "Use inventory_hostname or ansible_hostname variable"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — When with 'in' Operator (12 pts)${NC}"
# ─────────────────────────────────────────────
check "when-in.yml exists" 2 \
  "test -f $ANSIBLE_DIR/when-in.yml" \
  "Create playbook: when-in.yml"
check "playbook uses group_names" 3 \
  "grep -q 'group_names' $ANSIBLE_DIR/when-in.yml" \
  "Use magic variable: group_names"
check "playbook checks for webservers group" 2 \
  "grep -q 'webservers' $ANSIBLE_DIR/when-in.yml" \
  "Check if host is in webservers group"
check "playbook checks for databases group" 2 \
  "grep -q 'databases' $ANSIBLE_DIR/when-in.yml" \
  "Check if host is in databases group"
check "playbook creates directories" 3 \
  "grep -q '/opt/webserver\|/opt/database' $ANSIBLE_DIR/when-in.yml" \
  "Create directories based on group membership"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — When with 'is defined' (12 pts)${NC}"
# ─────────────────────────────────────────────
check "when-defined.yml exists" 2 \
  "test -f $ANSIBLE_DIR/when-defined.yml" \
  "Create playbook: when-defined.yml"
check "playbook defines app_port variable" 2 \
  "grep -q 'app_port:.*8080' $ANSIBLE_DIR/when-defined.yml" \
  "Define variable: app_port: 8080"
check "playbook uses 'is defined'" 3 \
  "grep -q 'is defined' $ANSIBLE_DIR/when-defined.yml" \
  "Use test: when: app_port is defined"
check "playbook uses 'is not defined'" 2 \
  "grep -q 'is not defined' $ANSIBLE_DIR/when-defined.yml" \
  "Use test: when: app_port is not defined"
ansible_check "port.txt created on node1" 3 \
  "node1.example.com" "stat" "path=/tmp/port.txt" "exists.*True" \
  "Run playbook to create port.txt"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — When with Boolean Variables (10 pts)${NC}"
# ─────────────────────────────────────────────
check "when-boolean.yml exists" 2 \
  "test -f $ANSIBLE_DIR/when-boolean.yml" \
  "Create playbook: when-boolean.yml"
check "playbook defines enable_firewall" 2 \
  "grep -q 'enable_firewall:.*true' $ANSIBLE_DIR/when-boolean.yml" \
  "Define: enable_firewall: true"
check "playbook defines enable_selinux" 2 \
  "grep -q 'enable_selinux:.*false' $ANSIBLE_DIR/when-boolean.yml" \
  "Define: enable_selinux: false"
check "playbook uses boolean in when" 2 \
  "grep -q 'when:.*enable_firewall\|when:.*not.*enable_selinux' $ANSIBLE_DIR/when-boolean.yml" \
  "Use: when: enable_firewall or when: not enable_selinux"
check "playbook manages firewalld" 2 \
  "grep -q 'firewalld' $ANSIBLE_DIR/when-boolean.yml" \
  "Start firewalld service when enable_firewall is true"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — When with String Matching (12 pts)${NC}"
# ─────────────────────────────────────────────
check "when-string.yml exists" 3 \
  "test -f $ANSIBLE_DIR/when-string.yml" \
  "Create playbook: when-string.yml"
check "playbook uses inventory_hostname" 3 \
  "grep -q 'inventory_hostname' $ANSIBLE_DIR/when-string.yml" \
  "Use variable: inventory_hostname"
check "playbook uses string matching" 3 \
  "grep -q 'startswith\|is match' $ANSIBLE_DIR/when-string.yml" \
  "Use: startswith() filter or 'is match' test"
check "playbook checks for node1 and node2" 3 \
  "grep -q 'node1' $ANSIBLE_DIR/when-string.yml && grep -q 'node2' $ANSIBLE_DIR/when-string.yml" \
  "Check for both node1 and node2 in hostname"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — failed_when Customization (15 pts)${NC}"
# ─────────────────────────────────────────────
check "failed-when.yml exists" 3 \
  "test -f $ANSIBLE_DIR/failed-when.yml" \
  "Create playbook: failed-when.yml"
check "playbook uses grep command" 3 \
  "grep -q 'grep.*student' $ANSIBLE_DIR/failed-when.yml" \
  "Use command: grep student /etc/passwd"
check "playbook uses register" 3 \
  "grep -q 'register:' $ANSIBLE_DIR/failed-when.yml" \
  "Use: register: result"
check "playbook uses failed_when" 3 \
  "grep -q 'failed_when:' $ANSIBLE_DIR/failed-when.yml" \
  "Use: failed_when: result.rc > 1"
check "playbook checks return code" 3 \
  "grep -q 'rc.*>.*1\|rc.*gt.*1' $ANSIBLE_DIR/failed-when.yml" \
  "Check: rc > 1 (fail only on errors, not on 'not found')"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — changed_when Customization (15 pts)${NC}"
# ─────────────────────────────────────────────
check "changed-when.yml exists" 3 \
  "test -f $ANSIBLE_DIR/changed-when.yml" \
  "Create playbook: changed-when.yml"
check "playbook uses cat command" 3 \
  "grep -q 'cat.*hostname' $ANSIBLE_DIR/changed-when.yml" \
  "Use command: cat /etc/hostname"
check "playbook uses register" 3 \
  "grep -q 'register:' $ANSIBLE_DIR/changed-when.yml" \
  "Use: register: result"
check "playbook uses changed_when: false" 6 \
  "grep -q 'changed_when:.*false' $ANSIBLE_DIR/changed-when.yml" \
  "Use: changed_when: false (task should never show as changed)"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 12 — When with Register (15 pts)${NC}"
# ─────────────────────────────────────────────
check "when-register.yml exists" 3 \
  "test -f $ANSIBLE_DIR/when-register.yml" \
  "Create playbook: when-register.yml"
check "playbook checks for httpd" 3 \
  "grep -q 'rpm -q httpd' $ANSIBLE_DIR/when-register.yml" \
  "Use command: rpm -q httpd"
check "playbook uses register" 2 \
  "grep -q 'register:' $ANSIBLE_DIR/when-register.yml" \
  "Use: register: httpd_check"
check "playbook uses failed_when: false" 2 \
  "grep -q 'failed_when:.*false' $ANSIBLE_DIR/when-register.yml" \
  "Use: failed_when: false on check task"
check "playbook uses when with rc" 3 \
  "grep -q 'when:.*rc.*!=.*0\|when:.*rc.*ne.*0' $ANSIBLE_DIR/when-register.yml" \
  "Use: when: httpd_check.rc != 0"
check "playbook installs httpd conditionally" 2 \
  "grep -A5 'when:.*rc' $ANSIBLE_DIR/when-register.yml | grep -q 'httpd'" \
  "Install httpd only if not already installed"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 13 — Complex Conditionals (18 pts)${NC}"
# ─────────────────────────────────────────────
check "when-complex.yml exists" 3 \
  "test -f $ANSIBLE_DIR/when-complex.yml" \
  "Create playbook: when-complex.yml"
check "playbook checks for httpd first" 3 \
  "grep -q 'rpm -q httpd' $ANSIBLE_DIR/when-complex.yml" \
  "Check if httpd is installed first"
check "playbook uses multiple when conditions" 3 \
  "grep -c 'when:' $ANSIBLE_DIR/when-complex.yml | awk '{if(\$1>=2) exit 0; else exit 1}'" \
  "Use multiple when conditions"
check "playbook checks OS" 2 \
  "grep -q 'ansible_distribution.*Rocky' $ANSIBLE_DIR/when-complex.yml" \
  "Check: ansible_distribution == 'Rocky'"
check "playbook checks memory" 2 \
  "grep -q 'ansible_memtotal_mb.*>' $ANSIBLE_DIR/when-complex.yml" \
  "Check: ansible_memtotal_mb > 1024"
check "playbook checks hostname" 2 \
  "grep -q 'web.*hostname\|hostname.*web' $ANSIBLE_DIR/when-complex.yml" \
  "Check: hostname contains 'web'"
check "playbook installs nginx" 3 \
  "grep -q 'nginx' $ANSIBLE_DIR/when-complex.yml" \
  "Install nginx when all conditions are met"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 14 — When with Nested Conditions (15 pts)${NC}"
# ─────────────────────────────────────────────
check "when-nested.yml exists" 3 \
  "test -f $ANSIBLE_DIR/when-nested.yml" \
  "Create playbook: when-nested.yml"
check "playbook has three tasks for server types" 3 \
  "grep -c 'High Performance\|Standard Server\|Basic Server' $ANSIBLE_DIR/when-nested.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
  "Create three tasks for different server types"
check "playbook uses memory and CPU facts" 3 \
  "grep -q 'ansible_memtotal_mb' $ANSIBLE_DIR/when-nested.yml && grep -q 'ansible_processor_vcpus' $ANSIBLE_DIR/when-nested.yml" \
  "Use both memory and CPU facts"
check "playbook creates /tmp/server-type.txt" 3 \
  "grep -q '/tmp/server-type.txt' $ANSIBLE_DIR/when-nested.yml" \
  "Create file: /tmp/server-type.txt"
ansible_check "server-type.txt created on node1" 3 \
  "node1.example.com" "stat" "path=/tmp/server-type.txt" "exists.*True" \
  "Run playbook to create server-type.txt"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 15 — When with List Membership (12 pts)${NC}"
# ─────────────────────────────────────────────
check "when-list.yml exists" 3 \
  "test -f $ANSIBLE_DIR/when-list.yml" \
  "Create playbook: when-list.yml"
check "playbook defines allowed_hosts list" 3 \
  "grep -A2 'allowed_hosts:' $ANSIBLE_DIR/when-list.yml | grep -q 'node1.example.com'" \
  "Define list: allowed_hosts with node1 and node2"
check "playbook uses 'in' with list" 3 \
  "grep -q 'in allowed_hosts' $ANSIBLE_DIR/when-list.yml" \
  "Use: when: inventory_hostname in allowed_hosts"
check "playbook uses 'not in' with list" 3 \
  "grep -q 'not in allowed_hosts' $ANSIBLE_DIR/when-list.yml" \
  "Use: when: inventory_hostname not in allowed_hosts"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 16 — Conditional LVM Provisioning (20 pts)${NC}"
# ─────────────────────────────────────────────
check "lvm-conditional.yml exists" 2 \
  "test -f $ANSIBLE_DIR/lvm-conditional.yml" \
  "Create playbook: lvm-conditional.yml"
check "Defines target_disk variable" 2 \
  "grep -qE 'target_disk:' $ANSIBLE_DIR/lvm-conditional.yml" \
  "Define target_disk variable at the top of the playbook"
check "Uses 'is not defined' guard" 3 \
  "grep -q 'is not defined' $ANSIBLE_DIR/lvm-conditional.yml" \
  "Skip hosts where ansible_devices[target_disk] is not defined"
check "Uses meta: end_host" 3 \
  "grep -q 'end_host' $ANSIBLE_DIR/lvm-conditional.yml" \
  "Use ansible.builtin.meta: end_host to cleanly skip a host"
check "Uses ansible.builtin.fail" 2 \
  "grep -qE 'ansible.builtin.fail|^[[:space:]]+fail:' $ANSIBLE_DIR/lvm-conditional.yml" \
  "Use ansible.builtin.fail when disk is smaller than desired_size_mb"
check "set_fact computes size from sectors" 3 \
  "grep -q 'set_fact' $ANSIBLE_DIR/lvm-conditional.yml && grep -q 'sectors' $ANSIBLE_DIR/lvm-conditional.yml" \
  "Use set_fact: target_disk_size_mb based on sectors * sectorsize"
check "Uses community.general.lvg" 2 \
  "grep -qE 'community.general.lvg|^[[:space:]]+lvg:' $ANSIBLE_DIR/lvm-conditional.yml" \
  "Use community.general.lvg to create the volume group"
check "Uses community.general.lvol" 2 \
  "grep -qE 'community.general.lvol|^[[:space:]]+lvol:' $ANSIBLE_DIR/lvm-conditional.yml" \
  "Use community.general.lvol for the logical volume"
check "Playbook syntax check passes" 1 \
  "ansible-playbook $ANSIBLE_DIR/lvm-conditional.yml --syntax-check &>/dev/null" \
  "Run: ansible-playbook lvm-conditional.yml --syntax-check"

# ─────────────────────────────────────────────
# Final Results
# ─────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}   Final Score${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

PERCENTAGE=$((PASS * 100 / TOTAL))

if [ $PERCENTAGE -ge 70 ]; then
  echo -e "  ${GREEN}${BOLD}✓ PASS${NC} — You scored ${BOLD}${PASS}/${TOTAL}${NC} points (${PERCENTAGE}%)"
  echo ""
  echo -e "  ${GREEN}Congratulations!${NC} You've mastered Ansible conditional logic."
else
  echo -e "  ${RED}${BOLD}✗ FAIL${NC} — You scored ${BOLD}${PASS}/${TOTAL}${NC} points (${PERCENTAGE}%)"
  echo ""
  echo -e "  ${YELLOW}You need 70% to pass (145/207 points).${NC}"
fi

echo ""
echo -e "${CYAN}Score Breakdown:${NC}"
echo -e "  Passed: ${GREEN}${PASS}${NC} points"
echo -e "  Failed: ${RED}${FAIL}${NC} points"
echo -e "  Total:  ${BOLD}${TOTAL}${NC} points"
echo ""

if [ ${#FAILED_TASKS[@]} -gt 0 ]; then
  echo -e "${YELLOW}Failed Tasks:${NC}"
  for task in "${FAILED_TASKS[@]}"; do
    DESC=$(echo "$task" | cut -d'|' -f1)
    HINT=$(echo "$task" | cut -d'|' -f2)
    echo -e "  ${RED}✗${NC} $DESC"
    if [ -n "$HINT" ] && [ "$HINT" != " " ]; then
      echo -e "    ${YELLOW}→${NC} $HINT"
    fi
  done
  echo ""
fi

echo -e "${CYAN}Next Steps:${NC}"
if [ $PERCENTAGE -ge 90 ]; then
  echo -e "  ${GREEN}✓${NC} Excellent work! Try the next thematic exam:"
  echo -e "    bash ~/exams/thematic/loops-and-iteration/START.sh"
elif [ $PERCENTAGE -ge 70 ]; then
  echo -e "  ${GREEN}✓${NC} Good job! Review failed tasks and try:"
  echo -e "    bash ~/exams/thematic/loops-and-iteration/START.sh"
else
  echo -e "  ${YELLOW}→${NC} Review the README.md for solutions"
  echo -e "  ${YELLOW}→${NC} Practice the failed tasks"
  echo -e "  ${YELLOW}→${NC} Retake this exam when ready"
fi

echo ""
echo -e "${CYAN}Resources:${NC}"
echo -e "  • Review solutions: cat ~/exams/thematic/conditionals-and-when/README.md | less"
echo -e "  • Ansible docs: ansible-doc -t test (for 'is defined', 'is match', etc.)"
echo -e "  • Conditionals guide: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html"
echo ""

# Made with Bob

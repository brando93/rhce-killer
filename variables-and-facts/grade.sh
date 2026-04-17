#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Variables and Facts Grader
# Run this after completing all tasks to see your score.
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

EXAM_NAME="variables-and-facts"
EXAM_TITLE="Variables and Facts"
TOTAL_POINTS=200

PASS=0
FAIL=0
TOTAL=0
RESULTS=()
FAILED_TASKS=()

# ── Colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

check() {
  local DESC="$1"
  local PTS="$2"
  local CMD="$3"
  local HINT="${4:-}"
  TOTAL=$((TOTAL + PTS))

  if eval "$CMD" &>/dev/null; then
    echo -e "  ${GREEN}[PASS]${NC} (+${PTS}pts) $DESC"
    PASS=$((PASS + PTS))
    RESULTS+=("PASS|$PTS|$DESC")
  else
    echo -e "  ${RED}[FAIL]${NC} (  0pts) $DESC"
    if [ -n "$HINT" ]; then
      echo -e "    ${YELLOW}→ Hint:${NC} $HINT"
    fi
    FAIL=$((FAIL + PTS))
    RESULTS+=("FAIL|0|$DESC")
    FAILED_TASKS+=("$DESC|$HINT")
  fi
}

ansible_check() {
  local DESC="$1"
  local PTS="$2"
  local HOST="$3"
  local MODULE="$4"
  local ARGS="$5"
  local GREP="$6"
  local HINT="${7:-}"

  TOTAL=$((TOTAL + PTS))
  OUTPUT=$(ansible "$HOST" -m "$MODULE" -a "$ARGS" 2>/dev/null)
  if echo "$OUTPUT" | grep -q "$GREP"; then
    echo -e "  ${GREEN}[PASS]${NC} (+${PTS}pts) $DESC"
    PASS=$((PASS + PTS))
    RESULTS+=("PASS|$PTS|$DESC")
  else
    echo -e "  ${RED}[FAIL]${NC} (  0pts) $DESC"
    if [ -n "$HINT" ]; then
      echo -e "    ${YELLOW}→ Hint:${NC} $HINT"
    fi
    FAIL=$((FAIL + PTS))
    RESULTS+=("FAIL|0|$DESC")
    FAILED_TASKS+=("$DESC|$HINT")
  fi
}

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}   RHCE KILLER — ${EXAM_TITLE} Results${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# ─────────────────────────────────────────────
echo -e "${BOLD}Task 01 — Facts Discovery (10 pts)${NC}"
# ─────────────────────────────────────────────
check "facts-discovery.yml exists" 2 \
  "test -f facts-discovery.yml" \
  "Create playbook: facts-discovery.yml"
check "playbook has gather_facts enabled" 2 \
  "grep -q 'gather_facts.*true' facts-discovery.yml || ! grep -q 'gather_facts.*false' facts-discovery.yml" \
  "Add: gather_facts: true (or omit for default)"
check "playbook displays ansible_distribution" 1 \
  "grep -q 'ansible_distribution' facts-discovery.yml" \
  "Use debug module to display {{ ansible_distribution }}"
check "playbook displays ansible_memtotal_mb" 1 \
  "grep -q 'ansible_memtotal_mb' facts-discovery.yml" \
  "Display memory fact: {{ ansible_memtotal_mb }}"
check "playbook displays ansible_processor_vcpus" 1 \
  "grep -q 'ansible_processor_vcpus' facts-discovery.yml" \
  "Display CPU fact: {{ ansible_processor_vcpus }}"
check "playbook displays ansible_default_ipv4" 1 \
  "grep -q 'ansible_default_ipv4' facts-discovery.yml" \
  "Display IP fact: {{ ansible_default_ipv4.address }}"
check "playbook displays ansible_hostname" 1 \
  "grep -q 'ansible_hostname' facts-discovery.yml" \
  "Display hostname fact: {{ ansible_hostname }}"
check "playbook syntax is valid" 1 \
  "ansible-playbook facts-discovery.yml --syntax-check 2>/dev/null" \
  "Check syntax with: ansible-playbook --syntax-check"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — Conditional Package Installation (15 pts)${NC}"
# ─────────────────────────────────────────────
check "conditional-packages.yml exists" 3 \
  "test -f conditional-packages.yml" \
  "Create playbook: conditional-packages.yml"
check "playbook uses ansible_memtotal_mb fact" 3 \
  "grep -q 'ansible_memtotal_mb' conditional-packages.yml" \
  "Use fact: {{ ansible_memtotal_mb }}"
check "playbook has when condition for httpd" 3 \
  "grep -A2 'name.*httpd' conditional-packages.yml | grep -q 'when'" \
  "Add: when: ansible_memtotal_mb > 1024"
check "playbook has when condition for nginx" 3 \
  "grep -A2 'name.*nginx' conditional-packages.yml | grep -q 'when'" \
  "Add: when: ansible_memtotal_mb <= 1024"
check "playbook syntax is valid" 3 \
  "ansible-playbook conditional-packages.yml --syntax-check 2>/dev/null" \
  "Check syntax with: ansible-playbook --syntax-check"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — OS-Specific Configuration (15 pts)${NC}"
# ─────────────────────────────────────────────
check "os-specific.yml exists" 3 \
  "test -f os-specific.yml" \
  "Create playbook: os-specific.yml"
check "playbook uses ansible_distribution fact" 3 \
  "grep -q 'ansible_distribution' os-specific.yml" \
  "Use fact: {{ ansible_distribution }}"
check "playbook has when conditions" 3 \
  "grep -q 'when:' os-specific.yml" \
  "Add when conditions for different OS"
ansible_check "file /etc/system-info.txt exists on node1" 3 \
  "node1.example.com" "command" "test -f /etc/system-info.txt" "rc=0" \
  "Run playbook to create file"
ansible_check "file contains correct content for Rocky" 3 \
  "node1.example.com" "command" "cat /etc/system-info.txt" "Rocky" \
  "File should contain 'This is a Rocky Linux system'"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Magic Variables - Inventory (15 pts)${NC}"
# ─────────────────────────────────────────────
check "inventory-info.yml exists" 3 \
  "test -f inventory-info.yml" \
  "Create playbook: inventory-info.yml"
check "playbook uses groups magic variable" 3 \
  "grep -q 'groups' inventory-info.yml" \
  "Use magic variable: {{ groups }}"
check "playbook runs on node1" 3 \
  "grep -q 'node1' inventory-info.yml" \
  "Set hosts: node1.example.com"
ansible_check "file /tmp/inventory-report.txt exists on node1" 3 \
  "node1.example.com" "command" "test -f /tmp/inventory-report.txt" "rc=0" \
  "Run playbook to create file"
ansible_check "file contains host information" 3 \
  "node1.example.com" "command" "cat /tmp/inventory-report.txt" "node" \
  "File should list inventory hosts"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Hostname Conditionals (10 pts)${NC}"
# ─────────────────────────────────────────────
check "hostname-conditional.yml exists" 2 \
  "test -f hostname-conditional.yml" \
  "Create playbook: hostname-conditional.yml"
check "playbook uses inventory_hostname or ansible_hostname" 2 \
  "grep -q 'inventory_hostname\|ansible_hostname' hostname-conditional.yml" \
  "Use: {{ inventory_hostname }} or {{ ansible_hostname }}"
ansible_check "directory /opt/node1-data exists on node1" 2 \
  "node1.example.com" "command" "test -d /opt/node1-data" "rc=0" \
  "Create directory with when: inventory_hostname == 'node1.example.com'"
ansible_check "directory /opt/node2-data exists on node2" 2 \
  "node2.example.com" "command" "test -d /opt/node2-data" "rc=0" \
  "Create directory with when: inventory_hostname == 'node2.example.com'"
ansible_check "directories have correct permissions" 2 \
  "node1.example.com" "command" "stat -c %a /opt/node1-data" "755" \
  "Set mode: '0755'"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Network Facts (15 pts)${NC}"
# ─────────────────────────────────────────────
check "network-check.yml exists" 3 \
  "test -f network-check.yml" \
  "Create playbook: network-check.yml"
check "playbook uses ansible_default_ipv4 fact" 3 \
  "grep -q 'ansible_default_ipv4' network-check.yml" \
  "Use fact: {{ ansible_default_ipv4.address }}"
check "playbook has network conditionals" 3 \
  "grep -q 'when:' network-check.yml" \
  "Add when conditions based on IP address"
ansible_check "file /etc/network-zone.conf exists on nodes" 3 \
  "managed" "command" "test -f /etc/network-zone.conf" "rc=0" \
  "Run playbook to create file"
ansible_check "file contains zone configuration" 3 \
  "managed" "command" "cat /etc/network-zone.conf" "zone=" \
  "File should contain zone=private or zone=public"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — Custom Facts (15 pts)${NC}"
# ─────────────────────────────────────────────
check "custom-facts.yml exists" 3 \
  "test -f custom-facts.yml" \
  "Create playbook: custom-facts.yml"
ansible_check "custom fact file exists on node1" 3 \
  "node1.example.com" "command" "test -f /etc/ansible/facts.d/app.fact" "rc=0" \
  "Create /etc/ansible/facts.d/app.fact"
ansible_check "custom fact has correct format" 3 \
  "node1.example.com" "command" "cat /etc/ansible/facts.d/app.fact" "\\[application\\]" \
  "Use INI format with [application] section"
check "playbook uses ansible_local" 2 \
  "grep -q 'ansible_local' custom-facts.yml" \
  "Access custom fact: {{ ansible_local.app.application.name }}"
ansible_check "file /tmp/app-info.txt exists" 2 \
  "node1.example.com" "command" "test -f /tmp/app-info.txt" "rc=0" \
  "Create file using custom fact values"
ansible_check "app info file has correct content" 2 \
  "node1.example.com" "command" "cat /tmp/app-info.txt" "webapp" \
  "File should contain 'Application: webapp, Version: 2.0'"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — Multiple Conditions (15 pts)${NC}"
# ─────────────────────────────────────────────
check "multi-conditions.yml exists" 3 \
  "test -f multi-conditions.yml" \
  "Create playbook: multi-conditions.yml"
check "playbook uses ansible_processor_vcpus" 3 \
  "grep -q 'ansible_processor_vcpus' multi-conditions.yml" \
  "Use fact: {{ ansible_processor_vcpus }}"
check "playbook uses ansible_memtotal_mb" 3 \
  "grep -q 'ansible_memtotal_mb' multi-conditions.yml" \
  "Use fact: {{ ansible_memtotal_mb }}"
check "playbook has multiple when conditions" 3 \
  "grep -A1 'when:' multi-conditions.yml | grep -q 'ansible_processor_vcpus\|ansible_memtotal_mb'" \
  "Use: when: ansible_processor_vcpus > 1 and ansible_memtotal_mb > 1024"
check "playbook syntax is valid" 3 \
  "ansible-playbook multi-conditions.yml --syntax-check 2>/dev/null" \
  "Check syntax with: ansible-playbook --syntax-check"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — Hostvars (20 pts)${NC}"
# ─────────────────────────────────────────────
check "hostvars-demo.yml exists" 4 \
  "test -f hostvars-demo.yml" \
  "Create playbook: hostvars-demo.yml"
check "playbook uses hostvars magic variable" 4 \
  "grep -q 'hostvars' hostvars-demo.yml" \
  "Use: {{ hostvars['node2.example.com']['ansible_default_ipv4']['address'] }}"
check "playbook runs on node1" 4 \
  "grep -q 'node1' hostvars-demo.yml" \
  "Set hosts: node1.example.com"
ansible_check "file /tmp/cluster-info.txt exists on node1" 4 \
  "node1.example.com" "command" "test -f /tmp/cluster-info.txt" "rc=0" \
  "Run playbook to create file"
ansible_check "file contains both node IPs" 4 \
  "node1.example.com" "command" "cat /tmp/cluster-info.txt" "10.0.2" \
  "File should contain IPs from both nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — Fact Gathering (10 pts)${NC}"
# ─────────────────────────────────────────────
check "fact-gathering.yml exists" 2 \
  "test -f fact-gathering.yml" \
  "Create playbook: fact-gathering.yml"
check "playbook disables automatic fact gathering" 2 \
  "grep -q 'gather_facts.*false' fact-gathering.yml" \
  "Add: gather_facts: false"
check "playbook uses setup module with filter" 2 \
  "grep -q 'setup:' fact-gathering.yml && grep -q 'filter' fact-gathering.yml" \
  "Use: ansible.builtin.setup with filter: ansible_default_ipv4"
ansible_check "file /tmp/ip-only.txt exists" 2 \
  "managed" "command" "test -f /tmp/ip-only.txt" "rc=0" \
  "Run playbook to create file"
ansible_check "file contains IP address" 2 \
  "node1.example.com" "command" "cat /tmp/ip-only.txt" "[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+" \
  "File should contain IP address"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — Register + When (15 pts)${NC}"
# ─────────────────────────────────────────────
check "register-conditional.yml exists" 3 \
  "test -f register-conditional.yml" \
  "Create playbook: register-conditional.yml"
check "playbook uses register keyword" 3 \
  "grep -q 'register:' register-conditional.yml" \
  "Add: register: httpd_check"
check "playbook uses when with register" 3 \
  "grep -q 'when:' register-conditional.yml" \
  "Add: when: httpd_check.rc != 0"
check "playbook checks for httpd package" 3 \
  "grep -q 'httpd' register-conditional.yml" \
  "Use: command: rpm -q httpd"
check "playbook syntax is valid" 3 \
  "ansible-playbook register-conditional.yml --syntax-check 2>/dev/null" \
  "Check syntax with: ansible-playbook --syntax-check"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 12 — Loop + Conditionals (20 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-conditionals.yml exists" 4 \
  "test -f loop-conditionals.yml" \
  "Create playbook: loop-conditionals.yml"
check "playbook defines packages variable" 4 \
  "grep -q 'packages:' loop-conditionals.yml" \
  "Define vars with packages list"
check "playbook uses loop" 4 \
  "grep -q 'loop:' loop-conditionals.yml" \
  "Add: loop: {{ packages }}"
check "playbook uses when with loop" 4 \
  "grep -A2 'loop:' loop-conditionals.yml | grep -q 'when:'" \
  "Add: when: ansible_memtotal_mb >= item.required_memory"
check "playbook uses ansible_memtotal_mb in condition" 4 \
  "grep -q 'ansible_memtotal_mb' loop-conditionals.yml" \
  "Compare memory with item.required_memory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 13 — Group Membership (10 pts)${NC}"
# ─────────────────────────────────────────────
check "group-conditional.yml exists" 2 \
  "test -f group-conditional.yml" \
  "Create playbook: group-conditional.yml"
check "playbook uses group_names magic variable" 2 \
  "grep -q 'group_names' group-conditional.yml" \
  "Use: when: 'managed' in group_names"
check "playbook has group membership conditions" 2 \
  "grep -q 'in group_names' group-conditional.yml" \
  "Add when conditions for group membership"
ansible_check "file /etc/node-type.conf exists on nodes" 2 \
  "managed" "command" "test -f /etc/node-type.conf" "rc=0" \
  "Run playbook to create file"
ansible_check "file contains type configuration" 2 \
  "managed" "command" "cat /etc/node-type.conf" "type=" \
  "File should contain type=control or type=managed"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 14 — Ansible Environment (10 pts)${NC}"
# ─────────────────────────────────────────────
check "ansible-env.yml exists" 2 \
  "test -f ansible-env.yml" \
  "Create playbook: ansible-env.yml"
check "playbook runs on localhost" 2 \
  "grep -q 'localhost' ansible-env.yml" \
  "Set hosts: localhost"
check "playbook uses ansible_version" 2 \
  "grep -q 'ansible_version' ansible-env.yml" \
  "Use: {{ ansible_version.full }}"
check "playbook uses ansible_python_version" 2 \
  "grep -q 'ansible_python_version' ansible-env.yml" \
  "Use: {{ ansible_python_version }}"
check "file /tmp/ansible-info.txt exists" 2 \
  "test -f /tmp/ansible-info.txt" \
  "Run playbook to create file on control node"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 15 — Failed/Changed When (15 pts)${NC}"
# ─────────────────────────────────────────────
check "custom-status.yml exists" 3 \
  "test -f custom-status.yml" \
  "Create playbook: custom-status.yml"
check "playbook uses failed_when" 3 \
  "grep -q 'failed_when:' custom-status.yml" \
  "Add: failed_when: grep_result.rc > 1"
check "playbook uses changed_when" 3 \
  "grep -q 'changed_when:' custom-status.yml" \
  "Add: changed_when: grep_result.rc == 0"
check "playbook uses register" 3 \
  "grep -q 'register:' custom-status.yml" \
  "Add: register: grep_result"
check "playbook syntax is valid" 3 \
  "ansible-playbook custom-status.yml --syntax-check 2>/dev/null" \
  "Check syntax with: ansible-playbook --syntax-check"

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
  echo -e "  ${GREEN}Congratulations!${NC} You've mastered Ansible facts and conditionals."
else
  echo -e "  ${RED}${BOLD}✗ FAIL${NC} — You scored ${BOLD}${PASS}/${TOTAL}${NC} points (${PERCENTAGE}%)"
  echo ""
  echo -e "  ${YELLOW}You need 70% to pass (140/200 points).${NC}"
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
  echo -e "    bash ~/exams/thematic/jinja2-basics/START.sh"
elif [ $PERCENTAGE -ge 70 ]; then
  echo -e "  ${GREEN}✓${NC} Good job! Review failed tasks and try:"
  echo -e "    bash ~/exams/thematic/jinja2-basics/START.sh"
else
  echo -e "  ${YELLOW}→${NC} Review the README.md for solutions"
  echo -e "  ${YELLOW}→${NC} Practice the failed tasks"
  echo -e "  ${YELLOW}→${NC} Retake this exam when ready"
fi

echo ""
echo -e "${CYAN}Resources:${NC}"
echo -e "  • Review solutions: cat ~/exams/thematic/variables-and-facts/README.md | less"
echo -e "  • Ansible docs: ansible-doc <module_name>"
echo -e "  • Facts reference: ansible hostname -m setup"
echo ""

# Clean up timer if exam is complete
rm -f "$HOME/.variables_and_facts_timer" 2>/dev/null

# Made with Bob
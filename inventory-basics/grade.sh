#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Inventory Basics Grader
# Run this after completing all tasks to see your score.
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

EXAM_NAME="inventory-basics"
EXAM_TITLE="Inventory Basics"
TOTAL_POINTS=120

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
echo -e "${BOLD}Task 01 — Create Basic Inventory (INI Format) (8 pts)${NC}"
# ─────────────────────────────────────────────
check "inventory file exists" 2 \
  "test -f $ANSIBLE_DIR/inventory" \
  "Create file: $ANSIBLE_DIR/inventory"
check "[webservers] group contains node1" 2 \
  "grep -A1 '^\[webservers\]' $ANSIBLE_DIR/inventory | grep -q 'node1.example.com'" \
  "Add node1.example.com under [webservers]"
check "[databases] group contains node2" 2 \
  "grep -A1 '^\[databases\]' $ANSIBLE_DIR/inventory | grep -q 'node2.example.com'" \
  "Add node2.example.com under [databases]"
check "[production] group contains both nodes" 2 \
  "grep -A2 '^\[production\]' $ANSIBLE_DIR/inventory | grep -q 'node1.example.com' && grep -A2 '^\[production\]' $ANSIBLE_DIR/inventory | grep -q 'node2.example.com'" \
  "Add both nodes under [production]"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — Configure ansible.cfg (8 pts)${NC}"
# ─────────────────────────────────────────────
check "ansible.cfg file exists" 2 \
  "test -f $ANSIBLE_DIR/ansible.cfg" \
  "Create file: $ANSIBLE_DIR/ansible.cfg"
check "inventory setting configured" 2 \
  "grep -q '^inventory.*=.*/home/student/ansible/inventory' $ANSIBLE_DIR/ansible.cfg" \
  "Add: inventory = /home/student/ansible/inventory"
check "remote_user setting configured" 2 \
  "grep -q '^remote_user.*=.*student' $ANSIBLE_DIR/ansible.cfg" \
  "Add: remote_user = student"
check "host_key_checking disabled" 2 \
  "grep -qi '^host_key_checking.*=.*false' $ANSIBLE_DIR/ansible.cfg" \
  "Add: host_key_checking = False (or false)"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — Test Connectivity with Ping (8 pts)${NC}"
# ─────────────────────────────────────────────
check "adhoc-ping.sh file exists" 2 \
  "test -f $ANSIBLE_DIR/adhoc-ping.sh" \
  "Create file: $ANSIBLE_DIR/adhoc-ping.sh"
check "adhoc-ping.sh contains ping command" 3 \
  "grep -q 'ansible.*all.*-m.*ping' $ANSIBLE_DIR/adhoc-ping.sh" \
  "Command should be: ansible all -m ping"
check "ping command works on node1" 2 \
  "ansible node1.example.com -m ping 2>/dev/null | grep -q 'SUCCESS'" \
  "Ensure SSH connectivity is working"
check "ping command works on node2" 1 \
  "ansible node2.example.com -m ping 2>/dev/null | grep -q 'SUCCESS'" \
  "Ensure SSH connectivity is working"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Gather Facts from Specific Group (8 pts)${NC}"
# ─────────────────────────────────────────────
check "adhoc-facts.sh file exists" 2 \
  "test -f $ANSIBLE_DIR/adhoc-facts.sh" \
  "Create file: $ANSIBLE_DIR/adhoc-facts.sh"
check "adhoc-facts.sh contains setup command" 3 \
  "grep -q 'ansible.*webservers.*-m.*setup' $ANSIBLE_DIR/adhoc-facts.sh" \
  "Command should be: ansible webservers -m setup"
check "setup module works on webservers" 3 \
  "ansible webservers -m setup 2>/dev/null | grep -q 'ansible_facts'" \
  "Ensure webservers group is defined correctly"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Install Package with Ad-hoc Command (8 pts)${NC}"
# ─────────────────────────────────────────────
check "adhoc-install.sh file exists" 2 \
  "test -f $ANSIBLE_DIR/adhoc-install.sh" \
  "Create file: $ANSIBLE_DIR/adhoc-install.sh"
check "adhoc-install.sh contains dnf command" 2 \
  "grep -q 'ansible.*all.*-m.*dnf.*tree' $ANSIBLE_DIR/adhoc-install.sh && (grep -q 'become' $ANSIBLE_DIR/adhoc-install.sh || grep -q -- '-b' $ANSIBLE_DIR/adhoc-install.sh)" \
  "Command should use: ansible all -m dnf -a 'name=tree state=present' --become (or -b)"
ansible_check "tree package installed on node1" 2 \
  "node1.example.com" "command" "rpm -q tree" "tree-" \
  "Run: ansible all -m dnf -a 'name=tree state=present' --become"
ansible_check "tree package installed on node2" 2 \
  "node2.example.com" "command" "rpm -q tree" "tree-" \
  "Package should be installed on all nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Create Directory with Ad-hoc Command (8 pts)${NC}"
# ─────────────────────────────────────────────
check "adhoc-mkdir.sh file exists" 2 \
  "test -f $ANSIBLE_DIR/adhoc-mkdir.sh" \
  "Create file: $ANSIBLE_DIR/adhoc-mkdir.sh"
check "adhoc-mkdir.sh contains file module command" 2 \
  "grep -q 'ansible.*all.*-m.*file' $ANSIBLE_DIR/adhoc-mkdir.sh && grep -q '/opt/ansible-test' $ANSIBLE_DIR/adhoc-mkdir.sh" \
  "Use: ansible all -m file -a 'path=/opt/ansible-test state=directory mode=0755' --become"
ansible_check "directory exists on node1" 2 \
  "node1.example.com" "stat" "path=/opt/ansible-test" "isdir.*True" \
  "Directory should exist with mode 0755"
ansible_check "directory exists on node2" 2 \
  "node2.example.com" "stat" "path=/opt/ansible-test" "isdir.*True" \
  "Directory should exist on all nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — Copy File with Ad-hoc Command (8 pts)${NC}"
# ─────────────────────────────────────────────
check "test.txt source file exists" 2 \
  "test -f $ANSIBLE_DIR/test.txt" \
  "Create file: echo 'Hello Ansible' > test.txt"
check "adhoc-copy.sh file exists" 2 \
  "test -f $ANSIBLE_DIR/adhoc-copy.sh" \
  "Create file: $ANSIBLE_DIR/adhoc-copy.sh"
check "adhoc-copy.sh contains copy command" 1 \
  "grep -q 'ansible.*all.*-m.*copy' $ANSIBLE_DIR/adhoc-copy.sh && grep -q 'test.txt' $ANSIBLE_DIR/adhoc-copy.sh" \
  "Use: ansible all -m copy -a 'src=test.txt dest=/tmp/test.txt'"
ansible_check "file copied to node1" 2 \
  "node1.example.com" "command" "cat /tmp/test.txt" "Hello Ansible" \
  "File should contain 'Hello Ansible'"
ansible_check "file copied to node2" 1 \
  "node2.example.com" "command" "cat /tmp/test.txt" "Hello Ansible" \
  "File should be copied to all nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — Host Patterns - Wildcards (8 pts)${NC}"
# ─────────────────────────────────────────────
check "inventory-patterns file exists" 2 \
  "test -f $ANSIBLE_DIR/inventory-patterns" \
  "Create file: $ANSIBLE_DIR/inventory-patterns"
check "inventory-patterns contains web hosts" 2 \
  "grep -q 'web1.example.com' $ANSIBLE_DIR/inventory-patterns && grep -q 'web2.example.com' $ANSIBLE_DIR/inventory-patterns" \
  "Define hosts: web1.example.com and web2.example.com"
check "inventory-patterns contains db hosts" 2 \
  "grep -q 'db1.example.com' $ANSIBLE_DIR/inventory-patterns && grep -q 'db2.example.com' $ANSIBLE_DIR/inventory-patterns" \
  "Define hosts: db1.example.com and db2.example.com"
check "inventory-patterns uses wildcard patterns" 2 \
  "grep -q 'web\*.example.com' $ANSIBLE_DIR/inventory-patterns && grep -q 'db\*.example.com' $ANSIBLE_DIR/inventory-patterns" \
  "Use patterns: web*.example.com and db*.example.com in group definitions"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — Host Patterns - Ranges (8 pts)${NC}"
# ─────────────────────────────────────────────
check "inventory-ranges file exists" 2 \
  "test -f $ANSIBLE_DIR/inventory-ranges" \
  "Create file: $ANSIBLE_DIR/inventory-ranges"
check "inventory-ranges uses range notation" 3 \
  "grep -q 'server\[1:4\].example.com' $ANSIBLE_DIR/inventory-ranges" \
  "Use range: server[1:4].example.com"
check "[app] group uses range" 2 \
  "grep -A1 '^\[app\]' $ANSIBLE_DIR/inventory-ranges | grep -q 'server\[1:2\].example.com'" \
  "Define [app] with server[1:2].example.com"
check "[cache] group uses range" 1 \
  "grep -A1 '^\[cache\]' $ANSIBLE_DIR/inventory-ranges | grep -q 'server\[3:4\].example.com'" \
  "Define [cache] with server[3:4].example.com"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — Group Variables (8 pts)${NC}"
# ─────────────────────────────────────────────
check "group_vars directory exists" 2 \
  "test -d $ANSIBLE_DIR/group_vars" \
  "Create directory: mkdir -p group_vars"
check "group_vars/webservers.yml exists" 2 \
  "test -f $ANSIBLE_DIR/group_vars/webservers.yml" \
  "Create file: group_vars/webservers.yml"
check "http_port variable defined" 2 \
  "grep -q 'http_port:.*80' $ANSIBLE_DIR/group_vars/webservers.yml" \
  "Add: http_port: 80"
check "max_clients variable defined" 2 \
  "grep -q 'max_clients:.*200' $ANSIBLE_DIR/group_vars/webservers.yml" \
  "Add: max_clients: 200"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — Host Variables (8 pts)${NC}"
# ─────────────────────────────────────────────
check "host_vars directory exists" 2 \
  "test -d $ANSIBLE_DIR/host_vars" \
  "Create directory: mkdir -p host_vars"
check "host_vars/node1.example.com.yml exists" 2 \
  "test -f $ANSIBLE_DIR/host_vars/node1.example.com.yml" \
  "Create file: host_vars/node1.example.com.yml"
check "server_role variable defined" 2 \
  "grep -q 'server_role:.*primary' $ANSIBLE_DIR/host_vars/node1.example.com.yml" \
  "Add: server_role: primary"
check "backup_enabled variable defined" 2 \
  "grep -q 'backup_enabled:.*true' $ANSIBLE_DIR/host_vars/node1.example.com.yml" \
  "Add: backup_enabled: true"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 12 — Parent and Child Groups (8 pts)${NC}"
# ─────────────────────────────────────────────
check "inventory-hierarchy file exists" 2 \
  "test -f $ANSIBLE_DIR/inventory-hierarchy" \
  "Create file: $ANSIBLE_DIR/inventory-hierarchy"
check "[web] group defined" 2 \
  "grep -A1 '^\[web\]' $ANSIBLE_DIR/inventory-hierarchy | grep -q 'node1.example.com'" \
  "Define [web] group with node1"
check "[db] group defined" 2 \
  "grep -A1 '^\[db\]' $ANSIBLE_DIR/inventory-hierarchy | grep -q 'node2.example.com'" \
  "Define [db] group with node2"
check "[production:children] parent group defined" 2 \
  "grep -q '^\[production:children\]' $ANSIBLE_DIR/inventory-hierarchy && grep -A2 '^\[production:children\]' $ANSIBLE_DIR/inventory-hierarchy | grep -q 'web' && grep -A2 '^\[production:children\]' $ANSIBLE_DIR/inventory-hierarchy | grep -q 'db'" \
  "Define [production:children] with web and db"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 13 — Inventory Variables in INI Format (8 pts)${NC}"
# ─────────────────────────────────────────────
check "inventory-vars file exists" 2 \
  "test -f $ANSIBLE_DIR/inventory-vars" \
  "Create file: $ANSIBLE_DIR/inventory-vars"
check "node1 has ansible_port variable" 2 \
  "grep 'node1.example.com' $ANSIBLE_DIR/inventory-vars | grep -q 'ansible_port=22'" \
  "Add: node1.example.com ansible_port=22"
check "node2 has ansible_port variable" 2 \
  "grep 'node2.example.com' $ANSIBLE_DIR/inventory-vars | grep -q 'ansible_port=22'" \
  "Add: node2.example.com ansible_port=22"
check "[all:vars] section with ansible_user" 2 \
  "grep -q '^\[all:vars\]' $ANSIBLE_DIR/inventory-vars && grep -A1 '^\[all:vars\]' $ANSIBLE_DIR/inventory-vars | grep -q 'ansible_user=student'" \
  "Add [all:vars] section with ansible_user=student"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 14 — List Inventory Hosts (8 pts)${NC}"
# ─────────────────────────────────────────────
check "adhoc-list-hosts.sh file exists" 3 \
  "test -f $ANSIBLE_DIR/adhoc-list-hosts.sh" \
  "Create file: $ANSIBLE_DIR/adhoc-list-hosts.sh"
check "adhoc-list-hosts.sh contains ansible-inventory command" 3 \
  "grep -q 'ansible-inventory.*--list' $ANSIBLE_DIR/adhoc-list-hosts.sh" \
  "Use: ansible-inventory --list"
check "ansible-inventory command works" 2 \
  "ansible-inventory --list 2>/dev/null | grep -q 'node1.example.com'" \
  "Ensure inventory file is configured correctly"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 15 — Verify Inventory Structure (8 pts)${NC}"
# ─────────────────────────────────────────────
check "adhoc-graph.sh file exists" 3 \
  "test -f $ANSIBLE_DIR/adhoc-graph.sh" \
  "Create file: $ANSIBLE_DIR/adhoc-graph.sh"
check "adhoc-graph.sh contains graph command" 3 \
  "grep -q 'ansible-inventory.*--graph' $ANSIBLE_DIR/adhoc-graph.sh" \
  "Use: ansible-inventory --graph"
check "ansible-inventory graph command works" 2 \
  "ansible-inventory --graph 2>/dev/null | grep -q '@all'" \
  "Command should display inventory hierarchy"

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
  echo -e "  ${GREEN}Congratulations!${NC} You've mastered Ansible inventory basics."
else
  echo -e "  ${RED}${BOLD}✗ FAIL${NC} — You scored ${BOLD}${PASS}/${TOTAL}${NC} points (${PERCENTAGE}%)"
  echo ""
  echo -e "  ${YELLOW}You need 70% to pass (84/120 points).${NC}"
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
  echo -e "    bash ~/exams/thematic/playbooks-fundamentals/START.sh"
elif [ $PERCENTAGE -ge 70 ]; then
  echo -e "  ${GREEN}✓${NC} Good job! Review failed tasks and try:"
  echo -e "    bash ~/exams/thematic/playbooks-fundamentals/START.sh"
else
  echo -e "  ${YELLOW}→${NC} Review the README.md for solutions"
  echo -e "  ${YELLOW}→${NC} Practice the failed tasks"
  echo -e "  ${YELLOW}→${NC} Retake this exam when ready"
fi

echo ""
echo -e "${CYAN}Resources:${NC}"
echo -e "  • Review solutions: cat ~/exams/thematic/inventory-basics/README.md | less"
echo -e "  • Ansible docs: ansible-doc <module_name>"
echo -e "  • Inventory guide: ansible-doc -t inventory -l"
echo ""

# Made with Bob

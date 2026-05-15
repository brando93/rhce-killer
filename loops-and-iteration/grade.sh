#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Loops and Iteration Grader
# Run this after completing all tasks to see your score.
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

EXAM_NAME="loops-and-iteration"
EXAM_TITLE="Loops And Iteration"
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
echo -e "${BOLD}Task 01 — Basic Loop with Simple List (10 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-basic.yml exists" 2 \
  "test -f $ANSIBLE_DIR/loop-basic.yml" \
  "Create playbook: loop-basic.yml"
check "playbook uses loop keyword" 2 \
  "grep -q 'loop:' $ANSIBLE_DIR/loop-basic.yml" \
  "Use: loop: ['alice', 'bob', 'charlie']"
ansible_check "user alice created on node1" 2 \
  "node1.example.com" "command" "id alice" "alice" \
  "Run playbook to create users"
ansible_check "user bob created on node1" 2 \
  "node1.example.com" "command" "id bob" "bob" \
  "User bob should be created"
ansible_check "user charlie created on node1" 2 \
  "node1.example.com" "command" "id charlie" "charlie" \
  "User charlie should be created"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — Loop with Package Installation (12 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-packages.yml exists" 2 \
  "test -f $ANSIBLE_DIR/loop-packages.yml" \
  "Create playbook: loop-packages.yml"
check "playbook uses loop with packages" 2 \
  "grep -q 'loop:' $ANSIBLE_DIR/loop-packages.yml && grep -q 'httpd' $ANSIBLE_DIR/loop-packages.yml" \
  "Use loop to install packages"
ansible_check "httpd installed on node1" 3 \
  "node1.example.com" "command" "rpm -q httpd" "httpd-" \
  "Run playbook to install packages"
ansible_check "firewalld installed on node1" 3 \
  "node1.example.com" "command" "rpm -q firewalld" "firewalld-" \
  "Install firewalld package"
ansible_check "vim-enhanced installed on node1" 2 \
  "node1.example.com" "command" "rpm -q vim-enhanced" "vim-enhanced-" \
  "Install vim-enhanced package"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — Loop with File Creation (12 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-files.yml exists" 2 \
  "test -f $ANSIBLE_DIR/loop-files.yml" \
  "Create playbook: loop-files.yml"
check "playbook uses loop with paths" 2 \
  "grep -q 'loop:' $ANSIBLE_DIR/loop-files.yml && grep -q '/opt/app' $ANSIBLE_DIR/loop-files.yml" \
  "Use loop with directory paths"
ansible_check "/opt/app1 exists on node1" 3 \
  "node1.example.com" "stat" "path=/opt/app1" "isdir.*True" \
  "Run playbook to create directories"
ansible_check "/opt/app2 exists on node1" 3 \
  "node1.example.com" "stat" "path=/opt/app2" "isdir.*True" \
  "Create /opt/app2 directory"
ansible_check "/opt/app3 exists on node1" 2 \
  "node1.example.com" "stat" "path=/opt/app3" "isdir.*True" \
  "Create /opt/app3 directory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Loop with Dictionary (15 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-dict.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-dict.yml" \
  "Create playbook: loop-dict.yml"
check "playbook uses loop with dictionaries" 3 \
  "grep -q 'loop:' $ANSIBLE_DIR/loop-dict.yml && grep -q 'name:' $ANSIBLE_DIR/loop-dict.yml && grep -q 'uid:' $ANSIBLE_DIR/loop-dict.yml" \
  "Use loop with list of dictionaries"
check "playbook uses item.name and item.uid" 2 \
  "grep -q 'item.name\|item.uid' $ANSIBLE_DIR/loop-dict.yml" \
  "Access dict values with {{ item.name }} and {{ item.uid }}"
ansible_check "developer user created with UID 2001" 3 \
  "node1.example.com" "command" "id developer" "uid=2001" \
  "Create user developer with UID 2001"
ansible_check "tester user created with UID 2002" 2 \
  "node1.example.com" "command" "id tester" "uid=2002" \
  "Create user tester with UID 2002"
ansible_check "admin user created with UID 2003" 2 \
  "node1.example.com" "command" "id admin" "uid=2003" \
  "Create user admin with UID 2003"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Loop with Conditional (15 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-when.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-when.yml" \
  "Create playbook: loop-when.yml"
check "playbook uses loop with when" 3 \
  "grep -q 'loop:' $ANSIBLE_DIR/loop-when.yml && grep -q 'when:' $ANSIBLE_DIR/loop-when.yml" \
  "Use loop with when condition"
check "playbook checks for http or nginx" 3 \
  "grep -q 'http.*in.*item\|nginx.*in.*item' $ANSIBLE_DIR/loop-when.yml" \
  "Use: when: \"'http' in item or 'nginx' in item\""
ansible_check "httpd installed on node1" 3 \
  "node1.example.com" "command" "rpm -q httpd" "httpd-" \
  "Install httpd (contains 'http')"
ansible_check "nginx installed on node1" 3 \
  "node1.example.com" "command" "rpm -q nginx" "nginx-" \
  "Install nginx (contains 'nginx')"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Loop with Register (15 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-register.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-register.yml" \
  "Create playbook: loop-register.yml"
check "playbook uses getent module" 3 \
  "grep -q 'getent:' $ANSIBLE_DIR/loop-register.yml" \
  "Use getent module with database: passwd"
check "playbook uses register" 3 \
  "grep -q 'register:' $ANSIBLE_DIR/loop-register.yml" \
  "Use: register: user_check"
check "playbook uses loop" 3 \
  "grep -q 'loop:' $ANSIBLE_DIR/loop-register.yml && grep -q 'root\|student\|nobody' $ANSIBLE_DIR/loop-register.yml" \
  "Loop over: ['root', 'student', 'nobody']"
check "playbook displays results" 3 \
  "grep -q 'debug:' $ANSIBLE_DIR/loop-register.yml" \
  "Use debug module to display registered results"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — Loop Control - Label (12 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-label.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-label.yml" \
  "Create playbook: loop-label.yml"
check "playbook uses loop_control" 3 \
  "grep -q 'loop_control:' $ANSIBLE_DIR/loop-label.yml" \
  "Use: loop_control:"
check "playbook uses label" 3 \
  "grep -q 'label:' $ANSIBLE_DIR/loop-label.yml" \
  "Use: label: \"{{ item.name }}\""
ansible_check "dev1 user created" 2 \
  "node1.example.com" "command" "id dev1" "uid=3001" \
  "Create user dev1 with UID 3001"
ansible_check "dev2 user created" 1 \
  "node1.example.com" "command" "id dev2" "uid=3002" \
  "Create user dev2 with UID 3002"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — Loop Control - Index (12 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-index.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-index.yml" \
  "Create playbook: loop-index.yml"
check "playbook uses loop_control with index_var" 3 \
  "grep -q 'loop_control:' $ANSIBLE_DIR/loop-index.yml && grep -q 'index_var:' $ANSIBLE_DIR/loop-index.yml" \
  "Use: loop_control: index_var: idx"
ansible_check "file-0.txt exists on node1" 2 \
  "node1.example.com" "stat" "path=/tmp/file-0.txt" "exists.*True" \
  "Create /tmp/file-0.txt using {{ idx }}"
ansible_check "file-1.txt exists on node1" 2 \
  "node1.example.com" "stat" "path=/tmp/file-1.txt" "exists.*True" \
  "Create /tmp/file-1.txt"
ansible_check "file-2.txt exists on node1" 2 \
  "node1.example.com" "stat" "path=/tmp/file-2.txt" "exists.*True" \
  "Create /tmp/file-2.txt"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — Loop Control - Pause (10 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-pause.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-pause.yml" \
  "Create playbook: loop-pause.yml"
check "playbook uses loop_control with pause" 4 \
  "grep -q 'loop_control:' $ANSIBLE_DIR/loop-pause.yml && grep -q 'pause:.*2' $ANSIBLE_DIR/loop-pause.yml" \
  "Use: loop_control: pause: 2"
check "playbook has three messages" 3 \
  "grep -c 'Message' $ANSIBLE_DIR/loop-pause.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
  "Loop over three messages"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — Nested Loop (18 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-nested.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-nested.yml" \
  "Create playbook: loop-nested.yml"
check "playbook uses nested loop" 3 \
  "grep -q 'loop:' $ANSIBLE_DIR/loop-nested.yml && grep -q 'item.0\|item.1' $ANSIBLE_DIR/loop-nested.yml" \
  "Use nested loop with {{ item.0 }} and {{ item.1 }}"
ansible_check "/home/alice/app1 exists" 3 \
  "node1.example.com" "stat" "path=/home/alice/app1" "isdir.*True" \
  "Create /home/alice/app1 directory"
ansible_check "/home/alice/app2 exists" 3 \
  "node1.example.com" "stat" "path=/home/alice/app2" "isdir.*True" \
  "Create /home/alice/app2 directory"
ansible_check "/home/bob/app1 exists" 3 \
  "node1.example.com" "stat" "path=/home/bob/app1" "isdir.*True" \
  "Create /home/bob/app1 directory"
ansible_check "/home/bob/app2 exists" 3 \
  "node1.example.com" "stat" "path=/home/bob/app2" "isdir.*True" \
  "Create /home/bob/app2 directory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — Loop with Subelements (18 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-subelements.yml exists" 4 \
  "test -f $ANSIBLE_DIR/loop-subelements.yml" \
  "Create playbook: loop-subelements.yml"
check "playbook uses subelements" 4 \
  "grep -q 'subelements' $ANSIBLE_DIR/loop-subelements.yml" \
  "Use: loop: \"{{ users | subelements('keys') }}\""
check "playbook defines users with keys" 3 \
  "grep -A5 'users:' $ANSIBLE_DIR/loop-subelements.yml | grep -q 'keys:'" \
  "Define users list with keys subelement"
check "playbook uses authorized_key module" 3 \
  "grep -q 'authorized_key:' $ANSIBLE_DIR/loop-subelements.yml" \
  "Use authorized_key module to add SSH keys"
ansible_check "alice user exists" 2 \
  "node1.example.com" "command" "id alice" "alice" \
  "Create alice user"
ansible_check "bob user exists" 2 \
  "node1.example.com" "command" "id bob" "bob" \
  "Create bob user"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 12 — Loop with dict2items (15 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-dict2items.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-dict2items.yml" \
  "Create playbook: loop-dict2items.yml"
check "playbook uses dict2items filter" 4 \
  "grep -q 'dict2items' $ANSIBLE_DIR/loop-dict2items.yml" \
  "Use: loop: \"{{ services | dict2items }}\""
check "playbook uses item.key and item.value" 3 \
  "grep -q 'item.key\|item.value' $ANSIBLE_DIR/loop-dict2items.yml" \
  "Access with {{ item.key }} and {{ item.value }}"
ansible_check "/tmp/services.txt exists" 2 \
  "node1.example.com" "stat" "path=/tmp/services.txt" "exists.*True" \
  "Create /tmp/services.txt file"
ansible_check "services.txt has http line" 2 \
  "node1.example.com" "command" "grep 'http:.*80' /tmp/services.txt" "http:.*80" \
  "File should contain: http: 80"
ansible_check "services.txt has https line" 1 \
  "node1.example.com" "command" "grep 'https:.*443' /tmp/services.txt" "https:.*443" \
  "File should contain: https: 443"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 13 — Loop with items2dict (15 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-items2dict.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-items2dict.yml" \
  "Create playbook: loop-items2dict.yml"
check "playbook has two loops" 3 \
  "grep -c 'loop:' $ANSIBLE_DIR/loop-items2dict.yml | awk '{if(\$1>=2) exit 0; else exit 1}'" \
  "Use two loops: one for groups, one for users"
check "playbook creates groups" 2 \
  "grep -q 'group:' $ANSIBLE_DIR/loop-items2dict.yml && grep -q 'developers\|testers' $ANSIBLE_DIR/loop-items2dict.yml" \
  "Create groups: developers and testers"
ansible_check "developers group exists" 2 \
  "node1.example.com" "command" "getent group developers" "developers" \
  "Create developers group"
ansible_check "testers group exists" 2 \
  "node1.example.com" "command" "getent group testers" "testers" \
  "Create testers group"
ansible_check "alice in developers group" 2 \
  "node1.example.com" "command" "id alice" "gid.*developers" \
  "Create alice with primary group developers"
ansible_check "bob in testers group" 1 \
  "node1.example.com" "command" "id bob" "gid.*testers" \
  "Create bob with primary group testers"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 14 — Loop with until (18 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-until.yml exists" 3 \
  "test -f $ANSIBLE_DIR/loop-until.yml" \
  "Create playbook: loop-until.yml"
check "playbook uses until keyword" 4 \
  "grep -q 'until:' $ANSIBLE_DIR/loop-until.yml" \
  "Use: until: result.stdout == 'active'"
check "playbook uses retries" 3 \
  "grep -q 'retries:' $ANSIBLE_DIR/loop-until.yml" \
  "Use: retries: 5"
check "playbook uses delay" 2 \
  "grep -q 'delay:' $ANSIBLE_DIR/loop-until.yml" \
  "Use: delay: 3"
check "playbook starts httpd first" 2 \
  "grep -q 'httpd' $ANSIBLE_DIR/loop-until.yml && grep -q 'started' $ANSIBLE_DIR/loop-until.yml" \
  "First task should start httpd service"
ansible_check "httpd is running on node1" 4 \
  "node1.example.com" "command" "systemctl is-active httpd" "active" \
  "Run playbook to start and verify httpd"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 15 — Complex Loop with Multiple Conditions (20 pts)${NC}"
# ─────────────────────────────────────────────
check "loop-complex.yml exists" 4 \
  "test -f $ANSIBLE_DIR/loop-complex.yml" \
  "Create playbook: loop-complex.yml"
check "playbook defines packages list" 3 \
  "grep -A10 'packages:' $ANSIBLE_DIR/loop-complex.yml | grep -q 'install:.*true'" \
  "Define packages list with install and service flags"
check "playbook has two tasks with loops" 3 \
  "grep -c 'loop:' $ANSIBLE_DIR/loop-complex.yml | awk '{if(\$1>=2) exit 0; else exit 1}'" \
  "Use two tasks: one for install, one for services"
check "first task uses when: item.install" 3 \
  "grep -A5 'dnf:' $ANSIBLE_DIR/loop-complex.yml | grep -q 'when:.*item.install'" \
  "Install packages: when: item.install"
check "second task uses when: item.service" 3 \
  "grep -A5 'service:' $ANSIBLE_DIR/loop-complex.yml | grep -q 'when:.*item.service'" \
  "Start services: when: item.service"
ansible_check "httpd installed and running" 2 \
  "node1.example.com" "command" "systemctl is-active httpd" "active" \
  "httpd should be installed and running"
ansible_check "firewalld installed and running" 2 \
  "node1.example.com" "command" "systemctl is-active firewalld" "active" \
  "firewalld should be installed and running"

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
  echo -e "  ${GREEN}Congratulations!${NC} You've mastered Ansible loops and iteration."
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
  echo -e "    bash ~/exams/thematic/blocks-and-error-handling/START.sh"
elif [ $PERCENTAGE -ge 70 ]; then
  echo -e "  ${GREEN}✓${NC} Good job! Review failed tasks and try:"
  echo -e "    bash ~/exams/thematic/blocks-and-error-handling/START.sh"
else
  echo -e "  ${YELLOW}→${NC} Review the README.md for solutions"
  echo -e "  ${YELLOW}→${NC} Practice the failed tasks"
  echo -e "  ${YELLOW}→${NC} Retake this exam when ready"
fi

echo ""
echo -e "${CYAN}Resources:${NC}"
echo -e "  • Review solutions: cat ~/exams/thematic/loops-and-iteration/README.md | less"
echo -e "  • Ansible docs: ansible-doc -t lookup (for subelements, dict2items)"
echo -e "  • Loops guide: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html"
echo ""

# Made with Bob

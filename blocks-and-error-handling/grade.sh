#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Blocks and Error Handling Grader
# Run this after completing all tasks to see your score.
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

EXAM_NAME="blocks-and-error-handling"
EXAM_TITLE="Blocks And Error Handling"
# ───── shared helpers (color codes, check(), counters, print_summary) ─
# Probe standard locations: local repo and ~/exams/lib on the control node.
for _LIB in \
    "$(dirname "$0")/../../lib/grade-helpers.sh" \
    "$(dirname "$0")/../scripts/lib/grade-helpers.sh" \
    "$(dirname "$0")/../lib/grade-helpers.sh"; do
    [ -f "$_LIB" ] && { source "$_LIB"; break; }
done
unset _LIB
TOTAL_POINTS=215


# ── Colors ──

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}   RHCE KILLER — ${EXAM_TITLE} Results${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# ─────────────────────────────────────────────
echo -e "${BOLD}Task 01 — Basic Block Structure (10 pts)${NC}"
# ─────────────────────────────────────────────
check "block-basic.yml exists" 2 \
  "test -f $ANSIBLE_DIR/block-basic.yml" \
  "Create playbook: block-basic.yml"
check "playbook uses block keyword" 3 \
  "grep -q 'block:' $ANSIBLE_DIR/block-basic.yml" \
  "Use: block:"
ansible_check "/opt/app directory exists" 3 \
  "node1.example.com" "stat" "path=/opt/app" "isdir.*True" \
  "Run playbook to create directory"
ansible_check "/opt/app/config.txt exists" 2 \
  "node1.example.com" "command" "cat /opt/app/config.txt" "Configuration" \
  "Create file with content 'Configuration'"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — Block with Rescue (15 pts)${NC}"
# ─────────────────────────────────────────────
check "block-rescue.yml exists" 3 \
  "test -f $ANSIBLE_DIR/block-rescue.yml" \
  "Create playbook: block-rescue.yml"
check "playbook uses block and rescue" 4 \
  "grep -q 'block:' $ANSIBLE_DIR/block-rescue.yml && grep -q 'rescue:' $ANSIBLE_DIR/block-rescue.yml" \
  "Use: block: and rescue:"
check "playbook tries to install fake package" 2 \
  "grep -q 'fake-package' $ANSIBLE_DIR/block-rescue.yml" \
  "Block should try to install fake-package-xyz"
ansible_check "httpd installed via rescue" 6 \
  "node1.example.com" "command" "rpm -q httpd" "httpd-" \
  "Rescue should install httpd when block fails"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — Block with Always (15 pts)${NC}"
# ─────────────────────────────────────────────
check "block-always.yml exists" 3 \
  "test -f $ANSIBLE_DIR/block-always.yml" \
  "Create playbook: block-always.yml"
check "playbook uses block and always" 4 \
  "grep -q 'block:' $ANSIBLE_DIR/block-always.yml && grep -q 'always:' $ANSIBLE_DIR/block-always.yml" \
  "Use: block: and always:"
check "always section has debug message" 3 \
  "grep -A3 'always:' $ANSIBLE_DIR/block-always.yml | grep -q 'This always runs'" \
  "Always section should display 'This always runs'"
ansible_check "httpd service is running" 5 \
  "node1.example.com" "command" "systemctl is-active httpd" "active" \
  "Block should start httpd service"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Complete Block/Rescue/Always (18 pts)${NC}"
# ─────────────────────────────────────────────
check "block-complete.yml exists" 3 \
  "test -f $ANSIBLE_DIR/block-complete.yml" \
  "Create playbook: block-complete.yml"
check "playbook uses all three sections" 5 \
  "grep -q 'block:' $ANSIBLE_DIR/block-complete.yml && grep -q 'rescue:' $ANSIBLE_DIR/block-complete.yml && grep -q 'always:' $ANSIBLE_DIR/block-complete.yml" \
  "Use: block:, rescue:, and always:"
ansible_check "/tmp/dest.txt exists" 5 \
  "node1.example.com" "stat" "path=/tmp/dest.txt" "exists.*True" \
  "Rescue should create and copy file"
ansible_check "/tmp/dest.txt has correct content" 5 \
  "node1.example.com" "command" "cat /tmp/dest.txt" "Created by rescue" \
  "File should contain 'Created by rescue'"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Ignore Errors (12 pts)${NC}"
# ─────────────────────────────────────────────
check "ignore-errors.yml exists" 3 \
  "test -f $ANSIBLE_DIR/ignore-errors.yml" \
  "Create playbook: ignore-errors.yml"
check "playbook uses ignore_errors" 4 \
  "grep -q 'ignore_errors:.*true' $ANSIBLE_DIR/ignore-errors.yml" \
  "Use: ignore_errors: true"
check "playbook tries to stop fake service" 2 \
  "grep -q 'fake-service' $ANSIBLE_DIR/ignore-errors.yml" \
  "Try to stop non-existent service"
check "playbook has continuation message" 3 \
  "grep -q 'Continuing despite error' $ANSIBLE_DIR/ignore-errors.yml" \
  "Second task should display continuation message"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Force Handlers (15 pts)${NC}"
# ─────────────────────────────────────────────
check "force-handlers.yml exists" 3 \
  "test -f $ANSIBLE_DIR/force-handlers.yml" \
  "Create playbook: force-handlers.yml"
check "playbook uses force_handlers" 4 \
  "grep -q 'force_handlers:.*true' $ANSIBLE_DIR/force-handlers.yml" \
  "Use: force_handlers: true at play level"
check "playbook has notify" 2 \
  "grep -q 'notify:' $ANSIBLE_DIR/force-handlers.yml" \
  "Use notify to trigger handler"
check "playbook has handlers section" 3 \
  "grep -q 'handlers:' $ANSIBLE_DIR/force-handlers.yml" \
  "Define handlers: section"
check "playbook has failing task" 3 \
  "grep -q '/bin/false' $ANSIBLE_DIR/force-handlers.yml" \
  "Use command: /bin/false to force failure"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — Assert Module (15 pts)${NC}"
# ─────────────────────────────────────────────
check "assert-basic.yml exists" 3 \
  "test -f $ANSIBLE_DIR/assert-basic.yml" \
  "Create playbook: assert-basic.yml"
check "playbook uses assert module" 4 \
  "grep -q 'assert:' $ANSIBLE_DIR/assert-basic.yml" \
  "Use: assert: module"
check "playbook checks memory" 3 \
  "grep -q 'ansible_memtotal_mb' $ANSIBLE_DIR/assert-basic.yml" \
  "Check: ansible_memtotal_mb > 1024"
check "playbook checks OS" 3 \
  "grep -q 'ansible_distribution.*Rocky' $ANSIBLE_DIR/assert-basic.yml" \
  "Check: ansible_distribution == 'Rocky'"
check "playbook uses that parameter" 2 \
  "grep -q 'that:' $ANSIBLE_DIR/assert-basic.yml" \
  "Use: that: parameter with conditions"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — Assert with Custom Message (12 pts)${NC}"
# ─────────────────────────────────────────────
check "assert-message.yml exists" 3 \
  "test -f $ANSIBLE_DIR/assert-message.yml" \
  "Create playbook: assert-message.yml"
check "playbook uses success_msg" 3 \
  "grep -q 'success_msg:' $ANSIBLE_DIR/assert-message.yml" \
  "Use: success_msg: parameter"
check "playbook uses fail_msg" 3 \
  "grep -q 'fail_msg:' $ANSIBLE_DIR/assert-message.yml" \
  "Use: fail_msg: parameter"
check "playbook checks hostname" 3 \
  "grep -q 'inventory_hostname.*node' $ANSIBLE_DIR/assert-message.yml" \
  "Check: 'node' in inventory_hostname"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — Fail Module (12 pts)${NC}"
# ─────────────────────────────────────────────
check "fail-module.yml exists" 3 \
  "test -f $ANSIBLE_DIR/fail-module.yml" \
  "Create playbook: fail-module.yml"
check "playbook uses stat module" 3 \
  "grep -q 'stat:' $ANSIBLE_DIR/fail-module.yml" \
  "Use: stat: module to check file"
check "playbook uses register" 2 \
  "grep -q 'register:' $ANSIBLE_DIR/fail-module.yml" \
  "Use: register: to capture result"
check "playbook uses fail module" 4 \
  "grep -q 'fail:' $ANSIBLE_DIR/fail-module.yml && grep -q 'when:' $ANSIBLE_DIR/fail-module.yml" \
  "Use: fail: module with when condition"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — Any Errors Fatal (15 pts)${NC}"
# ─────────────────────────────────────────────
check "any-errors-fatal.yml exists" 3 \
  "test -f $ANSIBLE_DIR/any-errors-fatal.yml" \
  "Create playbook: any-errors-fatal.yml"
check "playbook uses any_errors_fatal" 5 \
  "grep -q 'any_errors_fatal:.*true' $ANSIBLE_DIR/any-errors-fatal.yml" \
  "Use: any_errors_fatal: true at play level"
check "playbook fails on node1" 3 \
  "grep -q 'node1.example.com' $ANSIBLE_DIR/any-errors-fatal.yml" \
  "Fail only on node1.example.com"
check "playbook has second task" 4 \
  "grep -c 'name:' $ANSIBLE_DIR/any-errors-fatal.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
  "Have second task that should not execute"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — Max Fail Percentage (15 pts)${NC}"
# ─────────────────────────────────────────────
check "max-fail-percentage.yml exists" 3 \
  "test -f $ANSIBLE_DIR/max-fail-percentage.yml" \
  "Create playbook: max-fail-percentage.yml"
check "playbook uses max_fail_percentage" 5 \
  "grep -q 'max_fail_percentage:.*50' $ANSIBLE_DIR/max-fail-percentage.yml" \
  "Use: max_fail_percentage: 50"
check "playbook fails on node1 only" 3 \
  "grep -q 'node1.example.com' $ANSIBLE_DIR/max-fail-percentage.yml" \
  "Fail only on node1 (50% of hosts)"
check "playbook continues on node2" 4 \
  "grep -c 'name:' $ANSIBLE_DIR/max-fail-percentage.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
  "Second task should run on remaining hosts"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 12 — Block with Loop (18 pts)${NC}"
# ─────────────────────────────────────────────
check "block-loop.yml exists" 3 \
  "test -f $ANSIBLE_DIR/block-loop.yml" \
  "Create playbook: block-loop.yml"
check "playbook uses block with loop" 4 \
  "grep -q 'block:' $ANSIBLE_DIR/block-loop.yml && grep -q 'loop:' $ANSIBLE_DIR/block-loop.yml" \
  "Use: block: with loop:"
check "playbook uses rescue" 3 \
  "grep -q 'rescue:' $ANSIBLE_DIR/block-loop.yml" \
  "Use: rescue: for error handling"
ansible_check "/opt/app1 directory exists" 3 \
  "node1.example.com" "stat" "path=/opt/app1" "isdir.*True" \
  "Create /opt/app1 directory"
ansible_check "/opt/app2 directory exists" 3 \
  "node1.example.com" "stat" "path=/opt/app2" "isdir.*True" \
  "Create /opt/app2 directory"
ansible_check "/opt/app3 directory exists" 2 \
  "node1.example.com" "stat" "path=/opt/app3" "isdir.*True" \
  "Create /opt/app3 directory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 13 — Nested Blocks (18 pts)${NC}"
# ─────────────────────────────────────────────
check "block-nested.yml exists" 3 \
  "test -f $ANSIBLE_DIR/block-nested.yml" \
  "Create playbook: block-nested.yml"
check "playbook has nested blocks" 5 \
  "grep -c 'block:' $ANSIBLE_DIR/block-nested.yml | awk '{if(\$1>=2) exit 0; else exit 1}'" \
  "Use nested block structures"
check "playbook has multiple rescues" 3 \
  "grep -c 'rescue:' $ANSIBLE_DIR/block-nested.yml | awk '{if(\$1>=2) exit 0; else exit 1}'" \
  "Each block should have its own rescue"
ansible_check "httpd installed" 3 \
  "node1.example.com" "command" "rpm -q httpd" "httpd-" \
  "Outer block should install httpd"
ansible_check "httpd service running" 4 \
  "node1.example.com" "command" "systemctl is-active httpd" "active" \
  "Inner block should start httpd"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 14 — Changed When with Block (15 pts)${NC}"
# ─────────────────────────────────────────────
check "block-changed.yml exists" 3 \
  "test -f $ANSIBLE_DIR/block-changed.yml" \
  "Create playbook: block-changed.yml"
check "playbook uses block and always" 4 \
  "grep -q 'block:' $ANSIBLE_DIR/block-changed.yml && grep -q 'always:' $ANSIBLE_DIR/block-changed.yml" \
  "Use: block: and always:"
check "playbook uses changed_when: false" 4 \
  "grep -q 'changed_when:.*false' $ANSIBLE_DIR/block-changed.yml" \
  "Use: changed_when: false on command tasks"
check "playbook has echo and cat commands" 4 \
  "grep -q 'echo' $ANSIBLE_DIR/block-changed.yml && grep -q 'cat.*hostname' $ANSIBLE_DIR/block-changed.yml" \
  "Use commands: echo and cat /etc/hostname"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 15 — Complex Error Recovery (20 pts)${NC}"
# ─────────────────────────────────────────────
check "block-recovery.yml exists" 4 \
  "test -f $ANSIBLE_DIR/block-recovery.yml" \
  "Create playbook: block-recovery.yml"
check "playbook uses all three sections" 4 \
  "grep -q 'block:' $ANSIBLE_DIR/block-recovery.yml && grep -q 'rescue:' $ANSIBLE_DIR/block-recovery.yml && grep -q 'always:' $ANSIBLE_DIR/block-recovery.yml" \
  "Use: block:, rescue:, and always:"
check "playbook checks for nginx" 3 \
  "grep -q 'nginx' $ANSIBLE_DIR/block-recovery.yml" \
  "Check if nginx is installed/running"
check "rescue installs nginx" 3 \
  "grep -A5 'rescue:' $ANSIBLE_DIR/block-recovery.yml | grep -q 'nginx'" \
  "Rescue should install nginx"
ansible_check "nginx service running" 6 \
  "node1.example.com" "command" "systemctl is-active nginx" "active" \
  "Nginx should be running after recovery"

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
  echo -e "  ${GREEN}Congratulations!${NC} You've mastered Ansible error handling and blocks."
else
  echo -e "  ${RED}${BOLD}✗ FAIL${NC} — You scored ${BOLD}${PASS}/${TOTAL}${NC} points (${PERCENTAGE}%)"
  echo ""
  echo -e "  ${YELLOW}You need 70% to pass (151/215 points).${NC}"
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
echo -e "  • Review solutions: cat ~/exams/thematic/blocks-and-error-handling/README.md | less"
echo -e "  • Ansible docs: ansible-doc assert, ansible-doc fail"
echo -e "  • Error handling guide: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_error_handling.html"
echo ""

# Made with Bob

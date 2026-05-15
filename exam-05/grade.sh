#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# RHCE Killer — Exam 05 Grading Script
# Validates Troubleshooting and Advanced Ansible tasks
# ═══════════════════════════════════════════════════════════════════════════

# ───── shared helpers (color codes, check(), counters, print_summary) ─
# Probe standard locations: local repo and ~/exams/lib on the control node.
for _LIB in \
    "$(dirname "$0")/../../lib/grade-helpers.sh" \
    "$(dirname "$0")/../scripts/lib/grade-helpers.sh" \
    "$(dirname "$0")/../lib/grade-helpers.sh"; do
    [ -f "$_LIB" ] && { source "$_LIB"; break; }
done
unset _LIB


clear
echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                  RHCE KILLER — Exam 05 Grading                         ║"
echo "║           Troubleshooting and Advanced Techniques                      ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 01: Debug Broken Playbook (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 01: Debug Broken Playbook (15 pts) ━━━${NC}"

check "Playbook broken_syntax.yml exists" \
    3 \
    "file_exists /home/student/ansible/broken_syntax.yml" \
    "Create or fix /home/student/ansible/broken_syntax.yml"

check "Playbook passes syntax check" \
    5 \
    "ansible-playbook /home/student/ansible/broken_syntax.yml --syntax-check" \
    "Fix all syntax errors: missing colons, quotes, FQCN, indentation"

check "Playbook uses FQCN for modules" \
    3 \
    "grep -q 'ansible.builtin' /home/student/ansible/broken_syntax.yml" \
    "Use ansible.builtin.dnf, ansible.builtin.service, etc."

check "Playbook has proper handlers" \
    4 \
    "grep -q 'handlers:' /home/student/ansible/broken_syntax.yml && grep -q 'notify:' /home/student/ansible/broken_syntax.yml" \
    "Define handlers section and use notify to trigger them"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 02: Fix Logic Errors (20 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 02: Fix Logic Errors (20 pts) ━━━${NC}"

check "Playbook broken_logic.yml exists" \
    3 \
    "file_exists /home/student/ansible/broken_logic.yml" \
    "Create or fix /home/student/ansible/broken_logic.yml"

check "Uses correct conditional for production users" \
    5 \
    "grep -q \"'prod' in ansible_hostname\" /home/student/ansible/broken_logic.yml" \
    "Change condition to check for 'prod' in hostname, not 'dev'"

check "Development tools installed on dev servers only" \
    5 \
    "grep -A5 'Install development tools' /home/student/ansible/broken_logic.yml | grep -q \"env_type == 'development'\"" \
    "Install dev tools when env_type is 'development', not 'production'"

check "Dynamic env_type variable" \
    4 \
    "grep -q 'env_type.*prod.*development' /home/student/ansible/broken_logic.yml" \
    "Make env_type dynamic based on hostname"

check "Firewall uses immediate flag" \
    3 \
    "grep -q 'immediate:' /home/student/ansible/broken_logic.yml" \
    "Add immediate: true to firewalld tasks"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 03: Advanced Host Patterns (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 03: Advanced Host Patterns (15 pts) ━━━${NC}"

check "Playbook host_patterns.yml exists" \
    3 \
    "file_exists /home/student/ansible/host_patterns.yml" \
    "Create /home/student/ansible/host_patterns.yml"

check "Uses conditional for web except node1" \
    3 \
    "grep -q \"inventory_hostname != 'node1'\" /home/student/ansible/host_patterns.yml" \
    "Use when condition to exclude node1 from web group"

check "Uses delegate_to" \
    3 \
    "grep -q 'delegate_to:' /home/student/ansible/host_patterns.yml" \
    "Use delegate_to to run tasks on specific hosts"

check "Uses run_once" \
    3 \
    "grep -q 'run_once:' /home/student/ansible/host_patterns.yml" \
    "Use run_once for tasks that should execute only once"

check "Uses group membership checks" \
    3 \
    "grep -q \"in groups\" /home/student/ansible/host_patterns.yml" \
    "Check if host is in specific groups using 'in groups'"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 04: Includes vs Imports (20 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 04: Includes vs Imports (20 pts) ━━━${NC}"

check "Playbook includes_imports.yml exists" \
    3 \
    "file_exists /home/student/ansible/includes_imports.yml" \
    "Create /home/student/ansible/includes_imports.yml"

check "Tasks directory exists" \
    2 \
    "test -d /home/student/ansible/tasks" \
    "Create tasks/ directory for task files"

check "Uses import_tasks" \
    5 \
    "grep -q 'import_tasks:' /home/student/ansible/includes_imports.yml" \
    "Use import_tasks for static inclusion"

check "Uses include_tasks" \
    5 \
    "grep -q 'include_tasks:' /home/student/ansible/includes_imports.yml" \
    "Use include_tasks for dynamic inclusion"

check "Has task files in tasks directory" \
    5 \
    "ls /home/student/ansible/tasks/*.yml 2>/dev/null | wc -l | grep -q '[1-9]'" \
    "Create task files (common.yml, web.yml, etc.) in tasks/ directory"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 05: Advanced Tagging (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 05: Advanced Tagging (15 pts) ━━━${NC}"

check "Playbook tagged_deployment.yml exists" \
    2 \
    "file_exists /home/student/ansible/tagged_deployment.yml" \
    "Create /home/student/ansible/tagged_deployment.yml"

check "Uses 'always' tag" \
    3 \
    "grep -q 'tags: always' /home/student/ansible/tagged_deployment.yml || grep -q 'tags:.*always' /home/student/ansible/tagged_deployment.yml" \
    "Add tasks with 'always' tag"

check "Uses 'never' tag" \
    3 \
    "grep -q 'tags: never' /home/student/ansible/tagged_deployment.yml || grep -q 'tags:.*never' /home/student/ansible/tagged_deployment.yml" \
    "Add tasks with 'never' tag"

check "Uses hierarchical tags" \
    4 \
    "grep -c 'tags:' /home/student/ansible/tagged_deployment.yml | awk '{if(\$1>=5) exit 0; else exit 1}'" \
    "Use multiple tags: setup, deploy, config, verify, frontend, backend"

check "Playbook has tag combinations" \
    3 \
    "grep -A2 'tags:' /home/student/ansible/tagged_deployment.yml | grep -E '(frontend|backend|deploy|config)' | wc -l | awk '{if(\$1>=4) exit 0; else exit 1}'" \
    "Combine tags like frontend+deploy, backend+config"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 06: Task Delegation (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 06: Task Delegation (15 pts) ━━━${NC}"

check "Playbook delegation.yml exists" \
    3 \
    "file_exists /home/student/ansible/delegation.yml" \
    "Create /home/student/ansible/delegation.yml"

check "Uses delegate_to localhost" \
    3 \
    "grep -q 'delegate_to: localhost' /home/student/ansible/delegation.yml" \
    "Use delegate_to: localhost for control node tasks"

check "Uses local_action" \
    3 \
    "grep -q 'local_action:' /home/student/ansible/delegation.yml" \
    "Use local_action for tasks on control node"

check "Uses serial execution" \
    3 \
    "grep -q 'serial:' /home/student/ansible/delegation.yml" \
    "Use serial for rolling updates"

check "Uses run_once with delegation" \
    3 \
    "grep -A2 'run_once:' /home/student/ansible/delegation.yml | grep -q 'delegate_to'" \
    "Combine run_once with delegate_to"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 07: Magic Variables (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 07: Magic Variables (15 pts) ━━━${NC}"

check "Playbook magic_vars.yml exists" \
    2 \
    "file_exists /home/student/ansible/magic_vars.yml" \
    "Create /home/student/ansible/magic_vars.yml"

check "Uses hostvars" \
    3 \
    "grep -q 'hostvars' /home/student/ansible/magic_vars.yml" \
    "Use hostvars to access variables from other hosts"

check "Uses groups variable" \
    3 \
    "grep -q \"groups\\['\" /home/student/ansible/magic_vars.yml" \
    "Use groups to iterate over inventory groups"

check "Uses group_names" \
    2 \
    "grep -q 'group_names' /home/student/ansible/magic_vars.yml" \
    "Use group_names to check host's groups"

check "Uses inventory_hostname" \
    2 \
    "grep -q 'inventory_hostname' /home/student/ansible/magic_vars.yml" \
    "Use inventory_hostname in tasks"

check "Uses omit or lookup" \
    3 \
    "grep -qE '(omit|lookup)' /home/student/ansible/magic_vars.yml" \
    "Use omit for conditional parameters or lookup plugins"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 08: Best Practices (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 08: Best Practices (15 pts) ━━━${NC}"

check "Playbook best_practices.yml exists" \
    2 \
    "file_exists /home/student/ansible/best_practices.yml" \
    "Create /home/student/ansible/best_practices.yml"

check "Uses FQCN for all modules" \
    3 \
    "grep -c 'ansible.builtin\\|ansible.posix' /home/student/ansible/best_practices.yml | awk '{if(\$1>=5) exit 0; else exit 1}'" \
    "Use FQCN (ansible.builtin.*, ansible.posix.*) for all modules"

check "Uses changed_when" \
    2 \
    "grep -q 'changed_when:' /home/student/ansible/best_practices.yml" \
    "Use changed_when for command/shell tasks"

check "Uses block for error handling" \
    4 \
    "grep -q 'block:' /home/student/ansible/best_practices.yml && grep -q 'rescue:' /home/student/ansible/best_practices.yml" \
    "Use block/rescue/always for error handling"

check "Uses no_log for sensitive data" \
    2 \
    "grep -q 'no_log:' /home/student/ansible/best_practices.yml" \
    "Use no_log: true for tasks with sensitive data"

check "Playbook passes syntax check" \
    2 \
    "ansible-playbook /home/student/ansible/best_practices.yml --syntax-check" \
    "Ensure playbook has valid syntax"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 09: Performance Optimization (20 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 09: Performance Optimization (20 pts) ━━━${NC}"

check "Playbook optimized.yml exists" \
    3 \
    "file_exists /home/student/ansible/optimized.yml" \
    "Create /home/student/ansible/optimized.yml"

check "Uses gather_facts: false" \
    3 \
    "grep -q 'gather_facts: false' /home/student/ansible/optimized.yml" \
    "Disable automatic fact gathering where not needed"

check "Uses async and poll" \
    5 \
    "grep -q 'async:' /home/student/ansible/optimized.yml && grep -q 'poll:' /home/student/ansible/optimized.yml" \
    "Use async and poll for long-running tasks"

check "Uses strategy: free" \
    3 \
    "grep -q 'strategy: free' /home/student/ansible/optimized.yml" \
    "Use strategy: free for parallel execution"

check "Fact caching configured in ansible.cfg" \
    3 \
    "grep -q 'fact_caching' /home/student/ansible/ansible.cfg" \
    "Configure fact caching in ansible.cfg"

check "Pipelining enabled" \
    3 \
    "grep -q 'pipelining.*True' /home/student/ansible/ansible.cfg" \
    "Enable pipelining in ansible.cfg"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 10: Final Integration (25 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 10: Final Integration (25 pts) ━━━${NC}"

check "Playbook final_integration.yml exists" \
    3 \
    "file_exists /home/student/ansible/final_integration.yml" \
    "Create /home/student/ansible/final_integration.yml"

check "Has multiple plays" \
    4 \
    "grep -c '^- name:' /home/student/ansible/final_integration.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
    "Create at least 3 plays for different tiers"

check "Uses roles" \
    3 \
    "grep -q 'roles:' /home/student/ansible/final_integration.yml" \
    "Use roles in the playbook"

check "Has pre_tasks and post_tasks" \
    3 \
    "grep -q 'pre_tasks:' /home/student/ansible/final_integration.yml && grep -q 'post_tasks:' /home/student/ansible/final_integration.yml" \
    "Add pre_tasks and post_tasks sections"

check "Uses tags strategically" \
    3 \
    "grep -c 'tags:' /home/student/ansible/final_integration.yml | awk '{if(\$1>=5) exit 0; else exit 1}'" \
    "Use tags for different tiers and functions"

check "Has error handling" \
    3 \
    "grep -q 'block:' /home/student/ansible/final_integration.yml" \
    "Implement error handling with block/rescue"

check "Uses conditionals" \
    2 \
    "grep -q 'when:' /home/student/ansible/final_integration.yml" \
    "Use when conditions for logic"

check "Playbook passes syntax check" \
    4 \
    "ansible-playbook /home/student/ansible/final_integration.yml --syntax-check" \
    "Ensure playbook has valid syntax and structure"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# FINAL REPORT
# ═══════════════════════════════════════════════════════════════════════════
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                           FINAL SCORE                                  ║"
echo "╠════════════════════════════════════════════════════════════════════════╣"

PERCENTAGE=$((PASS * 100 / TOTAL))

if [ $PERCENTAGE -ge 70 ]; then
    COLOR=$GREEN
    STATUS="✓ PASS - EXPERT LEVEL"
elif [ $PERCENTAGE -ge 50 ]; then
    COLOR=$YELLOW
    STATUS="⚠ NEEDS IMPROVEMENT"
else
    COLOR=$RED
    STATUS="✗ FAIL"
fi

printf "║  Score: ${COLOR}%3d / %3d points (%3d%%)${NC}                                 ║\n" $PASS $TOTAL $PERCENTAGE
printf "║  Status: ${COLOR}%-30s${NC}                               ║\n" "$STATUS"
echo "╚════════════════════════════════════════════════════════════════════════╝"

if [ ${#FAILED_TASKS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Failed Tasks:${NC}"
    for task in "${FAILED_TASKS[@]}"; do
        echo -e "  ${RED}✗${NC} $task"
    done
    echo ""
    echo -e "${CYAN}💡 Advanced Tips:${NC}"
    echo "  • Use ansible-playbook --syntax-check for validation"
    echo "  • Use -vvv for detailed debugging output"
    echo "  • Check ansible-lint for best practices"
    echo "  • Test with --check mode before applying"
    echo "  • Review solutions: cat ~/exams/exam-05/README.md | less"
    echo "  • Use ansible-doc for module documentation"
fi

echo ""

if [ $PERCENTAGE -ge 70 ]; then
    echo -e "${GREEN}🎉 CONGRATULATIONS! You've mastered advanced Ansible techniques!${NC}"
    echo ""
    exit 0
else
    exit 1
fi

# Made with Bob

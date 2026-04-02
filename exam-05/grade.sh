#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# RHCE Killer — Exam 05 Grading Script
# Validates Troubleshooting and Advanced Ansible tasks
# ═══════════════════════════════════════════════════════════════════════════

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Scoring
TOTAL_SCORE=0
MAX_SCORE=150
FAILED_TASKS=()

# Helper function to check conditions
check() {
    local description="$1"
    local command="$2"
    local points="$3"
    local hint="$4"
    
    echo -ne "${CYAN}Checking:${NC} $description... "
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC} (+${points} pts)"
        TOTAL_SCORE=$((TOTAL_SCORE + points))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (0 pts)"
        if [ -n "$hint" ]; then
            echo -e "  ${YELLOW}💡 Hint:${NC} $hint"
        fi
        FAILED_TASKS+=("$description")
        return 1
    fi
}

file_exists() {
    [ -f "$1" ]
}

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
    "file_exists /home/student/ansible/broken_syntax.yml" \
    3 \
    "Create or fix /home/student/ansible/broken_syntax.yml"

check "Playbook passes syntax check" \
    "ansible-playbook /home/student/ansible/broken_syntax.yml --syntax-check" \
    5 \
    "Fix all syntax errors: missing colons, quotes, FQCN, indentation"

check "Playbook uses FQCN for modules" \
    "grep -q 'ansible.builtin' /home/student/ansible/broken_syntax.yml" \
    3 \
    "Use ansible.builtin.dnf, ansible.builtin.service, etc."

check "Playbook has proper handlers" \
    "grep -q 'handlers:' /home/student/ansible/broken_syntax.yml && grep -q 'notify:' /home/student/ansible/broken_syntax.yml" \
    4 \
    "Define handlers section and use notify to trigger them"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 02: Fix Logic Errors (20 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 02: Fix Logic Errors (20 pts) ━━━${NC}"

check "Playbook broken_logic.yml exists" \
    "file_exists /home/student/ansible/broken_logic.yml" \
    3 \
    "Create or fix /home/student/ansible/broken_logic.yml"

check "Uses correct conditional for production users" \
    "grep -q \"'prod' in ansible_hostname\" /home/student/ansible/broken_logic.yml" \
    5 \
    "Change condition to check for 'prod' in hostname, not 'dev'"

check "Development tools installed on dev servers only" \
    "grep -A5 'Install development tools' /home/student/ansible/broken_logic.yml | grep -q \"env_type == 'development'\"" \
    5 \
    "Install dev tools when env_type is 'development', not 'production'"

check "Dynamic env_type variable" \
    "grep -q 'env_type.*prod.*development' /home/student/ansible/broken_logic.yml" \
    4 \
    "Make env_type dynamic based on hostname"

check "Firewall uses immediate flag" \
    "grep -q 'immediate:' /home/student/ansible/broken_logic.yml" \
    3 \
    "Add immediate: true to firewalld tasks"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 03: Advanced Host Patterns (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 03: Advanced Host Patterns (15 pts) ━━━${NC}"

check "Playbook host_patterns.yml exists" \
    "file_exists /home/student/ansible/host_patterns.yml" \
    3 \
    "Create /home/student/ansible/host_patterns.yml"

check "Uses conditional for web except node1" \
    "grep -q \"inventory_hostname != 'node1'\" /home/student/ansible/host_patterns.yml" \
    3 \
    "Use when condition to exclude node1 from web group"

check "Uses delegate_to" \
    "grep -q 'delegate_to:' /home/student/ansible/host_patterns.yml" \
    3 \
    "Use delegate_to to run tasks on specific hosts"

check "Uses run_once" \
    "grep -q 'run_once:' /home/student/ansible/host_patterns.yml" \
    3 \
    "Use run_once for tasks that should execute only once"

check "Uses group membership checks" \
    "grep -q \"in groups\" /home/student/ansible/host_patterns.yml" \
    3 \
    "Check if host is in specific groups using 'in groups'"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 04: Includes vs Imports (20 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 04: Includes vs Imports (20 pts) ━━━${NC}"

check "Playbook includes_imports.yml exists" \
    "file_exists /home/student/ansible/includes_imports.yml" \
    3 \
    "Create /home/student/ansible/includes_imports.yml"

check "Tasks directory exists" \
    "test -d /home/student/ansible/tasks" \
    2 \
    "Create tasks/ directory for task files"

check "Uses import_tasks" \
    "grep -q 'import_tasks:' /home/student/ansible/includes_imports.yml" \
    5 \
    "Use import_tasks for static inclusion"

check "Uses include_tasks" \
    "grep -q 'include_tasks:' /home/student/ansible/includes_imports.yml" \
    5 \
    "Use include_tasks for dynamic inclusion"

check "Has task files in tasks directory" \
    "ls /home/student/ansible/tasks/*.yml 2>/dev/null | wc -l | grep -q '[1-9]'" \
    5 \
    "Create task files (common.yml, web.yml, etc.) in tasks/ directory"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 05: Advanced Tagging (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 05: Advanced Tagging (15 pts) ━━━${NC}"

check "Playbook tagged_deployment.yml exists" \
    "file_exists /home/student/ansible/tagged_deployment.yml" \
    2 \
    "Create /home/student/ansible/tagged_deployment.yml"

check "Uses 'always' tag" \
    "grep -q 'tags: always' /home/student/ansible/tagged_deployment.yml || grep -q 'tags:.*always' /home/student/ansible/tagged_deployment.yml" \
    3 \
    "Add tasks with 'always' tag"

check "Uses 'never' tag" \
    "grep -q 'tags: never' /home/student/ansible/tagged_deployment.yml || grep -q 'tags:.*never' /home/student/ansible/tagged_deployment.yml" \
    3 \
    "Add tasks with 'never' tag"

check "Uses hierarchical tags" \
    "grep -c 'tags:' /home/student/ansible/tagged_deployment.yml | awk '{if(\$1>=5) exit 0; else exit 1}'" \
    4 \
    "Use multiple tags: setup, deploy, config, verify, frontend, backend"

check "Playbook has tag combinations" \
    "grep -A2 'tags:' /home/student/ansible/tagged_deployment.yml | grep -E '(frontend|backend|deploy|config)' | wc -l | awk '{if(\$1>=4) exit 0; else exit 1}'" \
    3 \
    "Combine tags like frontend+deploy, backend+config"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 06: Task Delegation (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 06: Task Delegation (15 pts) ━━━${NC}"

check "Playbook delegation.yml exists" \
    "file_exists /home/student/ansible/delegation.yml" \
    3 \
    "Create /home/student/ansible/delegation.yml"

check "Uses delegate_to localhost" \
    "grep -q 'delegate_to: localhost' /home/student/ansible/delegation.yml" \
    3 \
    "Use delegate_to: localhost for control node tasks"

check "Uses local_action" \
    "grep -q 'local_action:' /home/student/ansible/delegation.yml" \
    3 \
    "Use local_action for tasks on control node"

check "Uses serial execution" \
    "grep -q 'serial:' /home/student/ansible/delegation.yml" \
    3 \
    "Use serial for rolling updates"

check "Uses run_once with delegation" \
    "grep -A2 'run_once:' /home/student/ansible/delegation.yml | grep -q 'delegate_to'" \
    3 \
    "Combine run_once with delegate_to"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 07: Magic Variables (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 07: Magic Variables (15 pts) ━━━${NC}"

check "Playbook magic_vars.yml exists" \
    "file_exists /home/student/ansible/magic_vars.yml" \
    2 \
    "Create /home/student/ansible/magic_vars.yml"

check "Uses hostvars" \
    "grep -q 'hostvars' /home/student/ansible/magic_vars.yml" \
    3 \
    "Use hostvars to access variables from other hosts"

check "Uses groups variable" \
    "grep -q \"groups\\['\" /home/student/ansible/magic_vars.yml" \
    3 \
    "Use groups to iterate over inventory groups"

check "Uses group_names" \
    "grep -q 'group_names' /home/student/ansible/magic_vars.yml" \
    2 \
    "Use group_names to check host's groups"

check "Uses inventory_hostname" \
    "grep -q 'inventory_hostname' /home/student/ansible/magic_vars.yml" \
    2 \
    "Use inventory_hostname in tasks"

check "Uses omit or lookup" \
    "grep -qE '(omit|lookup)' /home/student/ansible/magic_vars.yml" \
    3 \
    "Use omit for conditional parameters or lookup plugins"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 08: Best Practices (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 08: Best Practices (15 pts) ━━━${NC}"

check "Playbook best_practices.yml exists" \
    "file_exists /home/student/ansible/best_practices.yml" \
    2 \
    "Create /home/student/ansible/best_practices.yml"

check "Uses FQCN for all modules" \
    "grep -c 'ansible.builtin\\|ansible.posix' /home/student/ansible/best_practices.yml | awk '{if(\$1>=5) exit 0; else exit 1}'" \
    3 \
    "Use FQCN (ansible.builtin.*, ansible.posix.*) for all modules"

check "Uses changed_when" \
    "grep -q 'changed_when:' /home/student/ansible/best_practices.yml" \
    2 \
    "Use changed_when for command/shell tasks"

check "Uses block for error handling" \
    "grep -q 'block:' /home/student/ansible/best_practices.yml && grep -q 'rescue:' /home/student/ansible/best_practices.yml" \
    4 \
    "Use block/rescue/always for error handling"

check "Uses no_log for sensitive data" \
    "grep -q 'no_log:' /home/student/ansible/best_practices.yml" \
    2 \
    "Use no_log: true for tasks with sensitive data"

check "Playbook passes syntax check" \
    "ansible-playbook /home/student/ansible/best_practices.yml --syntax-check" \
    2 \
    "Ensure playbook has valid syntax"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 09: Performance Optimization (20 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 09: Performance Optimization (20 pts) ━━━${NC}"

check "Playbook optimized.yml exists" \
    "file_exists /home/student/ansible/optimized.yml" \
    3 \
    "Create /home/student/ansible/optimized.yml"

check "Uses gather_facts: false" \
    "grep -q 'gather_facts: false' /home/student/ansible/optimized.yml" \
    3 \
    "Disable automatic fact gathering where not needed"

check "Uses async and poll" \
    "grep -q 'async:' /home/student/ansible/optimized.yml && grep -q 'poll:' /home/student/ansible/optimized.yml" \
    5 \
    "Use async and poll for long-running tasks"

check "Uses strategy: free" \
    "grep -q 'strategy: free' /home/student/ansible/optimized.yml" \
    3 \
    "Use strategy: free for parallel execution"

check "Fact caching configured in ansible.cfg" \
    "grep -q 'fact_caching' /home/student/ansible/ansible.cfg" \
    3 \
    "Configure fact caching in ansible.cfg"

check "Pipelining enabled" \
    "grep -q 'pipelining.*True' /home/student/ansible/ansible.cfg" \
    3 \
    "Enable pipelining in ansible.cfg"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 10: Final Integration (25 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 10: Final Integration (25 pts) ━━━${NC}"

check "Playbook final_integration.yml exists" \
    "file_exists /home/student/ansible/final_integration.yml" \
    3 \
    "Create /home/student/ansible/final_integration.yml"

check "Has multiple plays" \
    "grep -c '^- name:' /home/student/ansible/final_integration.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
    4 \
    "Create at least 3 plays for different tiers"

check "Uses roles" \
    "grep -q 'roles:' /home/student/ansible/final_integration.yml" \
    3 \
    "Use roles in the playbook"

check "Has pre_tasks and post_tasks" \
    "grep -q 'pre_tasks:' /home/student/ansible/final_integration.yml && grep -q 'post_tasks:' /home/student/ansible/final_integration.yml" \
    3 \
    "Add pre_tasks and post_tasks sections"

check "Uses tags strategically" \
    "grep -c 'tags:' /home/student/ansible/final_integration.yml | awk '{if(\$1>=5) exit 0; else exit 1}'" \
    3 \
    "Use tags for different tiers and functions"

check "Has error handling" \
    "grep -q 'block:' /home/student/ansible/final_integration.yml" \
    3 \
    "Implement error handling with block/rescue"

check "Uses conditionals" \
    "grep -q 'when:' /home/student/ansible/final_integration.yml" \
    2 \
    "Use when conditions for logic"

check "Playbook passes syntax check" \
    "ansible-playbook /home/student/ansible/final_integration.yml --syntax-check" \
    4 \
    "Ensure playbook has valid syntax and structure"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# FINAL REPORT
# ═══════════════════════════════════════════════════════════════════════════
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                           FINAL SCORE                                  ║"
echo "╠════════════════════════════════════════════════════════════════════════╣"

PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))

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

printf "║  Score: ${COLOR}%3d / %3d points (%3d%%)${NC}                                 ║\n" $TOTAL_SCORE $MAX_SCORE $PERCENTAGE
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

#!/bin/bash

# RHCE Killer - Roles Advanced Grading Script
# Exam: Roles Advanced (20 tasks, 436 points)
# Passing score: 70% (305 points)


TOTAL_POINTS=0
MAX_POINTS=464
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
ROLES_DIR="$ANSIBLE_DIR/roles"

# Arrays to store results
declare -a FAILED_TASKS
declare -a FAILED_HINTS

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}RHCE Killer - Roles Advanced Grading${NC}"
echo -e "${CYAN}========================================${NC}\n"

echo -e "${YELLOW}Task 01: Role with include_role (20 pts)${NC}"
check "playbook dynamic-roles.yml exists" 5 \
    "test -f $ANSIBLE_DIR/dynamic-roles.yml" \
    "Create: dynamic-roles.yml playbook"

check "playbook uses include_role" 8 \
    "grep -q 'include_role:' $ANSIBLE_DIR/dynamic-roles.yml" \
    "Use: include_role module"

check "include_role has when clause" 7 \
    "grep -A 3 'include_role:' $ANSIBLE_DIR/dynamic-roles.yml | grep -q 'when:'" \
    "Add: when: condition to include_role"

echo ""
echo -e "${YELLOW}Task 02: Role with import_role (18 pts)${NC}"
check "playbook static-roles.yml exists" 5 \
    "test -f $ANSIBLE_DIR/static-roles.yml" \
    "Create: static-roles.yml playbook"

check "playbook uses import_role" 8 \
    "grep -q 'import_role:' $ANSIBLE_DIR/static-roles.yml" \
    "Use: import_role module"

check "import_role can use tags" 5 \
    "grep -A 3 'import_role:' $ANSIBLE_DIR/static-roles.yml | grep -q 'tags:\\|name:'" \
    "import_role works with tags"

echo ""
echo -e "${YELLOW}Task 03: Role Variable Precedence (22 pts)${NC}"
check "role config exists" 5 \
    "test -d $ROLES_DIR/config" \
    "Create: ansible-galaxy init config"

check "config has defaults/main.yml with app_port" 6 \
    "grep -q 'app_port:' $ROLES_DIR/config/defaults/main.yml" \
    "Define: app_port in defaults/main.yml"

check "config has vars/main.yml with app_port" 6 \
    "grep -q 'app_port:' $ROLES_DIR/config/vars/main.yml" \
    "Define: app_port in vars/main.yml"

check "playbook overrides app_port" 5 \
    "find $ANSIBLE_DIR -name '*.yml' -exec grep -l 'config' {} \\; | xargs grep -l 'app_port:' | head -1 | xargs test -f" \
    "Override: app_port in playbook"

echo ""
echo -e "${YELLOW}Task 04: Role with set_fact (20 pts)${NC}"
check "role dynamic exists" 5 \
    "test -d $ROLES_DIR/dynamic" \
    "Create: ansible-galaxy init dynamic"

check "dynamic uses set_fact" 10 \
    "grep -q 'set_fact:' $ROLES_DIR/dynamic/tasks/main.yml" \
    "Use: set_fact module in tasks"

check "set_fact creates dynamic variables" 5 \
    "grep -A 3 'set_fact:' $ROLES_DIR/dynamic/tasks/main.yml | grep -q ':'" \
    "Create variables with set_fact"

echo ""
echo -e "${YELLOW}Task 05: Role with register and set_fact (22 pts)${NC}"
check "role checker exists" 5 \
    "test -d $ROLES_DIR/checker" \
    "Create: ansible-galaxy init checker"

check "checker uses register" 8 \
    "grep -q 'register:' $ROLES_DIR/checker/tasks/main.yml" \
    "Use: register to capture output"

check "checker uses set_fact with registered var" 9 \
    "grep -q 'set_fact:' $ROLES_DIR/checker/tasks/main.yml" \
    "Use: set_fact to process registered data"

echo ""
echo -e "${YELLOW}Task 06: Role with include_vars (20 pts)${NC}"
check "role environment exists" 5 \
    "test -d $ROLES_DIR/environment" \
    "Create: ansible-galaxy init environment"

check "environment has vars/dev.yml" 5 \
    "test -f $ROLES_DIR/environment/vars/dev.yml" \
    "Create: vars/dev.yml"

check "environment has vars/prod.yml" 5 \
    "test -f $ROLES_DIR/environment/vars/prod.yml" \
    "Create: vars/prod.yml"

check "environment uses include_vars" 5 \
    "grep -q 'include_vars:' $ROLES_DIR/environment/tasks/main.yml" \
    "Use: include_vars to load var files"

echo ""
echo -e "${YELLOW}Task 07: Role with Nested Includes (22 pts)${NC}"
check "role complex exists" 5 \
    "test -d $ROLES_DIR/complex" \
    "Create: ansible-galaxy init complex"

check "complex has multiple task files" 8 \
    "ls $ROLES_DIR/complex/tasks/*.yml 2>/dev/null | wc -l | grep -q '[3-9]'" \
    "Create: multiple task files in tasks/"

check "main.yml includes other files" 9 \
    "grep -q 'include_tasks:\\|import_tasks:' $ROLES_DIR/complex/tasks/main.yml" \
    "Use: include_tasks or import_tasks"

echo ""
echo -e "${YELLOW}Task 08: Role with Pre and Post Tasks (20 pts)${NC}"
check "playbook ordered-execution.yml exists" 5 \
    "test -f $ANSIBLE_DIR/ordered-execution.yml" \
    "Create: ordered-execution.yml"

check "playbook has pre_tasks" 5 \
    "grep -q 'pre_tasks:' $ANSIBLE_DIR/ordered-execution.yml" \
    "Add: pre_tasks section"

check "playbook has post_tasks" 5 \
    "grep -q 'post_tasks:' $ANSIBLE_DIR/ordered-execution.yml" \
    "Add: post_tasks section"

check "playbook has roles section" 5 \
    "grep -q 'roles:' $ANSIBLE_DIR/ordered-execution.yml" \
    "Add: roles section between pre and post"

echo ""
echo -e "${YELLOW}Task 09: Role with Delegation (22 pts)${NC}"
check "role deploy exists" 5 \
    "test -d $ROLES_DIR/deploy" \
    "Create: ansible-galaxy init deploy"

check "deploy uses delegate_to" 12 \
    "grep -q 'delegate_to:' $ROLES_DIR/deploy/tasks/main.yml" \
    "Use: delegate_to in tasks"

check "delegate_to targets localhost" 5 \
    "grep 'delegate_to:' $ROLES_DIR/deploy/tasks/main.yml | grep -q 'localhost'" \
    "Delegate to: localhost"

echo ""
echo -e "${YELLOW}Task 10: Role with run_once (18 pts)${NC}"
check "role cluster exists" 5 \
    "test -d $ROLES_DIR/cluster" \
    "Create: ansible-galaxy init cluster"

check "cluster uses run_once" 10 \
    "grep -q 'run_once:' $ROLES_DIR/cluster/tasks/main.yml" \
    "Use: run_once: true"

check "run_once set to true" 3 \
    "grep 'run_once:' $ROLES_DIR/cluster/tasks/main.yml | grep -q 'true'" \
    "Set: run_once: true"

echo ""
echo -e "${YELLOW}Task 11: Role with Custom Facts (25 pts)${NC}"
check "role facts exists" 5 \
    "test -d $ROLES_DIR/facts" \
    "Create: ansible-galaxy init facts"

check "facts creates /etc/ansible/facts.d" 8 \
    "grep -q '/etc/ansible/facts.d' $ROLES_DIR/facts/tasks/main.yml" \
    "Create: /etc/ansible/facts.d directory"

check "facts creates custom fact file" 7 \
    "grep -q 'facts.d' $ROLES_DIR/facts/tasks/main.yml" \
    "Create: custom fact file in facts.d"

check "facts uses ansible_local" 5 \
    "grep -q 'ansible_local' $ROLES_DIR/facts/tasks/main.yml || test -f $ROLES_DIR/facts/files/*.fact" \
    "Use: ansible_local to access custom facts"

echo ""
echo -e "${YELLOW}Task 12: Role with Ansible Vault (22 pts)${NC}"
check "role secrets exists" 5 \
    "test -d $ROLES_DIR/secrets" \
    "Create: ansible-galaxy init secrets"

check "secrets has vars/vault.yml" 8 \
    "test -f $ROLES_DIR/secrets/vars/vault.yml" \
    "Create: vars/vault.yml"

check "vault.yml is encrypted" 9 \
    "head -n 1 $ROLES_DIR/secrets/vars/vault.yml | grep -q 'ANSIBLE_VAULT'" \
    "Encrypt: vars/vault.yml with ansible-vault"

echo ""
echo -e "${YELLOW}Task 13: Role with Complex Dependencies (25 pts)${NC}"
check "role application exists" 6 \
    "test -d $ROLES_DIR/application" \
    "Create: ansible-galaxy init application"

check "application has meta/main.yml" 6 \
    "test -f $ROLES_DIR/application/meta/main.yml" \
    "Create: meta/main.yml"

check "meta has dependencies" 8 \
    "grep -q 'dependencies:' $ROLES_DIR/application/meta/main.yml" \
    "Define: dependencies in meta/main.yml"

check "dependencies have parameters" 5 \
    "grep -A 10 'dependencies:' $ROLES_DIR/application/meta/main.yml | grep -q 'role:\\|name:'" \
    "Add: parameters to dependencies"

echo ""
echo -e "${YELLOW}Task 14: Role with allow_duplicates (20 pts)${NC}"
check "role logger exists" 5 \
    "test -d $ROLES_DIR/logger" \
    "Create: ansible-galaxy init logger"

check "logger has meta/main.yml" 5 \
    "test -f $ROLES_DIR/logger/meta/main.yml" \
    "Create: meta/main.yml"

check "meta has allow_duplicates" 10 \
    "grep -q 'allow_duplicates:' $ROLES_DIR/logger/meta/main.yml" \
    "Set: allow_duplicates: true"

echo ""
echo -e "${YELLOW}Task 15: Role with role_path (18 pts)${NC}"
check "ansible.cfg has roles_path" 10 \
    "grep -q 'roles_path' $ANSIBLE_DIR/ansible.cfg" \
    "Add: roles_path to ansible.cfg"

check "roles_path has multiple directories" 8 \
    "grep 'roles_path' $ANSIBLE_DIR/ansible.cfg | grep -q ':'" \
    "Set: multiple paths separated by colon"

echo ""
echo -e "${YELLOW}Task 16: Role with Galaxy Requirements (25 pts)${NC}"
check "requirements.yml exists" 8 \
    "test -f $ANSIBLE_DIR/requirements.yml" \
    "Create: requirements.yml"

check "requirements lists roles" 10 \
    "grep -q 'name:\\|src:' $ANSIBLE_DIR/requirements.yml" \
    "List: roles in requirements.yml"

check "requirements specifies versions" 7 \
    "grep -q 'version:' $ANSIBLE_DIR/requirements.yml" \
    "Specify: version for roles"

echo ""
echo -e "${YELLOW}Task 17: Role with Meta Runtime (20 pts)${NC}"
check "role with meta/runtime.yml exists" 8 \
    "find $ROLES_DIR -name 'runtime.yml' -path '*/meta/*' | head -1 | xargs test -f" \
    "Create: meta/runtime.yml in a role"

check "runtime.yml specifies ansible version" 7 \
    "find $ROLES_DIR -name 'runtime.yml' -path '*/meta/*' -exec grep -l 'requires_ansible' {} \\; | head -1 | xargs test -f" \
    "Specify: requires_ansible in runtime.yml"

check "runtime.yml lists collections" 5 \
    "find $ROLES_DIR -name 'runtime.yml' -path '*/meta/*' -exec grep -l 'collections' {} \\; | head -1 | xargs test -f" \
    "List: required collections"

echo ""
echo -e "${YELLOW}Task 18: Role with Argument Spec (25 pts)${NC}"
check "role with argument_specs.yml exists" 10 \
    "find $ROLES_DIR -name 'argument_specs.yml' -path '*/meta/*' | head -1 | xargs test -f" \
    "Create: meta/argument_specs.yml"

check "argument_specs defines required vars" 10 \
    "find $ROLES_DIR -name 'argument_specs.yml' -path '*/meta/*' -exec grep -l 'required' {} \\; | head -1 | xargs test -f" \
    "Define: required variables"

check "argument_specs specifies types" 5 \
    "find $ROLES_DIR -name 'argument_specs.yml' -path '*/meta/*' -exec grep -l 'type:' {} \\; | head -1 | xargs test -f" \
    "Specify: variable types"

echo ""
echo -e "${YELLOW}Task 19: Role with Collections (22 pts)${NC}"
check "role uses FQCN for modules" 10 \
    "find $ROLES_DIR -name 'main.yml' -path '*/tasks/*' -exec grep -l 'ansible\\.builtin\\.' {} \\; | head -1 | xargs test -f" \
    "Use: FQCN format (ansible.builtin.module)"

check "role uses multiple collections" 12 \
    "find $ROLES_DIR -name 'main.yml' -path '*/tasks/*' -exec grep -E 'ansible\\.(builtin|posix|utils)\\.' {} \\; | head -1 | grep -q '.'" \
    "Use: modules from different collections"

echo ""
echo -e "${YELLOW}Task 20: Complex Multi-Role Scenario (30 pts)${NC}"
check "complex infrastructure playbook exists" 6 \
    "find $ANSIBLE_DIR -name '*.yml' -exec grep -l 'roles:' {} \\; | xargs grep -l 'pre_tasks:' | head -1 | xargs test -f" \
    "Create: playbook with roles, pre_tasks, post_tasks"

check "playbook uses 5+ roles" 8 \
    "find $ANSIBLE_DIR -name '*.yml' -exec grep -A 20 'roles:' {} \\; | grep -E '^\\s*-\\s*(role:|name:)' | wc -l | grep -q '[5-9]'" \
    "Use: 5 or more roles"

check "playbook has tags" 6 \
    "find $ANSIBLE_DIR -name '*.yml' -exec grep -l 'tags:' {} \\; | head -1 | xargs test -f" \
    "Add: tags for selective execution"

check "playbook has conditionals" 5 \
    "find $ANSIBLE_DIR -name '*.yml' -exec grep -l 'when:' {} \\; | head -1 | xargs test -f" \
    "Add: conditional role application"

check "playbook demonstrates advanced concepts" 5 \
    "find $ANSIBLE_DIR -name '*.yml' -exec grep -l 'roles:' {} \\; | xargs grep -E 'pre_tasks:|post_tasks:|when:|tags:' | wc -l | grep -q '[4-9]'" \
    "Demonstrate: multiple advanced concepts"

echo ""
echo -e "${YELLOW}Task 21: phpinfo + Apache mod_proxy_balancer (28 pts)${NC}"
check "Role roles/phpinfo exists" 2 \
    "test -d $ANSIBLE_DIR/roles/phpinfo" \
    "Create with: ansible-galaxy init roles/phpinfo"

check "Role roles/balancer exists" 2 \
    "test -d $ANSIBLE_DIR/roles/balancer" \
    "Create with: ansible-galaxy init roles/balancer"

check "phpinfo template index.php.j2 exists" 2 \
    "test -f $ANSIBLE_DIR/roles/phpinfo/templates/index.php.j2" \
    "Create roles/phpinfo/templates/index.php.j2 with phpinfo()"

check "phpinfo template prints backend hostname" 2 \
    "grep -q 'Backend' $ANSIBLE_DIR/roles/phpinfo/templates/index.php.j2" \
    "Print 'Backend: {{ ansible_hostname }}' so balancer behavior is visible"

check "balancer template exists" 2 \
    "test -f $ANSIBLE_DIR/roles/balancer/templates/balancer.conf.j2" \
    "Create roles/balancer/templates/balancer.conf.j2"

check "balancer template uses mod_proxy_balancer syntax" 3 \
    "grep -q 'balancer://' $ANSIBLE_DIR/roles/balancer/templates/balancer.conf.j2" \
    "Use <Proxy \"balancer://mycluster\"> ... </Proxy>"

check "balancer template loops over groups['webservers']" 4 \
    "grep -qE \"for[[:space:]]+\\w+[[:space:]]+in[[:space:]]+groups\\\\['webservers'\\\\]\" $ANSIBLE_DIR/roles/balancer/templates/balancer.conf.j2" \
    "Loop: {% for host in groups['webservers'] %} ... {% endfor %}"

check "balancer template uses ProxyPass directives" 2 \
    "grep -q 'ProxyPass' $ANSIBLE_DIR/roles/balancer/templates/balancer.conf.j2" \
    "Add ProxyPass and ProxyPassReverse directives"

check "site.yml master playbook exists" 2 \
    "test -f $ANSIBLE_DIR/site.yml" \
    "Create site.yml with two plays: phpinfo on webservers, balancer on balancers"

check "site.yml targets webservers and balancers groups" 3 \
    "grep -q 'webservers' $ANSIBLE_DIR/site.yml && grep -q 'balancers' $ANSIBLE_DIR/site.yml" \
    "Each role goes to its own host group"

check "Both roles use firewalld to open http" 2 \
    "grep -qE 'firewalld' $ANSIBLE_DIR/roles/phpinfo/tasks/main.yml && grep -qE 'firewalld' $ANSIBLE_DIR/roles/balancer/tasks/main.yml" \
    "Open HTTP through firewalld in both roles"

check "Both roles notify restart httpd handler" 2 \
    "grep -q 'notify' $ANSIBLE_DIR/roles/phpinfo/tasks/main.yml && grep -q 'restart httpd' $ANSIBLE_DIR/roles/phpinfo/handlers/main.yml" \
    "Add notify: restart httpd and matching handler"

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
    echo -e "${YELLOW}You need $((305 - TOTAL_POINTS)) more points to pass.${NC}\n"
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
echo -e "2. Check roles in: $ROLES_DIR"
echo -e "3. Check playbooks in: $ANSIBLE_DIR"
echo -e "4. Advanced features: ${YELLOW}include_role, import_role, set_fact${NC}"
echo -e "5. Re-run: ${YELLOW}~/exams/thematic/roles-advanced/grade.sh${NC}\n"

exit 0

# Made with Bob

#!/bin/bash

# RHCE Killer - Roles Basics Grading Script
# Exam: Roles Basics (15 tasks, 263 points)
# Passing score: 70% (184 points)


TOTAL_POINTS=0
MAX_POINTS=263
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
TOTAL_TASKS=15

# Ansible directory
ANSIBLE_DIR="/home/student/ansible"
ROLES_DIR="$ANSIBLE_DIR/roles"

# Arrays to store results
declare -a FAILED_TASKS
declare -a FAILED_HINTS

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}RHCE Killer - Roles Basics Grading${NC}"
echo -e "${CYAN}========================================${NC}\n"

echo -e "${YELLOW}Task 01: Create Basic Role Structure (15 pts)${NC}"
check "role webserver exists" 4 \
    "test -d $ROLES_DIR/webserver" \
    "Create: ansible-galaxy init webserver"

check "webserver has tasks directory" 3 \
    "test -d $ROLES_DIR/webserver/tasks" \
    "Role should have tasks/ directory"

check "webserver has handlers directory" 2 \
    "test -d $ROLES_DIR/webserver/handlers" \
    "Role should have handlers/ directory"

check "webserver has templates directory" 2 \
    "test -d $ROLES_DIR/webserver/templates" \
    "Role should have templates/ directory"

check "webserver has defaults directory" 2 \
    "test -d $ROLES_DIR/webserver/defaults" \
    "Role should have defaults/ directory"

check "webserver has meta directory" 2 \
    "test -d $ROLES_DIR/webserver/meta" \
    "Role should have meta/ directory"

echo ""
echo -e "${YELLOW}Task 02: Role with Tasks (15 pts)${NC}"
check "role apache exists" 4 \
    "test -d $ROLES_DIR/apache" \
    "Create: ansible-galaxy init apache"

check "apache has tasks/main.yml" 3 \
    "test -f $ROLES_DIR/apache/tasks/main.yml" \
    "Create: tasks/main.yml in apache role"

check "apache tasks install httpd" 3 \
    "grep -q 'httpd' $ROLES_DIR/apache/tasks/main.yml" \
    "Add task to install httpd"

check "playbook use-apache.yml exists" 2 \
    "test -f $ANSIBLE_DIR/use-apache.yml" \
    "Create: use-apache.yml playbook"

ansible_check "httpd service running" 3 \
    "node1.example.com" "service" "name=httpd" "running" \
    "Service should be started and enabled"

echo ""
echo -e "${YELLOW}Task 03: Role with Handler (18 pts)${NC}"
check "role nginx exists" 4 \
    "test -d $ROLES_DIR/nginx" \
    "Create: ansible-galaxy init nginx"

check "nginx has handlers/main.yml" 4 \
    "test -f $ROLES_DIR/nginx/handlers/main.yml" \
    "Create: handlers/main.yml in nginx role"

check "nginx handler restarts service" 4 \
    "grep -q 'restart' $ROLES_DIR/nginx/handlers/main.yml && grep -q 'nginx' $ROLES_DIR/nginx/handlers/main.yml" \
    "Handler should restart nginx service"

check "nginx tasks notify handler" 3 \
    "grep -q 'notify:' $ROLES_DIR/nginx/tasks/main.yml" \
    "Task should notify handler"

ansible_check "nginx package installed" 3 \
    "node1.example.com" "command" "rpm -q nginx" "nginx-" \
    "Nginx should be installed"

echo ""
echo -e "${YELLOW}Task 04: Role with Template (20 pts)${NC}"
check "role webapp exists" 4 \
    "test -d $ROLES_DIR/webapp" \
    "Create: ansible-galaxy init webapp"

check "webapp has template index.html.j2" 5 \
    "test -f $ROLES_DIR/webapp/templates/index.html.j2" \
    "Create: templates/index.html.j2"

check "template uses inventory_hostname" 4 \
    "grep -q 'inventory_hostname' $ROLES_DIR/webapp/templates/index.html.j2" \
    "Template should use {{ inventory_hostname }}"

check "template uses app_env variable" 4 \
    "grep -q 'app_env' $ROLES_DIR/webapp/templates/index.html.j2" \
    "Template should use {{ app_env }}"

ansible_check "index.html deployed" 3 \
    "node1.example.com" "stat" "path=/var/www/html/index.html" "exists.*True" \
    "Template should be deployed to /var/www/html/index.html"

echo ""
echo -e "${YELLOW}Task 05: Role with Files (15 pts)${NC}"
check "role static exists" 4 \
    "test -d $ROLES_DIR/static" \
    "Create: ansible-galaxy init static"

check "static has files/logo.txt" 5 \
    "test -f $ROLES_DIR/static/files/logo.txt" \
    "Create: files/logo.txt"

check "logo.txt contains content" 3 \
    "grep -q 'Logo' $ROLES_DIR/static/files/logo.txt" \
    "File should contain 'Company Logo'"

ansible_check "logo.txt deployed" 3 \
    "node1.example.com" "stat" "path=/var/www/html/logo.txt" "exists.*True" \
    "File should be deployed to /var/www/html/logo.txt"

echo ""
echo -e "${YELLOW}Task 06: Role with Default Variables (18 pts)${NC}"
check "role database exists" 4 \
    "test -d $ROLES_DIR/database" \
    "Create: ansible-galaxy init database"

check "database has defaults/main.yml" 5 \
    "test -f $ROLES_DIR/database/defaults/main.yml" \
    "Create: defaults/main.yml"

check "defaults define db_port" 4 \
    "grep -q 'db_port:' $ROLES_DIR/database/defaults/main.yml" \
    "Define: db_port in defaults"

check "defaults define db_name" 5 \
    "grep -q 'db_name:' $ROLES_DIR/database/defaults/main.yml" \
    "Define: db_name in defaults"

echo ""
echo -e "${YELLOW}Task 07: Role with Vars (18 pts)${NC}"
check "role cache exists" 4 \
    "test -d $ROLES_DIR/cache" \
    "Create: ansible-galaxy init cache"

check "cache has vars/main.yml" 5 \
    "test -f $ROLES_DIR/cache/vars/main.yml" \
    "Create: vars/main.yml"

check "vars define cache_port" 4 \
    "grep -q 'cache_port:' $ROLES_DIR/cache/vars/main.yml" \
    "Define: cache_port in vars"

check "vars define cache_maxmemory" 5 \
    "grep -q 'cache_maxmemory:' $ROLES_DIR/cache/vars/main.yml" \
    "Define: cache_maxmemory in vars"

echo ""
echo -e "${YELLOW}Task 08: Role Dependencies (20 pts)${NC}"
check "role wordpress exists" 5 \
    "test -d $ROLES_DIR/wordpress" \
    "Create: ansible-galaxy init wordpress"

check "wordpress has meta/main.yml" 5 \
    "test -f $ROLES_DIR/wordpress/meta/main.yml" \
    "Create: meta/main.yml"

check "meta defines dependencies" 5 \
    "grep -q 'dependencies:' $ROLES_DIR/wordpress/meta/main.yml" \
    "Define: dependencies in meta/main.yml"

check "meta includes apache dependency" 5 \
    "grep -A 5 'dependencies:' $ROLES_DIR/wordpress/meta/main.yml | grep -q 'apache'" \
    "Add: apache as dependency"

echo ""
echo -e "${YELLOW}Task 09: Role with Multiple Task Files (20 pts)${NC}"
check "role fullstack exists" 5 \
    "test -d $ROLES_DIR/fullstack" \
    "Create: ansible-galaxy init fullstack"

check "fullstack has tasks/install.yml" 5 \
    "test -f $ROLES_DIR/fullstack/tasks/install.yml" \
    "Create: tasks/install.yml"

check "fullstack has tasks/configure.yml" 5 \
    "test -f $ROLES_DIR/fullstack/tasks/configure.yml" \
    "Create: tasks/configure.yml"

check "main.yml includes other tasks" 5 \
    "grep -q 'include_tasks\\|import_tasks' $ROLES_DIR/fullstack/tasks/main.yml" \
    "Use: include_tasks or import_tasks in main.yml"

echo ""
echo -e "${YELLOW}Task 10: Apply Role to Specific Hosts (15 pts)${NC}"
check "playbook webservers.yml exists" 5 \
    "test -f $ANSIBLE_DIR/webservers.yml" \
    "Create: webservers.yml playbook"

check "playbook targets webservers group" 5 \
    "grep -q 'hosts:.*webservers' $ANSIBLE_DIR/webservers.yml" \
    "Set: hosts: webservers"

check "playbook uses roles section" 5 \
    "grep -q 'roles:' $ANSIBLE_DIR/webservers.yml" \
    "Use: roles: section in playbook"

echo ""
echo -e "${YELLOW}Task 11: Role with Tags (18 pts)${NC}"
check "role monitoring exists" 5 \
    "test -d $ROLES_DIR/monitoring" \
    "Create: ansible-galaxy init monitoring"

check "monitoring tasks have install tag" 5 \
    "grep -q 'tags:.*install' $ROLES_DIR/monitoring/tasks/main.yml" \
    "Add: tags: install to tasks"

check "monitoring tasks have config tag" 4 \
    "grep -q 'tags:.*config' $ROLES_DIR/monitoring/tasks/main.yml" \
    "Add: tags: config to tasks"

check "monitoring tasks have service tag" 4 \
    "grep -q 'tags:.*service' $ROLES_DIR/monitoring/tasks/main.yml" \
    "Add: tags: service to tasks"

echo ""
echo -e "${YELLOW}Task 12: Role with Conditionals (18 pts)${NC}"
check "role firewall exists" 5 \
    "test -d $ROLES_DIR/firewall" \
    "Create: ansible-galaxy init firewall"

check "firewall tasks have when clause" 8 \
    "grep -q 'when:' $ROLES_DIR/firewall/tasks/main.yml" \
    "Add: when: condition to tasks"

check "when checks ansible_distribution" 5 \
    "grep -q 'ansible_distribution' $ROLES_DIR/firewall/tasks/main.yml" \
    "Use: when: ansible_distribution == 'Rocky'"

echo ""
echo -e "${YELLOW}Task 13: Role with Loops (15 pts)${NC}"
check "role users exists" 4 \
    "test -d $ROLES_DIR/users" \
    "Create: ansible-galaxy init users"

check "users has defaults with user_list" 5 \
    "grep -q 'user_list:' $ROLES_DIR/users/defaults/main.yml" \
    "Define: user_list in defaults/main.yml"

check "users tasks have loop" 6 \
    "grep -q 'loop:\\|with_items:' $ROLES_DIR/users/tasks/main.yml" \
    "Use: loop or with_items in tasks"

echo ""
echo -e "${YELLOW}Task 14: Role with Blocks (18 pts)${NC}"
check "role secure exists" 5 \
    "test -d $ROLES_DIR/secure" \
    "Create: ansible-galaxy init secure"

check "secure tasks have block" 5 \
    "grep -q 'block:' $ROLES_DIR/secure/tasks/main.yml" \
    "Use: block: in tasks"

check "secure tasks have rescue" 4 \
    "grep -q 'rescue:' $ROLES_DIR/secure/tasks/main.yml" \
    "Use: rescue: in tasks"

check "secure tasks have always" 4 \
    "grep -q 'always:' $ROLES_DIR/secure/tasks/main.yml" \
    "Use: always: in tasks"

echo ""
echo -e "${YELLOW}Task 15: Multiple Roles in Playbook (20 pts)${NC}"
check "playbook full-stack.yml exists" 5 \
    "test -f $ANSIBLE_DIR/full-stack.yml" \
    "Create: full-stack.yml playbook"

check "playbook has roles section" 5 \
    "grep -q 'roles:' $ANSIBLE_DIR/full-stack.yml" \
    "Use: roles: section"

check "playbook includes apache role" 3 \
    "grep -A 10 'roles:' $ANSIBLE_DIR/full-stack.yml | grep -q 'apache'" \
    "Add: apache to roles list"

check "playbook includes database role" 4 \
    "grep -A 10 'roles:' $ANSIBLE_DIR/full-stack.yml | grep -q 'database'" \
    "Add: database to roles list"

check "playbook includes cache role" 3 \
    "grep -A 10 'roles:' $ANSIBLE_DIR/full-stack.yml | grep -q 'cache'" \
    "Add: cache to roles list"

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
    echo -e "${YELLOW}You need $((184 - TOTAL_POINTS)) more points to pass.${NC}\n"
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
echo -e "4. Create roles: ${YELLOW}ansible-galaxy init <role_name>${NC}"
echo -e "5. Re-run: ${YELLOW}~/exams/thematic/roles-basics/grade.sh${NC}\n"

exit 0

# Made with Bob

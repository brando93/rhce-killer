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
check "role cache exists" 2 \
    "test -d $ROLES_DIR/cache" \
    "Create with: ansible-galaxy init roles/cache"

check "cache has defaults/main.yml" 2 \
    "test -f $ROLES_DIR/cache/defaults/main.yml" \
    "Create defaults/main.yml with cache_port, cache_maxmemory, cache_bind"

check "defaults set cache_port 6379" 2 \
    "grep -qE 'cache_port:[[:space:]]*6379' $ROLES_DIR/cache/defaults/main.yml" \
    "defaults should set cache_port: 6379 (gets overridden by vars)"

check "cache has vars/main.yml" 2 \
    "test -f $ROLES_DIR/cache/vars/main.yml" \
    "Create vars/main.yml that overrides cache_port and cache_maxmemory"

check "vars override cache_port to 6380" 3 \
    "grep -qE 'cache_port:[[:space:]]*6380' $ROLES_DIR/cache/vars/main.yml" \
    "vars/main.yml must set cache_port: 6380 (higher precedence than defaults)"

check "vars override cache_maxmemory to 256mb" 2 \
    "grep -qE 'cache_maxmemory:[[:space:]]*256mb' $ROLES_DIR/cache/vars/main.yml" \
    "vars/main.yml must set cache_maxmemory: 256mb"

check "cache.yml playbook exists and targets managed" 2 \
    "test -f $ANSIBLE_DIR/cache.yml && grep -qE 'hosts:[[:space:]]*managed' $ANSIBLE_DIR/cache.yml" \
    "Create cache.yml with hosts: managed and roles: [cache]"

check "/etc/cache.conf deployed to managed nodes" 3 \
    "ansible managed -b -m shell -a 'grep -q \"port = 6380\" /etc/cache.conf' &>/dev/null" \
    "Run cache.yml; /etc/cache.conf must show port = 6380 (vars overrode defaults)"

echo ""
echo -e "${YELLOW}Task 08: Role Dependencies (20 pts)${NC}"
check "role base exists" 2 \
    "test -d $ROLES_DIR/base" \
    "Create with: ansible-galaxy init roles/base"

check "role apache exists" 2 \
    "test -d $ROLES_DIR/apache" \
    "Create with: ansible-galaxy init roles/apache"

check "role wordpress exists" 2 \
    "test -d $ROLES_DIR/wordpress" \
    "Create with: ansible-galaxy init roles/wordpress"

check "wordpress meta/main.yml declares both deps" 4 \
    "grep -q 'dependencies:' $ROLES_DIR/wordpress/meta/main.yml && grep -q 'base' $ROLES_DIR/wordpress/meta/main.yml && grep -q 'apache' $ROLES_DIR/wordpress/meta/main.yml" \
    "meta/main.yml must declare dependencies on base AND apache"

check "wordpress.yml applies ONLY wordpress role" 3 \
    "test -f $ANSIBLE_DIR/wordpress.yml && grep -q 'wordpress' $ANSIBLE_DIR/wordpress.yml" \
    "Create wordpress.yml; playbook should list only the wordpress role (deps resolve automatically)"

check "/tmp/base-installed.txt exists on managed" 3 \
    "ansible managed -b -m shell -a 'test -f /tmp/base-installed.txt' &>/dev/null" \
    "After running, base role's marker file must exist on every managed node"

check "/tmp/apache-installed.txt exists on managed" 2 \
    "ansible managed -b -m shell -a 'test -f /tmp/apache-installed.txt' &>/dev/null" \
    "After running, apache role's marker file must exist on every managed node"

check "/tmp/wordpress-installed.txt exists on managed" 2 \
    "ansible managed -b -m shell -a 'test -f /tmp/wordpress-installed.txt' &>/dev/null" \
    "After running, wordpress role's marker file must exist on every managed node"

echo ""
echo -e "${YELLOW}Task 09: Role with Multiple Task Files (20 pts)${NC}"
check "role fullstack exists" 2 \
    "test -d $ROLES_DIR/fullstack" \
    "Create with: ansible-galaxy init roles/fullstack"

check "fullstack has install.yml, configure.yml, service.yml" 3 \
    "test -f $ROLES_DIR/fullstack/tasks/install.yml && test -f $ROLES_DIR/fullstack/tasks/configure.yml && test -f $ROLES_DIR/fullstack/tasks/service.yml" \
    "Create install.yml, configure.yml, service.yml under tasks/"

check "main.yml uses import_tasks for all three" 3 \
    "grep -c 'import_tasks' $ROLES_DIR/fullstack/tasks/main.yml | xargs -I {} test {} -ge 3" \
    "main.yml should orchestrate with 3 import_tasks (install/configure/service)"

check "install.yml installs httpd" 2 \
    "grep -qE 'name:[[:space:]]*httpd' $ROLES_DIR/fullstack/tasks/install.yml" \
    "install.yml should install httpd via ansible.builtin.dnf"

check "configure.yml writes /var/www/html/index.html" 2 \
    "grep -q '/var/www/html/index.html' $ROLES_DIR/fullstack/tasks/configure.yml" \
    "configure.yml deploys /var/www/html/index.html with a marker message"

check "service.yml starts and enables httpd" 2 \
    "grep -q 'httpd' $ROLES_DIR/fullstack/tasks/service.yml && grep -qE 'state:[[:space:]]*started' $ROLES_DIR/fullstack/tasks/service.yml" \
    "service.yml should start and enable httpd"

check "fullstack.yml playbook applies role to managed" 2 \
    "test -f $ANSIBLE_DIR/fullstack.yml && grep -qE 'hosts:[[:space:]]*managed' $ANSIBLE_DIR/fullstack.yml" \
    "Create fullstack.yml with hosts: managed and roles: [fullstack]"

check "httpd is active on managed nodes" 2 \
    "ansible managed -b -m shell -a 'systemctl is-active httpd' &>/dev/null" \
    "Run the playbook; httpd must be active on every managed node"

check "curl http://localhost returns marker content" 2 \
    "ansible managed -b -m shell -a 'curl -s http://localhost | grep -q Fullstack' &>/dev/null" \
    "/var/www/html/index.html must contain the 'Fullstack' marker text"

echo ""
echo -e "${YELLOW}Task 10: Apply Role to Specific Hosts (15 pts)${NC}"
check "playbook apply-managed.yml exists" 3 \
    "test -f $ANSIBLE_DIR/apply-managed.yml" \
    "Create apply-managed.yml"

check "playbook targets 'managed' group (NOT webservers)" 5 \
    "grep -qE 'hosts:[[:space:]]*managed' $ANSIBLE_DIR/apply-managed.yml" \
    "Use hosts: managed — the lab inventory has no 'webservers' group"

check "playbook uses roles: section with apache" 3 \
    "grep -q 'roles:' $ANSIBLE_DIR/apply-managed.yml && grep -q 'apache' $ANSIBLE_DIR/apply-managed.yml" \
    "Apply the apache role via the roles: keyword"

check "apache marker file exists on managed nodes" 2 \
    "ansible managed -b -m shell -a 'test -f /tmp/apache-installed.txt' &>/dev/null" \
    "Run the playbook; apache's marker file must appear on managed"

check "apache marker file does NOT exist on control" 2 \
    "! ansible control -b -m shell -a 'test -f /tmp/apache-installed.txt' &>/dev/null" \
    "The control node should NOT have been touched by this play"

echo ""
echo -e "${YELLOW}Task 11: Role with Tags (18 pts)${NC}"
check "role monitoring exists" 2 \
    "test -d $ROLES_DIR/monitoring" \
    "Create with: ansible-galaxy init roles/monitoring"

check "monitoring has install/config/service task files" 3 \
    "test -f $ROLES_DIR/monitoring/tasks/install.yml && test -f $ROLES_DIR/monitoring/tasks/config.yml && test -f $ROLES_DIR/monitoring/tasks/service.yml" \
    "Create install.yml, config.yml, service.yml under tasks/"

check "main.yml uses tagged import_tasks" 4 \
    "grep -q 'import_tasks' $ROLES_DIR/monitoring/tasks/main.yml && grep -cE 'tags:[[:space:]]*\\[' $ROLES_DIR/monitoring/tasks/main.yml | xargs -I {} test {} -ge 3" \
    "main.yml should have 3 import_tasks each with tags: [install] / [config] / [service]"

check "install.yml installs sysstat (NOT nagios/prometheus)" 3 \
    "grep -qE 'name:[[:space:]]*sysstat' $ROLES_DIR/monitoring/tasks/install.yml" \
    "Use sysstat (ships in BaseOS/AppStream); nagios/prometheus need extra repos not in the lab"

check "config.yml enables sysstat via lineinfile" 2 \
    "grep -q 'lineinfile' $ROLES_DIR/monitoring/tasks/config.yml && grep -q '/etc/sysconfig/sysstat' $ROLES_DIR/monitoring/tasks/config.yml" \
    "config.yml should use lineinfile to set ENABLED=\"true\" in /etc/sysconfig/sysstat"

check "service.yml starts and enables sysstat" 2 \
    "grep -q 'sysstat' $ROLES_DIR/monitoring/tasks/service.yml && grep -qE 'enabled:[[:space:]]*(true|yes)' $ROLES_DIR/monitoring/tasks/service.yml" \
    "service.yml should start and enable the sysstat service"

check "sysstat installed on managed nodes (post-run)" 2 \
    "ansible managed -b -m shell -a 'rpm -q sysstat' &>/dev/null" \
    "Run the playbook; sysstat must be installed on every managed node"

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

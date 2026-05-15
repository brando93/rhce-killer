#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# RHCE Killer — Exam 03 Grading Script
# Validates Ansible Roles and Collections tasks
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
echo "║                  RHCE KILLER — Exam 03 Grading                         ║"
echo "║                  Roles and Collections Tasks                           ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 01: Create a Custom Role from Scratch (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 01: Create a Custom Role from Scratch (15 pts) ━━━${NC}"

check "Role webserver directory exists" \
    2 \
    "dir_exists /home/student/ansible/roles/webserver" \
    "Create role with: ansible-galaxy init roles/webserver"

check "Role has proper structure (tasks)" \
    1 \
    "file_exists /home/student/ansible/roles/webserver/tasks/main.yml" \
    "Role should have tasks/main.yml file"

check "Role has handlers" \
    1 \
    "file_exists /home/student/ansible/roles/webserver/handlers/main.yml" \
    "Role should have handlers/main.yml file"

check "Role has templates directory" \
    1 \
    "dir_exists /home/student/ansible/roles/webserver/templates" \
    "Role should have templates/ directory"

check "Template file exists" \
    1 \
    "file_exists /home/student/ansible/roles/webserver/templates/index.html.j2" \
    "Create index.html.j2 template in templates/ directory"

check "Playbook site.yml exists" \
    1 \
    "file_exists /home/student/ansible/site.yml" \
    "Create site.yml playbook that uses webserver role"

check "Apache installed on web nodes" \
    2 \
    "ansible web -m shell -a 'rpm -q httpd' 2>/dev/null | grep -q 'httpd'" \
    "Role should install httpd package"

check "Apache service is running" \
    2 \
    "ansible web -m shell -a 'systemctl is-active httpd' 2>/dev/null | grep -q 'active'" \
    "Role should start and enable httpd service"

check "Custom index.html exists" \
    2 \
    "ansible web -m shell -a 'test -f /var/www/html/index.html' 2>/dev/null | grep -c 'SUCCESS' | grep -q '2'" \
    "Role should deploy custom index.html from template"

check "Firewall allows HTTP" \
    2 \
    "ansible web -m shell -a 'firewall-cmd --list-services' 2>/dev/null | grep -q 'http'" \
    "Role should configure firewall to allow HTTP"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 02: Role with Variables (defaults and vars) (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 02: Role with Variables (10 pts) ━━━${NC}"

check "Role appserver exists" \
    1 \
    "dir_exists /home/student/ansible/roles/appserver" \
    "Create role with: ansible-galaxy init roles/appserver"

check "Role has defaults/main.yml" \
    1 \
    "file_exists /home/student/ansible/roles/appserver/defaults/main.yml" \
    "Define default variables in defaults/main.yml"

check "Role has vars/main.yml" \
    1 \
    "file_exists /home/student/ansible/roles/appserver/vars/main.yml" \
    "Define role variables in vars/main.yml"

check "Playbook appserver.yml exists" \
    1 \
    "file_exists /home/student/ansible/appserver.yml" \
    "Create appserver.yml playbook"

check "App user created" \
    2 \
    "ansible app -m shell -a 'id appuser' 2>/dev/null | grep -q 'appuser'" \
    "Role should create appuser"

check "App directory exists" \
    2 \
    "ansible app -m shell -a 'test -d /opt/app' 2>/dev/null | grep -q 'SUCCESS'" \
    "Role should create /opt/app directory"

check "Config file exists" \
    2 \
    "ansible app -m shell -a 'test -f /etc/myapp.conf' 2>/dev/null | grep -q 'SUCCESS'" \
    "Role should create /etc/myapp.conf from template"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 03: Role with Templates and Handlers (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 03: Role with Templates and Handlers (15 pts) ━━━${NC}"

check "Role database exists" \
    2 \
    "dir_exists /home/student/ansible/roles/database" \
    "Create role with: ansible-galaxy init roles/database"

check "Template custom.cnf.j2 exists" \
    2 \
    "file_exists /home/student/ansible/roles/database/templates/custom.cnf.j2" \
    "Create custom.cnf.j2 template in templates/ directory"

check "Handler defined" \
    2 \
    "grep -q 'restart mariadb' /home/student/ansible/roles/database/handlers/main.yml" \
    "Define 'restart mariadb' handler in handlers/main.yml"

check "Playbook database.yml exists" \
    1 \
    "file_exists /home/student/ansible/database.yml" \
    "Create database.yml playbook"

check "MariaDB installed" \
    2 \
    "ansible database -m shell -a 'rpm -q mariadb-server' 2>/dev/null | grep -q 'mariadb-server'" \
    "Role should install mariadb-server"

check "MariaDB service running" \
    2 \
    "ansible database -m shell -a 'systemctl is-active mariadb' 2>/dev/null | grep -q 'active'" \
    "Role should start and enable mariadb service"

check "Custom config deployed" \
    2 \
    "ansible database -m shell -a 'test -f /etc/my.cnf.d/custom.cnf' 2>/dev/null | grep -q 'SUCCESS'" \
    "Role should deploy custom.cnf from template"

check "Template uses conditionals" \
    2 \
    "grep -q 'if' /home/student/ansible/roles/database/templates/custom.cnf.j2" \
    "Template should use Jinja2 conditionals for max_connections"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 04: Role Dependencies (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 04: Role Dependencies (10 pts) ━━━${NC}"

check "Role wordpress exists" \
    1 \
    "dir_exists /home/student/ansible/roles/wordpress" \
    "Create role with: ansible-galaxy init roles/wordpress"

check "Meta file exists" \
    1 \
    "file_exists /home/student/ansible/roles/wordpress/meta/main.yml" \
    "Role should have meta/main.yml file"

check "Dependencies defined in meta" \
    2 \
    "grep -q 'dependencies:' /home/student/ansible/roles/wordpress/meta/main.yml" \
    "Define dependencies in meta/main.yml"

check "Webserver dependency listed" \
    1 \
    "grep -q 'webserver' /home/student/ansible/roles/wordpress/meta/main.yml" \
    "Add webserver role as dependency"

check "Database dependency listed" \
    1 \
    "grep -q 'database' /home/student/ansible/roles/wordpress/meta/main.yml" \
    "Add database role as dependency"

check "Playbook wordpress.yml exists" \
    1 \
    "file_exists /home/student/ansible/wordpress.yml" \
    "Create wordpress.yml playbook"

check "PHP installed" \
    2 \
    "ansible web -m shell -a 'rpm -q php' 2>/dev/null | grep -q 'php'" \
    "Role should install PHP packages"

check "PHP info page exists" \
    1 \
    "ansible web -m shell -a 'test -f /var/www/html/info.php' 2>/dev/null | grep -c 'SUCCESS' | grep -q '2'" \
    "Role should create info.php file"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 05: Install Collections from Galaxy (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 05: Install Collections from Galaxy (10 pts) ━━━${NC}"

check "Collection community.general installed" \
    3 \
    "ansible-galaxy collection list | grep -q 'community.general'" \
    "Install with: ansible-galaxy collection install community.general"

check "Collection ansible.posix installed" \
    3 \
    "ansible-galaxy collection list | grep -q 'ansible.posix'" \
    "Install with: ansible-galaxy collection install ansible.posix"

check "Collection community.mysql installed" \
    3 \
    "ansible-galaxy collection list | grep -q 'community.mysql'" \
    "Install with: ansible-galaxy collection install community.mysql"

check "Collections documented" \
    1 \
    "file_exists /home/student/ansible/collections.txt" \
    "Document installed collections in collections.txt"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 06: Use Collection Modules (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 06: Use Collection Modules (10 pts) ━━━${NC}"

check "Playbook posix_demo.yml exists" \
    2 \
    "file_exists /home/student/ansible/posix_demo.yml" \
    "Create posix_demo.yml playbook"

check "Uses ansible.posix.firewalld module" \
    2 \
    "grep -q 'ansible.posix.firewalld' /home/student/ansible/posix_demo.yml" \
    "Use FQCN: ansible.posix.firewalld"

check "Uses ansible.posix.selinux module" \
    2 \
    "grep -q 'ansible.posix.selinux' /home/student/ansible/posix_demo.yml" \
    "Use FQCN: ansible.posix.selinux"

check "Uses ansible.posix.sysctl module" \
    2 \
    "grep -q 'ansible.posix.sysctl' /home/student/ansible/posix_demo.yml" \
    "Use FQCN: ansible.posix.sysctl"

check "IP forwarding enabled" \
    2 \
    "ansible all -m shell -a 'sysctl net.ipv4.ip_forward' 2>/dev/null | grep -q 'net.ipv4.ip_forward = 1'" \
    "Playbook should enable IP forwarding"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 07: Collections Requirements File (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 07: Collections Requirements File (10 pts) ━━━${NC}"

check "Requirements file exists" \
    2 \
    "file_exists /home/student/ansible/requirements.yml" \
    "Create requirements.yml file"

check "Collections section exists" \
    2 \
    "grep -q 'collections:' /home/student/ansible/requirements.yml" \
    "Add collections: section in requirements.yml"

check "Roles section exists" \
    2 \
    "grep -q 'roles:' /home/student/ansible/requirements.yml" \
    "Add roles: section in requirements.yml"

check "community.general listed" \
    1 \
    "grep -q 'community.general' /home/student/ansible/requirements.yml" \
    "List community.general collection"

check "ansible.posix listed" \
    1 \
    "grep -q 'ansible.posix' /home/student/ansible/requirements.yml" \
    "List ansible.posix collection"

check "geerlingguy.apache role listed" \
    2 \
    "grep -q 'geerlingguy.apache' /home/student/ansible/requirements.yml" \
    "List geerlingguy.apache role"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 08: Use External Roles from Galaxy (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 08: Use External Roles from Galaxy (15 pts) ━━━${NC}"

check "geerlingguy.nginx role installed" \
    3 \
    "ansible-galaxy role list | grep -q 'geerlingguy.nginx' || dir_exists /home/student/ansible/roles/geerlingguy.nginx" \
    "Install with: ansible-galaxy role install geerlingguy.nginx -p roles/"

check "Playbook nginx.yml exists" \
    2 \
    "file_exists /home/student/ansible/nginx.yml" \
    "Create nginx.yml playbook"

check "Playbook uses geerlingguy.nginx role" \
    2 \
    "grep -q 'geerlingguy.nginx' /home/student/ansible/nginx.yml" \
    "Reference geerlingguy.nginx role in playbook"

check "nginx_vhosts variable defined" \
    2 \
    "grep -q 'nginx_vhosts' /home/student/ansible/nginx.yml" \
    "Define nginx_vhosts variable in playbook"

check "Nginx installed" \
    3 \
    "ansible web -m shell -a 'rpm -q nginx' 2>/dev/null | grep -q 'nginx'" \
    "Role should install nginx"

check "Nginx listening on port 8080" \
    3 \
    "ansible web -m shell -a 'ss -tlnp | grep 8080' 2>/dev/null | grep -q '8080'" \
    "Configure nginx to listen on port 8080"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 09: System Roles (RHEL System Roles) (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 09: System Roles (15 pts) ━━━${NC}"

check "Playbook system_config.yml exists" \
    2 \
    "file_exists /home/student/ansible/system_config.yml" \
    "Create system_config.yml playbook"

check "Uses rhel-system-roles.timesync" \
    3 \
    "grep -q 'rhel-system-roles.timesync' /home/student/ansible/system_config.yml" \
    "Use rhel-system-roles.timesync role"

check "Uses rhel-system-roles.selinux" \
    3 \
    "grep -q 'rhel-system-roles.selinux' /home/student/ansible/system_config.yml" \
    "Use rhel-system-roles.selinux role"

check "Uses rhel-system-roles.firewall" \
    3 \
    "grep -q 'rhel-system-roles.firewall' /home/student/ansible/system_config.yml" \
    "Use rhel-system-roles.firewall role"

check "Chronyd service running" \
    2 \
    "ansible all -m shell -a 'systemctl is-active chronyd' 2>/dev/null | grep -c 'active' | grep -q '3'" \
    "Timesync role should configure chronyd"

check "SELinux is enforcing" \
    2 \
    "ansible all -m shell -a 'getenforce' 2>/dev/null | grep -c 'Enforcing' | grep -q '3'" \
    "SELinux role should set enforcing mode"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 10: Complex Role with Multiple Plays (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 10: Complex Role with Multiple Plays (10 pts) ━━━${NC}"

check "Playbook deploy_stack.yml exists" \
    1 \
    "file_exists /home/student/ansible/deploy_stack.yml" \
    "Create deploy_stack.yml playbook"

check "Has multiple plays" \
    2 \
    "grep -c '^- name:' /home/student/ansible/deploy_stack.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
    "Playbook should have at least 3 plays"

check "Uses tags" \
    2 \
    "grep -q 'tags:' /home/student/ansible/deploy_stack.yml" \
    "Define tags for selective execution"

check "Has database tag" \
    1 \
    "grep -q 'database' /home/student/ansible/deploy_stack.yml" \
    "Include 'database' tag"

check "Has frontend tag" \
    1 \
    "grep -q 'frontend' /home/student/ansible/deploy_stack.yml" \
    "Include 'frontend' tag"

check "Has pre_tasks" \
    1 \
    "grep -q 'pre_tasks:' /home/student/ansible/deploy_stack.yml" \
    "Add pre_tasks section"

check "Has post_tasks" \
    1 \
    "grep -q 'post_tasks:' /home/student/ansible/deploy_stack.yml" \
    "Add post_tasks section"

check "Playbook is valid" \
    1 \
    "ansible-playbook /home/student/ansible/deploy_stack.yml --syntax-check" \
    "Playbook should pass syntax check"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 11: phpinfo + Apache mod_proxy_balancer (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 11: phpinfo + Apache mod_proxy_balancer (15 pts) ━━━${NC}"

check "Role roles/phpinfo exists" \
    1 \
    "dir_exists /home/student/ansible/roles/phpinfo" \
    "Create with: ansible-galaxy init roles/phpinfo"

check "Role roles/balancer exists" \
    1 \
    "dir_exists /home/student/ansible/roles/balancer" \
    "Create with: ansible-galaxy init roles/balancer"

check "phpinfo template index.php.j2 exists" \
    1 \
    "file_exists /home/student/ansible/roles/phpinfo/templates/index.php.j2" \
    "Create roles/phpinfo/templates/index.php.j2 with <?php phpinfo(); ?>"

check "phpinfo template prints Backend hostname" \
    1 \
    "grep -q 'Backend' /home/student/ansible/roles/phpinfo/templates/index.php.j2" \
    "Include 'Backend: {{ ansible_hostname }}' in the template"

check "balancer template exists" \
    1 \
    "file_exists /home/student/ansible/roles/balancer/templates/balancer.conf.j2" \
    "Create roles/balancer/templates/balancer.conf.j2 with <Proxy balancer://...>"

check "balancer template uses mod_proxy_balancer syntax" \
    2 \
    "grep -q 'balancer://' /home/student/ansible/roles/balancer/templates/balancer.conf.j2" \
    "Use <Proxy \"balancer://mycluster\"> ... </Proxy>"

check "balancer template loops over groups['webservers']" \
    2 \
    "grep -E \"for[[:space:]]+\\w+[[:space:]]+in[[:space:]]+groups\\\\['webservers'\\\\]\" /home/student/ansible/roles/balancer/templates/balancer.conf.j2" \
    "Loop {% for host in groups['webservers'] %} ... {% endfor %}"

check "site.yml master playbook exists" \
    1 \
    "file_exists /home/student/ansible/site.yml" \
    "Create site.yml with two plays: phpinfo on webservers, balancer on balancers"

check "site.yml targets webservers and balancers" \
    1 \
    "grep -q 'webservers' /home/student/ansible/site.yml && grep -q 'balancers' /home/student/ansible/site.yml" \
    "Each role goes to its own host group"

check "Backend node1 returns its hostname" \
    2 \
    "ansible node1.example.com -b -m shell -a 'curl -s http://localhost/index.php' 2>/dev/null | grep -q 'Backend'" \
    "node1 must serve the templated phpinfo page"

check "Balancer config deployed" \
    1 \
    "ansible balancers -b -m shell -a 'test -f /etc/httpd/conf.d/balancer.conf' 2>/dev/null | grep -q 'SUCCESS'" \
    "Use ansible.builtin.template to drop /etc/httpd/conf.d/balancer.conf"

check "httpd active on balancer" \
    1 \
    "ansible balancers -b -m shell -a 'systemctl is-active httpd' 2>/dev/null | grep -q 'active'" \
    "Start and enable httpd on the balancer"

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
    STATUS="✓ PASS"
elif [ $PERCENTAGE -ge 50 ]; then
    COLOR=$YELLOW
    STATUS="⚠ NEEDS IMPROVEMENT"
else
    COLOR=$RED
    STATUS="✗ FAIL"
fi

printf "║  Score: ${COLOR}%3d / %3d points (%3d%%)${NC}                                 ║\n" $PASS $TOTAL $PERCENTAGE
printf "║  Status: ${COLOR}%-20s${NC}                                       ║\n" "$STATUS"
echo "╚════════════════════════════════════════════════════════════════════════╝"

# Show failed tasks if any
if [ ${#FAILED_TASKS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Failed Tasks:${NC}"
    for task in "${FAILED_TASKS[@]}"; do
        echo -e "  ${RED}✗${NC} $task"
    done
    echo ""
    echo -e "${CYAN}💡 Tips:${NC}"
    echo "  • Review the hints above for each failed check"
    echo "  • Check role structure: ls -la roles/<role_name>/"
    echo "  • Verify role syntax: ansible-playbook <playbook> --syntax-check"
    echo "  • List installed roles: ansible-galaxy role list"
    echo "  • List installed collections: ansible-galaxy collection list"
    echo "  • View solutions: cat ~/exams/exam-03/README.md | less"
    echo "  • Check role docs: cat roles/<role_name>/README.md"
fi

echo ""

# Exit with appropriate code
if [ $PERCENTAGE -ge 70 ]; then
    exit 0
else
    exit 1
fi

# Made with Bob

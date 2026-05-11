#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# RHCE Killer — Exam 03 Grading Script
# Validates Ansible Roles and Collections tasks
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
MAX_SCORE=135
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

# Helper to check file exists
file_exists() {
    [ -f "$1" ]
}

# Helper to check directory exists
dir_exists() {
    [ -d "$1" ]
}

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
    "dir_exists /home/student/ansible/roles/webserver" \
    2 \
    "Create role with: ansible-galaxy init roles/webserver"

check "Role has proper structure (tasks)" \
    "file_exists /home/student/ansible/roles/webserver/tasks/main.yml" \
    1 \
    "Role should have tasks/main.yml file"

check "Role has handlers" \
    "file_exists /home/student/ansible/roles/webserver/handlers/main.yml" \
    1 \
    "Role should have handlers/main.yml file"

check "Role has templates directory" \
    "dir_exists /home/student/ansible/roles/webserver/templates" \
    1 \
    "Role should have templates/ directory"

check "Template file exists" \
    "file_exists /home/student/ansible/roles/webserver/templates/index.html.j2" \
    1 \
    "Create index.html.j2 template in templates/ directory"

check "Playbook site.yml exists" \
    "file_exists /home/student/ansible/site.yml" \
    1 \
    "Create site.yml playbook that uses webserver role"

check "Apache installed on web nodes" \
    "ansible web -m shell -a 'rpm -q httpd' 2>/dev/null | grep -q 'httpd'" \
    2 \
    "Role should install httpd package"

check "Apache service is running" \
    "ansible web -m shell -a 'systemctl is-active httpd' 2>/dev/null | grep -q 'active'" \
    2 \
    "Role should start and enable httpd service"

check "Custom index.html exists" \
    "ansible web -m shell -a 'test -f /var/www/html/index.html' 2>/dev/null | grep -c 'SUCCESS' | grep -q '2'" \
    2 \
    "Role should deploy custom index.html from template"

check "Firewall allows HTTP" \
    "ansible web -m shell -a 'firewall-cmd --list-services' 2>/dev/null | grep -q 'http'" \
    2 \
    "Role should configure firewall to allow HTTP"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 02: Role with Variables (defaults and vars) (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 02: Role with Variables (10 pts) ━━━${NC}"

check "Role appserver exists" \
    "dir_exists /home/student/ansible/roles/appserver" \
    1 \
    "Create role with: ansible-galaxy init roles/appserver"

check "Role has defaults/main.yml" \
    "file_exists /home/student/ansible/roles/appserver/defaults/main.yml" \
    1 \
    "Define default variables in defaults/main.yml"

check "Role has vars/main.yml" \
    "file_exists /home/student/ansible/roles/appserver/vars/main.yml" \
    1 \
    "Define role variables in vars/main.yml"

check "Playbook appserver.yml exists" \
    "file_exists /home/student/ansible/appserver.yml" \
    1 \
    "Create appserver.yml playbook"

check "App user created" \
    "ansible app -m shell -a 'id appuser' 2>/dev/null | grep -q 'appuser'" \
    2 \
    "Role should create appuser"

check "App directory exists" \
    "ansible app -m shell -a 'test -d /opt/app' 2>/dev/null | grep -q 'SUCCESS'" \
    2 \
    "Role should create /opt/app directory"

check "Config file exists" \
    "ansible app -m shell -a 'test -f /etc/myapp.conf' 2>/dev/null | grep -q 'SUCCESS'" \
    2 \
    "Role should create /etc/myapp.conf from template"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 03: Role with Templates and Handlers (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 03: Role with Templates and Handlers (15 pts) ━━━${NC}"

check "Role database exists" \
    "dir_exists /home/student/ansible/roles/database" \
    2 \
    "Create role with: ansible-galaxy init roles/database"

check "Template custom.cnf.j2 exists" \
    "file_exists /home/student/ansible/roles/database/templates/custom.cnf.j2" \
    2 \
    "Create custom.cnf.j2 template in templates/ directory"

check "Handler defined" \
    "grep -q 'restart mariadb' /home/student/ansible/roles/database/handlers/main.yml" \
    2 \
    "Define 'restart mariadb' handler in handlers/main.yml"

check "Playbook database.yml exists" \
    "file_exists /home/student/ansible/database.yml" \
    1 \
    "Create database.yml playbook"

check "MariaDB installed" \
    "ansible database -m shell -a 'rpm -q mariadb-server' 2>/dev/null | grep -q 'mariadb-server'" \
    2 \
    "Role should install mariadb-server"

check "MariaDB service running" \
    "ansible database -m shell -a 'systemctl is-active mariadb' 2>/dev/null | grep -q 'active'" \
    2 \
    "Role should start and enable mariadb service"

check "Custom config deployed" \
    "ansible database -m shell -a 'test -f /etc/my.cnf.d/custom.cnf' 2>/dev/null | grep -q 'SUCCESS'" \
    2 \
    "Role should deploy custom.cnf from template"

check "Template uses conditionals" \
    "grep -q 'if' /home/student/ansible/roles/database/templates/custom.cnf.j2" \
    2 \
    "Template should use Jinja2 conditionals for max_connections"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 04: Role Dependencies (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 04: Role Dependencies (10 pts) ━━━${NC}"

check "Role wordpress exists" \
    "dir_exists /home/student/ansible/roles/wordpress" \
    1 \
    "Create role with: ansible-galaxy init roles/wordpress"

check "Meta file exists" \
    "file_exists /home/student/ansible/roles/wordpress/meta/main.yml" \
    1 \
    "Role should have meta/main.yml file"

check "Dependencies defined in meta" \
    "grep -q 'dependencies:' /home/student/ansible/roles/wordpress/meta/main.yml" \
    2 \
    "Define dependencies in meta/main.yml"

check "Webserver dependency listed" \
    "grep -q 'webserver' /home/student/ansible/roles/wordpress/meta/main.yml" \
    1 \
    "Add webserver role as dependency"

check "Database dependency listed" \
    "grep -q 'database' /home/student/ansible/roles/wordpress/meta/main.yml" \
    1 \
    "Add database role as dependency"

check "Playbook wordpress.yml exists" \
    "file_exists /home/student/ansible/wordpress.yml" \
    1 \
    "Create wordpress.yml playbook"

check "PHP installed" \
    "ansible web -m shell -a 'rpm -q php' 2>/dev/null | grep -q 'php'" \
    2 \
    "Role should install PHP packages"

check "PHP info page exists" \
    "ansible web -m shell -a 'test -f /var/www/html/info.php' 2>/dev/null | grep -c 'SUCCESS' | grep -q '2'" \
    1 \
    "Role should create info.php file"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 05: Install Collections from Galaxy (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 05: Install Collections from Galaxy (10 pts) ━━━${NC}"

check "Collection community.general installed" \
    "ansible-galaxy collection list | grep -q 'community.general'" \
    3 \
    "Install with: ansible-galaxy collection install community.general"

check "Collection ansible.posix installed" \
    "ansible-galaxy collection list | grep -q 'ansible.posix'" \
    3 \
    "Install with: ansible-galaxy collection install ansible.posix"

check "Collection community.mysql installed" \
    "ansible-galaxy collection list | grep -q 'community.mysql'" \
    3 \
    "Install with: ansible-galaxy collection install community.mysql"

check "Collections documented" \
    "file_exists /home/student/ansible/collections.txt" \
    1 \
    "Document installed collections in collections.txt"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 06: Use Collection Modules (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 06: Use Collection Modules (10 pts) ━━━${NC}"

check "Playbook posix_demo.yml exists" \
    "file_exists /home/student/ansible/posix_demo.yml" \
    2 \
    "Create posix_demo.yml playbook"

check "Uses ansible.posix.firewalld module" \
    "grep -q 'ansible.posix.firewalld' /home/student/ansible/posix_demo.yml" \
    2 \
    "Use FQCN: ansible.posix.firewalld"

check "Uses ansible.posix.selinux module" \
    "grep -q 'ansible.posix.selinux' /home/student/ansible/posix_demo.yml" \
    2 \
    "Use FQCN: ansible.posix.selinux"

check "Uses ansible.posix.sysctl module" \
    "grep -q 'ansible.posix.sysctl' /home/student/ansible/posix_demo.yml" \
    2 \
    "Use FQCN: ansible.posix.sysctl"

check "IP forwarding enabled" \
    "ansible all -m shell -a 'sysctl net.ipv4.ip_forward' 2>/dev/null | grep -q 'net.ipv4.ip_forward = 1'" \
    2 \
    "Playbook should enable IP forwarding"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 07: Collections Requirements File (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 07: Collections Requirements File (10 pts) ━━━${NC}"

check "Requirements file exists" \
    "file_exists /home/student/ansible/requirements.yml" \
    2 \
    "Create requirements.yml file"

check "Collections section exists" \
    "grep -q 'collections:' /home/student/ansible/requirements.yml" \
    2 \
    "Add collections: section in requirements.yml"

check "Roles section exists" \
    "grep -q 'roles:' /home/student/ansible/requirements.yml" \
    2 \
    "Add roles: section in requirements.yml"

check "community.general listed" \
    "grep -q 'community.general' /home/student/ansible/requirements.yml" \
    1 \
    "List community.general collection"

check "ansible.posix listed" \
    "grep -q 'ansible.posix' /home/student/ansible/requirements.yml" \
    1 \
    "List ansible.posix collection"

check "geerlingguy.apache role listed" \
    "grep -q 'geerlingguy.apache' /home/student/ansible/requirements.yml" \
    2 \
    "List geerlingguy.apache role"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 08: Use External Roles from Galaxy (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 08: Use External Roles from Galaxy (15 pts) ━━━${NC}"

check "geerlingguy.nginx role installed" \
    "ansible-galaxy role list | grep -q 'geerlingguy.nginx' || dir_exists /home/student/ansible/roles/geerlingguy.nginx" \
    3 \
    "Install with: ansible-galaxy role install geerlingguy.nginx -p roles/"

check "Playbook nginx.yml exists" \
    "file_exists /home/student/ansible/nginx.yml" \
    2 \
    "Create nginx.yml playbook"

check "Playbook uses geerlingguy.nginx role" \
    "grep -q 'geerlingguy.nginx' /home/student/ansible/nginx.yml" \
    2 \
    "Reference geerlingguy.nginx role in playbook"

check "nginx_vhosts variable defined" \
    "grep -q 'nginx_vhosts' /home/student/ansible/nginx.yml" \
    2 \
    "Define nginx_vhosts variable in playbook"

check "Nginx installed" \
    "ansible web -m shell -a 'rpm -q nginx' 2>/dev/null | grep -q 'nginx'" \
    3 \
    "Role should install nginx"

check "Nginx listening on port 8080" \
    "ansible web -m shell -a 'ss -tlnp | grep 8080' 2>/dev/null | grep -q '8080'" \
    3 \
    "Configure nginx to listen on port 8080"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 09: System Roles (RHEL System Roles) (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 09: System Roles (15 pts) ━━━${NC}"

check "Playbook system_config.yml exists" \
    "file_exists /home/student/ansible/system_config.yml" \
    2 \
    "Create system_config.yml playbook"

check "Uses rhel-system-roles.timesync" \
    "grep -q 'rhel-system-roles.timesync' /home/student/ansible/system_config.yml" \
    3 \
    "Use rhel-system-roles.timesync role"

check "Uses rhel-system-roles.selinux" \
    "grep -q 'rhel-system-roles.selinux' /home/student/ansible/system_config.yml" \
    3 \
    "Use rhel-system-roles.selinux role"

check "Uses rhel-system-roles.firewall" \
    "grep -q 'rhel-system-roles.firewall' /home/student/ansible/system_config.yml" \
    3 \
    "Use rhel-system-roles.firewall role"

check "Chronyd service running" \
    "ansible all -m shell -a 'systemctl is-active chronyd' 2>/dev/null | grep -c 'active' | grep -q '3'" \
    2 \
    "Timesync role should configure chronyd"

check "SELinux is enforcing" \
    "ansible all -m shell -a 'getenforce' 2>/dev/null | grep -c 'Enforcing' | grep -q '3'" \
    2 \
    "SELinux role should set enforcing mode"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 10: Complex Role with Multiple Plays (10 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 10: Complex Role with Multiple Plays (10 pts) ━━━${NC}"

check "Playbook deploy_stack.yml exists" \
    "file_exists /home/student/ansible/deploy_stack.yml" \
    1 \
    "Create deploy_stack.yml playbook"

check "Has multiple plays" \
    "grep -c '^- name:' /home/student/ansible/deploy_stack.yml | awk '{if(\$1>=3) exit 0; else exit 1}'" \
    2 \
    "Playbook should have at least 3 plays"

check "Uses tags" \
    "grep -q 'tags:' /home/student/ansible/deploy_stack.yml" \
    2 \
    "Define tags for selective execution"

check "Has database tag" \
    "grep -q 'database' /home/student/ansible/deploy_stack.yml" \
    1 \
    "Include 'database' tag"

check "Has frontend tag" \
    "grep -q 'frontend' /home/student/ansible/deploy_stack.yml" \
    1 \
    "Include 'frontend' tag"

check "Has pre_tasks" \
    "grep -q 'pre_tasks:' /home/student/ansible/deploy_stack.yml" \
    1 \
    "Add pre_tasks section"

check "Has post_tasks" \
    "grep -q 'post_tasks:' /home/student/ansible/deploy_stack.yml" \
    1 \
    "Add post_tasks section"

check "Playbook is valid" \
    "ansible-playbook /home/student/ansible/deploy_stack.yml --syntax-check" \
    1 \
    "Playbook should pass syntax check"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TASK 11: phpinfo + Apache mod_proxy_balancer (15 points)
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}━━━ Task 11: phpinfo + Apache mod_proxy_balancer (15 pts) ━━━${NC}"

check "Role roles/phpinfo exists" \
    "dir_exists /home/student/ansible/roles/phpinfo" \
    1 \
    "Create with: ansible-galaxy init roles/phpinfo"

check "Role roles/balancer exists" \
    "dir_exists /home/student/ansible/roles/balancer" \
    1 \
    "Create with: ansible-galaxy init roles/balancer"

check "phpinfo template index.php.j2 exists" \
    "file_exists /home/student/ansible/roles/phpinfo/templates/index.php.j2" \
    1 \
    "Create roles/phpinfo/templates/index.php.j2 with <?php phpinfo(); ?>"

check "phpinfo template prints Backend hostname" \
    "grep -q 'Backend' /home/student/ansible/roles/phpinfo/templates/index.php.j2" \
    1 \
    "Include 'Backend: {{ ansible_hostname }}' in the template"

check "balancer template exists" \
    "file_exists /home/student/ansible/roles/balancer/templates/balancer.conf.j2" \
    1 \
    "Create roles/balancer/templates/balancer.conf.j2 with <Proxy balancer://...>"

check "balancer template uses mod_proxy_balancer syntax" \
    "grep -q 'balancer://' /home/student/ansible/roles/balancer/templates/balancer.conf.j2" \
    2 \
    "Use <Proxy \"balancer://mycluster\"> ... </Proxy>"

check "balancer template loops over groups['webservers']" \
    "grep -E \"for[[:space:]]+\\w+[[:space:]]+in[[:space:]]+groups\\\\['webservers'\\\\]\" /home/student/ansible/roles/balancer/templates/balancer.conf.j2" \
    2 \
    "Loop {% for host in groups['webservers'] %} ... {% endfor %}"

check "site.yml master playbook exists" \
    "file_exists /home/student/ansible/site.yml" \
    1 \
    "Create site.yml with two plays: phpinfo on webservers, balancer on balancers"

check "site.yml targets webservers and balancers" \
    "grep -q 'webservers' /home/student/ansible/site.yml && grep -q 'balancers' /home/student/ansible/site.yml" \
    1 \
    "Each role goes to its own host group"

check "Backend node1 returns its hostname" \
    "ansible node1.example.com -b -m shell -a 'curl -s http://localhost/index.php' 2>/dev/null | grep -q 'Backend'" \
    2 \
    "node1 must serve the templated phpinfo page"

check "Balancer config deployed" \
    "ansible balancers -b -m shell -a 'test -f /etc/httpd/conf.d/balancer.conf' 2>/dev/null | grep -q 'SUCCESS'" \
    1 \
    "Use ansible.builtin.template to drop /etc/httpd/conf.d/balancer.conf"

check "httpd active on balancer" \
    "ansible balancers -b -m shell -a 'systemctl is-active httpd' 2>/dev/null | grep -q 'active'" \
    1 \
    "Start and enable httpd on the balancer"

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
    STATUS="✓ PASS"
elif [ $PERCENTAGE -ge 50 ]; then
    COLOR=$YELLOW
    STATUS="⚠ NEEDS IMPROVEMENT"
else
    COLOR=$RED
    STATUS="✗ FAIL"
fi

printf "║  Score: ${COLOR}%3d / %3d points (%3d%%)${NC}                                 ║\n" $TOTAL_SCORE $MAX_SCORE $PERCENTAGE
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

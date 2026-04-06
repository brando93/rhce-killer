#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Playbooks Fundamentals Grader
# Run this after completing all tasks to see your score.
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

EXAM_NAME="playbooks-fundamentals"
EXAM_TITLE="Playbooks Fundamentals"
TOTAL_POINTS=155

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
echo -e "${BOLD}Task 01 — Create Your First Playbook (10 pts)${NC}"
# ─────────────────────────────────────────────
check "first-playbook.yml exists" 3 \
  "test -f $ANSIBLE_DIR/first-playbook.yml" \
  "Create playbook: first-playbook.yml"
check "playbook has play name" 2 \
  "grep -q 'name:.*My First Playbook' $ANSIBLE_DIR/first-playbook.yml" \
  "Add play name: 'My First Playbook'"
check "playbook targets all hosts" 2 \
  "grep -q 'hosts:.*all' $ANSIBLE_DIR/first-playbook.yml" \
  "Add: hosts: all"
check "playbook uses debug module" 2 \
  "grep -q 'debug:' $ANSIBLE_DIR/first-playbook.yml && grep -q 'Hello from Ansible' $ANSIBLE_DIR/first-playbook.yml" \
  "Use debug module with msg: 'Hello from Ansible!'"
check "playbook syntax is valid" 1 \
  "ansible-playbook --syntax-check $ANSIBLE_DIR/first-playbook.yml" \
  "Check syntax with: ansible-playbook --syntax-check first-playbook.yml"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — Install Packages with Playbook (12 pts)${NC}"
# ─────────────────────────────────────────────
check "install-packages.yml exists" 2 \
  "test -f $ANSIBLE_DIR/install-packages.yml" \
  "Create playbook: install-packages.yml"
check "playbook uses become" 2 \
  "grep -q 'become:.*true' $ANSIBLE_DIR/install-packages.yml" \
  "Add: become: true"
check "playbook installs httpd" 2 \
  "grep -q 'httpd' $ANSIBLE_DIR/install-packages.yml" \
  "Install httpd package"
ansible_check "httpd installed on node1" 3 \
  "node1.example.com" "command" "rpm -q httpd" "httpd-" \
  "Run playbook to install packages"
ansible_check "firewalld installed on node1" 2 \
  "node1.example.com" "command" "rpm -q firewalld" "firewalld-" \
  "Install firewalld package"
ansible_check "mod_ssl installed on node1" 1 \
  "node1.example.com" "command" "rpm -q mod_ssl" "mod_ssl-" \
  "Install mod_ssl package"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — Manage Services (12 pts)${NC}"
# ─────────────────────────────────────────────
check "manage-services.yml exists" 2 \
  "test -f $ANSIBLE_DIR/manage-services.yml" \
  "Create playbook: manage-services.yml"
check "playbook manages firewalld service" 2 \
  "grep -q 'firewalld' $ANSIBLE_DIR/manage-services.yml && grep -q 'started' $ANSIBLE_DIR/manage-services.yml" \
  "Start and enable firewalld service"
check "playbook manages httpd service" 2 \
  "grep -q 'httpd' $ANSIBLE_DIR/manage-services.yml" \
  "Start and enable httpd service"
ansible_check "firewalld is running on node1" 3 \
  "node1.example.com" "command" "systemctl is-active firewalld" "active" \
  "Run playbook to start services"
ansible_check "httpd is running on node1" 3 \
  "node1.example.com" "command" "systemctl is-active httpd" "active" \
  "Ensure httpd service is started"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Create Users and Groups (15 pts)${NC}"
# ─────────────────────────────────────────────
check "create-users.yml exists" 2 \
  "test -f $ANSIBLE_DIR/create-users.yml" \
  "Create playbook: create-users.yml"
check "playbook creates group" 2 \
  "grep -q 'group:' $ANSIBLE_DIR/create-users.yml && grep -q 'developers' $ANSIBLE_DIR/create-users.yml" \
  "Use group module to create 'developers' group"
check "playbook creates user" 2 \
  "grep -q 'user:' $ANSIBLE_DIR/create-users.yml && grep -q 'devuser' $ANSIBLE_DIR/create-users.yml" \
  "Use user module to create 'devuser'"
ansible_check "developers group exists on node1" 3 \
  "node1.example.com" "command" "getent group developers" "developers.*3000" \
  "Create group with GID 3000"
ansible_check "devuser exists on node1" 3 \
  "node1.example.com" "command" "id devuser" "uid=3001.*gid=3000" \
  "Create user with UID 3001 and primary group developers"
ansible_check "devuser home directory exists" 3 \
  "node1.example.com" "stat" "path=/home/devuser" "isdir.*True" \
  "User should have home directory /home/devuser"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — File and Directory Management (15 pts)${NC}"
# ─────────────────────────────────────────────
check "file-management.yml exists" 2 \
  "test -f $ANSIBLE_DIR/file-management.yml" \
  "Create playbook: file-management.yml"
check "playbook creates directory" 2 \
  "grep -q '/opt/app' $ANSIBLE_DIR/file-management.yml && grep -q 'file:' $ANSIBLE_DIR/file-management.yml" \
  "Use file module to create /opt/app directory"
check "playbook creates file" 2 \
  "grep -q '/opt/app/config.txt' $ANSIBLE_DIR/file-management.yml" \
  "Create file /opt/app/config.txt"
ansible_check "directory /opt/app exists on node1" 3 \
  "node1.example.com" "stat" "path=/opt/app" "isdir.*True" \
  "Run playbook to create directory"
ansible_check "directory has correct owner" 2 \
  "node1.example.com" "stat" "path=/opt/app" "pw_name.*devuser" \
  "Set owner to devuser"
ansible_check "file /opt/app/config.txt exists" 2 \
  "node1.example.com" "command" "cat /opt/app/config.txt" "Application Configuration" \
  "Create file with correct content"
ansible_check "file has correct owner" 2 \
  "node1.example.com" "stat" "path=/opt/app/config.txt" "pw_name.*devuser" \
  "Set file owner to devuser"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Copy Files from Control Node (12 pts)${NC}"
# ─────────────────────────────────────────────
check "files directory exists" 2 \
  "test -d $ANSIBLE_DIR/files" \
  "Create directory: mkdir files"
check "index.html source file exists" 2 \
  "test -f $ANSIBLE_DIR/files/index.html" \
  "Create files/index.html with HTML content"
check "copy-files.yml exists" 2 \
  "test -f $ANSIBLE_DIR/copy-files.yml" \
  "Create playbook: copy-files.yml"
check "playbook uses copy module" 2 \
  "grep -q 'copy:' $ANSIBLE_DIR/copy-files.yml && grep -q 'index.html' $ANSIBLE_DIR/copy-files.yml" \
  "Use copy module to copy index.html"
ansible_check "index.html copied to node1" 2 \
  "node1.example.com" "stat" "path=/var/www/html/index.html" "exists.*True" \
  "Run playbook to copy file"
ansible_check "file has correct permissions" 2 \
  "node1.example.com" "stat" "path=/var/www/html/index.html" "mode.*0644" \
  "Set file mode to 0644"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — Lineinfile Module (12 pts)${NC}"
# ─────────────────────────────────────────────
check "modify-config.yml exists" 3 \
  "test -f $ANSIBLE_DIR/modify-config.yml" \
  "Create playbook: modify-config.yml"
check "playbook uses lineinfile module" 3 \
  "grep -q 'lineinfile:' $ANSIBLE_DIR/modify-config.yml && grep -q 'PermitRootLogin' $ANSIBLE_DIR/modify-config.yml" \
  "Use lineinfile module to modify sshd_config"
check "playbook uses regexp" 2 \
  "grep -q 'regexp:' $ANSIBLE_DIR/modify-config.yml" \
  "Use regexp to find the line"
ansible_check "PermitRootLogin set to no on node1" 4 \
  "node1.example.com" "command" "grep '^PermitRootLogin no' /etc/ssh/sshd_config" "PermitRootLogin no" \
  "Run playbook to modify sshd_config"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — Multiple Plays in One Playbook (15 pts)${NC}"
# ─────────────────────────────────────────────
check "multi-play.yml exists" 3 \
  "test -f $ANSIBLE_DIR/multi-play.yml" \
  "Create playbook: multi-play.yml"
check "playbook has two plays" 3 \
  "grep -c '^- name:' $ANSIBLE_DIR/multi-play.yml | grep -q '[2-9]'" \
  "Create two separate plays"
check "first play targets node1" 2 \
  "grep -A5 'Configure Web Servers' $ANSIBLE_DIR/multi-play.yml | grep -q 'node1.example.com'" \
  "First play should target node1.example.com"
check "second play targets node2" 2 \
  "grep -A5 'Configure Database Servers' $ANSIBLE_DIR/multi-play.yml | grep -q 'node2.example.com'" \
  "Second play should target node2.example.com"
ansible_check "mariadb-server installed on node2" 3 \
  "node2.example.com" "command" "rpm -q mariadb-server" "mariadb-server-" \
  "Run playbook to install mariadb-server"
ansible_check "mariadb service running on node2" 2 \
  "node2.example.com" "command" "systemctl is-active mariadb" "active" \
  "Start mariadb service on node2"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — Variables in Playbooks (15 pts)${NC}"
# ─────────────────────────────────────────────
check "use-variables.yml exists" 3 \
  "test -f $ANSIBLE_DIR/use-variables.yml" \
  "Create playbook: use-variables.yml"
check "playbook defines variables" 3 \
  "grep -q 'vars:' $ANSIBLE_DIR/use-variables.yml && grep -q 'app_name:' $ANSIBLE_DIR/use-variables.yml" \
  "Define variables in vars section"
check "playbook uses variables" 2 \
  "grep -q '{{.*app_name.*}}' $ANSIBLE_DIR/use-variables.yml" \
  "Use variables with {{ variable_name }} syntax"
ansible_check "appuser created on node1" 3 \
  "node1.example.com" "command" "id appuser" "appuser" \
  "Create user from app_user variable"
ansible_check "config file created on node1" 2 \
  "node1.example.com" "stat" "path=/etc/myapp.conf" "exists.*True" \
  "Create /etc/myapp.conf file"
ansible_check "config file has correct content" 2 \
  "node1.example.com" "command" "grep 'app_name=myapp' /etc/myapp.conf" "app_name=myapp" \
  "File should contain variable values"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — Handlers (15 pts)${NC}"
# ─────────────────────────────────────────────
check "files/httpd.conf exists" 2 \
  "test -f $ANSIBLE_DIR/files/httpd.conf" \
  "Create files/httpd.conf with content"
check "use-handlers.yml exists" 3 \
  "test -f $ANSIBLE_DIR/use-handlers.yml" \
  "Create playbook: use-handlers.yml"
check "playbook has handlers section" 3 \
  "grep -q 'handlers:' $ANSIBLE_DIR/use-handlers.yml" \
  "Define handlers section"
check "playbook uses notify" 3 \
  "grep -q 'notify:' $ANSIBLE_DIR/use-handlers.yml && grep -q 'restart httpd' $ANSIBLE_DIR/use-handlers.yml" \
  "Use notify to trigger handler"
check "handler restarts httpd" 2 \
  "grep -A5 'handlers:' $ANSIBLE_DIR/use-handlers.yml | grep -q 'httpd'" \
  "Handler should restart httpd service"
ansible_check "httpd.conf copied to node1" 2 \
  "node1.example.com" "stat" "path=/etc/httpd/conf/httpd.conf" "exists.*True" \
  "Run playbook to copy httpd.conf"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — Gather Facts and Use Them (12 pts)${NC}"
# ─────────────────────────────────────────────
check "use-facts.yml exists" 3 \
  "test -f $ANSIBLE_DIR/use-facts.yml" \
  "Create playbook: use-facts.yml"
check "playbook uses ansible facts" 3 \
  "grep -q 'ansible_hostname' $ANSIBLE_DIR/use-facts.yml && grep -q 'ansible_distribution' $ANSIBLE_DIR/use-facts.yml" \
  "Use Ansible facts like {{ ansible_hostname }}"
ansible_check "system-info.txt created on node1" 3 \
  "node1.example.com" "stat" "path=/tmp/system-info.txt" "exists.*True" \
  "Run playbook to create system-info.txt"
ansible_check "file contains hostname" 2 \
  "node1.example.com" "command" "grep 'Hostname:' /tmp/system-info.txt" "Hostname:" \
  "File should contain hostname information"
ansible_check "file contains OS info" 1 \
  "node1.example.com" "command" "grep 'OS:' /tmp/system-info.txt" "OS:" \
  "File should contain OS information"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 12 — Syntax Check and Dry Run (10 pts)${NC}"
# ─────────────────────────────────────────────
check "validation-commands.sh exists" 3 \
  "test -f $ANSIBLE_DIR/validation-commands.sh" \
  "Create file: validation-commands.sh"
check "file contains syntax-check command" 3 \
  "grep -q 'ansible-playbook.*--syntax-check' $ANSIBLE_DIR/validation-commands.sh" \
  "Add: ansible-playbook --syntax-check first-playbook.yml"
check "file contains check mode command" 3 \
  "grep -q 'ansible-playbook.*--check' $ANSIBLE_DIR/validation-commands.sh" \
  "Add: ansible-playbook --check install-packages.yml"
check "file is executable" 1 \
  "test -x $ANSIBLE_DIR/validation-commands.sh" \
  "Make executable: chmod +x validation-commands.sh"

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
  echo -e "  ${GREEN}Congratulations!${NC} You've mastered Ansible playbook fundamentals."
else
  echo -e "  ${RED}${BOLD}✗ FAIL${NC} — You scored ${BOLD}${PASS}/${TOTAL}${NC} points (${PERCENTAGE}%)"
  echo ""
  echo -e "  ${YELLOW}You need 70% to pass (109/155 points).${NC}"
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
  echo -e "    bash ~/exams/thematic/variables-and-facts/START.sh"
elif [ $PERCENTAGE -ge 70 ]; then
  echo -e "  ${GREEN}✓${NC} Good job! Review failed tasks and try:"
  echo -e "    bash ~/exams/thematic/variables-and-facts/START.sh"
else
  echo -e "  ${YELLOW}→${NC} Review the README.md for solutions"
  echo -e "  ${YELLOW}→${NC} Practice the failed tasks"
  echo -e "  ${YELLOW}→${NC} Retake this exam when ready"
fi

echo ""
echo -e "${CYAN}Resources:${NC}"
echo -e "  • Review solutions: cat ~/exams/thematic/playbooks-fundamentals/README.md | less"
echo -e "  • Ansible docs: ansible-doc <module_name>"
echo -e "  • Playbook guide: ansible-doc -t playbook"
echo ""

# Made with Bob

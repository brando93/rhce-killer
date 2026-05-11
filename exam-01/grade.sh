#!/bin/bash
# ─────────────────────────────────────────────────────────────
# RHCE Killer — Exam 01 Grader
# Run this after completing all tasks to see your score.
# ─────────────────────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

PASS=0
FAIL=0
TOTAL=0
RESULTS=()
FAILED_TASKS=()

# ── Colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'; BLUE='\033[0;34m'

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

  TOTAL=$((TOTAL + PTS))
  OUTPUT=$(ansible "$HOST" -m "$MODULE" -a "$ARGS" -i inventory 2>/dev/null)
  if echo "$OUTPUT" | grep -q "$GREP"; then
    echo -e "  ${GREEN}[PASS]${NC} (+${PTS}pts) $DESC"
    PASS=$((PASS + PTS))
  else
    echo -e "  ${RED}[FAIL]${NC} (  0pts) $DESC"
    FAIL=$((FAIL + PTS))
  fi
}

echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}   RHCE KILLER — Exam 01 Results${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# ─────────────────────────────────────────────
echo -e "${BOLD}Task 01 — Ad-hoc commands (5 pts)${NC}"
# ─────────────────────────────────────────────
check "adhoc-vim.sh file exists" 2 \
  "test -f $ANSIBLE_DIR/adhoc-vim.sh" \
  "Create file: cat > adhoc-vim.sh << 'EOF' ... EOF"
check "vim-enhanced installed on node1" 2 \
  "ansible node1.example.com -m command -a 'rpm -q vim-enhanced' -i inventory 2>/dev/null | grep -q 'vim-enhanced'" \
  "Run: ansible managed -m ansible.builtin.dnf -a 'name=vim-enhanced state=present' --become"
check "vim-enhanced installed on node2" 1 \
  "ansible node2.example.com -m command -a 'rpm -q vim-enhanced' -i inventory 2>/dev/null | grep -q 'vim-enhanced'" \
  "Package should be installed on all managed nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — File content /etc/motd (10 pts)${NC}"
# ─────────────────────────────────────────────
check "motd.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/motd.yml" \
  "Create playbook: motd.yml with ansible.builtin.copy module"
check "/etc/motd content correct on node1" 4 \
  "ansible node1.example.com -m command -a 'grep -q \"Managed by Ansible\" /etc/motd' -i inventory 2>/dev/null" \
  "Use ansible.builtin.copy with content parameter"
check "/etc/motd content correct on node2" 4 \
  "ansible node2.example.com -m command -a 'grep -q \"Managed by Ansible\" /etc/motd' -i inventory 2>/dev/null" \
  "Ensure playbook runs on 'managed' hosts"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — Custom facts (10 pts)${NC}"
# ─────────────────────────────────────────────
check "facts.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/facts.yml" \
  "Create playbook: facts.yml"
check "facts.d directory on node1" 2 \
  "ansible node1 -m command -a 'test -d /etc/ansible/facts.d' -i inventory" \
  "Use ansible.builtin.file module with state: directory"
check "rhce.fact deployed on node1" 3 \
  "ansible node1 -m command -a 'grep -q \"version=1\" /etc/ansible/facts.d/rhce.fact' -i inventory" \
  "Deploy .fact file with INI format content"
check "rhce.fact deployed on node2" 3 \
  "ansible node2 -m command -a 'grep -q \"version=1\" /etc/ansible/facts.d/rhce.fact' -i inventory" \
  "Ensure fact file is on all managed nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Ansible Vault (15 pts)${NC}"
# ─────────────────────────────────────────────
check "vault_pass.txt exists" 2 \
  "test -f $ANSIBLE_DIR/vault_pass.txt" \
  "Create file: echo 'RedHatRHCE2024' > vault_pass.txt"
check "secret.yml is encrypted" 4 \
  "head -1 $ANSIBLE_DIR/group_vars/all/secret.yml | grep -q 'ANSIBLE_VAULT'" \
  "Use: ansible-vault encrypt group_vars/all/secret.yml --vault-password-file vault_pass.txt"
check "secret.yml decrypts correctly" 3 \
  "ansible-vault view $ANSIBLE_DIR/group_vars/all/secret.yml --vault-password-file $ANSIBLE_DIR/vault_pass.txt | grep -q 'db_user'" \
  "Ensure secret.yml contains db_user and db_password variables"
check "create-user.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/create-user.yml" \
  "Create playbook that uses vaulted variables"
check "dbadmin user exists on node1" 4 \
  "ansible node1.example.com -m command -a 'id dbadmin' -i inventory 2>/dev/null" \
  "Use ansible.builtin.user with password_hash('sha512') filter"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Loops and conditionals (10 pts)${NC}"
# ─────────────────────────────────────────────
check "packages.yml exists" 1 \
  "test -f $ANSIBLE_DIR/packages.yml" \
  "Create playbook: packages.yml"
check "httpd installed on node1" 3 \
  "ansible node1.example.com -m command -a 'rpm -q httpd' -i inventory 2>/dev/null | grep -q 'httpd'" \
  "Install httpd with when: inventory_hostname in groups['managed']"
check "httpd running on node1" 2 \
  "ansible node1.example.com -m command -a 'systemctl is-active httpd' -i inventory 2>/dev/null | grep -q 'active'" \
  "Use ansible.builtin.service with state: started, enabled: true"
check "firewalld running on node1" 2 \
  "ansible node1.example.com -m command -a 'systemctl is-active firewalld' -i inventory 2>/dev/null | grep -q 'active'" \
  "Install and start firewalld on all hosts"
check "firewalld running on node2" 2 \
  "ansible node2.example.com -m command -a 'systemctl is-active firewalld' -i inventory 2>/dev/null | grep -q 'active'" \
  "Ensure firewalld is enabled on all managed nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Jinja2 templates (15 pts)${NC}"
# ─────────────────────────────────────────────
check "vhost.conf.j2 template exists" 3 \
  "test -f $ANSIBLE_DIR/templates/vhost.conf.j2" \
  "Create templates/vhost.conf.j2 with Jinja2 variables"
check "vhost.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/vhost.yml" \
  "Create playbook that uses ansible.builtin.template module"
check "vhost.conf deployed on node1" 4 \
  "ansible node1.example.com -m command -a 'test -f /etc/httpd/conf.d/vhost.conf' -i inventory 2>/dev/null" \
  "Deploy template to /etc/httpd/conf.d/vhost.conf"
check "vhost.conf has hostname variable" 3 \
  "ansible node1.example.com -m command -a 'grep -E \"(node1|ip-10-0)\" /etc/httpd/conf.d/vhost.conf' -i inventory 2>/dev/null" \
  "Template should use {{ ansible_hostname }} variable"
check "index.html created on node1" 3 \
  "ansible node1.example.com -m command -a 'test -f /var/www/html/index.html' -i inventory 2>/dev/null" \
  "Create index.html in /var/www/html/"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — Roles (20 pts)${NC}"
# ─────────────────────────────────────────────
check "baseline role directory exists" 2 \
  "test -d $ANSIBLE_DIR/roles/baseline" \
  "Create role: ansible-galaxy init roles/baseline"
check "role has tasks/main.yml" 2 \
  "test -f $ANSIBLE_DIR/roles/baseline/tasks/main.yml" \
  "Edit roles/baseline/tasks/main.yml with required tasks"
check "role has handlers/main.yml" 2 \
  "test -f $ANSIBLE_DIR/roles/baseline/handlers/main.yml" \
  "Handlers file should exist (created by ansible-galaxy init)"
check "baseline.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/baseline.yml" \
  "Create playbook that applies the baseline role"
check "chrony running on node1" 3 \
  "ansible node1.example.com -m command -a 'systemctl is-active chronyd' -i inventory 2>/dev/null | grep -q 'active'" \
  "Role should install and start chronyd service"
check "timezone set on node1" 3 \
  "ansible node1.example.com -m command -a 'timedatectl' -i inventory 2>/dev/null | grep -q 'America/New_York'" \
  "Use timedatectl command with name: America/New_York"
check "/etc/baseline_applied created on node1" 3 \
  "ansible node1.example.com -m command -a 'test -f /etc/baseline_applied' -i inventory 2>/dev/null" \
  "Create file with ansible.builtin.copy or ansible.builtin.file"
check "/etc/baseline_applied created on node2" 3 \
  "ansible node2.example.com -m command -a 'test -f /etc/baseline_applied' -i inventory 2>/dev/null" \
  "Ensure role runs on all managed nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — Collections (10 pts)${NC}"
# ─────────────────────────────────────────────
check "collections/requirements.yml exists" 2 \
  "test -f $ANSIBLE_DIR/collections/requirements.yml" \
  "Create collections/requirements.yml with collections list"
check "ansible.posix installed" 3 \
  "ansible-galaxy collection list ansible.posix --collections-path $ANSIBLE_DIR/collections 2>/dev/null | grep -q 'ansible.posix'" \
  "Install: ansible-galaxy collection install -r collections/requirements.yml -p collections/"
check "community.general installed" 3 \
  "ansible-galaxy collection list community.general --collections-path $ANSIBLE_DIR/collections 2>/dev/null | grep -q 'community.general'" \
  "Ensure both collections are installed locally"
check "posix-demo.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/posix-demo.yml" \
  "Create playbook using ansible.posix.mount module"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — Error handling (10 pts)${NC}"
# ─────────────────────────────────────────────
check "error-handling.yml exists" 2 \
  "test -f $ANSIBLE_DIR/error-handling.yml" \
  "Create playbook with block/rescue/always structure"
check "playbook uses block/rescue" 3 \
  "grep -q 'rescue' $ANSIBLE_DIR/error-handling.yml" \
  "Use block: for tasks, rescue: for error handling, always: for cleanup"
check "/tmp/health-check-ran on node1" 3 \
  "ansible node1.example.com -m command -a 'test -f /tmp/health-check-ran' -i inventory 2>/dev/null" \
  "Create file in always: block so it runs regardless of errors"
check "/tmp/health-check-ran on node2" 2 \
  "ansible node2.example.com -m command -a 'test -f /tmp/health-check-ran' -i inventory 2>/dev/null" \
  "Ensure always block runs on all managed nodes"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — Galaxy role (15 pts)${NC}"
# ─────────────────────────────────────────────
check "roles/requirements.yml exists" 3 \
  "test -f $ANSIBLE_DIR/roles/requirements.yml" \
  "Create roles/requirements.yml with geerlingguy.apache"
check "geerlingguy.apache role installed" 4 \
  "test -d $ANSIBLE_DIR/roles/geerlingguy.apache" \
  "Install: ansible-galaxy role install -r roles/requirements.yml -p roles/"
check "galaxy-apache.yml playbook exists" 3 \
  "test -f $ANSIBLE_DIR/galaxy-apache.yml" \
  "Create playbook that uses geerlingguy.apache role"
check "Apache responding on node1 port 80" 5 \
  "ansible node1.example.com -m command -a 'curl -s -o /dev/null -w %{http_code} http://localhost' -i inventory 2>/dev/null | grep -q '200'" \
  "Ensure Apache is installed, started, and accessible"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 11 — Yum/DNF repositories (10 pts)${NC}"
# ─────────────────────────────────────────────
check "repos.yml playbook exists" 1 \
  "test -f $ANSIBLE_DIR/repos.yml" \
  "Create /home/student/ansible/repos.yml using ansible.builtin.yum_repository"
check "Playbook uses yum_repository module" 1 \
  "grep -q 'yum_repository' $ANSIBLE_DIR/repos.yml" \
  "Use ansible.builtin.yum_repository (NOT copy of a static .repo file)"
check "EX294-BaseOS.repo present on node1" 2 \
  "ansible node1.example.com -m command -a 'test -f /etc/yum.repos.d/EX294-BaseOS.repo' -i inventory 2>/dev/null" \
  "Set the 'file:' parameter to EX294-BaseOS so the .repo file is named correctly"
check "EX294-BaseOS.repo present on node2" 2 \
  "ansible node2.example.com -m command -a 'test -f /etc/yum.repos.d/EX294-BaseOS.repo' -i inventory 2>/dev/null" \
  "Repository must land on every managed node"
check "EX294-AppStream.repo present on node1" 2 \
  "ansible node1.example.com -m command -a 'test -f /etc/yum.repos.d/EX294-AppStream.repo' -i inventory 2>/dev/null" \
  "Set the 'file:' parameter to EX294-AppStream"
check "Both repos visible to dnf on node1" 2 \
  "ansible node1.example.com -b -m shell -a 'dnf repolist 2>/dev/null | grep -E \"EX294-BaseOS|EX294-AppStream\" | wc -l' -i inventory 2>/dev/null | grep -q '2'" \
  "Both repositories must be enabled (enabled: yes)"

# ─────────────────────────────────────────────
# FINAL SCORE
# ─────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"

PCT=$(( PASS * 100 / TOTAL ))

if [ "$PCT" -ge 70 ]; then
  echo -e "${BOLD}${GREEN}  RESULT: PASS ✓${NC}"
  echo -e "${GREEN}  Congratulations! You passed the exam!${NC}"
else
  echo -e "${BOLD}${RED}  RESULT: FAIL ✗${NC}"
  echo -e "${RED}  You need at least 70% to pass.${NC}"
fi

echo ""
echo -e "${BOLD}  Score: ${PASS}/${TOTAL} points (${PCT}%)${NC}"
echo -e "  Passing threshold: 70% (91/130 points)"
echo -e "  Points earned: ${GREEN}${PASS}${NC} | Points lost: ${RED}${FAIL}${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# Show failed tasks with hints
if [ "${#FAILED_TASKS[@]}" -gt 0 ]; then
  echo -e "${BOLD}${YELLOW}📋 Tasks that need attention (${#FAILED_TASKS[@]} failed):${NC}"
  echo ""
  local task_num=1
  for task_info in "${FAILED_TASKS[@]}"; do
    DESC=$(echo "$task_info" | cut -d'|' -f1)
    HINT=$(echo "$task_info" | cut -d'|' -f2)
    echo -e "  ${RED}${task_num}.${NC} ${BOLD}$DESC${NC}"
    if [ -n "$HINT" ]; then
      echo -e "     ${BLUE}💡${NC} $HINT"
    fi
    echo ""
    task_num=$((task_num + 1))
  done
fi

# Show next steps
echo -e "${BOLD}${CYAN}📚 Next Steps:${NC}"
if [ "$PCT" -ge 70 ]; then
  echo -e "  ${GREEN}✓${NC} Review the solutions in the README.md to reinforce learning"
  echo -e "  ${GREEN}✓${NC} Try the exam again to improve your score"
  echo -e "  ${GREEN}✓${NC} Move on to Exam-02 for more advanced topics"
else
  echo -e "  ${YELLOW}→${NC} Review the failed tasks above"
  echo -e "  ${YELLOW}→${NC} Check the solutions section in README.md"
  echo -e "  ${YELLOW}→${NC} Practice the concepts you struggled with"
  echo -e "  ${YELLOW}→${NC} Run: ${CYAN}bash ~/exams/exam-01/START.sh${NC} to try again"
fi
echo ""

# Show useful commands
echo -e "${BOLD}${CYAN}🔧 Useful Commands:${NC}"
echo -e "  ${CYAN}ansible-playbook playbook.yml --syntax-check${NC}  # Check syntax"
echo -e "  ${CYAN}ansible-playbook playbook.yml --check${NC}         # Dry run"
echo -e "  ${CYAN}ansible-doc module_name${NC}                       # Module documentation"
echo -e "  ${CYAN}ansible all -m setup${NC}                          # View all facts"
echo ""

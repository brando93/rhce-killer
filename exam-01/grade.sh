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

# ── Colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

check() {
  local DESC="$1"
  local PTS="$2"
  local CMD="$3"
  TOTAL=$((TOTAL + PTS))

  if eval "$CMD" &>/dev/null; then
    echo -e "  ${GREEN}[PASS]${NC} (+${PTS}pts) $DESC"
    PASS=$((PASS + PTS))
    RESULTS+=("PASS|$PTS|$DESC")
  else
    echo -e "  ${RED}[FAIL]${NC} (  0pts) $DESC"
    FAIL=$((FAIL + PTS))
    RESULTS+=("FAIL|0|$DESC")
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
  "test -f $ANSIBLE_DIR/adhoc-vim.sh"
check "vim-enhanced installed on node1" 2 \
  "ansible node1 -m command -a 'rpm -q vim-enhanced' -i inventory | grep -v 'not installed'"
check "vim-enhanced installed on node2" 1 \
  "ansible node2 -m command -a 'rpm -q vim-enhanced' -i inventory | grep -v 'not installed'"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 02 — File content /etc/motd (10 pts)${NC}"
# ─────────────────────────────────────────────
check "motd.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/motd.yml"
check "/etc/motd content correct on node1" 4 \
  "ansible node1 -m command -a 'grep -q \"Managed by Ansible\" /etc/motd' -i inventory"
check "/etc/motd content correct on node2" 4 \
  "ansible node2 -m command -a 'grep -q \"Managed by Ansible\" /etc/motd' -i inventory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 03 — Custom facts (10 pts)${NC}"
# ─────────────────────────────────────────────
check "facts.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/facts.yml"
check "facts.d directory on node1" 2 \
  "ansible node1 -m command -a 'test -d /etc/ansible/facts.d' -i inventory"
check "rhce.fact deployed on node1" 3 \
  "ansible node1 -m command -a 'grep -q \"version=1\" /etc/ansible/facts.d/rhce.fact' -i inventory"
check "rhce.fact deployed on node2" 3 \
  "ansible node2 -m command -a 'grep -q \"version=1\" /etc/ansible/facts.d/rhce.fact' -i inventory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 04 — Ansible Vault (15 pts)${NC}"
# ─────────────────────────────────────────────
check "vault_pass.txt exists" 2 \
  "test -f $ANSIBLE_DIR/vault_pass.txt"
check "secret.yml is encrypted" 4 \
  "head -1 $ANSIBLE_DIR/group_vars/all/secret.yml | grep -q 'ANSIBLE_VAULT'"
check "secret.yml decrypts correctly" 3 \
  "ansible-vault view $ANSIBLE_DIR/group_vars/all/secret.yml --vault-password-file $ANSIBLE_DIR/vault_pass.txt | grep -q 'db_user'"
check "create-user.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/create-user.yml"
check "dbadmin user exists on node1" 4 \
  "ansible node1 -m command -a 'id dbadmin' -i inventory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 05 — Loops and conditionals (10 pts)${NC}"
# ─────────────────────────────────────────────
check "packages.yml exists" 1 \
  "test -f $ANSIBLE_DIR/packages.yml"
check "httpd installed on node1" 3 \
  "ansible node1 -m command -a 'rpm -q httpd' -i inventory | grep -v 'not installed'"
check "httpd running on node1" 2 \
  "ansible node1 -m command -a 'systemctl is-active httpd' -i inventory | grep -q '^active'"
check "firewalld running on node1" 2 \
  "ansible node1 -m command -a 'systemctl is-active firewalld' -i inventory | grep -q '^active'"
check "firewalld running on node2" 2 \
  "ansible node2 -m command -a 'systemctl is-active firewalld' -i inventory | grep -q '^active'"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 06 — Jinja2 templates (15 pts)${NC}"
# ─────────────────────────────────────────────
check "vhost.conf.j2 template exists" 3 \
  "test -f $ANSIBLE_DIR/templates/vhost.conf.j2"
check "vhost.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/vhost.yml"
check "vhost.conf deployed on node1" 4 \
  "ansible node1 -m command -a 'test -f /etc/httpd/conf.d/vhost.conf' -i inventory"
check "vhost.conf has node1 hostname" 3 \
  "ansible node1 -m command -a 'grep -q node1 /etc/httpd/conf.d/vhost.conf' -i inventory"
check "index.html created on node1" 3 \
  "ansible node1 -m command -a 'test -f /var/www/node1/index.html' -i inventory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 07 — Roles (20 pts)${NC}"
# ─────────────────────────────────────────────
check "baseline role directory exists" 2 \
  "test -d $ANSIBLE_DIR/roles/baseline"
check "role has tasks/main.yml" 2 \
  "test -f $ANSIBLE_DIR/roles/baseline/tasks/main.yml"
check "role has handlers/main.yml" 2 \
  "test -f $ANSIBLE_DIR/roles/baseline/handlers/main.yml"
check "baseline.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/baseline.yml"
check "chrony running on node1" 3 \
  "ansible node1 -m command -a 'systemctl is-active chronyd' -i inventory | grep -q '^active'"
check "timezone set on node1" 3 \
  "ansible node1 -m command -a 'timedatectl | grep New_York' -i inventory"
check "/etc/baseline_applied created on node1" 3 \
  "ansible node1 -m command -a 'test -f /etc/baseline_applied' -i inventory"
check "/etc/baseline_applied created on node2" 3 \
  "ansible node2 -m command -a 'test -f /etc/baseline_applied' -i inventory"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 08 — Collections (10 pts)${NC}"
# ─────────────────────────────────────────────
check "collections/requirements.yml exists" 2 \
  "test -f $ANSIBLE_DIR/collections/requirements.yml"
check "ansible.posix installed" 3 \
  "ansible-galaxy collection list ansible.posix --collections-path $ANSIBLE_DIR/collections 2>/dev/null | grep -q 'ansible.posix'"
check "community.general installed" 3 \
  "ansible-galaxy collection list community.general --collections-path $ANSIBLE_DIR/collections 2>/dev/null | grep -q 'community.general'"
check "posix-demo.yml playbook exists" 2 \
  "test -f $ANSIBLE_DIR/posix-demo.yml"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 09 — Error handling (10 pts)${NC}"
# ─────────────────────────────────────────────
check "error-handling.yml exists" 2 \
  "test -f $ANSIBLE_DIR/error-handling.yml"
check "playbook uses block/rescue" 3 \
  "grep -q 'rescue' $ANSIBLE_DIR/error-handling.yml"
check "/tmp/health-check-ran on node1" 3 \
  "ansible node1 -m command -a 'cat /tmp/health-check-ran' -i inventory | grep -q 'ok'"
check "/tmp/health-check-ran on node2" 2 \
  "ansible node2 -m command -a 'cat /tmp/health-check-ran' -i inventory | grep -q 'ok'"

echo ""
# ─────────────────────────────────────────────
echo -e "${BOLD}Task 10 — Galaxy role (15 pts)${NC}"
# ─────────────────────────────────────────────
check "roles/requirements.yml exists" 3 \
  "test -f $ANSIBLE_DIR/roles/requirements.yml"
check "geerlingguy.apache role installed" 4 \
  "test -d $ANSIBLE_DIR/roles/geerlingguy.apache"
check "galaxy-apache.yml playbook exists" 3 \
  "test -f $ANSIBLE_DIR/galaxy-apache.yml"
check "Apache responding on node1 port 80" 5 \
  "ansible node1 -m uri -a 'url=http://node1.example.com status_code=200' -i inventory"

# ─────────────────────────────────────────────
# FINAL SCORE
# ─────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"

PCT=$(( PASS * 100 / TOTAL ))

if [ "$PCT" -ge 70 ]; then
  echo -e "${BOLD}${GREEN}  RESULT: PASS ✓${NC}"
else
  echo -e "${BOLD}${RED}  RESULT: FAIL ✗${NC}"
fi

echo -e "${BOLD}  Score: ${PASS}/${TOTAL} points (${PCT}%)${NC}"
echo -e "  Passing threshold: 70% (84/120 points)"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

if [ "$PCT" -lt 70 ]; then
  echo -e "${YELLOW}  Failed tasks to review:${NC}"
  for r in "${RESULTS[@]}"; do
    STATUS=$(echo "$r" | cut -d'|' -f1)
    if [ "$STATUS" = "FAIL" ]; then
      DESC=$(echo "$r" | cut -d'|' -f3)
      echo -e "  ${RED}✗${NC} $DESC"
    fi
  done
  echo ""
fi

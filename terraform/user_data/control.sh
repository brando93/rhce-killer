#!/bin/bash
# RHCE Killer — Control Node Bootstrap
# Logs everything; errors are captured but do NOT abort the script
exec > /var/log/rhce-bootstrap.log 2>&1
set -x

echo "=== RHCE Killer Lab Bootstrap: Control Node ==="
echo "Started at: $(date)"

# ─────────────────────────────────────────────
# /etc/hosts
# ─────────────────────────────────────────────
cat >> /etc/hosts <<EOF
10.0.1.10  control.example.com  control
${node1_ip}  node1.example.com    node1
${node2_ip}  node2.example.com    node2
EOF

# ─────────────────────────────────────────────
# System packages
# ─────────────────────────────────────────────
dnf update -y
dnf install -y \
  ansible-core \
  python3 \
  python3-pip \
  git \
  vim \
  tree \
  tmux \
  wget \
  curl \
  bash-completion

# ─────────────────────────────────────────────
# Ansible collections for the RHCE exam
# ─────────────────────────────────────────────
ansible-galaxy collection install ansible.posix community.general \
  --collections-path /usr/share/ansible/collections || true

# ─────────────────────────────────────────────
# Create student user
# ─────────────────────────────────────────────
id student &>/dev/null || useradd -m -s /bin/bash student
echo "student ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/student
chmod 440 /etc/sudoers.d/student

# ─────────────────────────────────────────────
# SSH key for student → nodes
# Terraform passes the private key via templatefile()
# ─────────────────────────────────────────────
mkdir -p /home/student/.ssh
chmod 700 /home/student/.ssh

# Write the private key (passed by Terraform templatefile)
cat > /home/student/.ssh/id_rsa <<'SSHKEY'
${private_key}
SSHKEY
chmod 600 /home/student/.ssh/id_rsa

# Derive the public key from the private key
ssh-keygen -y -f /home/student/.ssh/id_rsa > /home/student/.ssh/id_rsa.pub
chmod 644 /home/student/.ssh/id_rsa.pub

# SSH client config — no host key checking for lab nodes
cat > /home/student/.ssh/config <<EOF
Host node1 node1.example.com 10.0.1.11
  HostName 10.0.1.11
  User rocky
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host node2 node2.example.com 10.0.1.12
  HostName 10.0.1.12
  User rocky
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
chmod 600 /home/student/.ssh/config

# Also copy key to rocky's .ssh so rocky can SSH to nodes during bootstrap
cp /home/student/.ssh/id_rsa /root/.ssh/rhce_key
chmod 600 /root/.ssh/rhce_key

chown -R student:student /home/student/.ssh

# ─────────────────────────────────────────────
# Exam workspace — mirrors the real EX294 layout
# ─────────────────────────────────────────────
ANSIBLE_DIR="/home/student/ansible"
mkdir -p "$ANSIBLE_DIR"/{roles,collections,group_vars,host_vars,templates,files}

cat > "$ANSIBLE_DIR/ansible.cfg" <<EOF
[defaults]
inventory         = /home/student/ansible/inventory
roles_path        = /home/student/ansible/roles
collections_paths = /home/student/ansible/collections:/usr/share/ansible/collections
remote_user       = rocky
host_key_checking = False

[privilege_escalation]
become          = True
become_method   = sudo
become_user     = root
become_ask_pass = False
EOF

cat > "$ANSIBLE_DIR/inventory" <<EOF
[control]
control.example.com ansible_connection=local

[managed]
node1.example.com
node2.example.com

[all:vars]
ansible_user=rocky
EOF

chown -R student:student "$ANSIBLE_DIR"

# ─────────────────────────────────────────────
# Push student's public key to managed nodes
# Retry loop — nodes take time to boot
# ─────────────────────────────────────────────
PUBKEY=$(cat /home/student/.ssh/id_rsa.pub)

for NODE_IP in ${node1_ip} ${node2_ip}; do
  echo "  [INFO] Waiting for $NODE_IP to accept SSH..."
  for i in $(seq 1 20); do
    if ssh \
        -i /root/.ssh/authorized_keys \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        -o BatchMode=yes \
        rocky@"$NODE_IP" \
        "mkdir -p ~/.ssh && echo '$PUBKEY' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" \
        2>/dev/null; then
      echo "  [OK] Key deployed to $NODE_IP (attempt $i)"
      break
    fi
    # Also try with the rhce_key (same key, root's copy)
    if ssh \
        -i /root/.ssh/rhce_key \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        -o BatchMode=yes \
        rocky@"$NODE_IP" \
        "mkdir -p ~/.ssh && echo '$PUBKEY' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" \
        2>/dev/null; then
      echo "  [OK] Key deployed to $NODE_IP via rhce_key (attempt $i)"
      break
    fi
    echo "  [WAIT] $NODE_IP not ready (attempt $i/20) — sleeping 15s..."
    sleep 15
  done
done

# ─────────────────────────────────────────────
# Exam scripts directory
# ─────────────────────────────────────────────
EXAMS_DIR="/home/student/exams/exam-01"
mkdir -p "$EXAMS_DIR"

# START.sh — 4-hour countdown timer
cat > "$EXAMS_DIR/START.sh" <<'STARTEOF'
#!/bin/bash
EXAM_DURATION=$((4 * 60 * 60))
START_TIME=$(date +%s)
END_TIME=$((START_TIME + EXAM_DURATION))
echo "$START_TIME" > /home/student/.exam_start_time
clear
cat <<BANNER
╔══════════════════════════════════════════════════════════════╗
║           RHCE KILLER — EX294 Practice Exam 01               ║
╠══════════════════════════════════════════════════════════════╣
║  Duration : 4 hours                                          ║
║  Start    : $(date '+%H:%M:%S %Z')                                    ║
║  End      : $(date -d "@$END_TIME" '+%H:%M:%S %Z')                              ║
║                                                              ║
║  Read tasks : cat ~/exams/exam-01/README.md                  ║
║  Grade now  : bash ~/exams/exam-01/grade.sh                  ║
║  Press Ctrl+C to exit timer (exam continues)                 ║
╚══════════════════════════════════════════════════════════════╝
BANNER
while true; do
  NOW=$(date +%s)
  REMAINING=$((END_TIME - NOW))
  [ "$REMAINING" -le 0 ] && echo -e "\n\n  TIME IS UP — run: bash ~/exams/exam-01/grade.sh" && break
  HH=$((REMAINING / 3600))
  MM=$(( (REMAINING % 3600) / 60 ))
  SS=$((REMAINING % 60))
  if   [ "$REMAINING" -le 300 ];  then COLOR="\033[0;31m"
  elif [ "$REMAINING" -le 900 ];  then COLOR="\033[1;33m"
  else COLOR="\033[0;36m"; fi
  printf "\r  ${COLOR}Time remaining: %02d:%02d:%02d\033[0m   " "$HH" "$MM" "$SS"
  sleep 1
done
STARTEOF

# grade.sh — checks actual results on nodes
cat > "$EXAMS_DIR/grade.sh" <<'GRADEEOF'
#!/bin/bash
ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || { echo "ERROR: $ANSIBLE_DIR not found"; exit 1; }

PASS=0; FAIL=0; TOTAL=0
GREEN='\033[0;32m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

check() {
  local DESC="$1" PTS="$2" CMD="$3"
  TOTAL=$((TOTAL + PTS))
  if eval "$CMD" &>/dev/null; then
    echo -e "  ${GREEN}[PASS]${NC} (+${PTS}pts) $DESC"; PASS=$((PASS + PTS))
  else
    echo -e "  ${RED}[FAIL]${NC} (  0pts) $DESC"; FAIL=$((FAIL + PTS))
  fi
}

echo -e "\n${BOLD}${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}   RHCE KILLER — Exam 01 Score${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════${NC}\n"

echo -e "${BOLD}Task 01 — Ad-hoc commands (5 pts)${NC}"
check "adhoc-vim.sh exists" 2 "test -f $ANSIBLE_DIR/adhoc-vim.sh"
check "vim-enhanced on node1" 2 "ansible node1 -m command -a 'rpm -q vim-enhanced' -i inventory | grep -v 'not installed'"
check "vim-enhanced on node2" 1 "ansible node2 -m command -a 'rpm -q vim-enhanced' -i inventory | grep -v 'not installed'"

echo -e "\n${BOLD}Task 02 — /etc/motd (10 pts)${NC}"
check "motd.yml exists" 2 "test -f $ANSIBLE_DIR/motd.yml"
check "/etc/motd correct on node1" 4 "ansible node1 -m command -a 'grep -q \"Managed by Ansible\" /etc/motd' -i inventory"
check "/etc/motd correct on node2" 4 "ansible node2 -m command -a 'grep -q \"Managed by Ansible\" /etc/motd' -i inventory"

echo -e "\n${BOLD}Task 03 — Custom facts (10 pts)${NC}"
check "facts.yml exists" 2 "test -f $ANSIBLE_DIR/facts.yml"
check "rhce.fact on node1" 4 "ansible node1 -m command -a 'grep -q version=1 /etc/ansible/facts.d/rhce.fact' -i inventory"
check "rhce.fact on node2" 4 "ansible node2 -m command -a 'grep -q version=1 /etc/ansible/facts.d/rhce.fact' -i inventory"

echo -e "\n${BOLD}Task 04 — Vault (15 pts)${NC}"
check "vault_pass.txt exists" 2 "test -f $ANSIBLE_DIR/vault_pass.txt"
check "secret.yml is encrypted" 4 "head -1 $ANSIBLE_DIR/group_vars/all/secret.yml 2>/dev/null | grep -q ANSIBLE_VAULT"
check "secret.yml decrypts OK" 3 "ansible-vault view $ANSIBLE_DIR/group_vars/all/secret.yml --vault-password-file $ANSIBLE_DIR/vault_pass.txt | grep -q db_user"
check "create-user.yml exists" 2 "test -f $ANSIBLE_DIR/create-user.yml"
check "dbadmin user on node1" 4 "ansible node1 -m command -a 'id dbadmin' -i inventory"

echo -e "\n${BOLD}Task 05 — Loops/conditionals (10 pts)${NC}"
check "packages.yml exists" 1 "test -f $ANSIBLE_DIR/packages.yml"
check "httpd running on node1" 3 "ansible node1 -m command -a 'systemctl is-active httpd' -i inventory | grep -q active"
check "firewalld running on node1" 3 "ansible node1 -m command -a 'systemctl is-active firewalld' -i inventory | grep -q active"
check "firewalld running on node2" 3 "ansible node2 -m command -a 'systemctl is-active firewalld' -i inventory | grep -q active"

echo -e "\n${BOLD}Task 06 — Jinja2 templates (15 pts)${NC}"
check "vhost.conf.j2 exists" 3 "test -f $ANSIBLE_DIR/templates/vhost.conf.j2"
check "vhost.yml exists" 2 "test -f $ANSIBLE_DIR/vhost.yml"
check "vhost.conf on node1" 4 "ansible node1 -m command -a 'test -f /etc/httpd/conf.d/vhost.conf' -i inventory"
check "index.html on node1" 3 "ansible node1 -m command -a 'test -f /var/www/node1/index.html' -i inventory"
check "index.html has hostname" 3 "ansible node1 -m command -a 'grep -q node1 /var/www/node1/index.html' -i inventory"

echo -e "\n${BOLD}Task 07 — Roles (20 pts)${NC}"
check "baseline role exists" 2 "test -d $ANSIBLE_DIR/roles/baseline"
check "tasks/main.yml exists" 2 "test -f $ANSIBLE_DIR/roles/baseline/tasks/main.yml"
check "baseline.yml exists" 2 "test -f $ANSIBLE_DIR/baseline.yml"
check "chronyd running on node1" 3 "ansible node1 -m command -a 'systemctl is-active chronyd' -i inventory | grep -q active"
check "timezone set on node1" 4 "ansible node1 -m command -a 'timedatectl | grep New_York' -i inventory"
check "/etc/baseline_applied on node1" 4 "ansible node1 -m command -a 'test -f /etc/baseline_applied' -i inventory"
check "/etc/baseline_applied on node2" 3 "ansible node2 -m command -a 'test -f /etc/baseline_applied' -i inventory"

echo -e "\n${BOLD}Task 08 — Collections (10 pts)${NC}"
check "requirements.yml exists" 2 "test -f $ANSIBLE_DIR/collections/requirements.yml"
check "ansible.posix installed" 4 "ansible-galaxy collection list --collections-path $ANSIBLE_DIR/collections 2>/dev/null | grep -q 'ansible.posix'"
check "posix-demo.yml exists" 2 "test -f $ANSIBLE_DIR/posix-demo.yml"
check "tmpbind mounted on node2" 2 "ansible node2 -m command -a 'mount | grep tmpbind' -i inventory"

echo -e "\n${BOLD}Task 09 — Error handling (10 pts)${NC}"
check "error-handling.yml exists" 2 "test -f $ANSIBLE_DIR/error-handling.yml"
check "block/rescue in playbook" 3 "grep -q rescue $ANSIBLE_DIR/error-handling.yml"
check "/tmp/health-check-ran node1" 3 "ansible node1 -m command -a 'cat /tmp/health-check-ran' -i inventory | grep -q ok"
check "/tmp/health-check-ran node2" 2 "ansible node2 -m command -a 'cat /tmp/health-check-ran' -i inventory | grep -q ok"

echo -e "\n${BOLD}Task 10 — Galaxy role (15 pts)${NC}"
check "roles/requirements.yml exists" 3 "test -f $ANSIBLE_DIR/roles/requirements.yml"
check "geerlingguy.apache installed" 4 "test -d $ANSIBLE_DIR/roles/geerlingguy.apache"
check "galaxy-apache.yml exists" 3 "test -f $ANSIBLE_DIR/galaxy-apache.yml"
check "Apache on node1 port 80" 5 "ansible node1 -m uri -a 'url=http://node1.example.com status_code=200' -i inventory"

PCT=$(( PASS * 100 / TOTAL ))
echo -e "\n${BOLD}${CYAN}═══════════════════════════════════════════${NC}"
if [ "$PCT" -ge 70 ]; then
  echo -e "${BOLD}\033[0;32m  RESULT: PASS ✓${NC}"
else
  echo -e "${BOLD}\033[0;31m  RESULT: FAIL ✗${NC}"
fi
echo -e "${BOLD}  Score: ${PASS}/${TOTAL} (${PCT}%)   Passing: 70%${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}\n"
GRADEEOF

chmod +x "$EXAMS_DIR/START.sh" "$EXAMS_DIR/grade.sh"
chown -R student:student /home/student/exams

# ─────────────────────────────────────────────
# reset-lab.sh
# ─────────────────────────────────────────────
cat > /home/student/reset-lab.sh <<'RESETEOF'
#!/bin/bash
ANSIBLE_DIR="/home/student/ansible"
cd "$ANSIBLE_DIR" || exit 1
echo "Cleaning managed nodes..."
ansible managed -i inventory -m package -a "name=httpd,mariadb-server,firewalld,chrony state=absent" --become 2>/dev/null || true
ansible managed -i inventory -m command -a "bash -c 'userdel -r dbadmin 2>/dev/null; timedatectl set-timezone UTC; rm -f /etc/motd /etc/baseline_applied /tmp/health-check-ran /tmp/service-failed'" --become 2>/dev/null || true
echo "Cleaning ~/ansible workspace..."
find "$ANSIBLE_DIR" -maxdepth 1 -name "*.yml" -delete
find "$ANSIBLE_DIR" -maxdepth 1 -name "*.sh"  -delete
rm -rf "$ANSIBLE_DIR/roles" "$ANSIBLE_DIR/templates" \
       "$ANSIBLE_DIR/collections" "$ANSIBLE_DIR/group_vars" \
       "$ANSIBLE_DIR/host_vars" "$ANSIBLE_DIR/vault_pass.txt"
mkdir -p "$ANSIBLE_DIR"/{roles,collections,group_vars/all,host_vars,templates,files}
echo "Done — lab is clean. Start exam: bash ~/exams/exam-01/START.sh"
RESETEOF
chmod +x /home/student/reset-lab.sh
chown student:student /home/student/reset-lab.sh

# ─────────────────────────────────────────────
# MOTD
# ─────────────────────────────────────────────
cat > /etc/motd <<'MOTD'
╔══════════════════════════════════════════════════════════════╗
║           RHCE KILLER — EX294 Practice Lab                   ║
╠══════════════════════════════════════════════════════════════╣
║  Control node  : control.example.com (10.0.1.10)            ║
║  Managed node1 : node1.example.com   (10.0.1.11)            ║
║  Managed node2 : node2.example.com   (10.0.1.12)            ║
╠══════════════════════════════════════════════════════════════╣
║  Exam workspace: ~/ansible/                                  ║
║  Start exam    : bash ~/exams/exam-01/START.sh               ║
║  Check score   : bash ~/exams/exam-01/grade.sh               ║
║  Reset lab     : bash ~/reset-lab.sh                         ║
╚══════════════════════════════════════════════════════════════╝
MOTD

echo "=== Bootstrap complete at: $(date) ==="

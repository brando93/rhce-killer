#!/bin/bash
# ─────────────────────────────────────────────
# RHCE Killer — Reset Lab
# Wipes all exam work from managed nodes so you
# can attempt the exam again from a clean state.
# ─────────────────────────────────────────────

ANSIBLE_DIR="/home/student/ansible"

echo "╔══════════════════════════════════════════════╗"
echo "║       RHCE Killer — Lab Reset                ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "This will:"
echo "  - Remove installed packages (httpd, mariadb-server, etc.)"
echo "  - Remove all files created by exam tasks on the nodes"
echo "  - Clear your ~/ansible/ working directory"
echo "  - Keep SSH keys and connectivity intact"
echo ""
read -p "Reset the lab? (yes/no): " CONFIRM
[ "$CONFIRM" != "yes" ] && echo "Cancelled." && exit 0

cd "$ANSIBLE_DIR" || exit 1

echo ""
echo "  [1/4] Cleaning managed nodes..."

ansible managed -i inventory -m package -a \
  "name=httpd,mariadb-server,firewalld,chrony state=absent" \
  --become 2>/dev/null || true

ansible managed -i inventory -m file -a \
  "path={{ item }} state=absent" \
  --become \
  -e '{"item": ["/etc/motd", "/etc/ansible/facts.d/rhce.fact", "/etc/httpd/conf.d/vhost.conf", "/etc/baseline_applied", "/tmp/health-check-ran", "/tmp/service-failed", "/mnt/tmpbind"]}' \
  2>/dev/null || true

ansible managed -i inventory -m command -a \
  "bash -c 'userdel -r dbadmin 2>/dev/null; timedatectl set-timezone UTC'" \
  --become 2>/dev/null || true

echo "  [2/4] Cleaning ansible working directory..."
# Remove exam files but keep inventory, ansible.cfg, and SSH config
find "$ANSIBLE_DIR" -maxdepth 1 -name "*.yml" -delete
find "$ANSIBLE_DIR" -maxdepth 1 -name "*.sh" -delete
rm -rf "$ANSIBLE_DIR/roles" "$ANSIBLE_DIR/templates" \
       "$ANSIBLE_DIR/collections" "$ANSIBLE_DIR/group_vars" \
       "$ANSIBLE_DIR/host_vars" "$ANSIBLE_DIR/vault_pass.txt"

echo "  [3/4] Recreating clean directory structure..."
mkdir -p "$ANSIBLE_DIR"/{roles,collections,group_vars/all,host_vars,templates}

echo "  [4/4] Verifying connectivity..."
ansible managed -i inventory -m ping 2>/dev/null && \
  echo "  Nodes reachable ✓" || echo "  WARNING: Node connectivity issue"

echo ""
echo "  ✓ Lab reset complete. Ready for another attempt."
echo ""
echo "  Start exam: bash ~/exams/exam-01/START.sh"
echo "  Read tasks: cat ~/exams/exam-01/README.md"

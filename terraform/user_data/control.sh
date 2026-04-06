#!/bin/bash
set -eo pipefail
exec > /var/log/rhce-bootstrap.log 2>&1
echo "=== RHCE Killer Lab Bootstrap: Control Node ==="
echo "Started at: $(date)"

cat >> /etc/hosts <<EOF
10.0.1.10  control.example.com  control
${node1_ip}  node1.example.com    node1
${node2_ip}  node2.example.com    node2
EOF

dnf update -y
dnf install -y ansible-core python3 python3-pip git vim tree tmux wget curl bash-completion

ansible-galaxy collection install ansible.posix community.general --collections-path /usr/share/ansible/collections

useradd -m -s /bin/bash student
echo "student ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/student
chmod 440 /etc/sudoers.d/student

mkdir -p /home/student/.ssh
chmod 700 /home/student/.ssh

cat > /home/student/.ssh/id_rsa <<'SSHKEY'
${private_key}
SSHKEY

chmod 600 /home/student/.ssh/id_rsa
chown -R student:student /home/student/.ssh

su - student -c "ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub"

cat > /home/student/.ssh/authorized_keys <<'AUTHKEY'
${public_key}
AUTHKEY

chmod 600 /home/student/.ssh/authorized_keys
chown student:student /home/student/.ssh/authorized_keys

cat > /home/student/.ssh/config <<EOF
Host node1 node1.example.com ${node1_ip}
  HostName ${node1_ip}
  User student
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host node2 node2.example.com ${node2_ip}
  HostName ${node2_ip}
  User student
  IdentityFile ~/.ssh/id_rsa
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
chmod 600 /home/student/.ssh/config
chown student:student /home/student/.ssh/config

ANSIBLE_DIR="/home/student/ansible"
mkdir -p $ANSIBLE_DIR/{roles,collections,group_vars,host_vars}

cat > $ANSIBLE_DIR/ansible.cfg <<EOF
[defaults]
inventory       = /home/student/ansible/inventory
roles_path      = /home/student/ansible/roles
collections_path= /home/student/ansible/collections
remote_user     = student
host_key_checking = False

[privilege_escalation]
become       = True
become_method= sudo
become_user  = root
become_ask_pass = False
EOF

cat > $ANSIBLE_DIR/inventory <<EOF
[control]
control.example.com ansible_connection=local

[managed]
node1.example.com
node2.example.com

[all:vars]
ansible_user=student
EOF

chown -R student:student $ANSIBLE_DIR

EXAMS_DIR="/home/student/exams"
mkdir -p "$EXAMS_DIR"/{complete,thematic}

for exam in exam-01 exam-02 exam-03 exam-04 exam-05; do
  mkdir -p "$EXAMS_DIR/complete/$exam"
  echo "# RHCE Killer Exam - Run: make sync-exams" > "$EXAMS_DIR/complete/$exam/README.md"
  echo '#!/bin/bash' > "$EXAMS_DIR/complete/$exam/START.sh"
  echo 'echo "Run: make sync-exams"' >> "$EXAMS_DIR/complete/$exam/START.sh"
  echo '#!/bin/bash' > "$EXAMS_DIR/complete/$exam/grade.sh"
  echo 'echo "Run: make sync-exams"' >> "$EXAMS_DIR/complete/$exam/grade.sh"
  chmod +x "$EXAMS_DIR/complete/$exam"/*.sh
done

for exam in inventory-basics playbooks-fundamentals variables-and-facts conditionals-and-when loops-and-iteration blocks-and-error-handling jinja2-basics jinja2-advanced ansible-vault ssh-and-privilege roles-basics roles-advanced collections-and-galaxy debugging-and-troubleshooting performance-optimization system-administration; do
  mkdir -p "$EXAMS_DIR/thematic/$exam"
  echo "# RHCE Killer Thematic Exam - Run: make sync-exams" > "$EXAMS_DIR/thematic/$exam/README.md"
  echo '#!/bin/bash' > "$EXAMS_DIR/thematic/$exam/START.sh"
  echo 'echo "Run: make sync-exams"' >> "$EXAMS_DIR/thematic/$exam/START.sh"
  echo '#!/bin/bash' > "$EXAMS_DIR/thematic/$exam/grade.sh"
  echo 'echo "Run: make sync-exams"' >> "$EXAMS_DIR/thematic/$exam/grade.sh"
  chmod +x "$EXAMS_DIR/thematic/$exam"/*.sh
done

chown -R student:student "$EXAMS_DIR"

cat > /etc/motd <<'MOTD'
╔══════════════════════════════════════════════════════════════╗
║           RHCE KILLER — EX294 Practice Lab                   ║
║                  21 Exams Available                          ║
╠══════════════════════════════════════════════════════════════╣
║  Control node  : control.example.com (10.0.1.10)            ║
║  Managed nodes : node1, node2                                ║
╠══════════════════════════════════════════════════════════════╣
║  📚 TWO LEARNING PATHS AVAILABLE                             ║
╠══════════════════════════════════════════════════════════════╣
║  PATH A: Complete Exams (Real Exam Simulation)               ║
║    Location: ~/exams/complete/                               ║
║    • exam-01 to exam-05 (4 hours each)                       ║
║    • Start: bash ~/exams/complete/exam-01/START.sh           ║
║                                                              ║
║  PATH B: Thematic Exams (Deep Learning by Topic)             ║
║    Location: ~/exams/thematic/                               ║
║    • 16 topic-focused exams (2-3.5 hours each)               ║
║    • Start: bash ~/exams/thematic/inventory-basics/START.sh  ║
╠══════════════════════════════════════════════════════════════╣
║  📖 Quick Reference                                          ║
║    Workspace   : cd ~/ansible/                               ║
║    List exams  : ls ~/exams/complete/ ~/exams/thematic/      ║
║    Sync files  : make sync-exams (from local machine)        ║
║    Ansible docs: ansible-doc <module_name>                   ║
╠══════════════════════════════════════════════════════════════╣
║  🎯 Recommended: New to Ansible? Start with Path B           ║
║     Preparing for EX294? Use Path A for timed practice       ║
║                                                              ║
║  💡 Tip: All exams have complete solutions in README files!  ║
╚══════════════════════════════════════════════════════════════╝
MOTD

echo "=== Bootstrap complete at: $(date) ==="

# Made with Bob

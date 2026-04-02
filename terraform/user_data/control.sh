#!/bin/bash
set -eo pipefail
exec > /var/log/rhce-bootstrap.log 2>&1

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

# Install ansible collections needed for RHCE exam (EX294)
# Note: redhat.rhel_system_roles is NOT required for EX294 and needs RH subscription
ansible-galaxy collection install \
  ansible.posix \
  community.general \
  --collections-path /usr/share/ansible/collections

# ─────────────────────────────────────────────
# Create student user (exam uses this user)
# ─────────────────────────────────────────────
useradd -m -s /bin/bash student
echo "student ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/student
chmod 440 /etc/sudoers.d/student

# ─────────────────────────────────────────────
# SSH key for student → nodes (passwordless)
# ─────────────────────────────────────────────
mkdir -p /home/student/.ssh
chmod 700 /home/student/.ssh

# Write the Terraform-generated private key
cat > /home/student/.ssh/id_rsa <<'SSHKEY'
${private_key}
SSHKEY

chmod 600 /home/student/.ssh/id_rsa
chown -R student:student /home/student/.ssh

# Generate public key from private key
su - student -c "ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub"

# SSH client config — no host key checking for lab nodes
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

# ─────────────────────────────────────────────
# Exam workspace: /home/student/ansible
# (mirrors exactly what the exam provides)
# ─────────────────────────────────────────────
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

# ─────────────────────────────────────────────
# SSH key is already deployed to nodes via their bootstrap script
# No need to copy keys here - nodes have student user with authorized_keys
# ─────────────────────────────────────────────
echo "SSH passwordless access configured via bootstrap scripts"

# ─────────────────────────────────────────────
# Copy exam files from local repository
# Note: For production, push to GitHub and use:
# REPO_URL="https://raw.githubusercontent.com/YOUR_USERNAME/rhce-killer/main"
# ─────────────────────────────────────────────
EXAMS_DIR="/home/student/exams"
LOCAL_REPO="/tmp/rhce-killer-exams"

echo "Setting up exam files..."

# Create temporary directory for exam files
mkdir -p "$LOCAL_REPO"

# Create exam directories
for exam in exam-01 exam-02 exam-03 exam-04 exam-05; do
  mkdir -p "$EXAMS_DIR/$exam"
done

# For testing: Create placeholder files that will be replaced via SCP after deployment
# In production, these would be downloaded from GitHub
for exam in exam-01 exam-02 exam-03 exam-04 exam-05; do
  echo "Setting up $exam..."
  
  # Create placeholder README
  cat > "$EXAMS_DIR/$exam/README.md" <<'EXAMREADME'
# RHCE Killer Exam

This exam file will be synced after deployment.

To sync exam files manually:
1. From your local machine, run: make sync-exams
2. Or manually: scp -i rhce-killer.pem -r exam-* rocky@CONTROL_IP:/tmp/
3. Then on control node: sudo cp -r /tmp/exam-* /home/student/exams/ && sudo chown -R student:student /home/student/exams/

EXAMREADME
  
  # Create placeholder START.sh
  cat > "$EXAMS_DIR/$exam/START.sh" <<'STARTSH'
#!/bin/bash
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  RHCE Killer - Exam Timer                                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Exam files need to be synced. Please run: make sync-exams"
echo ""
STARTSH
  
  # Create placeholder grade.sh
  cat > "$EXAMS_DIR/$exam/grade.sh" <<'GRADESH'
#!/bin/bash
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  RHCE Killer - Grading Script                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Exam files need to be synced. Please run: make sync-exams"
echo ""
GRADESH
  
  # Set permissions
  chmod +x "$EXAMS_DIR/$exam"/*.sh
done

chown -R student:student "$EXAMS_DIR"
echo "Exam directory structure created. Files will be synced after deployment."

# ─────────────────────────────────────────────
# MOTD — shown when you SSH into control
# ─────────────────────────────────────────────
cat > /etc/motd <<'MOTD'
╔══════════════════════════════════════════════════════════════╗
║           RHCE KILLER — EX294 Practice Lab                   ║
╠══════════════════════════════════════════════════════════════╣
║  Control node  : control.example.com (10.0.1.10)            ║
║  Managed nodes : node1, node2                                ║
╠══════════════════════════════════════════════════════════════╣
║  📚 AVAILABLE EXAMS (Progressive Difficulty)                 ║
╠══════════════════════════════════════════════════════════════╣
║  Exam 01: Basic Ansible Tasks              (100 pts) ⭐      ║
║    Start: bash ~/exams/exam-01/START.sh                      ║
║    Grade: bash ~/exams/exam-01/grade.sh                      ║
║                                                              ║
║  Exam 02: Intermediate Tasks               (120 pts) ⭐⭐    ║
║    Start: bash ~/exams/exam-02/START.sh                      ║
║    Grade: bash ~/exams/exam-02/grade.sh                      ║
║                                                              ║
║  Exam 03: Roles & Collections              (120 pts) ⭐⭐⭐  ║
║    Start: bash ~/exams/exam-03/START.sh                      ║
║    Grade: bash ~/exams/exam-03/grade.sh                      ║
║                                                              ║
║  Exam 04: Linux Administration             (120 pts) ⭐⭐⭐  ║
║    Start: bash ~/exams/exam-04/START.sh                      ║
║    Grade: bash ~/exams/exam-04/grade.sh                      ║
║                                                              ║
║  Exam 05: Troubleshooting & Advanced       (150 pts) ⭐⭐⭐⭐║
║    Start: bash ~/exams/exam-05/START.sh                      ║
║    Grade: bash ~/exams/exam-05/grade.sh                      ║
╠══════════════════════════════════════════════════════════════╣
║  📖 Quick Reference                                          ║
║    Workspace    : cd ~/ansible/                              ║
║    List exams   : ls ~/exams/                                ║
║    View exam    : cat ~/exams/exam-01/README.md | less       ║
║    Ansible docs : ansible-doc <module_name>                  ║
╠══════════════════════════════════════════════════════════════╣
║  🎯 Recommended Study Path:                                  ║
║    1. Start with Exam 01 (Basics)                            ║
║    2. Progress to Exam 02 (Intermediate)                     ║
║    3. Master Exam 03 (Roles & Collections)                   ║
║    4. Complete Exam 04 (System Administration)               ║
║    5. Challenge Exam 05 (Expert Level)                       ║
║                                                              ║
║  💡 Tip: Each exam has complete solutions in its README!     ║
╚══════════════════════════════════════════════════════════════╝
MOTD

echo "=== Bootstrap complete at: $(date) ==="

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
# Create exam files - use simple approach to avoid user_data size limit
# ─────────────────────────────────────────────
mkdir -p /home/student/exams/exam-01

# Copy exam files from the repo directory (mounted via cloud-init or downloaded)
# For now, create minimal placeholders
cat > /home/student/exams/exam-01/README.md <<'EOF'
# RHCE Killer - Exam 01

Exam files will be populated here.
Check the project repository for full exam content.
EOF

cat > /home/student/exams/exam-01/START.sh <<'EOF'
#!/bin/bash
echo "Exam timer - implement your timer here"
EOF

cat > /home/student/exams/exam-01/grade.sh <<'EOF'
#!/bin/bash
echo "Grading script - implement grading logic here"
EOF

chmod +x /home/student/exams/exam-01/*.sh
chown -R student:student /home/student/exams

# ─────────────────────────────────────────────
# MOTD — shown when you SSH into control
# ─────────────────────────────────────────────
cat > /etc/motd <<MOTD
╔══════════════════════════════════════════════════════════════╗
║           RHCE KILLER — EX294 Practice Lab                   ║
╠══════════════════════════════════════════════════════════════╣
║  Control node  : control.example.com (10.0.1.10)            ║
║  Managed node1 : node1.example.com   (${node1_ip})            ║
║  Managed node2 : node2.example.com   (${node2_ip})            ║
╠══════════════════════════════════════════════════════════════╣
║  Exam workspace: ~/ansible/                                  ║
║  Start exam    : cd ~/ansible && bash ~/exams/exam-01/START  ║
║  Check score   : bash ~/exams/exam-01/grade.sh               ║
║  Reset lab     : bash ~/reset-lab.sh                         ║
╚══════════════════════════════════════════════════════════════╝
MOTD

echo "=== Bootstrap complete at: $(date) ==="

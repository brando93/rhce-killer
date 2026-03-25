#!/bin/bash
exec > /var/log/rhce-node-bootstrap.log 2>&1
set -x

echo "=== RHCE Killer Lab Bootstrap: Managed Node ==="
echo "Started at: $(date)"

# ─────────────────────────────────────────────
# /etc/hosts
# ─────────────────────────────────────────────
cat >> /etc/hosts <<EOF
10.0.1.10  control.example.com  control
10.0.1.11  node1.example.com    node1
10.0.1.12  node2.example.com    node2
EOF

# ─────────────────────────────────────────────
# System packages (Python for Ansible)
# ─────────────────────────────────────────────
dnf install -y python3 python3-pip

# ─────────────────────────────────────────────
# Create student user (same as control node)
# ─────────────────────────────────────────────
useradd -m -s /bin/bash student
echo "student ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/student
chmod 440 /etc/sudoers.d/student

# ─────────────────────────────────────────────
# SSH setup for student user
# ─────────────────────────────────────────────
mkdir -p /home/student/.ssh
chmod 700 /home/student/.ssh

# Write the Terraform-generated public key to authorized_keys
cat > /home/student/.ssh/authorized_keys <<'PUBKEY'
${public_key}
PUBKEY

chmod 600 /home/student/.ssh/authorized_keys
chown -R student:student /home/student/.ssh

# ─────────────────────────────────────────────
# Keep rocky user with sudo (for AWS access)
# ─────────────────────────────────────────────
echo "rocky ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/rocky
chmod 440 /etc/sudoers.d/rocky

echo "=== Node bootstrap complete at: $(date) ==="

#!/bin/bash
exec > /var/log/rhce-node-bootstrap.log 2>&1
set -x

echo "=== RHCE Killer Lab Bootstrap: Managed Node ==="
echo "Started at: $(date)"

cat >> /etc/hosts <<EOF
10.0.1.10  control.example.com  control
10.0.1.11  node1.example.com    node1
10.0.1.12  node2.example.com    node2
EOF

dnf install -y python3 python3-pip

# passwordless sudo for rocky (Ansible needs this)
echo "rocky ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/rocky
chmod 440 /etc/sudoers.d/rocky

mkdir -p /home/rocky/.ssh
chmod 700 /home/rocky/.ssh
chown rocky:rocky /home/rocky/.ssh

echo "=== Node bootstrap complete at: $(date) ==="

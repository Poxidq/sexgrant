#!/bin/bash

# Get the VM's SSH config
VM_SSH_CONFIG=$(vagrant ssh-config)

# Extract required values
HOSTNAME=$(echo "$VM_SSH_CONFIG" | grep HostName | awk '{print $2}')
PORT=$(echo "$VM_SSH_CONFIG" | grep Port | awk '{print $2}')
IDENTITY_FILE=$(echo "$VM_SSH_CONFIG" | grep IdentityFile | awk '{print $2}')

# Ensure the VM is accessible
until ping -c1 $HOSTNAME &>/dev/null; do
    echo "Waiting for VM to become accessible..."
    sleep 5
done

# Create ansible directory if it doesn't exist
mkdir -p ansible

# Create inventory file
cat > ansible/inventory.ini <<EOF
[selinux_lab]
vagrant_vm ansible_host=$HOSTNAME ansible_port=$PORT ansible_user=vagrant ansible_ssh_private_key_file=$IDENTITY_FILE

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOF

echo "Generated inventory file at ansible/inventory.ini with:"
echo "Host: $HOSTNAME"
echo "Port: $PORT"
echo "Identity file: $IDENTITY_FILE"
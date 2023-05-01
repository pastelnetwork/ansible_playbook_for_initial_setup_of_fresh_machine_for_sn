#!/bin/bash

# Grant password-less sudo access to the ubuntu user
echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ubuntu

# Update the package cache and install the required packages
sudo apt-get update
sudo apt-get install -y ansible git

# Create a temporary directory for the playbook
temp_dir=$(mktemp -d)

# Clone the repository containing the playbook
git clone https://github.com/pastelnetwork/ansible_playbook_for_initial_setup_of_fresh_machine_for_sn.git "$temp_dir"

# Create a temporary inventory file for the local machine
inventory_file="$temp_dir/inventory.ini"
echo "localhost ansible_connection=local" > "$inventory_file"

# Run the Ansible playbook on the local machine
ansible-playbook -i "$inventory_file" "$temp_dir/local_version_of_fresh_vps_setup_playbook_for_new_sn.yml"

# Cleanup
rm -rf "$temp_dir"
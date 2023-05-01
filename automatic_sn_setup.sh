#!/bin/bash

echo "This script automates the setup and configuration of a Pastel Supernode (SN)"
echo "starting with a fresh Ubuntu 22.04 server with a static IP. It does this by "
echo "installing essential tools, packages, and custom configurations using an"
echo "Ansible playbook. The script installs git and Ansible, then downloads and"
echo "runs the playbook, and then cleans up temporary files. The playbook itself"
echo "does most of the work of setting up the SN, including installing the pastelup"
echo "tool which is in turn used to install and the SN software and configure it."

# Step 1: Grant password-less sudo access to the ubuntu user
echo "Granting password-less sudo access to the 'ubuntu' user..."
echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ubuntu

# Step 2: Update the package cache and install the required packages
echo "Updating package cache and installing required packages (Ansible and Git)..."
sudo apt-get update
sudo apt-get install -y ansible git

# Step 3: Create a temporary directory for the playbook
echo "Creating a temporary directory for the Ansible playbook..."
temp_dir=$(mktemp -d)

# Step 4: Clone the repository containing the playbook
echo "Cloning the playbook repository..."
git clone https://github.com/pastelnetwork/ansible_playbook_for_initial_setup_of_fresh_machine_for_sn.git "$temp_dir"

# Step 5: Create a temporary inventory file for the local machine
echo "Creating a temporary inventory file for the local machine..."
inventory_file="$temp_dir/inventory.ini"
echo "localhost ansible_connection=local" > "$inventory_file"

# Step 6: Run the Ansible playbook on the local machine
echo "Running the Ansible playbook on the local machine..."
ansible-playbook -i "$inventory_file" "$temp_dir/local_version_of_fresh_vps_setup_playbook_for_new_sn.yml"
echo "Ansible playbook completed."

# Step 7: Cleanup
echo "Cleaning up temporary files..."
rm -rf "$temp_dir"

echo "Script completed. Your SN is now set up and configured!"

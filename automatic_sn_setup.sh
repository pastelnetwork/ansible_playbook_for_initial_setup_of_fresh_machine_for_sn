#!/bin/bash

echo "This script automates the setup and configuration of a Pastel Supernode (SN)"
echo "starting with a fresh Ubuntu 22.04 server with a static IP. It does this by "
echo "installing essential tools, packages, and custom configurations using an"
echo "Ansible playbook. The script installs git and Ansible, then downloads and"
echo "runs the playbook, and then cleans up temporary files. The playbook itself"
echo "does most of the work of setting up the SN, including installing the pastelup"
echo "tool which is in turn used to install and the SN software and configure it."

# Step 1: Generate a secure password for the 'ubuntu' user
echo "Generating a secure password for the 'ubuntu' user..."
password=$(openssl rand -base64 30 | tr -dc 'a-zA-Z0-9!@#$%^&*()_+?><:;,' | head -c 40)

echo "Generated password: $password"
echo "Please store this password securely in a password manager or other secure method."

# Step 2: Create the 'ubuntu' user with the generated password and add to the sudo group
echo "Creating the 'ubuntu' user and adding to the sudo group..."
sudo adduser --gecos "" --disabled-password ubuntu
echo "ubuntu:$password" | sudo chpasswd
sudo usermod -aG sudo ubuntu

# Step 3: Generate an ed25519 SSH key for the 'ubuntu' user
echo "Generating an ed25519 SSH key for the 'ubuntu' user..."
sudo -u ubuntu mkdir -p /home/ubuntu/.ssh
sudo -u ubuntu ssh-keygen -t ed25519 -f /home/ubuntu/.ssh/id_ed25519 -N ""

# Step 4: Display the .pem file content and instructions on how to save it
echo "Here is the content of the id_ed25519 private key file:"
sudo -u ubuntu cat /home/ubuntu/.ssh/id_ed25519
echo "To save this private key, create a new file named 'id_ed25519.pem' on your local machine and copy the content above into the file."

# Step 5: Provide a command to download the generated .pem file directly
echo "Alternatively, you can download the private key directly from the remote machine with the following command:"
echo "scp ubuntu@<remote_server_ip>:/home/ubuntu/.ssh/id_ed25519 /path/to/save/id_ed25519.pem"

# Step 6: Grant password-less sudo access to the 'ubuntu' user
echo "Granting password-less sudo access to the 'ubuntu' user..."
echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ubuntu

# Step 7: Update the package cache and install the required packages
echo "Updating package cache and installing required packages (Ansible and Git)..."
sudo apt-get update
sudo apt-get install -y ansible git

# Step 8: Create a temporary directory for the playbook
echo "Creating a temporary directory for the Ansible playbook..."
temp_dir=$(mktemp -d)

# Step 9: Clone the repository containing the playbook
echo "Cloning the playbook repository..."
git clone https://github.com/pastelnetwork/ansible_playbook_for_initial_setup_of_fresh_machine_for_sn.git "$temp_dir"

# Step 10: Create a temporary inventory file for the local machine
echo "Creating a temporary inventory file for the local machine..."
inventory_file="$temp_dir/inventory.ini"
echo "localhost ansible_connection=local" > "$inventory_file"

# Step 11: Run the Ansible playbook on the local machine
echo "Running the Ansible playbook on the local machine..."
ansible-playbook -i "$inventory_file" "$temp_dir/local_version_of_fresh_vps_setup_playbook_for_new_sn.yml"
echo "Ansible playbook completed."

# Step 12: Cleanup
echo "Cleaning up temporary files..."
rm -rf "$temp_dir"

# Step 13: Offer to clear sensitive information from the console
read -p "Do you want to clear the console of sensitive information? (y/n): " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  clear
  echo "Console cleared."
else
  echo "Sensitive information remains in the console."
fi

echo "Script completed. Your SN is now set up and configured!"

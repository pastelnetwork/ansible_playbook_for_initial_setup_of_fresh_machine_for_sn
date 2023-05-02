#!/bin/bash

function pause() {
  read -p "$*"
}

function update_progress() {
  echo "$1" | sudo -u ubuntu tee -a /home/ubuntu/setup_progress.txt >/dev/null
}

divider="\n-------------------------------------------------------------------\n"
echo $divider
echo "This script automates the setup and configuration of a Pastel Supernode (SN)"
echo "starting with a fresh Ubuntu 22.04 server with a static IP. It does this by "
echo "installing essential tools, packages, and custom configurations using an"
echo "Ansible playbook. The script installs git and Ansible, then downloads and"
echo "runs the playbook, and then cleans up temporary files. The playbook itself"
echo "does most of the work of setting up the SN, including installing the pastelup"
echo "tool which is in turn used to install and the SN software and configure it."
echo $divider

# Create setup_progress.txt if it doesn't exist
if [ ! -f /home/ubuntu/setup_progress.txt ]; then
  sudo -u ubuntu touch /home/ubuntu/setup_progress.txt
fi

# Step 1: Generate a secure password for the 'ubuntu' user
if ! grep -q "step1_completed" /home/ubuntu/setup_progress.txt; then
  echo "Generating a secure password for the 'ubuntu' user..."
  password=$(openssl rand -base64 30 | tr -dc 'a-zA-Z0-9!@#$%^&*()_+?><:;,' | head -c 40)

  echo ""
  echo "Generated password: $password"
  echo "Please store this password securely in a password manager or other secure method."
  echo $divider
  pause 'Press [Enter] key when you have stored the password...'

  update_progress "step1_completed"
fi

# Step 2: Create the 'ubuntu' user with the generated password and add to the sudo group
if ! grep -q "step2_completed" /home/ubuntu/setup_progress.txt; then
  echo "Creating the 'ubuntu' user and adding to the sudo group..."
  sudo adduser --gecos "" --disabled-password ubuntu
  echo "ubuntu:$password" | sudo chpasswd
  sudo usermod -aG sudo ubuntu
  echo $divider

  update_progress "step2_completed"
fi

# Step 3: Generate an ed25519 SSH key for the 'ubuntu' user
if ! grep -q "step3_completed" /home/ubuntu/setup_progress.txt; then
  echo "Generating an ed25519 SSH key for the 'ubuntu' user..."
  sudo -u ubuntu mkdir -p /home/ubuntu/.ssh
  sudo -u ubuntu ssh-keygen -t ed25519 -f /home/ubuntu/.ssh/id_ed25519 -N ""
  echo $divider

  update_progress "step3_completed"
fi

# Step 4: Display the .pem file content and instructions on how to save it
if ! grep -q "step4_completed" /home/ubuntu/setup_progress.txt; then
  echo "Here is the content of the id_ed25519 private key file:"
  sudo -u ubuntu cat /home/ubuntu/.ssh/id_ed25519
  echo $divider
  echo "To save this private key, create a new file named 'id_ed25519.pem' on your local machine and copy the content above into the file."

  update_progress "step4_completed"
fi

# Step 5: Provide a command to download the generated .pem file directly
if ! grep -q "step5_completed" /home/ubuntu/setup_progress.txt; then
  IP_ADDRESS=$(curl ipinfo.io/ip)
  echo "Alternatively, you can download the private key directly from the remote machine with the following command:"
  echo "scp ubuntu@$IP_ADDRESS:/home/ubuntu/.ssh/id_ed25519 /path/to/save/id_ed25519.pem"
  echo $divider

  update_progress "step5_completed"
fi

# Step 6: Grant password-less sudo access to the 'ubuntu' user
if ! grep -q "step6_completed" /home/ubuntu/setup_progress.txt; then
  echo "Granting password-less sudo access to the 'ubuntu' user..."
  echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ubuntu
  echo $divider

  update_progress "step6_completed"
fi

# Step 7: Update the package cache and install the required packages
if ! grep -q "step7_completed" /home/ubuntu/setup_progress.txt; then
  echo "Updating package cache and installing required packages (Ansible and Git)..."
  sudo apt-get update
  sudo apt-get install -y ansible git
  echo $divider

  update_progress "step7_completed"
fi

# Step 8: Create a temporary directory for the playbook
if ! grep -q "step8_completed" /home/ubuntu/setup_progress.txt; then
  echo "Creating a temporary directory for the Ansible playbook..."
  temp_dir=$(mktemp -d)

  update_progress "step8_completed"
fi

# Step 9: Clone the repository containing the playbook
if ! grep -q "step9_completed" /home/ubuntu/setup_progress.txt; then
  echo "Cloning the playbook repository..."
  git clone https://github.com/pastelnetwork/ansible_playbook_for_initial_setup_of_fresh_machine_for_sn.git "$temp_dir"

  update_progress "step9_completed"
fi

# Step 10: Create a temporary inventory file for the local machine
if ! grep -q "step10_completed" /home/ubuntu/setup_progress.txt; then
  echo "Creating a temporary inventory file for the local machine..."
  inventory_file="$temp_dir/inventory.ini"
  echo "localhost ansible_connection=local" > "$inventory_file"

  update_progress "step10_completed"
fi

# Step 11: Run the Ansible playbook on the local machine
if ! grep -q "step11_completed" /home/ubuntu/setup_progress.txt; then
  echo "Switching to the ubuntu user and then running the Ansible playbook on the local machine..."
  sudo su - ubuntu
  ansible-playbook -i "$inventory_file" "$temp_dir/local_version_of_fresh_vps_setup_playbook_for_new_sn.yml"
  echo "Ansible playbook completed."

  update_progress "step11_completed"
fi

# Step 11.5: Check if the ansible playbook finished correctly
if ! grep -q "step11_5_completed" /home/ubuntu/setup_progress.txt; then
  echo "Verifying that the ansible playbook finished correctly..."
  if [ -f /home/ubuntu/.pastel/pastel.conf ] && grep -q "rpcworkqueue=maximum" /home/ubuntu/.pastel/pastel.conf; then
    echo "Ansible playbook finished successfully."
  else
    echo "Ansible playbook did not finish successfully. Exiting."
    exit 1
  fi
  echo $divider

  update_progress "step11_5_completed"
fi

# Step 12: Install additional Rust-based utilities
if ! grep -q "step12_completed" /home/ubuntu/setup_progress.txt; then
  echo "Installing additional Rust-based utilities (lsd, du-dust, bat, ripgrep, exa, tokei, hyperfine)..."
  sudo -u ubuntu bash -c 'cargo install lsd du-dust bat ripgrep exa tokei hyperfine'
  echo "Rust-based utilities installed successfully."
  echo $divider

  update_progress "step12_completed"
fi

# Step 13: Cleanup
if ! grep -q "step13_completed" /home/ubuntu/setup_progress.txt; then
  echo "Cleaning up temporary files..."
  rm -rf "$temp_dir"

  update_progress "step13_completed"
fi

# Step 14: Save script output to a file
if ! grep -q "step14_completed" /home/ubuntu/setup_progress.txt; then
  echo "Saving console output to /home/ubuntu/output_of_automated_sn_setup_script.txt"
  script_output=$(echo $divider; echo "Generated password: $password"; echo $divider; cat /home/ubuntu/.ssh/id_ed25519; echo $divider)
  echo "$script_output" > /home/ubuntu/output_of_automated_sn_setup_script.txt
  echo "Please note that this file contains sensitive information. Delete it when it is no longer needed."
  echo $divider

  update_progress "step14_completed"
fi

# Step 15: Offer to clear sensitive information from the console
read -p "Do you want to clear the console of sensitive information? (y/n): " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  clear
  echo "Console cleared."
else
  echo "Sensitive information remains in the console."
fi

# Step 16: Update and upgrade system packages, and remove unused packages
echo "Updating and upgrading system packages, and removing unused packages..."
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
echo "System packages updated and upgraded. Unused packages removed."

echo $divider
echo "Script completed! Your SN is partly set up, but still needs to be activated"
echo "to be used in the suggested hot/cold setup. You will need to complete these steps"
echo "on your home computer:"

echo "1. Download the id_ed25519.pem file from the remote server to your home computer."
echo "2. Download the pastelup tool for your OS from https://github.com/pastelnetwork/pastelup/releases/tag/v1.2.1-beta5"

SSH_USER="ubuntu"

echo "3. Install the SuperNode remotely using the following command:"
echo "./pastelup install supernode remote -r beta -n testnet --ssh-ip $IP_ADDRESS --ssh-user $SSH_USER --ssh-key <PATH_TO_SSH_PRIVATE_KEY_FILE>"

echo "4. Initialize the SuperNode with a cold/hot setup using the following command:"
echo "./pastelup init supernode coldhot --new --name <SN_name> --ssh-ip $IP_ADDRESS --ssh-user $SSH_USER --ssh-key <PATH_TO_SSH_PRIVATE_KEY_FILE>"

echo "5. Start the masternode with the following command:"
echo "./pastel-cli masternode start-alias <SN_name>"

echo "6. Check the masternode status and list your PastelID on the hot node:"
echo "./pastel/pastel-cli masternode status"
echo "./pastel/pastel-cli pastelid list mine"
echo "Remember the PastelID returned by the last command."

echo "7. Check your balance and generate a new address:"
echo "./pastel/pastel-cli getbalance"
echo "./pastel/pastel-cli getnewaddress"
echo "Remember the address returned by the last command."

echo "8. Send coins to the address from step 7."

echo "9. Register the masternode with the following command:"
echo "./pastel/pastel-cli tickets register mnid <PastelID_returned_in_step_6> <PastelID_Passphrase> <Address_generated_in_step_7>"

echo "10. Check the masternode status again:"
echo "./pastel/pastel-cli masternode status"

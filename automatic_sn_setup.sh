#!/bin/bash

# Environment variables
PASTEL_REPO="https://github.com/pastelnetwork"
PLAYBOOK_REPO="ansible_playbook_for_initial_setup_of_fresh_machine_for_sn"
PLAYBOOK_NAME="local_version_of_fresh_vps_setup_playbook_for_new_sn.yml"
SECTION_DIVIDER="\n-------------------------------------------------------------------\n"

# Check for dependencies and install them if not present
function check_and_install_dependencies() {
  dependencies_to_install=""
  for dependency in curl openssl git ansible; do
    if ! command -v "$dependency" >/dev/null; then
      dependencies_to_install+="$dependency "
    fi
  done

  if [ -n "$dependencies_to_install" ]; then
    echo "Missing dependencies: $dependencies_to_install"
    echo "Installing missing dependencies..."
    sudo apt-get update
    for dependency in $dependencies_to_install; do
      sudo apt-get install -y "$dependency"
    done
  else
    echo "All required dependencies are installed."
  fi
}

function prompt_for_confirmation() {
  echo "This script automates the setup and configuration of a Pastel Supernode (SN)"
  echo "on a fresh Ubuntu 22.04 server with a static IP. Please review the script's"
  echo "assumptions and prerequisites before proceeding."
  echo "Press CTRL+C to abort at any time."
  sleep 3  # Wait for 3 seconds before proceeding
  echo -e $SECTION_DIVIDER
}

function create_setup_progress_file() {
  if [ ! -f /tmp/setup_progress.txt ]; then
    touch /tmp/setup_progress.txt
  fi
  chmod 666 /tmp/setup_progress.txt
}

# Update progress function
function update_progress() {
  echo "$1" >> /tmp/setup_progress.txt
}

function generate_secure_password() {
  if ! grep -q "step1_completed" /tmp/setup_progress.txt; then
    echo "Generating a secure password for the 'ubuntu' user..."
    password=$(openssl rand -base64 30 | tr -dc 'a-zA-Z0-9!@#$%^&*()_+?><:;,.' | head -c 40)
    echo ""
    echo "Generated password: $password"
    echo "Please store this password securely in a password manager or other secure method."
    echo -e $SECTION_DIVIDER
    echo -n 'Press [Enter] key when you have stored the password...'
    read -r _
    update_progress "step1_completed"
  fi
}

# Create the 'ubuntu' user with the generated password and add to the sudo group
function create_ubuntu_user() {
  if ! grep -q "step2_completed" /tmp/setup_progress.txt; then
    if ! id -u ubuntu >/dev/null 2>&1; then
      echo "Creating the 'ubuntu' user and adding to the sudo group..."
      sudo adduser --gecos "" --disabled-password ubuntu
      echo "ubuntu:$password" | sudo chpasswd
      sudo usermod -aG sudo ubuntu
      echo -e $SECTION_DIVIDER
    else
      echo "The 'ubuntu' user already exists."
    fi
    update_progress "step2_completed"
  fi
}

# Generate an ed25519 SSH key for the 'ubuntu' user
function generate_ssh_key() {
  if ! grep -q "step3_completed" /tmp/setup_progress.txt; then
    if [ ! -f /home/ubuntu/.ssh/id_ed25519 ]; then
      echo "Generating an ed25519 SSH key for the 'ubuntu' user..."
      sudo -u ubuntu mkdir -p /home/ubuntu/.ssh
      sudo -u ubuntu ssh-keygen -t ed25519 -f /home/ubuntu/.ssh/id_ed25519 -N ""
      echo -e $SECTION_DIVIDER
    else
      echo "An ed25519 SSH key already exists for the 'ubuntu' user."
    fi

    update_progress "step3_completed"
  fi
}

# Display the .pem file content and instructions on how to save it
function display_pem_file_content() {
  echo "Here is the content of the id_ed25519 private key file:"
  sudo -u ubuntu cat /home/ubuntu/.ssh/id_ed25519
  echo -e $SECTION_DIVIDER
}

function save_pem_file_instructions() {
  echo "To save this private key, create a new file named 'id_ed25519.pem' on your local machine and copy the content above into the file."
}

function scp_command_to_download_pem_file() {
  IP_ADDRESS=$(curl ipinfo.io/ip)
  echo "Alternatively, you can download the private key directly from the remote machine with the following command:"
  echo "scp ubuntu@$IP_ADDRESS:/home/ubuntu/.ssh/id_ed25519 /path/to/save/id_ed25519.pem"
  echo -e $SECTION_DIVIDER
}

function grant_passwordless_sudo_access() {
  echo "Granting password-less sudo access to the 'ubuntu' user..."
  echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ubuntu
  echo -e $SECTION_DIVIDER
}

function update_package_cache_and_install_required_packages() {
  echo "Updating package cache and installing required packages (Ansible and Git)..."
  sudo apt-get update >/dev/null 2>&1
  sudo apt-get install -y ansible git >/dev/null 2>&1
  echo -e $SECTION_DIVIDER
}

function create_directory_for_playbook() {
  echo "Creating a directory for the Ansible playbook..."
  playbook_dir="/home/ubuntu/sn_setup_files"
  sudo -u ubuntu mkdir -p "$playbook_dir"
}

function clone_playbook_repository() {
  echo "Cloning the playbook repository..."
  # Remove the existing directory if it exists and is not empty
  if [ -d "$playbook_dir" ]; then
    rm -rf "$playbook_dir"
  fi
  # Create the directory for the Ansible playbook
  sudo -u ubuntu mkdir -p "$playbook_dir"
  git clone "${PASTEL_REPO}/${PLAYBOOK_REPO}" "$playbook_dir"
}

function create_inventory_file() {
  echo "Creating an inventory file for the local machine..."
  ansible_inventory_file="$playbook_dir/inventory.ini"
  echo "localhost ansible_connection=local" > "$ansible_inventory_file"
}

function run_ansible_playbook() {
  if ! grep -q "step9_completed" /tmp/setup_progress.txt; then
    echo "Switching to the ubuntu user and then running the Ansible playbook on the local machine..."
    sudo su - ubuntu -c "(ansible-playbook -i \"$ansible_inventory_file\" \"$playbook_dir/$PLAYBOOK_NAME\" && echo \"step9_completed\" >> /tmp/setup_progress.txt)"
    echo "Ansible playbook completed."
  else
    echo "Ansible playbook has already been run successfully."
  fi
}

function verify_ansible_playbook_completion() {
  echo "Verifying that the ansible playbook finished correctly..."
  if [ -f /home/ubuntu/.pastel/pastel.conf ] && grep -q "rpcworkqueue=maximum" /home/ubuntu/.pastel/pastel.conf; then
    echo "Ansible playbook finished successfully."
  else
    echo "Ansible playbook did not finish successfully. Exiting."
    exit 1
  fi
  echo -e $SECTION_DIVIDER
}

function install_additional_rust_based_utilities() {
  echo "Installing additional Rust-based utilities (lsd, du-dust, bat, ripgrep, exa, tokei, hyperfine)..."
  sudo -u ubuntu zsh -c 'source /home/ubuntu/.zshrc; cargo install lsd du-dust bat ripgrep exa tokei hyperfine'
  echo "Rust-based utilities installed successfully."
  echo -e $SECTION_DIVIDER
}

function display_final_instructions() {
  echo "The automated setup is complete. The output of the script, including the generated password and private key content, has been saved to:"
  echo "/home/ubuntu/output_of_automated_sn_setup_script.txt"
  echo "You can view the contents of this file using the 'cat' command:"
  echo "cat /home/ubuntu/output_of_automated_sn_setup_script.txt"
  echo "Please make sure to save the password and private key in a secure location, as they are necessary for accessing this SuperNode."
  echo -e $SECTION_DIVIDER
  IP_ADDRESS=$(curl ipinfo.io/ip)
  SSH_USER="ubuntu"
  echo "Script completed! Your SN is partly set up, but still needs to be activated"
  echo "to be used in the suggested hot/cold setup. You will need to complete these steps"
  echo "on your home computer:"
  echo "1. Download the /home/ubuntu/.ssh/id_ed25519.pem file from the remote server to your home computer."
  echo "2. Download the pastelup tool for your OS from https://github.com/pastelnetwork/pastelup/releases/tag/v1.2.1-beta5"
  echo "3. Install the SuperNode remotely using the following command:"
  echo "./pastelup install supernode remote -r beta -n testnet --ssh-ip $IP_ADDRESS --ssh-user $SSH_USER --ssh-key <PATH_TO_SSH_PRIVATE_KEY_FILE>"
  echo -e $SECTION_DIVIDER
  echo "4. Initialize the SuperNode with a cold/hot setup using the following command ('SN_name' can be something like 'My_SN_01'):"
  echo "./pastelup init supernode coldhot --new --name <SN_name> --ssh-ip $IP_ADDRESS --ssh-user $SSH_USER --ssh-key <PATH_TO_SSH_PRIVATE_KEY_FILE>"
  echo -e $SECTION_DIVIDER
  echo "5. Start the masternode with the following command:"
  echo "./pastel-cli masternode start-alias <SN_name>"
  echo -e $SECTION_DIVIDER
  echo "6. Check the masternode status and list your PastelID on the remote machine:"
  echo "./pastel/pastel-cli masternode status"
  echo "./pastel/pastel-cli pastelid list mine"
  echo "Remember the PastelID returned by the last command."
  echo -e $SECTION_DIVIDER
  echo "7. Check your balance and generate a new address:"
  echo "./pastel/pastel-cli getbalance"
  echo "./pastel/pastel-cli getnewaddress"
  echo "Remember the address returned by the last command."
  echo -e $SECTION_DIVIDER
  echo "8. Send coins to the address from step 7."
  echo -e $SECTION_DIVIDER
  echo "9. Register the masternode with the following command:"
  echo "./pastel/pastel-cli tickets register mnid <PastelID_returned_in_step_6> <PastelID_Passphrase> <Address_generated_in_step_7>"
  echo -e $SECTION_DIVIDER
  echo "10. Check the masternode status again:"
  echo "./pastel/pastel-cli masternode status"
  echo -e $SECTION_DIVIDER
}

function main() {
  check_and_install_dependencies
  prompt_for_confirmation
  create_setup_progress_file
  generate_secure_password
  create_ubuntu_user
  generate_ssh_key
  display_pem_file_content
  save_pem_file_instructions
  scp_command_to_download_pem_file
  grant_passwordless_sudo_access
  update_package_cache_and_install_required_packages
  create_directory_for_playbook
  clone_playbook_repository
  create_inventory_file
  run_ansible_playbook
  verify_ansible_playbook_completion
  install_additional_rust_based_utilities
  display_final_instructions
}

exec > >(tee -i /root/output_of_automated_sn_setup_script.txt)
echo "You can view the output of this script in /root/output_of_automated_sn_setup_script.txt"
main
